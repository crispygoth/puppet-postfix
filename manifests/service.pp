class postfix::service(
  $service_ensure = 'running',
) {
  exec { 'restart postfix after packages install':
    command     => regsubst($::postfix::params::restart_cmd, 'reload', 'restart'),
    refreshonly => true,
    subscribe   => Package['postfix'],
    require     => Class['postfix::files'],
  }
  service { 'postfix':
    ensure    => $service_ensure,
    enable    => true,
    hasstatus => true,
    restart   => $::postfix::params::restart_cmd,
  }
}
