#
# Cookbook Name:: att-swift
# Recipe:: default
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

gem_package 'att-swift' do
  gem_binary node['gem_path']
  version '>= 0'
end

