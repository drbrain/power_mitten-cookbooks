#
# Cookbook Name:: rdoc
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

#cookbook_file '/tmp/rdoc.gem' do
#  source 'rdoc.gem'
#  mode 0644
#end
#
#execute 'install rdoc' do
#  command "#{node['gem_path']} install /tmp/rdoc.gem -q --no-rdoc --no-ri"
#end

gem_package 'rdoc' do
  version '>= 4'
  options '--force'
  gem_binary node['gem_path']

  action :upgrade
end

