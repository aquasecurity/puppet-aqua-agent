# == Class: aquaenforcer::service
class aquaenforcer::service inherits aquaenforcer {

  service { 'docker-aqua-agent':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    start      => 'docker start aqua-agent',
    stop       => '/opt/aquasec/uninstall.sh -q'
  }

}