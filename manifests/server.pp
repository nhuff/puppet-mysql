class mysql::server(
$packages     = $mysql::params::server_packages,
$services     = $mysql::params::services,
$root_pass    = $mysql::params::root_pass,
$conf_file    = $mysql::params::conf_file,
$manage_dbs   = $mysql::params::manage_dbs,
$manage_users = $mysql::params::manage_users
) inherits mysql::params {
  $all_privileges = ['select', 'insert', 'update', 'delete',
    'create', 'drop', 'index',
    'alter', 'create temporary tables', 'lock tables', 'create view',
    'show view', 'create routine', 'alter routine', 'execute']


  package {$packages:
    ensure => 'latest',
  }

  service {$services:
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package[$packages],
  }
  
  exec{'mysql-set-root':
    command => "mysqladmin -u root password ${root_pass}",
    path    => '/usr/bin',
    creates => '/root/.my.cnf',
    require => Service['mysqld'],
    before  => File['/root/.my.cnf'],
  }

  file{'/root/.my.cnf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '600',
    content => "[mysql]\nuser=root\npassword=${root_pass}\n"
  }

  file{$conf_file:
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  #make sure these databases and users don't get purged.
  mysql_db{['mysql','information_schema']: ensure => present}
  mysql_user{['root@localhost','root@127.0.0.1']: 
    ensure   => present,
    password => $root_password,
  }

  if $manage_dbs {
    resources{'mysql_db': purge => true}
  }

  if $manage_users {
    resources{['mysql_user','mysql_grant']: purge => true}
  }

  Mysql::Server_param<| |> ~> Service[$services]
}
