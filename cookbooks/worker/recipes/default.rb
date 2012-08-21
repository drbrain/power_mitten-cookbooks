#
# Cookbook Name:: worker
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

ruby_version = node['worker']['ruby_version']

ruby_build_ruby ruby_version

ruby_path =
  File.join node['ruby_build']['default_ruby_base_path'], ruby_version

gem_package 'rdoc' do
  gem_binary File.join(ruby_path, 'bin/gem')
end

