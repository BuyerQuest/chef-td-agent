control 'td-agent-install' do
  impact 'high'
  title 'td-agent / fluent-package installation'
  desc 'Ensure td-agent or fluent-package is installed and running'

  conf_dir_name = 'fluent'
  service_name  = 'fluentd'
  package_name  = 'fluent-package'
  gem_binary    = '/usr/sbin/fluent-gem'

  if input('td_agent_version') == 4
    conf_dir_name = 'td-agent'
    service_name  = 'td-agent'
    package_name  = 'td-agent'
    gem_binary    = '/usr/sbin/td-agent-gem'
  end

  describe package(package_name) do
    it { should be_installed }
  end

  describe service(service_name) do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe file("/etc/#{conf_dir_name}") do
    it { should be_directory }
  end

  describe file("/etc/#{conf_dir_name}/#{service_name}.conf") do
    it { should be_file }
    its('mode') { should cmp '0644' }
  end

  describe file("/etc/#{conf_dir_name}/conf.d") do
    it { should be_directory }
    its('mode') { should cmp '0755' }
  end

  describe gem('fluent-plugin-gelf', gem_binary) do
    it { should be_installed }
  end
end
