define mysql::server_param($value) {
  $param = $name

  augeas{"mysql-$param":
    context => '/files/etc/my.cnf/target[. = "mysqld"]',
    changes => "set $param $value",
    notify  => Service['mysqld'],
  }
}
