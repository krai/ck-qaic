# Qualcomm Cloud AI - MLPerf Inference benchmarking (not using docker) 
    
Please refer to [Docker README](https://github.com/krai/ck-qaic/blob/main/docker/README.md) for instructions to follow while using docker

<a name="installation"></a>
# Installation

Tested on a ([Gigabyte R282-Z93](https://www.gigabyte.com/Enterprise/Rack-Server/R282-Z93-rev-100)) server with CentOS 7.9 and QAIC Platform SDK 1.6.80:

<pre><b>[anton@dyson ~]&dollar;</b> rpm -q centos-release
centos-release-7-9.2009.1.el7.centos.x86_64</pre>

<pre><b>[anton@dyson ~]&dollar;</b> uname -a
Linux dyson.localdomain 5.4.1-1.el7.elrepo.x86_64 #1 SMP Fri Nov 29 10:21:13 EST 2019 x86_64 x86_64 x86_64 GNU/Linux</pre>

<pre><b>[anton@dyson ~]&dollar;</b> cat /opt/qti-aic/versions/platform.xml</pre>
```
<versions>
        <ci_build>
           <base_name>AIC</base_name>
           <base_version>1.6</base_version>
           <build_id>80</build_id>
        </ci_build>
        </versions>
```

<a name="install_system"></a>
## Install system-wide prerequisites

**NB:** Run the below commands with `sudo` or as superuser.

<a name="install_system_centos7"></a>
### CentOS 7

#### Generic

``` 
sudo yum upgrade -y
sudo yum install -y
make which patch vim git wget zip unzip openssl-devel bzip2-devel libffi-devel
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
<pre>
Python 3.8.12
</pre>

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
<pre>
gcc (GCC) 11.2.1 20210728 (Red Hat 11.2.1-1)
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
</pre>

##### `g++`

```
scl enable devtoolset-11 "g++ --version"
```
<pre>
g++ (GCC) 11.2.1 20210728 (Red Hat 11.2.1-1)
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
</pre>

<a name="install_ck"></a>
## Install [Collective Knowledge](http://cknowledge.org/) (CK)

```
export CK_PYTHON=`which python3.8`
$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources --user --upgrade
$CK_PYTHON -m pip install ck==2.6.1
echo 'export PATH=&dollar;HOME/.local/bin:$PATH' >> $HOME/.bashrc
source $HOME/.bashrc
ck version
```
<pre>
V2.6.1
</pre>

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
<pre>
OS CK UOA:            linux-64 (4258b5fe54828a50)

OS name:              CentOS Linux 7 (Core)
Short OS name:        Linux 5.4.1
Long OS name:         Linux-5.4.1-1.el7.elrepo.x86_64-x86_64-with-centos-7.9.2009-Core
OS bits:              64
OS ABI:               x86_64

Platform init UOA:    qaic
</pre>
```
cat $(ck find repo:local)/cfg/local-platform/.cm/meta.json
```
<pre>
{
  "platform_init_uoa": {
    "linux-64": "qaic"
  }
}
</pre>




<a name="detect_python"></a>
## Detect Python

**NB:** Please detect only one Python interpreter. Python 3.6, the default on CentOS 7, is <font color="#268BD0"><b>recommended</b></font>. While CK can normally detect available Python interpreters automatically, we are playing safe here by only detecting a particular one. Please only detect multiple Python interpreters, if you understand the consequences.

### <font color="#268BD0">Python v3.8</font>

```
ck detect soft:compiler.python --full_path=`which python3.8`
ck show env --tags=compiler,python
```
<pre>
Env UID:         Target OS: Bits: Name:  Version: Tags:

ce146fbbcd1a8fea   linux-64    64 python 3.8.12    64bits,compiler,host-os-linux-64,lang-python,python,target-os-linux-64,v3,v3.8,v3.8.12
</pre>

<a name="detect_gcc"></a>
## Detect (system) GCC

**NB:** CK can normally detect compilers automatically, but we are playing safe here.

``` 
which gcc
```
<pre>
/opt/rh/devtoolset-11/root/usr/bin/gcc
</pre>
```
ck detect soft:compiler.gcc --full_path=`which gcc`
```
```
ck show env --tags=compiler,gcc
```
<pre>
Env UID:         Target OS: Bits: Name:          Version: Tags:

2e27213b1488daf9   linux-64    64 GNU C compiler 11.2.1    64bits,compiler,gcc,host-os-linux-64,lang-c,lang-cpp,target-os-linux-64,v11,v11.2,v11.2.1
</pre>

<a name="install_cmake"></a>
## Install CMake from source

```
ck install package --tags=tool,cmake,from.source
ck show env --tags=tool,cmake,from.source
```
Env UID:         Target OS: Bits: Name: Version: Tags:

9784ba222cddacb6   linux-64    64 cmake 3.20.5   64bits,cmake,compiled,compiled-by-gcc,compiled-by-gcc-9.3.0,from.source,host-os-linux-64,source,target-os-linux-64,tool,v3,v3.20,v3.20.5
</pre>

<a name="install_python_deps"></a>
## Install Python dependencies (in userspace)

#### Install implicit dependencies via pip

**NB:** These dependencies are _implicit_, i.e. CK will not try to satisfy them. If they are not installed, however, the workflow will fail.

```
export CK_PYTHON=`which python3.8`
$CK_PYTHON -m pip install --user --upgrade wheel
```

#### Install explicit dependencies via CK (also via `pip`, but register with CK at the same time)

**NB:** These dependencies are _explicit_, i.e. CK will try to satisfy them automatically. On a machine with multiple versions of Python, things can get messy, so we are playing safe here.

```
ck install package --tags=python-package,numpy
ck install package --tags=python-package,absl
ck install package --tags=python-package,cython
ck install package --tags=python-package,opencv-python-headless
```

If you use large NFS folders in your $PATH you can avoid log waiting time when CK searches in them by setting the following kernel variable
```
ck set kernel var.soft_search_dirs="/fake_dir"
```

<a name="install_inference_repo"></a>
## Install the MLPerf Inference repo and build LoadGen

```
ck install package --tags=mlperf,inference,source
ck install package --tags=mlperf,loadgen,static
```

**For power runs**
```
ck install package --tags=mlperf,power,source
```
## Install and Run the Benchmarks
1. [Image Classification](https://github.com/krai/ck-qaic/blob/main/program/image-classification-qaic-loadgen/README.md)
2. [Object Detection](https://github.com/krai/ck-qaic/blob/main/program/object-detection-qaic-loadgen/README.md)
3. [Language Processing](https://github.com/krai/ck-qaic/blob/main/program/packed-bert-qaic-loadgen/README.md)
