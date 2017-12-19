# 'aquaenforcer' Puppet module to install Aqua Enforcer

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with aquaenforcer](#setup)
    * [What aquaenforcer affects](#what-aquaenforcer-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with aquaenforcer](#beginning-with-aquaenforcer)
1. [Usage - Configuration options](#usage)
1. [Reference - Module class reference.](#reference)
1. [Limitations - Minor implementation limitations](#limitations)
1. [Feedback - Guide for contributing to the module](#development)

## Description

This module installs the Aqua Enforcer agent as a container on Docker
hosts, via Puppet.

This uses garethr/docker module to install the agent container in
service mode and ensures it is running.

## Setup

### What aquaenforcer affects **OPTIONAL**

The Aqua Enforcer agent will be installed, using whatever configuration
is set according to the batch install token (which must be pre-created
on the Aqua console) and the passed parameters.


### Setup Requirements **OPTIONAL**

This module requires the garethr/docker module to be installed.

The Aqua Console and Aqua Gateway services must already be installed.
It is recommended to use a shared hostname or VIP for the target
Aqua Gateway service to ensure that the agent will always know which
Gateway cluster it is supposed to communicate with.

A Batch Install Token should exist on the Aqua Console before installing
the Enforcer.  If it does not exist, the Aqua Enforcer will not pull
configuration until the host has been approved in the Aqua Console via
the Hosts screen.

### Beginning with aquaenforcer

There are two required parameters that must be set.  These can be set via
Hiera, see hiera.yaml for hierarchy.  These parameters are the Aqua
Gateway address and the Aqua Enforcer's installation token value.

All other parameters are optional.  They are detailed in usage below.
The module simply needs to be included, eg `include aquaenforcer`.

## Usage


| Required parameters                    | Description                                                                                             |
|:-----------------------------|:--------------------------------------------------------------------------------------------------------|
| `aquaenforcer::gateway_addr` | Hostname or IP address, and port, for Aqua Gateway service.  Example: `aqua-gateway.mycompany.com:3622` |
|     `aquaenforcer::aqua_token`                         |     Batch install token value (created in advance on the Aqua Console                                                                                                    |

These parameters will default to typical values if they are not set.

| Optional Parameters | Default Value | Description |
|:--------------------|:--------------|:------------|
| `aquaenforcer::aqua_image`                    |  `aquasec/agent:2.6.3`              | Image name and tag (enforce change control by using your own registry)            |
| `aquaenforcer::aqua_network`                    | `0`              | Set 0 to disable Aqua network interception, 1 to enable.            |
| `aquaenforcer::aqua_install_path`                    | `/opt/aquasec`              |  Install path for Enforcer on the host, use default unless on GKE or directed by support.           |


## Example

As a clean example, the following will install the garethr/docker
prerequisite to a temporary puppet module path outside your existing
module base, then use this configuration to install the Aqua Enforcer on
the system.    This assumes the host is authenticated to registry defined
in the aqua_image variable (or that registry does not require it, eg, ECR).

Please use a test environment for initial testing to validate in your own
environment.

### Steps

First, create a Batch Install Token in the Aqua Console by browsing to
Hosts -> Batch Install -> Add Batch Install, and entering 'audit' into
the Installation Token field (Batch Name and Aqua Gateways are also
required fields but can be any valid value).

Next, on the host where you wish to test the installation, add the
following to `/etc/puppetlabs/code/environments/production/data/common.yaml`
(you could also set on specific node or other location in hierarchy).

```
 ---
aquaenforcer::aqua_image: registry.yourcompany.com/aquasec/agent:2.6.3
aquaenforcer::aqua_token: audit
aquaenforcer::gateway_addr: aqua-gateway.yourcompany.com:3622
```

Finally, run the following commands to pull this repo and apply the changes,
after reviewing the module configuration.

```
puppet module install garethr/docker --modulepath=/home/testuser/puppet/modules

git clone https://github.com/aquasecurity/puppet-aqua-agent.git
sudo ln -s /home/testuser/puppet-aqua-agent /home/testuser/puppet/modules/aquaenforcer
sudo puppet apply --modulepath=/home/testuser/puppet/modules  puppet-aqua-agent/examples/init.pp
```


The agent should be installed, you can check with commands like `sudo docker ps -a`
and `sudo slk status`, or by reviewing Hosts page in Aqua Console.


## Reference

The module classes are detailed below:

aquaenforcer
aquaenforcer::params
aquaenforcer::install
aquaenforcer::service

|   | Class reference |
|:--|:----------------|
|  aquaenforcer |             Inherits parameters and calls install class    |
|  aquaenforcer::params |  Defines default values and loads parameters from environment               |
| aquaenforcer::install  |   Uses garethr/docker to install Aqua Enforcer in service mode, calls service              |
|  aquaenforcer::service |  Configures service so Puppet ensures agent is always running.               |


## Limitations

Due to the nature of 'service' definition, full systemd unit file
parameters like ExecStartPost are not able to be set; when performing a
`systemctl start docker-aqua-agent`, this results in immediate return
while container is instantiating.   If you only have systemd OS then it
may be preferable to use systemd unit file instead with ERB to define a
custom ExecStartPost=- to check `docker version` output for 'Aqua' string
to know that Aqua Enforcer is started.   This is not an issue for the installation of the agent; a check is in
place to ensure installation is complete before returning.

If you want to perform a complete uninstall when stopping the Enforcer,
instead of simply stopping the agent, comment out the line in the install.pp here:

`# before_stop     => '/opt/aquasec/uninstall.sh -q',`


## Feedback

Please feel free to feed back any optimizations you may make.


