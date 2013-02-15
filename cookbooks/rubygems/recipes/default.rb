#
# Cookbook Name:: rubygems
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
cookbook_file '/tmp/rubygems-update.tar.gz' do
  source 'rubygems-1.8.25.tgz'
  mode 0644
end

ruby = File.join node['ruby_path'], 'bin/ruby'

execute 'Unpack rubygems-update' do
  cwd '/tmp'

  command 'tar xzf rubygems-update.tar.gz'
end

execute 'Update rubygems' do
  cwd '/tmp/rubygems-1.8.25'

  command "#{ruby} setup.rb --no-rdoc --no-ri"
end

