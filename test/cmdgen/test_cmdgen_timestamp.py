#!/usr/bin/python3

import re
import ck.kernel as ck
from helper_functions import *

# ==========================================================================================================================
#  Timestamp
# ==========================================================================================================================
def test_cmdgen_timestamp(implementation_model, sut_scenario_target, value, mode, sdk, timestamp):
    # Arrange
    model = implementation_model[1]
    sut = sut_scenario_target[0]
    scenario = sut_scenario_target[1]
    target = sut_scenario_target[2]
    implementation = implementation_model[0]
    
    if skip_tests(model, scenario, sut) != '':
        return 
   
    # i = ck_cmdgen_params(implementation, model, sut, scenario, target, value, mode, sdk, timestamp )
    
    i = ck_cmdgen_args(data_uoa = implementation, model = model, sut = sut,scenario = scenario,  
                       target = target, value = value,  mode = mode, sdk = sdk, timestamp = timestamp)
    
    # Act
    cmd = ck_cmdgen_command(i)
        
    # Accert 
    
    # Match target qps or latency.
    if scenario in [ 'offline', 'server' ]:
        match = re.search(r'target_qps\.(\d*\.?\d*)\${timestamp_val}', cmd)
    elif scenario in [ 'singlestream', 'multistream' ]:
        match = re.search(r'target_latency\.(\d*\.?\d*)\${timestamp_val}', cmd)
        
    # Check timestamp, if requested, is added only to performance experiments.
    if timestamp == 'yes' and mode == 'performance':
        assert match
        assert match.group(1) == value
    else:
        assert match == None
