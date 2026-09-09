import gdb
import gdb.printing

# GDB pretty printing for the CC library, github.com/JacksonAllan/CC

def cc_padding(size, align):
    return (~size + 1) & (align - 1)

def parse_cc_type(val_type):
    try:
        t = val_type.strip_typedefs()
        if t.code != gdb.TYPE_CODE_PTR:
            return None
        target = t.target().strip_typedefs()
        if target.code != gdb.TYPE_CODE_ARRAY:
            return None
        r = target.range()
        cntr_id = r[1] - r[0] + 1
        if cntr_id < 1 or cntr_id > 7:
            return None
        fn_ptr = target.target().strip_typedefs()
        if fn_ptr.code != gdb.TYPE_CODE_PTR:
            return None
        fn = fn_ptr.target().strip_typedefs()
        if fn.code != gdb.TYPE_CODE_FUNC:
            return None
        el_type = fn.target()
        fields = fn.fields()
        if not fields or len(fields) < 1:
            return None
        key_ptr = fields[0].type.strip_typedefs()
        if key_ptr.code != gdb.TYPE_CODE_PTR:
            return None
        key_type = key_ptr.target()
        return cntr_id, el_type, key_type
    except Exception:
        return None

class CCContainerPrinter:
    def __init__(self, val, type_info):
        self.val = val
        self.addr = int(val)
        self.cntr_id, self.el_type, self.key_type = type_info

    def to_string(self):
        if self.addr == 0:
            return "cc_container(NULL)"

        try:
            if self.cntr_id == 1: # VEC
                hdr_type = gdb.lookup_type('cc_vec_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                cap = int(hdr['cap'])
                return f"cc_vec<{self.el_type}> of size {size}, capacity {cap}"

            elif self.cntr_id == 2: # LIST
                hdr_type = gdb.lookup_type('cc_list_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                return f"cc_list<{self.el_type}> of size {size}"

            elif self.cntr_id == 3: # MAP
                hdr_type = gdb.lookup_type('cc_map_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                cap_mask = int(hdr['cap_mask'])
                cap = cap_mask + 1 if cap_mask != 0 else 0
                return f"cc_map<{self.key_type}, {self.el_type}> of size {size}, capacity {cap}"

            elif self.cntr_id == 4: # SET
                hdr_type = gdb.lookup_type('cc_map_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                cap_mask = int(hdr['cap_mask'])
                cap = cap_mask + 1 if cap_mask != 0 else 0
                return f"cc_set<{self.el_type}> of size {size}, capacity {cap}"

            elif self.cntr_id == 5: # OMAP
                hdr_type = gdb.lookup_type('cc_omap_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                if size == 18446744073709551615 or size == 4294967295:
                    size = 0
                return f"cc_omap<{self.key_type}, {self.el_type}> of size {size}"

            elif self.cntr_id == 6: # OSET
                hdr_type = gdb.lookup_type('cc_omap_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                if size == 18446744073709551615 or size == 4294967295:
                    size = 0
                return f"cc_oset<{self.el_type}> of size {size}"

            elif self.cntr_id == 7: # STR
                hdr_type = gdb.lookup_type('cc_str_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                cap = int(hdr['cap'])
                data_ptr = hdr['data']
                if int(data_ptr) == 0:
                    return f'cc_str<{self.el_type}> ""'
                el_name = str(self.el_type.strip_typedefs())
                if 'char' in el_name:
                    try:
                        s_str = data_ptr.cast(gdb.lookup_type('char').pointer()).string('utf-8', 'replace', length=size)
                        return f'cc_str<{self.el_type}> "{s_str}"'
                    except Exception:
                        pass
                return f"cc_str<{self.el_type}> of size {size}, capacity {cap}"

        except Exception as e:
            return f"cc_container(uninitialized/invalid)"

        return f"cc_container({self.val})"

    def children(self):
        if self.addr == 0:
            return

        try:
            if self.cntr_id == 1: # VEC
                hdr_type = gdb.lookup_type('cc_vec_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                data_ptr = gdb.Value(self.addr + hdr_type.sizeof).cast(self.el_type.pointer())
                for i in range(size):
                    yield (f"[{i}]", data_ptr[i])

            elif self.cntr_id == 2: # LIST
                hdr_type = gdb.lookup_type('cc_list_hdr_ty')
                node_hdr_type = gdb.lookup_type('cc_listnode_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                end_node_addr = int(hdr['end'].address)
                node_hdr_size = node_hdr_type.sizeof
                curr = hdr['r_end']['next']
                i = 0
                while curr != 0 and int(curr) != end_node_addr and i < size:
                    el_val = gdb.Value(int(curr) + node_hdr_size).cast(self.el_type.pointer()).dereference()
                    yield (f"[{i}]", el_val)
                    curr = curr['next']
                    i += 1

            elif self.cntr_id == 3: # MAP
                hdr_type = gdb.lookup_type('cc_map_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                cap_mask = int(hdr['cap_mask'])
                cap = cap_mask + 1 if cap_mask != 0 else 0
                meta = hdr['metadata']
                hdr_size = hdr_type.sizeof
                el_size = self.el_type.sizeof
                el_align = self.el_type.alignof
                key_size = self.key_type.sizeof
                key_align = self.key_type.alignof
                el_pad = cc_padding(el_size, key_align)
                key_offset = el_size + el_pad
                key_pad = cc_padding(el_size + el_pad + key_size, max(el_align, key_align))
                bucket_size = key_offset + key_size + key_pad
                count = 0
                for i in range(cap):
                    if int(meta[i]) != 0:
                        b_addr = self.addr + hdr_size + i * bucket_size
                        key = gdb.Value(b_addr + key_offset).cast(self.key_type.pointer()).dereference()
                        val = gdb.Value(b_addr).cast(self.el_type.pointer()).dereference()
                        yield (f"[{count}].key", key)
                        yield (f"[{count}].val", val)
                        count += 1

            elif self.cntr_id == 4: # SET
                hdr_type = gdb.lookup_type('cc_map_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                cap_mask = int(hdr['cap_mask'])
                cap = cap_mask + 1 if cap_mask != 0 else 0
                meta = hdr['metadata']
                hdr_size = hdr_type.sizeof
                el_size = self.el_type.sizeof
                count = 0
                for i in range(cap):
                    if int(meta[i]) != 0:
                        b_addr = self.addr + hdr_size + i * el_size
                        val = gdb.Value(b_addr).cast(self.el_type.pointer()).dereference()
                        yield (f"[{count}]", val)
                        count += 1

            elif self.cntr_id == 5: # OMAP
                hdr_type = gdb.lookup_type('cc_omap_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                if size != 18446744073709551615 and size != 4294967295 and size > 0:
                    sentinel_addr = int(hdr['sentinel'])
                    node_hdr_size = gdb.lookup_type('cc_omapnode_hdr_ty').sizeof
                    el_size = self.el_type.sizeof
                    key_align = self.key_type.alignof
                    key_offset = el_size + cc_padding(el_size, key_align)
                    curr = hdr['root']
                    stack = []
                    count = 0
                    while (curr and int(curr) != sentinel_addr) or stack:
                        while curr and int(curr) != sentinel_addr:
                            stack.append(curr)
                            curr = curr['children'][0]
                        curr = stack.pop()
                        n_addr = int(curr)
                        val = gdb.Value(n_addr + node_hdr_size).cast(self.el_type.pointer()).dereference()
                        key = gdb.Value(n_addr + node_hdr_size + key_offset).cast(self.key_type.pointer()).dereference()
                        yield (f"[{count}].key", key)
                        yield (f"[{count}].val", val)
                        count += 1
                        curr = curr['children'][1]

            elif self.cntr_id == 6: # OSET
                hdr_type = gdb.lookup_type('cc_omap_hdr_ty')
                hdr = gdb.Value(self.addr).cast(hdr_type.pointer()).dereference()
                size = int(hdr['size'])
                if size != 18446744073709551615 and size != 4294967295 and size > 0:
                    sentinel_addr = int(hdr['sentinel'])
                    node_hdr_size = gdb.lookup_type('cc_omapnode_hdr_ty').sizeof
                    curr = hdr['root']
                    stack = []
                    count = 0
                    while (curr and int(curr) != sentinel_addr) or stack:
                        while curr and int(curr) != sentinel_addr:
                            stack.append(curr)
                            curr = curr['children'][0]
                        curr = stack.pop()
                        n_addr = int(curr)
                        val = gdb.Value(n_addr + node_hdr_size).cast(self.el_type.pointer()).dereference()
                        yield (f"[{count}]", val)
                        count += 1
                        curr = curr['children'][1]

            elif self.cntr_id == 7: # STR
                return
        except Exception:
            return

    def display_hint(self):
        if self.cntr_id in (3, 5):
            return 'map'
        elif self.cntr_id == 7:
            return 'string'
        else:
            return 'array'

def build_cc_printer(val):
    type_info = parse_cc_type(val.type)
    if type_info is not None:
        return CCContainerPrinter(val, type_info)
    return None

def register_cc_printers(objfile=None):
    gdb.printing.register_pretty_printer(objfile, build_cc_printer, replace=True)

register_cc_printers(None)
