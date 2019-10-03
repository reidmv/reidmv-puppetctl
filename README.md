# reidmv-puppetctl

This module provides control actions for Puppet related to adding, modifying,
or removing content deployed to a Puppet master.

This is a proof-of-concept which demonstrates using new speculative features of
r10k.

```
puppetctl::environment - Manage Puppet environments

USAGE:
bolt task run --nodes <node-name> puppetctl::environment action=<value> name=<value> options=<value> config=<value>

PARAMETERS:
- action: Enum[list,add,modify,remove]
    What action to take on a Puppet environment
- name: Optional[String]
    The name of the environment
- options: Optional[Hash]
    Environment options to add or modify
- config: Optional[String]
    Path to r10k yaml environment config file
```

```
puppetctl::module - Manage Puppet modules

USAGE:
bolt task run --nodes <node-name> puppetctl::module action=<value> environment=<value> name=<value> options=<value> config=<value>

PARAMETERS:
- action: Enum[list,add,modify,remove]
    What action to take on a Puppet module
- environment: String
    Which environment to act on
- name: Optional[String]
    The name of the module
- options: Optional[Variant[String,Hash]]
    Module options to add or modify
- config: Optional[String]
    Path to r10k yaml environment config file
```
