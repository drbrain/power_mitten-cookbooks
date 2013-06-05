#
# Cookbook Name:: control
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

template '/home/ubuntu/.power_mitten' do
  source 'dot_power_mitten.erb'

  owner 'ubuntu'
  group 'ubuntu'
  mode 0700

  variables \
    swift_uri:      node['credentials']['swift_uri'],
    swift_username: node['credentials']['swift_username'],
    swift_key:      node['credentials']['swift_key'],

    openstack_api_key:  node['credentials']['openstack_api_key'],
    openstack_auth_url: node['credentials']['openstack_auth_url'],
    openstack_tenant:   node['credentials']['openstack_tenant'],
    openstack_username: node['credentials']['openstack_username'],

    extra: node['extra_configuration']
end

