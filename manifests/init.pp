# Class: aquaenforcer
# ===========================
#
# Installs the Aqua Enforcer agent container.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `aqua_image`
# The name of the image and tag for the agent
# e.g. "aquasec/agent:2.6.3"
#
# * `gateway_addr`
# IP Address (or hostname) and port of the Aqua Gateway service
# e.g. "aqua-gateway.mycompany.com:3622"
#
# * `aqua_token`
# The batch install token value to use with the agent, this muyst pre-exist on Aqua console.
# e.g. "audit"
#
# * `aqua_network`
# Network enforcement mode for the agent.  0 to disable (default), 1 to enable.
# e.g. "0"
#
# * `aqua_install_path`
# (Optional) Host path for Aqua Enforcer files..  Useful for read-only filesystems such as GKE.   If
# this is not set then default '/opt/aquasec' is used.
# e.g. "/opt/aquasec"
#
#
# Authors
# -------
#
# Aqua Security <support@aquasec.com>
#
# Copyright
# ---------
#
# Copyright 2017 Aqua Security, unless otherwise noted.
#

class aquaenforcer (
  $aqua_image        = $aquaenforcer::aqua_image,
  $gateway_addr      = $aquaenforcer::gateway_addr,
  $aqua_token        = $aquaenforcer::aqua_token,
  $aqua_network      = $aquaenforcer::aqua_network,
  $aqua_install_path = $aquaenforcer::aqua_install_path,
) inherits ::aquaenforcer::params {
  validate_legacy(String, 'validate_string', $aqua_token)
  validate_legacy(String, 'validate_string', $gateway_addr)

  include aquaenforcer::install
}
