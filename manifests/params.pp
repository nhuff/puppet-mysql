class mysql::params {
  $root_pass  = ''
  $manage_dbs = false
  $manage_users = false
  case $::osfamily {
    'redhat': {
      $server_packages = 'mysql-server'
      $client_packages = 'mysql'
      $services        = 'mysqld'
    }
    default: {
      crit("OS family '$::osfamily' not currently supported")
    }
  }
}
