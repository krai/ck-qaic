chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo
usermod -aG qaic,root,wheel krai
echo "krai ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
export PYTHON_VERSION=3.8.12
cd /usr/src \
&& wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
&& tar xzf Python-${PYTHON_VERSION}.tgz \
&& rm -f Python-${PYTHON_VERSION}.tgz \
&& cd /usr/src/Python-${PYTHON_VERSION} \
&& ./configure --enable-optimizations && make -j8 altinstall \
&& rm -rf /usr/src/Python-${PYTHON_VERSION}*
