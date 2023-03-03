#!/usr/bin/python3

import re
import ck.kernel as ck
from helper_functions import *

# test local arguments
mode = 'accuracy'
device_ids_value =  '0' 
# ==========================================================================================================================
# Device_ids with no value
# ==========================================================================================================================
def test_cmdgen_device_ids_no_value(implementation_model, scenario_device_ids, sut, sdk ):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1] 
    scenario = scenario_device_ids[0]
    device_ids = scenario_device_ids[1]
    
    if skip_tests( model, scenario, sut ) != '':
        return 
         
    i = ck_cmdgen_args( data_uoa = implementation, model = model, sut = sut, 
                       scenario = scenario, device_ids = device_ids,  mode = mode, sdk = sdk )
  
    # Act
    r=ck.access(i)
    return_code = r['return']
    assert return_code == 0
    cmds = r.get('cmds')
    assert len(cmds) == 1
    cmd = cmds[0]
      
    # Assert
    match_loadgen = re.search(r'--env.CK_ENV_QAIC_DEVICE_IDS=(\d*\.?\d*)', cmd)
    assert match_loadgen.group(1) != None 
    
    # print( f'/n----- match_loadgen = {match_loadgen}/n')

# ==========================================================================================================================
# Device_ids with value
# ==========================================================================================================================
# @pytest.mark.skip
def test_cmdgen_device_ids_value(implementation_model, scenario_device_ids, sut, sdk ):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1] 
    scenario = scenario_device_ids[0]
    device_ids = scenario_device_ids[1]
    
    if skip_tests( model, scenario, sut ) != '':
        return 
         
       
    i = ck_cmdgen_args( data_uoa = implementation, model = model, sut = sut, 
                       scenario = scenario,  mode = mode, sdk = sdk, 
                       device_ids = device_ids, device_ids_value = device_ids_value )
    # print('\n')
    # print(f'CK Command: ----------- {i} ')
    
    # Act
    r=ck.access(i)
    return_code = r['return']
    assert return_code == 0
    cmds = r.get('cmds')
    assert len(cmds) == 1
    cmd = cmds[0]
      
    # Assert
    match_loadgen = re.search(r'--env.CK_ENV_QAIC_DEVICE_IDS=(\d*\.?\d*)', cmd)
    assert match_loadgen.group(1) == device_ids_value
    
    