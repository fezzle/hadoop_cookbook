#
# Cookbook Name:: hadoop
# Recipe:: hbase_master
#
# Copyright (C) 2013 Continuuity, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'hadoop::hbase'
include_recipe 'hadoop::hbase_checkconfig'

package "hbase-master" do
  action :install
end

# HBase can use a local directory or an HDFS directory for its rootdir...
# if HDFS, create execute block with action :nothing
# else create the local directory when file://
if (node['hbase']['hbase_site']['hbase.rootdir'] =~ /^\/|^hdfs:\/\//i && node['hbase']['hbase_site']['hbase.cluster.distributed'].to_b)
  execute 'hbase-hdfs-rootdir' do
    command "hdfs dfs -mkdir -p #{node['hbase']['hbase_site']['hbase.rootdir']} && hdfs dfs -chown hbase #{node['hbase']['hbase_site']['hbase.rootdir']}"
    timeout 300
    user 'hdfs'
    group 'hdfs'
    not_if "hdfs dfs -test -d #{node['hbase']['hbase_site']['hbase.rootdir']}", :user => 'hdfs'
    action :nothing
  end
else # Assume hbase.rootdir starts with file://
  directory node['hbase']['hbase_site']['hbase.rootdir'].gsub('file://', '') do
    owner 'hbase'
    group 'hbase'
    mode '0700'
    action :create
    recursive true
  end
end

service "hbase-master" do
  supports [ :restart => true, :reload => false, :status => true ]
  action :nothing
end
