## Extra Options to CmdGen

* `--power` adds power measurement to the experiment run
* `--group.edge` runs three scenarios: `--scenario=offline`, `--scenario=singlestream` and `--scenario=multistream`
* `--group.datacenter` runs two scenarios: `--scenario=offline` and `--scenario=server`
* `--group.open` runs the following modes: `--mode=accuracy` and `--mode=performance`
* `--group.closed` runs the modes for `--group.open` and in addition the following compliance tests: `--compilance,=TEST01,TEST04,TEST05` for vision benchmarks and `--compilance,=TEST01,TEST05` for bert.
