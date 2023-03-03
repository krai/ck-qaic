import pytest
import ck.kernel as ck

# implementation_model - A selection of implementations and models.   git status
@pytest.fixture(params=[
        ('benchmark.image-classification.qaic-loadgen',   'resnet50'),
        ('benchmark.packed-bert.qaic-loadgen',            'bert-99'),
        ('benchmark.packed-bert.qaic-loadgen',            'bert-99.9'),
        ('benchmark.object-detection.qaic-loadgen',       'retinanet'),
        ('benchmark.object-detection-large.qaic-loadgen', 'ssd_resnet34'),
        ('benchmark.object-detection-small.qaic-loadgen', 'ssd_mobilenet'),
    ])
def implementation_model(request):
    return request.param

# sut_scenario_target - A selection of edge/datacenter suts and scenarios.                
@pytest.fixture(params=[ 
        ('q4_std_edge', 'offline',      'offline_target_qps'),
        ('q4_std_edge', 'offline',      'target_qps'),
        ('q4_std_edge', 'singlestream', 'singlestream_target_latency'),
        ('q4_std_edge', 'singlestream', 'target_latency'),
        ('q4_std_edge', 'multistream',  'multistream_target_latency'),
        ('q4_std_edge', 'multistream',  'target_latency'),
        ('q4_pro_dc',   'offline',      'offline_target_qps'),
        ('q4_pro_dc',   'offline',      'target_qps'),
        ('q4_pro_dc',   'server',       'server_target_qps'),
        ('q4_pro_dc',   'server',       'target_qps')
    ])
def sut_scenario_target(request):
    return request.param

# mode_scenario_target
@pytest.fixture(params=[ 
        ('accuracy',    'offline',      'offline_target_qps'),
        ('accuracy',    'offline',      'target_qps'),
        ('accuracy',    'server',       'server_target_qps'),
        ('accuracy',    'server',       'target_qps'),
        ('accuracy',    'singlestream', 'singlestream_target_latency'),
        ('accuracy',    'multistream',  'multistream_target_latency'),
        ('performance', 'offline',      'offline_target_qps'),
        ('performance', 'offline',      'target_qps'),
        ('performance', 'server',       'server_target_qps'),
        ('performance', 'server',       'target_qps'),
        ('performance', 'singlestream', 'singlestream_target_latency'),
        ('performance', 'multistream',  'multistream_target_latency')
    ])

def mode_scenario_target(request):
    return request.param

# A selection of integer or floating-point values.
# @pytest.fixture(params = [ '123' ])
@pytest.fixture(params = [ '123', '0.123', '456.', '123.456' ])
def value(request):    
    return request.param

# value1_value2
@pytest.fixture(params = [ ('123', '234'), ('0.123', '0.234')  ])
def value1_value2(request):    
    return request.param

# A selection of SDK versions.
@pytest.fixture(params=['1.7.1.12', '1.8.0'])
def sdk(request):
    return request.param

# Modes.
@pytest.fixture(params=['performance', 'accuracy'])
def mode(request):
   return request.param 

# Timestamp.
@pytest.fixture(params=[ 'yes', 'no' ])
def timestamp(request):
    return request.param 

# scenario_device_ids - Scenario Device_ids
@pytest.fixture(params = [
    ( 'singlestream', 'device_ids'),
    ( 'multistream',  'device_ids'),
    ( 'offline',      'device_ids')])
def scenario_device_ids(request):
    return request.param 

# sut - A selection of sut
@pytest.fixture( params = [ 'q1_std_edge', 'q4_std_edge' ])
def sut(request):
    return request.param 

# scenario - A selection of scenarios.
@pytest.fixture( params = [
    'singlestream',
    'multistream',
])
def scenario(request):
    return request.param 

# scenario_target - A selection of scenarios and target latency flags.                
@pytest.fixture( params = [
    ( 'singlestream', 'target_latency'),
    ( 'singlestream', 'singlestream_target_latency'),
    ( 'multistream',  'target_latency'),
    ( 'multistream',  'multistream_target_latency'),
])
def scenario_target(request):
    return request.param 

# scenario_target1_target2 - A selection of scenarios and targets.                
@pytest.fixture( params = [
    ('singlestream', 'target_latency', 'singlestream_target_latency'),
    ('multistream',  'target_latency', 'multistream_target_latency'),
    ('singlestream', 'singlestream_target_latency', 'target_latency'),
    ('multistream',  'multistream_target_latency', 'target_latency'),
])
def scenario_target1_target2(request):
    return request.param 

 
# soc_reset - Test --soc_reset.
@pytest.fixture( params = [ 'yes', 'no' ])
def soc_reset(request):   
   return request.param              


# @pytest.fixture
# def model_fixture():
#     with open("./data/model.json", "r") as f:
#         return json.load(f)
    
# @pytest.fixture
# def captured_print(capsys):
#     print("hello")

# @pytest.fixture.capsys
# def cmdgen_capsys():
#     return ''

# @pytest.fixture
# def scenario_category():
#     with open("/home/laura/ck-qaic-dev-krai/test/test_cmdgen/data/scenario_category.json", "r") as f:
#         return json.load(f)
   
# @dataclass
# class ImplementationModel:
#    implementaton: str
#    model: str 
