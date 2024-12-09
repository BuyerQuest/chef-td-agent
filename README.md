# td-agent

Install and configure td-agent or fluent-package on Amazon, Redhat, or Debian Linux.

## DESCRIPTION

[Chef](https://www.chef.io/chef/) cookbook for td-agent (Treasure Data Agent). The release log of td-agent is available [here](https://www.fluentd.org/blog/).

NOTE: td-agent is open-sourced as the [Fluentd project](http://github.com/fluent/). If you want to use a stable version of Fluentd, using this cookbook is recommended.

### Chef

- Might work with Chef 13.
- Chef >= 14 if using td_agent_sysctl_optimizations resource
- Tested with Cinc 18.

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

