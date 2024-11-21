# InSpec test for recipe xe_aws_cloudwatch_agent::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe package('fluent-package') do
  it { should be_installed }
end

describe service('fluentd') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/fluent') do
  it { should be_directory }
end

describe file('/etc/fluent/fluentd.conf') do
  it { should be_file }
  its('mode') { should cmp '0644' }
end

describe file('/etc/fluent/conf.d') do
  it { should be_directory }
  its('mode') { should cmp '0755' }
end

describe gem('fluent-plugin-gelf', '/usr/sbin/fluent-gem') do
  it { should be_installed }
end
