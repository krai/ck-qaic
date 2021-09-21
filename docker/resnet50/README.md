# Qualcomm Cloud AI - MLPerf ResNet50 Docker image

## Build parameters

- `SDK_VER=1.5.6`
- `DOCKER_OS=centos7`
- `IMAGENET={min,full,preprocessed}`

## Build examples

### `IMAGENET=min`

```
$ IMAGENET=min $(ck find ck-qaic:docker:resnet50)/build.sh
Running: time docker build --no-cache --build-arg IMAGENET=min --build-arg BASE_IMAGE=qran-centos7 --build-arg SDK_VER=1.5.6 --build-arg PYTHON_VER=3.8.12 --build-arg GCC_MAJOR_VER=10 --build-arg GROUP_ID=981 --build-arg USER_ID=2000 --target "final_min" -t krai/mlperf.resnet50.min.centos7:1.5.6 -f Dockerfile.centos7 .
...
Step 56/59 : FROM preamble as final_min
 ---> ae6258e36937
Step 57/59 : ONBUILD COPY --from=imagenet_min          /home/krai/CK       /home/krai/CK
 ---> Running in 48fb89cba33d
Removing intermediate container 48fb89cba33d
 ---> ec0cfe5dd6fa
Step 58/59 : ONBUILD COPY --from=imagenet_min          /home/krai/CK_REPOS /home/krai/CK_REPOS
 ---> Running in 616867c9ae71
Removing intermediate container 616867c9ae71
 ---> 8685ce464aca
Step 59/59 : ONBUILD COPY --from=imagenet_min          /home/krai/CK_TOOLS /home/krai/CK_TOOLS
 ---> Running in f0d10e97296a
Removing intermediate container f0d10e97296a
 ---> c6851fb861db
Successfully built c6851fb861db
Successfully tagged krai/mlperf.resnet50.min.centos7:1.5.6

real    16m56.588s
user    0m0.868s
sys     0m0.838s

Done.

$ docker image ls krai/mlperf.resnet50.min.centos7
REPOSITORY                         TAG       IMAGE ID       CREATED              SIZE
krai/mlperf.resnet50.min.centos7   1.5.6     c6851fb861db   About a minute ago   7.85GB
```

### `IMAGENET=full`
```
$ IMAGENET=full $(ck find ck-qaic:docker:resnet50)/build.sh
Running: time docker build --no-cache --target "final_full" --build-arg IMAGENET=full --build-arg BASE_IMAGE=qran-centos7 --build-arg SDK_VER=1.5.6 --build-arg PYTHON_VER=3.8.12 --build-arg GCC_MAJOR_VER=10 --build-arg GROUP_ID=981 --build-arg USER_ID=2000 -t krai/mlperf.resnet50.full.centos7:1.5.6 -f Dockerfile.centos7 .

...

Installation path: /home/krai/CK_TOOLS/dataset-imagenet-preprocessed-using-opencv-crop.875-for.resnet50.quantized-full-layout.nhwc-side.224-validation

Installation time: 603.7303237915039 sec.

Removing intermediate container fe3926af93b6
 ---> 10d84479e93b
Step 65/67 : ONBUILD COPY /home/krai/CK       /home/krai/CK
 ---> Running in 8eff8dccf025
Removing intermediate container 8eff8dccf025
 ---> 20686f86a600
Step 66/67 : ONBUILD COPY /home/krai/CK_REPOS /home/krai/CK_REPOS
 ---> Running in c42d59120258
Removing intermediate container c42d59120258
 ---> 43a662b05732
Step 67/67 : ONBUILD COPY /home/krai/CK_TOOLS /home/krai/CK_TOOLS
 ---> Running in 8ac9e174bce1
Removing intermediate container 8ac9e174bce1
 ---> 1d64922cfc6a
Successfully built 1d64922cfc6a
Successfully tagged krai/mlperf.resnet50.full.centos7:1.5.6

real    32m19.230s
user    0m1.609s
sys     0m1.779s

Done.

$ docker image ls krai/mlperf.resnet50.full.centos7
REPOSITORY                          TAG       IMAGE ID       CREATED              SIZE
krai/mlperf.resnet50.full.centos7   1.5.6     1d64922cfc6a   About a minute ago   22.8GB
```

### `IMAGENET=preprocessed`
```
$ IMAGENET=preprocessed $(ck find ck-qaic:docker:resnet50)/build.sh
```
