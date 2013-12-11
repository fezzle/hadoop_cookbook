#
# Cookbook Name:: hadoop
# Recipe:: hive
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

include_recipe 'hadoop::repo'

package "hive" do
  action :install
end

hive_conf_dir = "/etc/hive/#{node['hive']['conf_dir']}"

directory hive_conf_dir do
  mode "0755"
  owner "root"
  group "root"
  action :create
  recursive true
end

# Setup hive-site.xml
if node['hive'].has_key? 'hive_site'
  myVars = { :options => node['hive']['hive_site'] }

  template "#{hive_conf_dir}/hive-site.xml" do
    source "generic-site.xml.erb"
    mode "0644"
    owner "hive"
    group "hive"
    action :create
    variables myVars
  end
end # End hive-site.xml

# Setup hive-env.sh
if node['hive'].has_key? 'hive_env'
  myVars = { :options => node['hive']['hive_env'] }

  template "#{hive_conf_dir}/hive-env.sh" do
    source "generic-env.sh.erb"
    mode "0755"
    owner "hive"
    group "hive"
    action :create
    variables myVars
  end
end # End hive-env.sh

# Update alternatives to point to our configuration
execute "update hive-conf alternatives" do
  command "update-alternatives --install /etc/hive/conf hive-conf /etc/hive/#{node['hive']['conf_dir']} 50"
  not_if "update-alternatives --display hive-conf | grep best | awk '{print $5}' | grep /etc/hive/#{node['hive']['conf_dir']}"
end
