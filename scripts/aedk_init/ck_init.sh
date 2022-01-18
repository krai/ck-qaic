export CK_PYTHON=`which python3.8`
$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources --user --upgrade
$CK_PYTHON -m pip install ck==2.6.1
$CK_PYTHON -m pip install --user --upgrade wheel
echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.bashrc
source $HOME/.bashrc
ck version
ck pull repo --url=https://github.com/krai/ck-qaic
ck detect platform.os --platform_init_uoa=aedk
ck detect soft:compiler.python --full_path=`which python3.8`
ck detect soft:compiler.gcc --full_path=`which gcc`
ck install package --tags=tool,cmake,from.source --quiet
ck install package --tags=python-package,numpy --quiet
ck install package --tags=python-package,absl --quiet
ck install package --tags=python-package,cython --quiet
ck install package --tags=python-package,opencv-python-headless --quiet
