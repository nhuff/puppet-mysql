class mysql::server($config_params = {},$root_pass='') {
    include mysql::client

	$all_privileges = ['select', 'insert', 'update', 'delete',
		'create', 'drop', 'index',
		'alter', 'create temporary tables', 'lock tables', 'create view',
		'show view', 'create routine', 'alter routine', 'execute']

	$p_keys = keys($config_params)
	$mysql_root = $root_pass

	resources {['mysql_db','mysql_user','mysql_grant']:
		purge => true,
	}

    package {"mysql-server":
        ensure => installed,
    }
/*
    file {"/etc/cron.daily/dumpdb":
        ensure => file,
        owner  => "root",
        group  => "root",
        mode   => "755",
        source => "puppet:///modules/mysql/dumpdb",
    }

    file {"/etc/cron.daily/mysql_save":
        ensure  => file,
        owner   => "root",
        group   => "root",
        mode    => "755",
        content => template("mysql/mysql_save.erb"),
    }

*/
    service {"mysqld":
        ensure    => running,
        enable    => true,
        hasstatus => true,
        require   => Package['mysql-server'],
    }
	
	file{'/usr/share/augeas/lenses/dist/mysql.aug':
		ensure => file,
		owner  => 'root',
		group  => 'root',
		mode   => '0644',
		source => 'puppet:///modules/mysql/mysql.aug',
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

	mysql::server_param{$p_keys: params => $config_params}	

	#make sure these databases and users don't get purged.
	mysql_db{['mysql','information_schema']: ensure => present}
	mysql_user{['root@localhost','root@127.0.0.1']: 
		ensure   => present,
		password => $root_password,
	}
}
