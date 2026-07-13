fluent_package_install 'default' do
  major_version node['td_agent']['version']
  lts node['td_agent']['lts']
  plugins node['td_agent']['plugins']
  action [:install, :configure]
end
