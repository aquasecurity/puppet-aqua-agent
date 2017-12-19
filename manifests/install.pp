# == Class: aquaenforcer::install
class aquaenforcer::install inherits aquaenforcer {

  docker::run { 'aqua-agent':
    image                     => $aquaenforcer::aqua_image,
    remove_container_on_start => true,
    remove_volume_on_start    => true,
    remove_container_on_stop  => true,
    remove_volume_on_stop     => true,
    net                       => 'host',
    volumes                   => [
      '/var/run:/var/run',
      '/dev:/dev',
      '/opt/aquasec:/host/opt/aquasec:ro',
      '/opt/aquasec/tmp:/opt/aquasec/tmp',
      '/opt/aquasec/audit:/opt/aquasec/audit',
      '/proc:/host/proc:ro',
      '/sys:/host/sys:ro',
      '/etc:/host/etc:ro',
    ],
    env                       => [
      'SILENT=yes',
      "AQUA_TOKEN=$aquaenforcer::aqua_token",
      "AQUA_SERVER=$aquaenforcer::gateway_addr",
      "AQUA_NETWORK_CONTROL=$aquaenforcer::aqua_network",
      'AQUA_SERVICE_STOP=no',
      'RESTART_CONTAINERS=no',
      "AQUA_INSTALL_PATH=$aquaenforcer::aqua_install_path",
    ],
    restart_service           => true,
    privileged                => true,
    pull_on_start             => false,
    # This will completely remove agent upon stop, cleaning /opt/aquasec directory
    # before_stop     => '/opt/aquasec/uninstall.sh -q',
    extra_parameters          => [
      '--restart=always',
      '--pid=host',
      '--userns=host',
    ],
  }

  exec { 'wait_for_agent_startup':
    require => Service["docker-aqua-agent"],
    command => '/bin/bash -c "for i in {1..120}; do sleep 1 &&  docker version | grep -qi Aqua && break; done"',
    path    => "/usr/bin:/bin",
  }

}