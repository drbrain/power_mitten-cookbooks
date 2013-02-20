#
# Cookbook Name:: RingyDingy
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

gem_package 'RingyDingy' do
  gem_binary node['gem_path']
  version '>= 1.3'
  action :upgrade
end

template '/etc/init.d/ring_server' do
  source 'init.d/service.erb'
  mode 0755
  owner 'root'
  group 'root'

  variables ruby_path: node['ruby_path'], prog: 'ring_server'
end

