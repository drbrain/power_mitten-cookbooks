#
# Cookbook Name:: node
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

script 'sync' do
  interpreter 'bash'
  code 'sync; sleep 1; sync'
end

