# puppet manifest to setup new pi.

$new_user = 'ben'

$main_packages = [
  'tmux',
  'vim',
  'zsh',
  'stow',
  'git',
  'uptimed',
  'nftables',
  'unattended-upgrades',
  'toilet',
]

$purge_packages = [
  'iptables',
]

package { [ $main_packages, ]:
  ensure          => latest,
  install_options => [
    '--no-install-recommends',
  ],
}

package { [ $purge_packages, ]:
  ensure => 'purged',
}

user { $new_user:
  ensure => present,
  groups => [
    'users',
    'sudo',
    'adm',
  ]
  home   => '/home/ben',
  shell  => '/usr/bin/zsh',
  # password is 'changeme'
  passwd => Sensitive('$6$jk23iosd90sdjk23$7t5U.cW2VEAhgAExwlqlg0Yh6lEMLrMgQ5KL5LGO2N7.US.HoTj7oAUVErqhpm6iKa7PW7/oiKjsE04UrWstX/'),
}->
exec { 'force_passwd_expire':
  command => 'passwd -e $new_user',
  path    => '/usr/bin',
}
