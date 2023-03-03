## Extra Options to CmdGen

* `--power` adds power measurement to the experiment run
* `--group.edge` runs three scenarios: `--scenario=offline`, `--scenario=singlestream` and `--scenario=multistream` (except for bert)
* `--group.datacenter` runs two scenarios: `--scenario=offline` and `--scenario=server`
* `--group.open` runs the following modes: `--mode=accuracy` and `--mode=performance`
* `--group.closed` runs the modes for `--group.open` and in addition the following compliance tests: `--compliance,=TEST01,TEST04,TEST05` for resnet50 and `--compliance,=TEST01,TEST05` for retinanet and bert.
