#
# Cookbook Name:: rubygems
# Recipe:: default
#
# Copyright 2013, AT&T
#
# All rights reserved - Do Not Redistribute
#

gem = node['gem_path']

execute 'Update rubygems' do
  command "#{gem} update --system"
end

