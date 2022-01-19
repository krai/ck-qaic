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

## Pull the `ck-qaic` repository (run once)

```
ck pull repo --url=https://github.com/krai/ck-qaic
```

## Copy the scripts to the device (run once)

Copy the numbered scripts in this directory to a temporary directory on the device e.g.:

```
scp $(ck find repo:ck-qaic)/script/setup.aedk/?.*.sh aedk1:/tmp
```

## Obtain the ImageNet dataset

Suppose the ImageNet validation dataset (50,000 images) is in an archive called
`dataset-imagenet-ilsvrc2012-val.tar` (6.4G).

<details><pre>
&dollar; md5sum dataset-imagenet-ilsvrc2012-val.tar
3f31a40f2bb902e28aa23aad0fc8e383  dataset-imagenet-ilsvrc2012-val.tar
</pre></details>

Extract it under e.g. `/data` or `$HOME`:
```
tar xvf dataset-imagenet-ilsvrc2012-val.tar -C /data
```

## Detect the ImageNet dataset (run once)
```
echo "full" | ck detect soft:dataset.imagenet.val --extra_tags=ilsvrc2012,full \
--full_path=/data/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG
```

# On the device

## Run under the `root` user (run once)

Connect to the device as `root` e.g.:
```
ssh root@aedk1
```

Go to the temporary directory and run:
```
./1.run_as_root.sh
```

## Run under the `krai` user (run once)

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

## Uninstall/Install the Platform SDK (repeat as needed)
**TODO**

# On the host

## Uninstall/Install the Apps SDK (repeat as needed)
**TODO**

## Compile the models and copy to the device (repeat as needed)

Example:
```
IPS=aedk1 PORTS=3231 EXTRA_MODEL=aedk_15w $(ck find ck-qaic:script:setup.aedk)/install_to_aedk.sh
```

## Copy the ImageNet dataset to the device (run once)

```
scp dataset-imagenet-ilsvrc2012-val.tar aedk1:/home/krai
```
