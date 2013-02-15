#
# Cookbook Name:: ssh_key
# Recipe:: default
#
# Copyright 2012, ATT
#
# All rights reserved - Do Not Redistribute
#

directory '/home/ubuntu/.ssh' do
  owner 'ubuntu'
  group 'ubuntu'
  mode 0700
end

file '/home/ubuntu/.ssh/authorized_keys' do
  action :create_if_missing

  owner 'ubuntu'
  group 'ubuntu'
  mode  0600

  content File.read '/root/.ssh/authorized_keys'

  only_if '[ -e /root/.ssh/authorized_keys ]'
end

