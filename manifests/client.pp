class mysql::client {
    package { "mysql":
        ensure => installed,
    }
}
