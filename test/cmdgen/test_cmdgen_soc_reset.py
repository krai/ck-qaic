#!/usr/bin/python3

import re
import ck.kernel as ck
from helper_functions import *


# TODO:
# 5 - target?
# 6 - value?

mode='accuracy'
# ==========================================================================================================================
# Socket Reset
# ==========================================================================================================================
# @pytest.mark.skip
def test_cmdgen_soc_reset(implementation_model, scenario, sut, sdk, soc_reset):    
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1]

    if skip_tests(model, scenario, sut) != '':
        return 
    
    i = ck_cmdgen_args(data_uoa = implementation, model = model, sut = sut,scenario = scenario,  
                        mode = mode, sdk = sdk, soc_reset = soc_reset)
    
    # Act
    r=ck.access(i)
    return_code = r['return']
    
    # Assert 
    assert return_code == 0
    cmds = r.get('cmds')
    assert len(cmds) == 1
    cmd = cmds[0]
    
    # print( f'/n----- Command = { cmd }/n')
    
    # Assert whether 'soc_reset' is added to the tags.
    match_tags = re.search(r'--tags.*soc_reset', cmd)
    # print( f'/n----- match_loadgen = {match_tags}/n')
    if soc_reset == 'yes':
        assert match_tags != None
    else:
        assert match_tags == None
