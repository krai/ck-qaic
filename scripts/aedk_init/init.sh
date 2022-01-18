sudo yum upgrade -y
sudo yum install -y make which patch vim git wget zip unzip openssl-devel bzip2-devel libffi-devel
sudo yum clean all
sudo yum install -y dnf
dnf install -y gcc-toolset-11-gcc-c++
dnf install -y scl-utils
echo "source scl_source enable gcc-toolset-11" >> ~/.bashrc
source ~/.bashrc
export GIT_USER="krai"
export GIT_EMAIL="info@krai.ai"
git config --global user.name ${GIT_USER} && git config --global user.email ${GIT_EMAIL}
curl https://sh.rustup.rs -sSf | sh
