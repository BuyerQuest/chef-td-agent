# td-agent

Install and configure fluent-package on Amazon, Red Hat, Ubuntu, or Debian Linux.

## DESCRIPTION

[Chef](https://www.chef.io/chef/) cookbook for Fluent Package. Fluent Package release information is available in the [Fluentd documentation](https://docs.fluentd.org/installation/install-fluent-package).

This cookbook supports Fluent Package v5 and newer. Version 6 LTS is the default.

Include `td-agent::default` to install and configure the latest Fluent Package v6 LTS release. Optional Fluentd plugins can be supplied with `node['td_agent']['plugins']`.

Or use the Resources provided below instead.

### Chef

- Requires Chef Infra Client or Cinc Client 18 or newer.
- Tested with Cinc Client 18 and 19.

## Resources

- [td_agent_filter](./documentation/resources/td_agent_filter.md)
- [td_agent_install](./documentation/resources/td_agent_install.md)
- [td_agent_match](./documentation/resources/td_agent_match.md)
- [td_agent_plugin](./documentation/resources/td_agent_plugin.md)
- [td_agent_source](./documentation/resources/td_agent_source.md)
- [td_agent_sysctl_optimizations](./documentation/resources/td_agent_sysctl_optimizations.md)

## License

Copyright 2014-today Treasure Data, Inc.
Copyright 2022-2024 Varis, Inc.

The code is licensed under the Apache License 2.0 (see  LICENSE for details).
