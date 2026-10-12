sudo dpkg-reconfigure console-setup
curl -sSL https://raw.githubusercontent.com/DevSolar/apter/refs/heads/main/apter > apter
chmod +x apter 
ssh-keygen
./apter install gh git
gh auth login
rm apter 
gh repo clone apter
gh repo clone gim
gh repo clone unix-home
gh repo clone crosscc
gh repo clone astrolabe
sudo nano /etc/apt/sources.list.d/testing.sources
sudo nano /etc/apt/preferences.d/default-pin
apter update
mkdir unix-home/old
mv .bash* .profile unix-home/old/
mv .profile unix-home/old/
mv .config/gh .config/labwc unix-home/config/
cd unix-home/
./setup.sh 
cd .local/bin/
ln -s ~/apter/apter 
ln -s ~/gim/gim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz
sudo tar -C /opt -xzf nvim-linux-arm64.tar.gz
sudo ln -sf /opt/nvim-linux-arm64/bin/nvim .local/bin/nvim
sudo apt install -t testing tree-sitter-cli
apter install clang clangd clang-format
apter install firefox
apter install greetd wlgreet sway foot
sudo cp ~/unix-home/system/etc/greetd/* /etc/greetd/
sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target
apter install fonts-font-awesome-legacy fonts-materialdesignicons-legacy
