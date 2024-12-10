name             'td-agent'
maintainer       'Varis DevOps Team'
license          'Apache-2.0'
description      'Installs/Configures fluent-package and td-agent'
version          '5.0.1'

chef_version     '>= 13'
issues_url       'https://github.com/buyerquest/chef-td-agent/issues'
source_url       'https://github.com/buyerquest/chef-td-agent'

%w(redhat centos amazon debian ubuntu).each do |os|
  supports os
end
