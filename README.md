# rundeck_chef_nodes
A ruby implementation to allow Rundeck to retrieve Chef nodes as a Rundeck resource model source

## Background

Rundeck uses a resource model concept that allows for projects and jobs to discover nodes and their definitions from external systems. The Rundeck resource model source allows you to write a plugin to integrate with an external system. 

"rundeck_chef_nodes" is a ruby based script model source plugin.

The following is a high level description of how it works:



1. Rundeck runs a ruby called nodes.rb
2. nodes.rb uses Chef search to discover nodes based upon a search_query that is passed into the nodes.rb script by Rundeck
3. The nodes.rb script populates a ruby hash of nodes and returns the results as yaml
4. Rundeck receives the result and provides the list of nodes, with their attributes, as resources to be used within a project
5. The rundeck job associated with the project that contains the "ChefNodes" resource model source plugin can use the list of nodes ( attributes and tags) returned by the script execution as remote nodes to dispatch commands




## Prerequisites

**Base Assumptions**

1. You are using a linux instance ( this example use Centos 6.x)
2. Your linux instance can connect to the internet
3. Your linux instance has ssh access to github

**Rundeck installed and working**

1. Install rundeck ( This example uses 2.5.3-1 ) http://rundeck.org/docs/administration/installation.html
2. Validate rundeck is working

**chefdk and knife.rb installed, configured and validated**

1. Install chefdk ( This example uses Chef Development Kits 0.4.0 )
2. Create a .chef subdirectory under the /var/lib/rundeck subdirectory
3. Within the .chef subdirectory create your knife.rb file and deploy the required pem files and trusted_certs to support the knife.rb.
4. Make sure rundeck is the owner of your .chef subdirectory and all constructs within the .chef subdirecory
5. Make chefdk your working ruby environment by modifying the .bash_profile of the rundeck user within the /var/lib/rundeck subdirectory. Add eval "$(chef shell-init bash)" to the rundeck .bash_profile
5. Validate chef by running the following commands on the linux instance where you have installed rundeck and chefdk:

Switch to the rundeck user:

    $ su - rundeck
    

Use knife to list nodes ( this validates your knife.rb is setup correctly - you should get a list of nodes from your chef environment) :

    $ knife node list

Determine you are using chefdk - you should receive a value of opt/chefdk/embedded/ruby:

	$ which ruby


    






## Installation of the rundeck_chef_nodes plugin

ssh into the linux instance and switch to the rundeck user

Switch to rundeck user:

    $ su - rundeck
    
Ensure you are in the /var/lib/rundeck subdirectory:

	$ pwd
    /var/lib/rundeck
    
    
git clone the rundeck_chef_nodes repo:

	$ git clone git@github.com:devopulence/rundeck_chef_nodes.git
    
chown the rundeck_chef_nodes subdirectory ( if you used a different user to clone the repo)

	$ chown -R rundeck.rundeck rundeck_chef_nodes
    
change directory into rundeck_chef_nodes ( make sure you are the rundeck user for remainder of tasks)

	$ cd rundeck_chef_nodes
    
run bundler to ensure gemfiles are installed

	$ bundle install
    
change directory into chef-nodes

    $ cd chef-nodes
    
export the rundeck base

    $ export RDECK_BASE=/var/lib/rundeck
    
run make install to build and install the plugin (

	$  make install
    zip -r chef-nodes.zip chef-nodes
  	adding: chef-nodes/ (stored 0%)
  	adding: chef-nodes/plugin.yaml (deflated 45%)
  	adding: chef-nodes/contents/ (stored 0%)
  	adding: chef-nodes/contents/nodes.rb (deflated 63%)
		cp chef-nodes.zip /var/lib/rundeck/libext


    
validate the chef-nodes.zip exists in the /var/lib/rundeck/libext subdirectory

    $ cd /var/lib/rundeck/libext
    $ ls | grep chef-nodes
    $ chef-nodes.zip

## Usage

At this point the rundeck_chef_nodes plugin is installed.



The following section demonstrates how to use the plugin within a project/job

**Add the ChefNodes plugin as a source to a Rundeck project**

1. Click the "configure" button for an existing project
2. Click the "simple configureation" button to modify using the simple configuration
3. The first section is the "Resource Model Source" section
4. At the bottom of the section click the "Add Source" button
5. Locate the ChefNodes source and click the + (plus sign), this will add the ChefNodes Script Plugin to the section.
6. You will notice the plugin is added and a "Search Query" field appears. The "Search Query" is a field where you can specify a chef search query that you would like to be used as part of the plugin. For example you can use a wild card like "name:*.whatever.com" without the quotes where whatever.com is the domain name of your servers.
7. Click the "save" button within the plugin panel to save the plugin
8. Click the "save" button at the bottom of the project to save the project

**Use the plugin within a Rundeck job**

1. Edit a rundeck job within the project or create a new job within the project where you just added the ChefNodes Script Plugin
2. Scroll down to the Nodes section
4. Click the "Dispatch to Nodes" radio button
5. Click the Filter down arrow and click "Show all Nodes". You should see all the nodes in the matched nodes section below the filter.
6. You can add a filter to refine the matched nodes to a subset of your choice.  Example:  name:server1.whatever.com or tags:dev
7. Save the job and you should be good to go




## Authors
Created and maintained by John D'Esposito - john.desposito@devopulence.com

