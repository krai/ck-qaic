echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.bashrc
echo 'export CK_PYTHON=`which python3.8`' >> $HOME/.bashrc
source $HOME/.bashrc
$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources --user --upgrade
$CK_PYTHON -m pip install ck==2.6.1
$CK_PYTHON -m pip install --user --upgrade wheel
$CK_PYTHON -m pip install h5py
$CK_PYTHON -m pip install tensorflow-aarch64 -f https://tf.kmtea.eu/whl/stable.html
ck version
ck set kernel var.package_quiet_install=yes
ck pull repo --url=https://github.com/krai/ck-qaic
ck detect platform.os --platform_init_uoa=aedk
ck detect soft:compiler.python --full_path=`which python3.8`
ck detect soft:compiler.gcc --full_path=`which gcc`
ck install package --tags=tool,cmake,from.source
ck install package --tags=python-package,numpy
ck install package --tags=python-package,absl
ck install package --tags=python-package,cython
ck install package --tags=python-package,opencv-python-headless
