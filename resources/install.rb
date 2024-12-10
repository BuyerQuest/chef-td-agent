# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
#
# Cookbok Name:: td-agent
# Resource:: fluent_package_install
#
# Authors:
# Varis Devops Team - govaris.com
# Corey Hemminger <hemminger@hotmail.com>
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
#

resource_name :fluent_package_install
provides :fluent_package_install
provides :td_agent_install
unified_mode true

description 'Installs td-agent (v4) or fluent-package (v5+) and creates default configuration'

property :name, String,
          description: 'Name of the resource',
          name_property: true

property :major_version, [String, Float, Integer],
         description: 'Major version to install',
         default: node['td_agent']['version'],
         callbacks: {
           'Major version should be 4 or higher' => lambda { |major_version|
                                                      major_version.to_i >= 4
                                                    },
         }

property :lts, [true, false],
          default: node['td_agent']['lts'],
          description: 'Install LTS release instead of latest'

property :template_source, String,
         default: 'td-agent',
         description: 'Cookbook to source template from'

property :default_config, [true, false],
         default: true,
         description: 'Set default config in main conf file'

property :in_forward, Hash,
         default: {
           port: 24224,
           bind: '0.0.0.0',
         },
         description: 'Port to listen for td-agent forwarded messages'

property :in_http, Hash,
         default: {
           port: 8888,
           bind: '0.0.0.0',
         },
         description: 'Setup HTTP site for diagnostics'

property :api_key, String,
         description: 'Adds api key for td cloud analytics'

property :plugins, [String, Hash, Array],
         description: 'Plugins to install, fluent-plugin- auto added to plugin name, Hash can be used to specify gem_package options as key value pairs'

action :install do
  description 'Installs fluent-package or td-agent from repository'

  node.override['td_agent']['version'] = new_resource.major_version.to_s
  node.override['td_agent']['lts'] = new_resource.lts

  case node['td_agent']['version'].to_i
  when 4
    # v4 is td-agent
    node.override['td_agent']['conf_dir_name'] = 'td-agent'
    node.override['td_agent']['service_name'] = 'td-agent'
    node.override['td_agent']['package_name'] = 'td-agent'
    node.override['td_agent']['gem_binary'] = '/usr/sbin/td-agent-gem'

    case node['platform_family']
    when 'debian'
      apt_repository 'treasure-data' do
        uri "http://packages.treasuredata.com/#{new_resource.major_version}/#{node['platform']}/#{node['lsb']['codename']}/"
        components ['contrib']
        key 'https://packages.treasuredata.com/GPG-KEY-td-agent'
      end
    when 'rhel', 'amazon'
      yum_repository 'treasure-data' do
        description 'TreasureData'
        baseurl "http://packages.treasuredata.com/#{new_resource.major_version}/#{platform?('amazon') ? 'amazon' : 'redhat'}/#{node['platform_version'].to_i}/$basearch"
        gpgkey 'https://packages.treasuredata.com/GPG-KEY-td-agent'
      end
    end
  else # 5+
    # v5+ is fluent-package
    node.override['td_agent']['conf_dir_name'] = 'fluent'
    node.override['td_agent']['service_name'] = 'fluentd'
    node.override['td_agent']['package_name'] = 'fluent-package'
    node.override['td_agent']['gem_binary'] = '/usr/sbin/fluent-gem'

    case node['platform_family']
    when 'debian'
      node.override['td_agent']['repo_package_name'] = "fluent-#{node['td_agent']['lts'] ? 'lts-' : ''}apt-source"
      # Repo is distributed as a deb package
      package "https://packages.treasuredata.com/#{node['td_agent']['lts'] ? 'lts/' : ''}#{node['td_agent']['version']}/#{node['platform']}/#{node['lsb']['codename']}/pool/contrib/f/fluent-#{node['td_agent']['lts'] ? 'lts-' : ''}apt-source/fluent-#{node['td_agent']['lts'] ? 'lts-' : ''}apt-source_2023.7.29-1_all.deb"
    when 'rhel', 'amazon'
      yum_repository "fluent-package#{node['td_agent']['lts'] ? '-lts' : ''}" do
        description "Fluentd Project"
        baseurl "http://packages.treasuredata.com/#{node['td_agent']['lts'] ? 'lts/' : ''}#{node['td_agent']['version']}/#{platform?('amazon') ? 'amazon' : 'redhat'}/#{node['platform_version'].to_i}/$basearch"
        gpgkey %w(
          https://packages.treasuredata.com/GPG-KEY-td-agent
          https://packages.treasuredata.com/GPG-KEY-fluent-package
        )
      end
    end
  end

  package node['td_agent']['package_name']

  directory "/etc/#{node['td_agent']['conf_dir_name']}/conf.d" do
    owner node['td_agent']['service_name']
    group node['td_agent']['service_name']
    mode '0755'
  end
end

action :remove do
  description 'Removes td-agent and repository'

  package node['td_agent']['package_name'] do
    action :remove
  end

  directory "/etc/#{node['td_agent']['conf_dir_name']}" do
    recursive true
    action :delete
  end

  case node['platform_family']
  when 'debian'
    package node['td_agent']['repo_package_name'] do
      action :remove
    end
  when 'rhel', 'amazon'
    yum_repository "fluent-package#{node['td_agent']['lts'] ? '-lts' : ''}" do
      action :remove
    end
  end
end

action :configure do
  description 'Creates default configuration and installs plugins'

  template "/etc/#{node['td_agent']['conf_dir_name']}/#{node['td_agent']['service_name']}.conf" do
    cookbook new_resource.template_source
    source 'td-agent.conf.erb'
    variables(
        major_version: new_resource.major_version,
        default_config: new_resource.default_config,
        in_forward: new_resource.in_forward,
        in_http: new_resource.in_http,
        api_key: new_resource.api_key
      )
    notifies :reload, "service[#{node['td_agent']['service_name']}]", :delayed
  end

  plugins = Mash.new
  if new_resource.plugins.is_a?(String)
    plugins[new_resource.plugins] = { gem_binary: node['td_agent']['gem_binary'] }
  elsif new_resource.plugins.is_a?(Array)
    new_resource.plugins&.each do |plugin|
      plugins[plugin] = { gem_binary: node['td_agent']['gem_binary'] }
    end
  else
    new_resource.plugins&.each do |name, hash|
      hash['gem_binary'] ||= node['td_agent']['gem_binary']
      plugins[name] = hash
    end
  end
  plugins&.each do |name, hash|
    gem_package "fluent-plugin-#{name}" do
      hash&.each do |key, value|
        send(key, value)
      end
      notifies :restart, "service[#{node['td_agent']['service_name']}]", :delayed
    end
  end

  service node['td_agent']['service_name'] do
    supports restart: true, reload: true, status: true
    action [:enable, :start]
  end
end

action_class do
  include ::TdAgent::Helpers
end
