# Set up Edge AI Development Kit (AEDK)

We provide instructions to set up a Qualcomm Edge AI Development Kit (AEDK),
which we call "the device", for MLPerf Inference benchmarking from scratch.
We assume that the device has a recent firmware ("meta") installed e.g. `00064`.

We also assume that the user operates a Linux workstation (or a Windows laptop
under WSL), which we call "the host". We further assume that the host has
installed the Collective Knowledge framework (CK) and the QAIC Apps SDK
matching the QAIC Platform SDK to be installed on the device.

Instructions below alternate between running "on the host" and "on the device".

# On the host

## Pull the `ck-qaic` repository

```
ck pull repo --url=https://github.com/krai/ck-qaic
```

## Copy the scripts to the device

Copy the scripts in this directory to a temporary directory on the device e.g.:

```
scp $(ck find repo:ck-qaic)/script/setup.aedk/*.sh aedk1:/tmp
```

# On the device

## Run under the `root` user

Connect to the device as `root` e.g.:
```
ssh root@aedk1
```

Go to the temporary directory and run:
```
./1.run_as_root.sh
```

## Run under the `krai` user

Connect to the device as `krai` e.g.:
```
ssh krai@aedk1
```

Go to the temporary directory and run:
```
sudo chown krai ./2.run_as_krai.sh
sudo chmod u+x ./2.run_as_krai.sh
./2.run_as_krai.sh
```

## Install the Platform SDK
**TODO**

# On the host

## Copy the ImageNet validation dataset to `/home/krai`
**TODO**

## Install the Apps SDK
**TODO**

## Compile the models and copy to the device

Example:
```
IPS=aedk1 PORTS=3231 MODEL_EXTRA=aedk_15w $(ck find ck-qaic:script:setup.aedk)/install_to_aedk.sh
```
