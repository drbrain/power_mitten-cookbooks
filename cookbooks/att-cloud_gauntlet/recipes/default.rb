#
# Cookbook Name:: att-cloud_gauntlet
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

cookbook_file '/tmp/att-cloud_gauntlet.gem' do
  source 'att-cloud_gauntlet.gem'
  mode 0644
end

bash 'remove att-cloud_gauntlet' do
  user 'root'

  code <<-CODE
#{node['gem_path']} uninstall att-cloud_gauntlet
  CODE
end

gem_package 'att-cloud_gauntlet' do
  gem_binary node['gem_path']
  source '/tmp/att-cloud_gauntlet.gem'
  version '>= 0'
  action :install
end

[
  ['checksummer',          ''],
  ['gauntlet_control',     ''],
  ['gauntlet_ring_server', ''],
  ['gem_dependencies',     ''],
  ['gem_downloader',       ''],
  ['rdocer',               ''],
  ['startup',              ''],
].each do |service, extra_args|
  template "/etc/init.d/#{service}" do
    source 'init.d/service.erb'
    mode 0755
    owner 'root'
    group 'root'

    variables(ruby_path: node['ruby_path'],
              prog: service, extra_args: extra_args)
  end
end

service 'startup' do
  supports restart: true, status: true
  action :enable
end

