#
# Cookbook Name:: RingyDingy
# Recipe:: enable_rdocer
#
# Copyright 2012, AT&T
#
# All rights reserved - Do Not Redistribute
#

service 'ring_server' do
  supports restart: true, status: true
  action :start
end

