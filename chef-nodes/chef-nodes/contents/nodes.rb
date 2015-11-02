#!/opt/chefdk/embedded/bin ruby
require 'json'
require 'rubygems'
require 'yaml'



opt_search_query     = ARGV[0]




class Node
  attr_accessor :node_name, :chef_environment, :host_name,:public_host_name,:os_family

  def initialize (node_name,chef_environment,host_name,public_host_name,os_family)
    @node_name = node_name
    @chef_environment = chef_environment
    @host_name = host_name
    @public_host_name = public_host_name
    @os_family =  os_family
  end

end





@nodes = Array.new

def set_node(a_node)
  @nodes << a_node

end



def get_nodes_as_hash

  get_nodes_as_hash = {}

  @nodes.each do |the_node|

    a_node_hash = {}

    a_node_hash["node_name"]= "#{the_node.node_name}"
    a_node_hash["host_name"]= "#{the_node.public_host_name}"  #using public_host_name because this example is based on an Amazon EC2 instance
    a_node_hash["tags"]= "#{the_node.os_family},dev"  # added "dev" to demonstrate tagging for this example
    a_node_hash["os_family"]= "#{the_node.os_family}"
    a_node_hash["enviroment"] = "dev"  #hardcoding this value to "dev" for this example

    get_nodes_as_hash["#{the_node.node_name}"]= a_node_hash

  end

  get_nodes_as_hash

end

nodes_raw_json = `knife search node "#{opt_search_query}" -F json`

nodes_raw_hash = JSON.parse(nodes_raw_json)
nodes_raw_array = nodes_raw_hash['rows']





nodes_raw_array.each do |node_raw|

  node_cooked = node_raw['automatic']
  node_cooked.merge! node_raw['default']
  node_cooked.merge! node_raw['normal']
  node_cooked['chef_environment'] = node_raw['chef_environment']
  node_cooked['id']=node_raw['automatic']['hostname']

  node_final = Node.new(node_raw['name'],node_raw['chef_environment'],node_raw['automatic']['hostname'],node_cooked['cloud']['public_hostname'],node_raw['automatic']['os'])
  set_node(node_final)




end


$stdout.write get_nodes_as_hash.to_yaml




