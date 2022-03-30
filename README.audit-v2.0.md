# Qualcomm Cloud AI - MLPerf Inference v2.0 audit

## R282-Z93-Q2 results

| Benchmark | Offline Performance | Offline Accuracy | SingleStream Performance | SingleStream Accuracy | MultiStream Performance | MultiStream Accuracy |
| --------- | ------------------- | ---------------- | ------------------------ | --------------------- | ----------------------- | -------------------- |


## Install Python v3.8 (should be already installed)

```
sudo su
export PYTHON_VERSION=3.8.13
cd /usr/src \
&& wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
&& tar xzf Python-${PYTHON_VERSION}.tgz \
&& rm -f Python-${PYTHON_VERSION}.tgz \
&& cd /usr/src/Python-${PYTHON_VERSION} \
&& ./configure --enable-optimizations --with-ssl && make -j 32 altinstall \
&& rm -rf /usr/src/Python-${PYTHON_VERSION}*
```

```
python3.8 --version
```

<details><pre>
Python 3.8.13
</pre></details>

## Account setup

```
sudo useradd auditor
sudo passwd auditor
sudo usermod -aG qaic,root,wheel,docker auditor
sudo mkdir /local/mnt/workspace/auditor
sudo chown auditor:qaic /local/mnt/workspace/auditor
ssh auditor@localhost
```

## Recommended user setup

**TODO**
