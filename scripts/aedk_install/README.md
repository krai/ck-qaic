# Install all models to AEDK devices

## On Host machine
Compile the models and copy the binaries on to the AEDKs. Example usage
```
IPS=aedk3 PORTS=3233 MODEL_EXTRA=aedk_20w $(ck find repo:ck-qaic)/scripts/aedk_install/install_to_aedk.sh
```
