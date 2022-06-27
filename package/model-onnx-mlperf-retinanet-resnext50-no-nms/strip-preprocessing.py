import onnx
import sys

model = onnx.load(sys.argv[1])

input_name = [n.name for n in model.graph.input][0]

nodes_til_conv = []

for n in model.graph.node:
    if n.name == 'Conv_22':
        conv_node = n
        break
    else:
        nodes_til_conv.append(n)

conv_node.input[0] = input_name

new_nodes = []

for n in model.graph.node:
    if n not in nodes_til_conv:
        new_nodes.append(n)

del model.graph.node[:]

model.graph.node.MergeFrom(new_nodes)
onnx.checker.check_model(model)

onnx.save(model, sys.argv[2])