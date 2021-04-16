# AI Model Efficiency Toolkit (AIMET)

<a href="https://quic.github.io/aimet-pages/index.html">AIMET</a> is a library that provides advanced model quantization 
and compression techniques for trained neural network models.
It provides features that have been proven to improve run-time performance of deep learning neural network models with 
lower compute and memory requirements and minimal impact to task accuracy. 

* This CK package by default installs a CPU variant of AIMET
* To use the GPU, please add the "with-cuda" tag to pick the "with-cuda" variant. On Ubuntu, this will require the following packages to be installed.

      sudo apt-get install nvidia-kernel-source-460-server nvidia-compute-utils-460
      sudo apt-get install python3.6-dev
      sudo apt-get install libilmbase-dev
      sudo apt-get install libopenexr-dev
      sudo apt-get install libgstreamer1.0-dev
      sudo apt-get install -y ffmpeg
      sudo apt-get install libavresample-dev
      sudo apt-get install libgfortran
