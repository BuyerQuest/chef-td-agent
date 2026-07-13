[back to resource list](https://github.com/treasure-data/chef-td-agent#resources)

# td_agent_install

Installs Fluent Package v5 or newer and creates the default configuration.

Introduced: v4.0.0

## Requires

- Chef Infra Client or Cinc Client >= 18

### Actions

- `:install` Installs Fluent Package from its repository
- `:configure` Creates default configuration and installs plugins
- `:remove` Removes Fluent Package and its repository

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `major_version` | String, Float, Integer | `node['td_agent']['version']` | Major version of Fluent Package to install (`5` or `6`) |
| `lts` | true, false | `node['td_agent']['lts']` | Install the LTS release instead of the current release |
| `template_source` | String | 'td-agent' | Cookbook to source template from |
| `default_config` | [true, false] | true | Set the default config in /etc/fluent/fluentd.conf |
| `in_forward` | Hash | {port: 24224, bind: '0.0.0.0',} | Port to listen for forwarded Fluentd messages |
| `in_http` | Hash | {port: 8888, bind: '0.0.0.0',} | Setup HTTP site for diagnostics |
| `api_key` | String | nil | Adds api key for td cloud analytics |
| `plugins` | [String, Hash, Array] | nil | Plugins to install, fluent-plugin- auto added to plugin name, Hash can be used to specify gem_package options as key value pairs |

### Examples

To install the latest Fluent Package v6 LTS release and set up the default configuration:

```ruby
fluent_package_install 'default' do
  action [:install, :configure]
end
```

To install, setup default configuration, and install plugins

```ruby
fluent_package_install 'default' do
  major_version 6
  plugins 'gelf'
  action [:install, :configure]
end
```
