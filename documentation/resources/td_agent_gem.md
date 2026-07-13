[back to resource list](https://github.com/treasure-data/chef-td-agent#resources)

# td_agent_gem

Install a Fluentd gem using the `fluent-gem` binary supplied by Fluent Package.

Introduced: v4.0.0

## Requires

- Chef Infra Client or Cinc Client >= 18

### Actions

- `:create` Installs the named gem
- `:delete` Removes the named gem

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `name` | String | name_property | Gem name |
| `version` | String | '' | Optional: Install a specific version, `x.y.z` format |

### Examples

```ruby
# Shortest form
td_agent_gem 'forest'

# install a specific version
td_agent_gem 'forest' do
  version '0.1.1'
end

# Be obnoxiously verbose
td_agent_gem 'Install forest output plugin' do
  name 'forest'
  version '0.1.1'
end
```

### Notes

See the `td_agent_plugin` resource to install a gem from a direct URL download.
