default['td_agent']['version'] = 6
default['td_agent']['lts'] = true
default['td_agent']['plugins'] = []

default['td_agent']['conf_dir_name'] = 'fluent'
default['td_agent']['service_name'] = 'fluentd'
default['td_agent']['service_user'] = platform_family?('debian') ? '_fluentd' : 'fluentd'
default['td_agent']['service_group'] = platform_family?('debian') ? '_fluentd' : 'fluentd'
default['td_agent']['package_name'] = 'fluent-package'
default['td_agent']['gem_binary'] = '/usr/sbin/fluent-gem'
