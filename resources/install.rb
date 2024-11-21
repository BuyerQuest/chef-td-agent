# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
#
# Cookbok Name:: fluentv5
# Resource:: fluent_package_install
#
# Author:: Varis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource_name :fluent_package_install
 
description 'Installs Fluentd package v5 and creates default configuration'
 
property :major_version, String,
         name_property: true,
         description: 'Major version of Fluentd to install'
 
property :template_source, String,
         default: 'td-agent',
         description: 'Cookbook to source template from'
 
property :default_config, [true, false],
         default: true,
         description: 'Set default config in /etc/fluentd/fluentd.conf file'
 
property :in_forward, Hash,
         default: {
           port: 24224,
           bind: '0.0.0.0'
         },
         description: 'Port to listen for Fluentd forwarded messages'
 
property :in_http, Hash,
         default: {
           port: 8888,
           bind: '0.0.0.0'
         },
         description: 'Setup HTTP site for diagnostics'
 
property :api_key, String,
         description: 'Adds api key for Fluentd cloud analytics'
 
property :plugins, [String, Hash, Array],
         description: 'Plugins to install, fluent-plugin- auto added to plugin name'
 
action :install do
  description 'Installs Fluentd from repository'
 
  if platform_family?('debian')
    apt_repository 'fluent-package' do
      url "https://packages.treasuredata.com/#{new_resource.major_version}/#{node['platform']}/#{node['platform_version']}/fluentd"
      key 'https://packages.treasuredata.com/GPG-KEY-fluent-package'
    end
  else
    baseurl = case new_resource.major_version
              when nil, '1'
                "https://packages.treasuredata.com/amazon/2/$basearch"
              when '5'
                "https://packages.treasuredata.com/lts/5/amazon/2/$basearch"
              else
                "https://packages.treasuredata.com/#{new_resource.major_version}/amazon/2/$basearch"
              end
 
    yum_repository 'treasuredata' do
      description 'Treasuredate'
      baseurl baseurl
      gpgkey 'https://packages.treasuredata.com/GPG-KEY-fluent-package,https://packages.treasuredata.com/GPG-KEY-td-agent'
      action :create
    end
  end

  package 'fluent-package' do
    action :install
  end
 
  directory '/etc/fluent/conf.d' do
    owner 'fluentd'
    group 'fluentd'
    mode '0755'
  end
end
 
action :remove do
  description 'Removes Fluentd and repository'
 
  package 'fluent-package' do
    action :remove
  end
 
  directory '/etc/fluentd' do
    recursive true
    action :delete
  end
 
  if platform_family?('debian')
    apt_repository 'fluent-package' do
      action :remove
    end
  else
    yum_repository 'fluent-package' do
      action :remove
    end
  end
end
 
action :configure do
  description 'Creates default configuration and installs plugins'
 
  template '/etc/fluent/fluentd.conf' do
  cookbook new_resource.template_source
  source 'td-agent.conf.erb'
  variables(
      major_version: new_resource.major_version,
      default_config: new_resource.default_config,
      in_forward: new_resource.in_forward,
      in_http: new_resource.in_http,
      api_key: new_resource.api_key
    )
  notifies :reload, 'service[fluentd]', :delayed
end
 
plugins = Mash.new
  if new_resource.plugins.is_a?(String)
    plugins[new_resource.plugins] = { gem_binary: '/usr/sbin/fluent-gem' }
  elsif new_resource.plugins.is_a?(Array)
    new_resource.plugins.each do |plugin|
      plugins[plugin] = { gem_binary: '/usr/sbin/fluent-gem' }
    end
  else
    new_resource.plugins.each do |name, hash|
      hash['gem_binary'] ||= '/usr/sbin/fluent-gem'
      plugins[name] = hash
    end
  end
 
  plugins.each do |name, hash|
    gem_package "fluent-plugin-#{name}" do
      gem_binary hash['gem_binary']
      action :install
    end
  end
  service 'fluentd' do
    supports restart: true, reload: true, status: true
    action [:enable, :start]
  end
end
action_class do
  include ::TdAgent::Helpers
end

