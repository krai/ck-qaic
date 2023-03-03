#!/usr/bin/python3

import pytest
import ck.kernel as ck
from helper_functions import *

print("Collective Knowledge v{}\n".format(ck.version({}).get('version_str')))

# ==========================================================================================================================
# No Parameters Valid Implementation
# ==========================================================================================================================
def test_cmdgen_no_params_valid(implementation_model):
    # Arrange
    i = ck_cmdgen_args(data_uoa = implementation_model[0])
    
    # Act
    r=ck.access(i)
    actual_error = r[ 'error' ]
    return_code = r[ 'return' ]
    
    # Assert
    assert return_code == 1
    expected_error = "Neither input_params nor accu contain substitution for non-optional \'ck_benchmark_prefix\' anchor"
    assert expected_error == actual_error # strict matching
    
    
# ==========================================================================================================================
# No Parameters Invalid Implementation
# ==========================================================================================================================    
def test_cmdgen_no_params_invalid():
    # Arrange
    invalid_implementation = 'benchmark.bert-packed.qaic-loadgen'
    i = ck_cmdgen_params( invalid_implementation )
    
    # Act
    r=ck.access(i)
    actual_error = r['error']
    return_code = r['return']
    
    # Assert
    assert return_code == 16
    expected_error = "[cmdgen] can\'t find path to CK entry \"{}\"".format(invalid_implementation)
    assert actual_error.find(expected_error) # substring matching
    
