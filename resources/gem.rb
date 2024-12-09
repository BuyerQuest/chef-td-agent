# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
#
# Cookbok Name:: td-agent
# Resource:: td_agent_plugin
#
# Author:: Corey Hemminger <hemminger@hotmail.com>
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

resource_name :fluent_gem
provides :fluent_gem
provides :td_agent_gem

description 'Installs a gem for fluent-package'

unified_mode true

property :name, String,
         name_property: true,
         description: 'Name of plugin'

property :version, String,
         default: "''",
         description: 'Specific version to install'

action :create do
  description 'Install fluent-package gem'

  execute 'fluent-gem' do
    command "#{node['td_agent']['gem_binary']} install #{new_resource.name} -v #{new_resource.version}"
  end
end

action :delete do
  description 'Removes fluent-package gem'

  execute 'fluent-gem' do
    command "#{node['td_agent']['gem_binary']} uninstall #{new_resource.name} -v #{new_resource.version}"
  end
end

action_class do
  def td_plugin_name
    "fluent-plugin-#{new_resource.package_name}"
  end

  def major
    unless @major
      version = node["td_agent"]["version"]
      @major = version.nil? ? nil : version.to_s.split('.').first
    end
    @major
  end
end
