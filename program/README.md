# Qualcomm Cloud AI - MLPerf Inference benchmarking (without Docker) 
    
Please refer to this [README](https://github.com/krai/ck-qaic/blob/main/docker/README.md) for instructions with Docker (for Datacenter and Edge servers).

<a name="installation"></a>
# Installation

## Prerequisites

Check the CentOS release to be 7 or 8:
```
rpm -q centos-release
```

Check the Linux kernel version to be 5.4+:
```
uname -a
```

Check the Platform SDK is installed:
```
cat /opt/qti-aic/versions/platform.xml
```

<a name="install_system"></a>
## Install system-wide prerequisites

**NB:** Run the below commands with `sudo` or as superuser.

<a name="install_system_centos7"></a>
### CentOS 7

#### Generic

``` 
sudo yum upgrade -y
sudo yum install -y make which patch vim git wget zip unzip openssl-devel bzip2-devel libffi-devel
sudo yum clean all
```

#### dnf  ("the new yum"!)

```
sudo yum install -y dnf
```

#### Python 3.8

```
sudo su
export PYTHON_VERSION=3.8.12
cd /usr/src \
&& wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
&& tar xzf Python-${PYTHON_VERSION}.tgz \
&& rm -f Python-${PYTHON_VERSION}.tgz \
&& cd /usr/src/Python-${PYTHON_VERSION} \
&& ./configure --enable-optimizations --with-ssl && make -j 32 altinstall \
&& rm -rf /usr/src/Python-${PYTHON_VERSION}*
exit
python3.8 --version
```
<details><pre>
Python 3.8.12
</pre></details>

#### GCC 11

```
sudo yum install -y centos-release-scl
sudo yum install -y scl-utils
sudo yum install -y devtoolset-11
echo "source scl_source enable devtoolset-11" >> ~/.bashrc
source ~/.bashrc
```

##### `gcc`

```
scl enable devtoolset-11 "gcc --version"
```
<details><pre>
gcc (GCC) 11.2.1 20210728 (Red Hat 11.2.1-1)
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
</pre></details>

##### `g++`

```
scl enable devtoolset-11 "g++ --version"
```
<details><pre>
g++ (GCC) 11.2.1 20210728 (Red Hat 11.2.1-1)
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
</pre></details>

<a name="install_ck"></a>
## Install [Collective Knowledge](http://cknowledge.org/) (CK)

```
export CK_PYTHON=$(which python3.8)
$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources --user --upgrade
$CK_PYTHON -m pip install ck==2.6.1
echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.bashrc
source $HOME/.bashrc
ck version
```

<a name="install_ck_repos"></a>
## Install CK repositories

```
ck pull repo --url=https://github.com/krai/ck-qaic
```


<a name="set_platform_scripts"></a>
## Set platform scripts

### Use QAIC settings (ECC on)

```
ck detect platform.os --platform_init_uoa=qaic
```

<a name="detect_python"></a>
## Detect Python

**NB:** Please detect only one Python interpreter. Python 3.6, the default on CentOS 7, is <font color="#268BD0"><b>recommended</b></font>. While CK can normally detect available Python interpreters automatically, we are playing safe here by only detecting a particular one. Please only detect multiple Python interpreters, if you understand the consequences.

### <font color="#268BD0">Python v3.8</font>

```
ck detect soft:compiler.python --full_path=`which python3.8`
ck show env --tags=compiler,python
```

<details><pre>
Env UID:         Target OS: Bits: Name:  Version: Tags:

ce146fbbcd1a8fea   linux-64    64 python 3.8.12    64bits,compiler,host-os-linux-64,lang-python,python,target-os-linux-64,v3,v3.8,v3.8.12
</pre></details>

<a name="detect_gcc"></a>
## Detect (system) GCC

**NB:** CK can normally detect compilers automatically, but we are playing safe here.

```
ck detect soft:compiler.gcc --full_path=$(which gcc)
ck show env --tags=compiler,gcc
```

<details><pre>
Env UID:         Target OS: Bits: Name:          Version: Tags:

2e27213b1488daf9   linux-64    64 GNU C compiler 11.2.1    64bits,compiler,gcc,host-os-linux-64,lang-c,lang-cpp,target-os-linux-64,v11,v11.2,v11.2.1
</pre></details>

<a name="install_cmake"></a>
## Install CMake from source

```
ck install package --tags=tool,cmake,from.source --quiet
ck show env --tags=tool,cmake,from.source
```

<details><pre>
Env UID:         Target OS: Bits: Name: Version: Tags:

9784ba222cddacb6   linux-64    64 cmake 3.20.5   64bits,cmake,compiled,compiled-by-gcc,compiled-by-gcc-9.3.0,from.source,host-os-linux-64,source,target-os-linux-64,tool,v3,v3.20,v3.20.5
</pre></details>

<a name="install_python_deps"></a>
## Install Python dependencies (in userspace)

#### Install implicit dependencies via pip

**NB:** These dependencies are _implicit_, i.e. CK will not try to satisfy them. If they are not installed, however, the workflow will fail.

```
export CK_PYTHON=$(which python3.8)
$CK_PYTHON -m pip install --user --upgrade wheel
```

#### Install explicit dependencies via CK (also via `pip`, but register with CK at the same time)

**NB:** These dependencies are _explicit_, i.e. CK will try to satisfy them automatically. On a machine with multiple versions of Python, things can get messy, so we are playing safe here.

```
ck install package --tags=python-package,numpy --quiet
ck install package --tags=python-package,absl --quiet
ck install package --tags=python-package,cython --quiet
ck install package --tags=python-package,opencv-python-headless --quiet
ck install package --tags=lib,python-package,onnx --force_version=1.8.1
```

**NB:** If you have large NFS folders in your $PATH, you can set the following kernel variable to avoid long waiting times when CK searches in them: 
```
ck set kernel var.soft_search_dirs="/fake_dir"
```

<a name="install_inference_repo"></a>
## Install the MLPerf Inference repo and build LoadGen

```
ck install package --tags=mlperf,inference,source --quiet
ck install package --tags=mlperf,loadgen,static --quiet
ck install package --tags=mlperf,power,source --quiet
```

## Install and Run the Benchmarks
1. [Image Classification](https://github.com/krai/ck-qaic/blob/main/program/image-classification-qaic-loadgen/README.md)
2. [Object Detection](https://github.com/krai/ck-qaic/blob/main/program/object-detection-qaic-loadgen/README.md)
3. [Language Processing](https://github.com/krai/ck-qaic/blob/main/program/packed-bert-qaic-loadgen/README.md)

## Copy the models to AEDKs
Once all the models are installed you can copy them in one go to any AEDK device by using [these](https://github.com/krai/ck-qaic/tree/main/script/setup.aedk#hr-compile-the-models-and-copy-to-the-device) instructions
