#
# Cookbook Name:: power_mitten
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

cookbook_file '/tmp/power_mitten.gem' do
  source 'power_mitten.gem'
  mode 0644
end

bash 'remove power_mitten' do
  user 'root'

  code <<-CODE
#{node['gem_path']} uninstall power_mitten
  CODE
end

gem_package 'power_mitten' do
  gem_binary node['gem_path']
  source '/tmp/power_mitten.gem'
  version '>= 0'
  action :install
end

template "/etc/init.d/mitten_startup" do
  source 'init.d/service.erb'
  mode 0755
  owner 'root'
  group 'root'

  variables(ruby_path: node['ruby_path'],
            prog: 'mitten', extra_args: 'startup')
end

service 'mitten_startup' do
  supports restart: true, status: true
  action :enable
end

