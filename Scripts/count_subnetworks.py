#coding:utf-8
#!/usr/bin/env python

import os
import sys
__author__ = 'Ye Peng'
__email__ = 'pengye@genomics.cn'
__version__ = '0.1.0'
__date__ = 'April 24, 2018'

if len(sys.argv) < 2:
    sys.exit('''Usage: python %s getSubnetworks.py input_network_file [>output_file]
The input_network_file should have a header and contain tab-separated "source\ttarget\tstatus\t(other attrs)"''' % sys.argv[0])
if not os.path.exists(sys.argv[1]):
    sys.exit('ERROR: Input file %s was not found!' % sys.argv[1])

i_file = sys.argv[1]

def recordEdge(node1, node2, dict_list):
    if node1 in dict_list.keys():
        dict_list[node1].append(node2)
    else: 
        dict_list[node1] = [node2]
    if node2 in dict_list.keys():
        dict_list[node2].append(node1)
    else: 
        dict_list[node2] = [node1]
        
def loadNetwork(i_file):
    network_all = {}
    network_trimmed = {}
    with open(i_file) as i_f:
        for line in i_f.readlines()[1:]:
            source, target, status = line.strip().split('\t')[:3]
            recordEdge(source, target, network_all)
            if status != '1': recordEdge(source, target, network_trimmed)
    return network_all, network_trimmed


class subnetworks(object):
    
    def __init__(self, whole_network, max_iter=10000):
        self.whole_network = whole_network
        self.max_iter = max_iter
        self.trimmed_network = {}
        
    def trimTips(self, input_dict):
        import copy
        dict_ = copy.deepcopy(input_dict)
        to_remove = set()
        while (True in map(lambda x: len(x)==1, dict_.values())):
            for key, value in dict_.items():
                if len(value)==1 or (len(value)==2 and key in value):
                # only links with one node, or
                # links with one node and itself (self-loop)
                    del dict_[key]
                    to_remove.add(key)
            for key, value in  dict_.items():
                for x in value:
                    if x in to_remove:
                        dict_[key].remove(x)
        return dict_
    
    def trimNetwork(self):
        self.trimmed_network = self.trimTips(self.whole_network)

    def iterateNetwork(self, input_network, start):
        one_subnetwork = set([start])
        self.visited_nodes.add(start)
        path = [start]
        while(len(path)):
            node = path[-1]
            if (len([x for x in input_network[node] 
                            if x not in self.visited_nodes])):
                adj_node = [x for x in input_network[node] 
                            if x not in self.visited_nodes][0]
                one_subnetwork.add(adj_node)
                self.visited_nodes.add(adj_node)
                path.append(adj_node)
            else:
                node = path.pop()
        return len(one_subnetwork)
                
    def get_subnetworks(self, input_network_):
        self.visited_nodes = set()
        subnetwork_nodeCount = {}
        iteration = 1
        for start_ in input_network_.keys():
            if start_ not in self.visited_nodes:
                node_count = self.iterateNetwork(input_network_, start_)
                subnetwork_nodeCount[iteration] = {'nodeCount':node_count, 
                                                   'startingPoint':start_}
                iteration += 1
        return subnetwork_nodeCount

def main():
    '''
    Usage: python getSubnetworks.py input_network_file [>output_file]
    The input_network_file should have a header and contain tab-separated "source\ttarget\tstatus\t(other attrs)"
    ''' 
    ## load network
    network_all, network_noGreenEdges = loadNetwork(i_file)

    ## initiate a network
    test_network = subnetworks(network_noGreenEdges)

    ## trim tips
    test_network.trimNetwork()
    
    ## get subnetworks
    subnetwork_all = test_network.get_subnetworks(test_network.whole_network)
    subnetwork_trimmed = test_network.get_subnetworks(test_network.trimmed_network)
    
    print '#Stats'
    print 'Node count in the input network: %d' % len(test_network.whole_network.keys())
    print 'Node count in the trimmed network: %d' % len(test_network.trimmed_network.keys())
    print 'Subnetwork count in the input network: %d' % len(subnetwork_all.keys())
    print 'Subnetwork count in the trimmed network: %d' % len(subnetwork_trimmed.keys())
    
    print '\n#Detailed info'
    print 'Subnetworks in the input network:'
    print subnetwork_all
    print '\nSubnetworks in the trimmed network:'
    print subnetwork_trimmed

if __name__ == '__main__':
        main()
