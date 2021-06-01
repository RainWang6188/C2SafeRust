from anytree import Node, RenderTree, NodeMixin
from anytree.exporter import DotExporter
import re

root_node = []
recorded_node = []

class DependencyNode(NodeMixin):
    def __init__(self, name, type, parent=None, children=None):
        self.name = name
        self.type = type
        self.parent = parent
        if children:
            self.children = children

def add_node(name, type_val, parent_name=None, isRoot=0):  
    p = None
    if isRoot == 0:
        for node in recorded_node:
            if node.name == parent_name:
                p = node
    
    if p == None and isRoot == 0:
        print("Error Occured: cannot find parent node when adding nonroot node!")
        exit(-1)
    else:
        new_node = DependencyNode(name, type_val, parent=p)

    if isRoot == 1:
        root_node.append(new_node)
    recorded_node.append(new_node)


FILE_DIR = './uaf.ll.txt'

ir_file = open(FILE_DIR, 'r')
line_count = 0

flag = 0

for line in ir_file:
    line_count += 1
    if re.search('@main()', line):
        flag = 1
        continue
    if flag == 0:
        continue
    # case1: 'alloca' -> root node
    if re.search('alloca', line): 
        assign_index_range = re.search(' = alloca ', line).span()
        temp_index_range = re.search('%', line[:assign_index_range[0]]).span()
        left_operand = line[temp_index_range[0]: assign_index_range[0]]
        
        align_index_range = re.search(', align', line).span()
        type_val = line[assign_index_range[1]: align_index_range[0]]

        add_node(left_operand, type_val, isRoot=1)
    # case2: '@malloc' ->  root node
    elif re.search('call .* @malloc', line):
        assign_index_range = re.search(' = call noalias i8\* @malloc', line).span()
        temp_index_range = re.search("%", line[:assign_index_range[0]]).span()
        left_operand = line[temp_index_range[0]: assign_index_range[0]]

        add_node(left_operand, 'i8*', isRoot=1)
    # case3: 'bitcast' -> (p=right_operand, c=left_operand(type changed)) 
    elif re.search('bitcast', line):
        assign_index_range = re.search(' = bitcast ', line).span()
        temp_index_range = re.search('%', line[: assign_index_range[0]]).span()
        left_operand = line[temp_index_range[0]: assign_index_range[0]]

        temp_index_range = re.search('%[0-9a-zA-Z]* to', line).span()
        right_operand = line[temp_index_range[0]: temp_index_range[1]-3]

        type_val = line[temp_index_range[1]+1:-1]

        #print("left_operand = {}, type_val = {}, right_operand={}".format(left_operand, type_val, right_operand))

        add_node(left_operand, type_val, right_operand, 0)
    # case4: 'load' -> (p=right_operand, c=left_operand)
    elif re.search('load', line):
        assign_index_range = re.search(' = load ', line).span()
        temp_index_range = re.search('%', line).span()
        left_operand = line[temp_index_range[0]: assign_index_range[0]]

        temp_index_range = re.search(',', line).span()
        type_val = line[assign_index_range[1]: temp_index_range[0]]

        temp_index_range = re.search('%[_a-zA-Z][_0-9a-zA-Z]*,', line).span()
        right_operand = line[temp_index_range[0]: temp_index_range[1]-1]
        # print('line={}'.format(line_count))
        # print("left_operand = {}, type_val = {}, right_operand={}".format(left_operand, type_val, right_operand))
        add_node(left_operand, type_val, right_operand, 0)
    # case5: 'getelementptr' -> 
    elif re.search('getelementptr', line):
        assign_index_range = re.search(' = getelementptr inbounds ', line).span()
        temp_index_range = re.search('%', line).span()
        left_operand = line[temp_index_range[0]: assign_index_range[0]]

        type_val = 'element ptr'

        temp_index_range = re.search('%[0-9a-zA-Z]*,', line).span()
        right_operand = line[temp_index_range[0]: temp_index_range[1]-1]

        add_node(left_operand, type_val, right_operand, 1)
    # other cases: 'store' | '^call' | 'ret' ...
    else: 
        continue
ir_file.close()

for root in root_node:
    #[bug]
    #DotExporter(root).to_picture(root.name + ".png")
    
    # for line in DotExporter(root):
    #     print(line)
    for pre, fill, node in RenderTree(root):
        treestr = u"%s%s" % (pre, node.name)
        print(treestr.ljust(10), node.type)
