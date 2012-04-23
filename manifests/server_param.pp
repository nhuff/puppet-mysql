define mysql::server_param($params) {
  $param = $name
  $value = $params[$name]

  augeas{"mysql-$param":
    context => '/files/etc/my.cnf/target[. = "mysqld"]',
    changes => "set $param $value",
    notify  => Service['mysqld'],
  }
}
