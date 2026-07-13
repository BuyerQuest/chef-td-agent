control 'td-agent-install' do
  impact 'high'
  title 'fluent-package installation'
  desc 'Ensure fluent-package is installed and running'

  conf_dir_name = 'fluent'
  service_name  = 'fluentd'
  package_name  = 'fluent-package'
  gem_binary    = '/usr/sbin/fluent-gem'
  service_user  = os.family == 'debian' ? '_fluentd' : 'fluentd'

  describe package(package_name) do
    it { should be_installed }
    its('version') { should match(/^#{input('td_agent_version')}\./) }
  end

  if input('td_agent_version') == 6
    lts_repository_package = os.family == 'debian' ? 'fluent-lts-apt-source' : 'fluent-lts-release'

    describe package(lts_repository_package) do
      it { should be_installed }
    end
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
    its('owner') { should eq service_user }
    its('mode') { should cmp '0755' }
  end

  describe gem('fluent-plugin-gelf', gem_binary) do
    it { should be_installed }
  end
end
