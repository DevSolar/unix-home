#!/usr/bin/env bash

set -euo pipefail

shopt -s extglob

# ─── ANSI Helpers (Standard 16-color palette only) ───────────────────────────
R=$'\e[0m'         # Reset
B=$'\e[1m'         # Bold
D=$'\e[2m'         # Dim
I=$'\e[3m'         # Italic

# Foreground accents (Standard 16 colors)
FG_BLACK=$'\e[30m'
FG_RED=$'\e[31m'
FG_GREEN=$'\e[32m'
FG_YELLOW=$'\e[33m'
FG_BLUE=$'\e[34m'
FG_MAGENTA=$'\e[35m'
FG_CYAN=$'\e[36m'
FG_WHITE=$'\e[37m'

FG_GRAY=$'\e[90m'
FG_BRIGHT_RED=$'\e[91m'
FG_BRIGHT_GREEN=$'\e[92m'
FG_BRIGHT_YELLOW=$'\e[93m'
FG_BRIGHT_BLUE=$'\e[94m'
FG_BRIGHT_MAGENTA=$'\e[95m'
FG_BRIGHT_CYAN=$'\e[96m'
FG_BRIGHT_WHITE=$'\e[97m'

# Number Highlight Color
NUM_COLOR="${FG_BRIGHT_WHITE}${B}"

#{
#    "cwd": "/home/solar/tio2",
#    "session_id": "",
#    "conversation_id": "",
#    "transcript_path": "/home/solar/.gemini/antigravity/brain/.system_generated/logs/transcript.jsonl",
#    "model": {
#        "id": "Gemini 3.5 Flash (Low)",
#        "display_name": "Gemini 3.5 Flash (Low)",
#        "effort": "low"
#    },
#    "workspace": {
#        "current_dir": "/home/solar/tio2",
#        "project_dir": "/home/solar/tio2"
#    },
#    "version": "1.1.10",
#    "context_window": {
#        "total_input_tokens": 0,
#        "total_output_tokens": 0,
#        "context_window_size": 1048576,
#        "used_percentage": 0,
#        "remaining_percentage": 100,
#        "current_usage": null
#    },
#    "exceeds_200k_tokens": null,
#    "product": "antigravity",
#    "quota": {
#        "3p-5h": {
#            "remaining_fraction": 1,
#            "reset_time": "2026-08-05T03: 06: 04Z",
#            "reset_in_seconds": 17994
#        },
#            "3p-weekly": {
#            "remaining_fraction": 1,
#            "reset_time": "2026-08-11T22: 06: 04Z",
#            "reset_in_seconds": 604794
#        },
#            "gemini-5h": {
#            "remaining_fraction": 0.9761426,
#            "reset_time": "2026-08-05T01: 30: 43Z",
#            "reset_in_seconds": 12273
#        },
#            "gemini-weekly": {
#            "remaining_fraction": 0.9960237,
#            "reset_time": "2026-08-11T20: 30: 43Z",
#            "reset_in_seconds": 599073
#        }
#    },
#    "agent_state": "idle",
#    "vcs": {
#        "type": "git"
#    },
#    "sandbox": {
#        "enabled": false
#    },
#    "plan_tier": "Google AI Pro",
#    "email": "solar@rootdirectory.de",
#    "terminal_width": 168
#}

# ─── Parse JSON from stdin (Single jq pass for performance) ──────────────────
# Extract all fields in one pass to prevent spawning jq 8 times.
INPUT_DATA=$(cat)
if [ -z "$INPUT_DATA" ]; then
  INPUT_DATA="{}"
fi

{
  read -r DIR
  read -r MODEL
  read -r EFFORT
  read -r CTX_PCT
  read -r CTX_SIZE
  read -r QUOTA_3P_5H_PCT
  read -r QUOTA_3P_5H_RES
  read -r QUOTA_3P_WEEK_PCT
  read -r QUOTA_3P_WEEK_RES
  read -r QUOTA_GEMINI_5H_PCT
  read -r QUOTA_GEMINI_5H_RES
  read -r QUOTA_GEMINI_WEEK_PCT
  read -r QUOTA_GEMINI_WEEK_RES
  read -r STATE
  read -r VCS_BRANCH
  read -r VCS_DIRTY
  read -r SANDBOX
  read -r ARTIFACTS
  read -r PLAN
  read -r SUBAGENTS
  read -r BG_TASKS
  read -r COLS
} <<< "$(
  printf '%s\n' "$INPUT_DATA" | jq -r '
    (.cwd // ""),
    (.model.display_name // ""),
    (.model.effort // ""),
    (.context_window.used_percentage // 0),
    ((.context_window.context_window_size // 0) | floor),
    ((.quota."3p-5h".remaining_fraction // 0) * 100),
    ((.quota."3p-5h".reset_in_seconds // 0) | floor),
    ((.quota."3p-weekly".remaining_fraction // 0) * 100),
    ((.quota."3p-weekly".reset_in_seconds // 0) | floor),
    ((.quota."gemini-5h".remaining_fraction // 0) * 100),
    ((.quota."gemini-5h".reset_in_seconds // 0) | floor),
    ((.quota."gemini-weekly".remaining_fraction // 0) * 100),
    ((.quota."gemini-weekly".reset_in_seconds // 0) | floor),
    (.agent_state // "idle"),
    (.vcs.branch // ""),
    (.vcs.dirty // false),
    (.sandbox.enabled // false),
    ((.artifact_count // 0) | floor),
    (.plan_tier // ""),
    (if .subagents | type == "array" then (.subagents | length) else 0 end),
    ((.task_count // 0) | floor),
    ((.terminal_width // 80) | floor)
  ' 2>/dev/null || printf "\n\n\n0\n0\n0\n0\n0\n0\n0\n0\n0\n0\nidle\n\nfalse\nfalse\n0\n\n0\n0\n80\n"
)"


# ─── Multibyte / ANSI Formatter (mbprintf) ──────────────────────────────────
_mbtruncate()
{
	local str="$1"
	local max_len="$2"
	local out=""
	local count=0
	local has_ansi=0
	local ansi_re=$'^\x1b(\\[[0-9;?]*[a-zA-Z]|\\][^\x1b]*\x1b\\\\)'

	while [[ -n "$str" && $count -lt $max_len ]]; do
		if [[ "$str" =~ $ansi_re ]]; then
			out+="${BASH_REMATCH[0]}"
			str="${str#"${BASH_REMATCH[0]}"}"
			has_ansi=1
		else
			out+="${str:0:1}"
			str="${str:1}"
			count=$((count + 1))
		fi
	done

	while [[ "$str" =~ $ansi_re ]]; do
		out+="${BASH_REMATCH[0]}"
		str="${str#"${BASH_REMATCH[0]}"}"
	done

	if [[ $has_ansi -eq 1 && ! "$out" =~ \x1b\[0?m$ ]]; then
		out+=$'\e[0m'
	fi

	printf '%s' "$out"
}

_mbprintf()
{
	local flags="$1"
	local has_dot="$2"
	local width="$3"
	local prec="$4"
	local input="$5"

	if [[ "$width" =~ ^-[0-9]+$ ]]; then
		width=$(( -width ))
		flags="${flags}-"
	fi

	if [[ -n "$has_dot" ]]; then
		prec="${prec:-0}"
		if [[ "$prec" =~ ^[0-9]+$ && $prec -ge 0 ]]; then
			if [[ "$input" == *$'\e'* ]]; then
				input=$(_mbtruncate "$input" "$prec")
			else
				input="${input:0:prec}"
			fi
		fi
	fi

	local visible="$input"
	if [[ "$visible" == *$'\e'* ]]; then
		local ansi_pat=$'\e\[*([0-9;?])[a-zA-Z]'
		visible="${visible//$ansi_pat/}"
	fi

	local char_len=${#visible}
	width=${width:-0}
	local pad_len=$(( width > char_len ? width - char_len : 0 ))

	local padding=""
	if [[ $pad_len -gt 0 ]]; then
		printf -v padding '%*s' "$pad_len" ""
	fi

	if [[ "$flags" == *-* ]]; then
		printf '%s%s' "$input" "$padding"
	else
		printf '%s%s' "$padding" "$input"
	fi
}

mbprintf()
{
	local target_var=""
	if [[ "$1" == "-v" ]]; then
		target_var="$2"
		shift 2
	fi

	local fmt="$1"
	shift

	local _out=""
	_emit() {
		if [[ -n "$target_var" ]]; then
			_out+="$1"
		else
			printf '%s' "$1"
		fi
	}

	while true; do
		local rest="$fmt"
		local args_consumed_pass=0

		while [[ -n "$rest" ]]; do
			if [[ "$rest" =~ ^(%([-+0 #]+)?([0-9]+|\*)?(\.)?([0-9]+|\*)?([aAcdeEfFgGiopsuxX%bq]))(.*)? ]]; then
				local spec="${BASH_REMATCH[1]}"
				local flags="${BASH_REMATCH[2]}"
				local width_token="${BASH_REMATCH[3]}"
				local has_dot="${BASH_REMATCH[4]}"
				local prec_token="${BASH_REMATCH[5]}"
				local conv_type="${BASH_REMATCH[6]}"
				rest="${BASH_REMATCH[7]}"

				if [[ "$conv_type" == "%" ]]; then
					_emit '%'
				else
					local width=""
					local prec=""

					if [[ "$width_token" == "*" ]]; then
						width="${1:-0}"
						shift
						args_consumed_pass=$((args_consumed_pass + 1))
					else
						width="${width_token:-0}"
					fi

					if [[ "$prec_token" == "*" ]]; then
						prec="${1:-0}"
						shift
						args_consumed_pass=$((args_consumed_pass + 1))
					else
						prec="$prec_token"
					fi

					local val="$1"
					[[ $# -gt 0 ]] && shift
					args_consumed_pass=$((args_consumed_pass + 1))

					if [[ "$conv_type" == "s" ]]; then
						local formatted_s
						formatted_s=$(_mbprintf "$flags" "$has_dot" "$width" "$prec" "$val")
						_emit "$formatted_s"
					else
						local conv_args=()
						[[ "$width_token" == "*" ]] && conv_args+=("$width")
						[[ "$prec_token" == "*" ]] && conv_args+=("$prec")
						conv_args+=("$val")
						local formatted_conv
						printf -v formatted_conv -- "$spec" "${conv_args[@]}"
						_emit "$formatted_conv"
					fi
				fi
			elif [[ "$rest" =~ ^([^%]+)(%.*)? ]]; then
				local chunk="${BASH_REMATCH[1]}"
				local formatted_chunk
				printf -v formatted_chunk -- "$chunk"
				_emit "$formatted_chunk"
				rest="${BASH_REMATCH[2]}"
			else
				_emit "${rest:0:1}"
				rest="${rest:1}"
			fi
		done

		if [[ $# -eq 0 || $args_consumed_pass -eq 0 ]]; then
			break
		fi
	done

	if [[ -n "$target_var" ]]; then
		printf -v "$target_var" '%s' "$_out"
	fi
}

# ─── Computed Values ─────────────────────────────────────────────────────────
secs2dhm() {
    DHM=""
    local T=${1%.*}
    T=${T:-0}
    local D=$((T/86400))
    local H=$(( (T/3600)%24 ))
    local M=$(( (T/60)%60 ))
    if (( D > 0 )); then
        DHM="${D}d"
    fi
    if (( H > 0 )); then
        DHM="$DHM${H}h"
    fi
    if (( M > 0 )); then
        DHM="$DHM${M}m"
    fi
    if [ -z "$DHM" ]; then
        DHM="0m"
    fi
}

# LC_NUMERIC=C prevents printf errors in locales that use commas for decimals
CTX_FMT=$(LC_NUMERIC=C printf "%.1f" "$CTX_PCT" 2>/dev/null || echo "0.0")
CTX_INT=$(LC_NUMERIC=C printf "%.0f" "$CTX_PCT" 2>/dev/null || echo 0)
CTX_INT=${CTX_INT:-0}

QUOTA_3P_WEEK_PCT100=$QUOTA_3P_WEEK_PCT
QUOTA_3P_WEEK_FMT=$(LC_NUMERIC=C printf "%.1f" "$QUOTA_3P_WEEK_PCT100" 2>/dev/null || echo "0.0")
QUOTA_3P_WEEK_INT=$(LC_NUMERIC=C printf "%.0f" "$QUOTA_3P_WEEK_PCT100" 2>/dev/null || echo 0)
QUOTA_3P_WEEK_INT=${QUOTA_3P_WEEK_INT:-0}
secs2dhm "${QUOTA_3P_WEEK_RES}"
QUOTA_3P_WEEK_DHM=$DHM

QUOTA_3P_5H_PCT100=$QUOTA_3P_5H_PCT
if [ "$QUOTA_3P_WEEK_INT" -eq 0 ]; then
  QUOTA_3P_5H_PCT100=0
fi
QUOTA_3P_5H_FMT=$(LC_NUMERIC=C printf "%.1f" "$QUOTA_3P_5H_PCT100" 2>/dev/null || echo "0.0")
QUOTA_3P_5H_INT=$(LC_NUMERIC=C printf "%.0f" "$QUOTA_3P_5H_PCT100" 2>/dev/null || echo 0)
QUOTA_3P_5H_INT=${QUOTA_3P_5H_INT:-0}
secs2dhm "${QUOTA_3P_5H_RES}"
QUOTA_3P_5H_DHM=$DHM

QUOTA_GEMINI_WEEK_PCT100=$QUOTA_GEMINI_WEEK_PCT
QUOTA_GEMINI_WEEK_FMT=$(LC_NUMERIC=C printf "%.1f" "$QUOTA_GEMINI_WEEK_PCT100" 2>/dev/null || echo "0.0")
QUOTA_GEMINI_WEEK_INT=$(LC_NUMERIC=C printf "%.0f" "$QUOTA_GEMINI_WEEK_PCT100" 2>/dev/null || echo 0)
QUOTA_GEMINI_WEEK_INT=${QUOTA_GEMINI_WEEK_INT:-0}
secs2dhm "${QUOTA_GEMINI_WEEK_RES}"
QUOTA_GEMINI_WEEK_DHM=$DHM

QUOTA_GEMINI_5H_PCT100=$QUOTA_GEMINI_5H_PCT
if [ "$QUOTA_GEMINI_WEEK_INT" -eq 0 ]; then
  QUOTA_GEMINI_5H_PCT100=0
fi
QUOTA_GEMINI_5H_FMT=$(LC_NUMERIC=C printf "%.1f" "$QUOTA_GEMINI_5H_PCT100" 2>/dev/null || echo "0.0")
QUOTA_GEMINI_5H_INT=$(LC_NUMERIC=C printf "%.0f" "$QUOTA_GEMINI_5H_PCT100" 2>/dev/null || echo 0)
QUOTA_GEMINI_5H_INT=${QUOTA_GEMINI_5H_INT:-0}
secs2dhm "${QUOTA_GEMINI_5H_RES}"
QUOTA_GEMINI_5H_DHM=$DHM

# ─── State Indicator (No background colors) ──────────────────────────────────
case "$STATE" in
  idle)     S="${FG_BRIGHT_GREEN}${B}● READY${R}" ;;
  thinking) S="${FG_BRIGHT_YELLOW}${B}◆ THINKING${R}" ;;
  working)  S="${FG_BRIGHT_CYAN}${B}⚙  WORKING${R}" ;;
  tool_use) S="${FG_BRIGHT_MAGENTA}${B}🔧 TOOL${R}" ;;
  *)        S="${FG_WHITE}${B}⏳ $(echo "$STATE" | tr '[:lower:]' '[:upper:]')${R}" ;;
esac

# ─── VCS Branch ──────────────────────────────────────────────────────────────
V=""
if [ -n "$VCS_BRANCH" ]; then
  if [ "$VCS_DIRTY" = "true" ]; then
    V="${FG_GRAY} ╱ ${FG_BRIGHT_RED}${VCS_BRANCH}${FG_BRIGHT_YELLOW}*${R}"
  else
    V="${FG_GRAY} ╱ ${FG_BRIGHT_BLUE}${VCS_BRANCH}${R}"
  fi
fi

# ─── Model ───────────────────────────────────────────────────────────────────
M=""
if [ -n "$MODEL" ]; then
  M="${FG_GRAY} ╱ ${FG_BRIGHT_MAGENTA}${I}${MODEL}${R}"
fi

# ─── Sandbox Badge ───────────────────────────────────────────────────────────
if [ "$SANDBOX" = "true" ]; then
  SB="${FG_GRAY}sandbox ${FG_BRIGHT_GREEN}${B}ON${R}"
else
  SB="${FG_GRAY}sandbox off${R}"
fi

# ─── Percent Bar (10 segments, fine-grain Unicode) ────────────────────────────
render_bar() {
  local val=${1%.*}
  val=${val:-0}
  local mode=${2:-"normal"}
  local bar_len=10
  local filled=$((val * bar_len / 100))
  local remainder=$(( (val * bar_len) % 100 ))

  # Pick color based on percentage and mode
  local bar_color
  if [ "$mode" = "quota" ] || [ "$mode" = "reverse" ]; then
    if [ "$val" -le 10 ]; then
      bar_color="$FG_BRIGHT_RED"
    elif [ "$val" -le 40 ]; then
      bar_color="$FG_BRIGHT_YELLOW"
    else
      bar_color="$FG_BRIGHT_GREEN"
    fi
  else
    if [ "$val" -ge 90 ]; then
      bar_color="$FG_BRIGHT_RED"
    elif [ "$val" -ge 60 ]; then
      bar_color="$FG_BRIGHT_YELLOW"
    else
      bar_color="$FG_BRIGHT_GREEN"
    fi
  fi

  # Build bar with partial-fill last block
  local bar=""
  for ((i = 0; i < bar_len; i++)); do
    if [ "$i" -lt "$filled" ]; then
      bar="${bar}█"
    elif [ "$i" -eq "$filled" ]; then
      if [ "$remainder" -ge 75 ]; then
        bar="${bar}▓"
      elif [ "$remainder" -ge 50 ]; then
        bar="${bar}▒"
      elif [ "$remainder" -ge 25 ]; then
        bar="${bar}░"
      else
        bar="${bar}·"
      fi
    else
      bar="${bar}·"
    fi
  done

  BAR="${bar_color}${bar}"
}

render_bar "$CTX_INT"
CTX_BAR=${BAR}

if [ "${COLS:-80}" -ge 80 ]; then
    render_bar "$QUOTA_3P_5H_INT" "quota"
    QUOTA_3P_5H_BAR=${BAR}

    render_bar "$QUOTA_3P_WEEK_INT" "quota"
    QUOTA_3P_WEEK_BAR=${BAR}

    render_bar "$QUOTA_GEMINI_5H_INT" "quota"
    QUOTA_GEMINI_5H_BAR=${BAR}

    render_bar "$QUOTA_GEMINI_WEEK_INT" "quota"
    QUOTA_GEMINI_WEEK_BAR=${BAR}
else
    QUOTA_3P_5H_BAR=""
    QUOTA_3P_WEEK_BAR=""
    QUOTA_GEMINI_5H_BAR=""
    QUOTA_GEMINI_WEEK_BAR=""
fi

# ─── Stats ───────────────────────────────────────────────────────────────────
mbprintf -v CTX "%-9s %s %6s" "${FG_GRAY}ctx${R}" "${CTX_BAR}" "${NUM_COLOR}${CTX_FMT}%${R}"
mbprintf -v QUOTA_GEMINI_5H "%-9s %s %6s %-11s" "${FG_GRAY}Gem./5h${R}" "${QUOTA_GEMINI_5H_BAR}" "${NUM_COLOR}${QUOTA_GEMINI_5H_FMT}%${R}" "${FG_GRAY}(${QUOTA_GEMINI_5H_DHM})${R}"
mbprintf -v QUOTA_GEMINI_WEEK "%-9s %s %6s %-11s" "${FG_GRAY}Gem./wk.${R}" "${QUOTA_GEMINI_WEEK_BAR}" "${NUM_COLOR}${QUOTA_GEMINI_WEEK_FMT}%${R}" "${FG_GRAY}(${QUOTA_GEMINI_WEEK_DHM})${R}"
mbprintf -v QUOTA_3P_5H "%-9s %s %6s %-11s" "${FG_GRAY}3p/5h${R}" "${QUOTA_3P_5H_BAR}" "${NUM_COLOR}${QUOTA_3P_5H_FMT}%${R}" "${FG_GRAY}(${QUOTA_3P_5H_DHM})${R}"
mbprintf -v QUOTA_3P_WEEK "%-9s %s %6s %-11s" "${FG_GRAY}3p/wk.${R}" "${QUOTA_3P_WEEK_BAR}" "${NUM_COLOR}${QUOTA_3P_WEEK_FMT}%${R}" "${FG_GRAY}(${QUOTA_3P_WEEK_DHM})${R}"
ART_FMT="${FG_GRAY}artifacts ${NUM_COLOR}${ARTIFACTS}${R}"
SUB_FMT="${FG_GRAY}subagents ${NUM_COLOR}${SUBAGENTS}${R}"
BG_FMT="${FG_GRAY}tasks ${NUM_COLOR}${BG_TASKS}${R}"

# ─── Separators ──────────────────────────────────────────────────────────────
DOT="${FG_GRAY} · ${R}"

# ─── Output ──────────────────────────────────────────────────────────────────
LINE1="${S}${M}${V}"
LINE2=" ${CTX}${DOT}${ART_FMT}${DOT}${SUB_FMT}${DOT}${BG_FMT}${DOT}${SB}"
LINE3=" ${QUOTA_GEMINI_5H}${DOT}${QUOTA_GEMINI_WEEK}"
LINE4=" ${QUOTA_3P_5H}${DOT}${QUOTA_3P_WEEK}"

if [ "${COLS:-80}" -ge 80 ]; then
  # Medium: three-line layout with border
  echo -e "${FG_GRAY}╭─${R} ${LINE1}"
  echo -e "${FG_GRAY}├─${R}${LINE2}"
  echo -e "${FG_GRAY}├─${R}${LINE3}"
  echo -e "${FG_GRAY}╰─${R}${LINE4}"
else
  # Narrow: compact two-line, minimal chrome
  echo -e "${S}${M}"
  echo -e "${CTX}${DOT}${BG_FMT}"
  echo -e "${LINE3}${BG_FMT}"
  echo -e "${LINE4}${BG_FMT}"
fi
