define mysql::server_param($params) {
	$param = $name
	$value = $params[$name]

	augeas{"mysql-$param":
		context => '/files/etc/my.cnf/mysqld',
		changes => "set $param $value",
		notify  => Service['mysqld'],
		require => File['/usr/share/augeas/lenses/dist/mysql.aug']
	}
}
