# Install QAIC model to AEDK devices

## IPs, Ports and Username needs to be given for devices. Requires passwordless ssh enabled to the devices

```bash
$ ck install package --tags=install-to-aedk --dep_add_tags.model-qaic=qaic,resnet50-example,precision.int8 --env.CK_AEDK_IPS="aedk1 aedk2" --env.CK_AEDK_USER=arjun --env.CK_AEDK_PORTS="3231 3232"
```

