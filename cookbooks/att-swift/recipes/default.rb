#
# Cookbook Name:: att-swift
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

cookbook_file '/tmp/att-swift.gem' do
  source 'att-swift.gem'
  mode 0644
end

gem_package 'att-swift' do
  gem_binary node['gem_path']
  source '/tmp/att-swift.gem'
  version '>= 0'
end

