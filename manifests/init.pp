# @summary Installs and configure vsftpd
#
# Please see man vsftpd.conf(5) for configuration option (no i am not going to list ~130 options here)
#
# @example
#   include vsftpd
class vsftpd (
  $config,
  Optionnal $cert_content,
  Optionnal $key_content,
  Optionnal $users,
  Optionnal $salt,
){

  case $facts['os']['family'] {
    default:  { fail('OS Not supported') }
    'RedHat': {
      $config_file = '/etc/vsftpd/vsftpd.conf'
      service { 'vsftpd':
        require => Package['vsftpd'],
        enable  => true,
      }
    }
    'Debian': {
      $config_file = '/etc/vsftpd.conf'
    }
  }

  package { 'vsftpd':
    ensure => present,
  }

  package {'unix_crypt':
    ensure   => present,
    provider => gem,
  }

  file { $config_file:
    ensure  => present,
    content => $config.map |$key,$value| { $key=$value },
    require => Package['vsftpd'],
  }

  if ($cert_content and $key_content and $config['rsa_cert_file'] and $config['rsa_private_key_file']) {
    file { $config['rsa_cert_file']:
      ensure  => present,
      content => $cert_content,
      require => Package['vsftpd'],
    }
    file { $config['rsa_private_key_file']:
      ensure  => present,
      content => $key_content,
      require => Package['vsftpd'],
    }
  }

  if $users and $salt {
    file { '/etc/vsftpd/vsftp-users':
      ensure  => present,
      content => $users.map |$key,$value| { $key + ':' + passwd($value, $salt) },
      require => Package['vsftpd'],
    }
  }
}
