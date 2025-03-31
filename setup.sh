mkdir downloads
cd downloads
git clone git@github.com:lianakoleva/setup.git

# get fish
wget https://launchpad.net/~fish-shell/+archive/ubuntu/release-4/+files/fish_4.0.0-2~jammy_amd64.deb
sudo dpkg -i fish_4.0.0-2~jammy_amd64.deb
sudo cp setup/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish
sudo cp setup/config.fish ~/.config/fish/config.fish
fish

# get drivers
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
sudo cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get install -y cuda-drivers

# restart
sudo reboot

# verify installation
nvidia-smi

# set up github
ssh-keygen -t ed25519 -C "my-email@users.noreply.github.com"
eval "$(ssh-agent -s)" # in bash
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
# copy SSH public key to clipboard
# go to Github > Settings > SSH and GPG keys > New SSH key > Add SSH key

# set up workspace
mkdir ~/work
cd ~/work

# install criu
git clone git@github.com:cedana/criu.git
cd criu
sudo apt -y install asciidoc libcap-dev libnet-dev libnl-3-dev libprotobuf-c-dev libprotobuf-dev protobuf-c-compiler protobuf-compiler python3-pip python3-protobuf
sudo make install
criu --version

# install golang
cd ~/downloads
sudo apt update
sudo apt -y install libbtrfs-dev libgpgme-dev libseccomp-dev pkg-config
wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xvzf go1.22.0.linux-amd64.tar.gz
# export PATH=$PATH:/usr/local/go/bin
go version

# install lunarvim
cd ~/downloads
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
# sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
nvim
curl https://sh.rustup.rs -sSf | sh
source "$HOME/.cargo/env.fish"
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)
export PATH=/home/ubuntu/.local/bin:$PATH

# install cedana
cd ~/work
git clone git@github.com:cedana/cedana.git
cd cedana
make start

# resize shared memory
sudo nano /etc/fstab
# append “none /dev/shm tmpfs defaults,size=32G 0 0” w/o quotes
sudo mount /dev/shm


# install docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
cd ~/downloads
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo groupadd docker 
sudo usermod -aG docker $USER
sudo reboot
sudo systemctl enable docker
sudo systemctl start docker

# install cedana gpu controller
cd ~/work
git clone git@github.com:cedana/cedana-gpu.git gpu
cd gpu
docker build -f docker/build.Dockerfile  -t cedana-gpu.build:latest .
docker run -it --rm -v (pwd):/src cedana-gpu.build:latest -DDEBUG=ON -DLOG_LEVEL=DEBUG # ~20 minutes
sudo cp build/cedana-gpu-controller /usr/local/bin && sudo cp build/libcedana-gpu.so /usr/local/lib

# install nvidia container toolkit w/ docker
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

