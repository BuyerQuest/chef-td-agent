default['td_agent']['version'] = 5
default['td_agent']['lts'] = true

case node['td_agent']['version'].to_i
when 4
  # v4 is td-agent
  default['td_agent']['conf_dir_name'] = 'td-agent'
  default['td_agent']['service_name'] = 'td-agent'
  default['td_agent']['package_name'] = 'td-agent'
  default['td_agent']['gem_binary'] = '/usr/sbin/td-agent-gem'
else # 5+
  # v5+ is fluent-package
  default['td_agent']['conf_dir_name'] = 'fluent'
  default['td_agent']['service_name'] = 'fluentd'
  default['td_agent']['package_name'] = 'fluent-package'
  default['td_agent']['gem_binary'] = '/usr/sbin/fluent-gem'
end
