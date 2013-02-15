#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

node['ruby_build']['install_pkgs_cruby'] << 'libncurses5'
node['ruby_build']['install_pkgs_cruby'] << 'libncurses5-dev'

ruby_version = node['ruby_version']

ruby_build_ruby ruby_version

node['ruby_path'] =
  File.join node['ruby_build']['default_ruby_base_path'], ruby_version

node['gem_path'] = File.join node['ruby_path'], 'bin/gem'

