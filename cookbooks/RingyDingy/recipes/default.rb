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

