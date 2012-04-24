class mysql::client (
$package = $mysql::params::client_packages,
$drivers = []
) inherits mysql::params {
    package { $package:
        ensure => installed,
    }

    define drivers() {
      $pack = getvar("mysql::params::${name}_driver")
      package{$pack: ensure => 'latest'}
    }

    mysql::client::drivers{$drivers:}
}
