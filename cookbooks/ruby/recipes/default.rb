#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

ruby_version = node['ruby_version']

ruby_build_ruby ruby_version

node.set['ruby_path'] =
  File.join node['ruby_build']['default_ruby_base_path'], ruby_version

node.set['gem_path'] = File.join node['ruby_path'], 'bin/gem'

