# Set up Edge AI Development Kit (AEDK)

## Pull the `ck-qaic` repository

```
ck pull repo --url=https://github.com/krai/ck-qaic
```

## Copy the scripts to the device

Copy the scripts in this directory to a temporary directory on the device e.g.:

```
scp $(ck find repo:ck-qaic)/script/setup.aedk/*.sh aedk1:/tmp
```

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

## Copy the ImageNet validation dataset to `/home/krai`
**TODO**
