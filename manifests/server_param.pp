define mysql::server_param($value,$section='mysqld') {
  $conf  = $mysql::server::conf_file 
  $param = $name

  augeas{"mysql-$param":
    incl    => $conf,
    lens    => 'mysql.lns',
    context => "/files${conf}/target[. = '${section}']",
    changes => "set $param $value",
    notify  => Service['mysqld'],
    require => File[$conf],
  }
}
