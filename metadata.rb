name             'td-agent'
maintainer       'BuyerQuest DevOps Team'
license          'Apache-2.0'
description      'Installs and configures fluent-package'
version          '6.0.0'

chef_version     '>= 18'
issues_url       'https://github.com/buyerquest/chef-td-agent/issues'
source_url       'https://github.com/buyerquest/chef-td-agent'

%w(redhat centos amazon debian ubuntu).each do |os|
  supports os
end
