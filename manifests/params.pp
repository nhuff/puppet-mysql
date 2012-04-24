class mysql::params {
  $root_pass  = ''
  $manage_dbs = false
  $manage_users = false
  case $::osfamily {
    'redhat': {
      $server_packages = 'mysql-server'
      $client_packages = 'mysql'
      $services        = 'mysqld'
      $conf_file       = '/etc/my.cnf'
      $php_driver      = 'php-mysql'
      $python_driver   = 'MySQL-python'
      $python27_driver = 'MySQL-python27'
      $ruby_driver     = 'ruby-mysql'
      $perl_driver     = 'perl-DBD-MySQL'
    }
    default: {
      crit("OS family '$::osfamily' not currently supported")
    }
  }
}
