# Qualcomm Cloud AI - MLPerf Inference - Calibration

This package calibrates:
- [BERT Large](#bert_large) using the QAIC toolchain.

<a name="BERT Large"></a>
## Calibrate BERT Large

The BERT Large model is calibrated using the QAIC toolchain based on
[Glow](https://github.com/pytorch/glow). This requires `100` examples 
randomly selected from the [SQuAD](https://rajpurkar.github.io/SQuAD-explorer/) Stanford Question Answering Dataset v1.1 dataset (`10570` examples).

Two of the examples result in a sample sequence length larger than 384 and so are split into two samples, hence 102 samples generated from 100 examples.

<a name="bert_calbration_dataset"></a>
### Prepare the calibration dataset(https://github.com/mlcommons/inference/blob/master/calibration/SQuAD-v1.1/bert-calibration.txt)

#### Preprocess the calibration dataset

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package \
--tags=dataset,tokenized,converted,pickle,calibration
</pre>

### Calibrate the model

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --tags=profile,bert-packed,qaic
</pre>

