

class opencart (
	opencart_home = '/var/opencart/',
	apache_domain = 'www.example.com',
	apache_serveradmin = 'webmaster@example.com',
	apache_serveraliases = ['example.com', ]
) {
	file { 'opencart_home':
		path       => $opencart_home,
		ensure     => directory
		#owner      => $gerrit_uid,
		#group      => $gerrit_gid,
		#require    => [
		#	User[$gerrit_user],
		#	Group[$gerrit_group],
		#]
	}

	class {'apache':  }
	class {'apache::mod::php': }
	apache::vhost { $apache_domain:
		priority        => '10',
		vhost_name      => '*',
		port            => '80',
		docroot         => "${opencart_home}docroot/",
		logroot         => "${opencart_home}logroot/",
		serveradmin     => $apache_serveradmin,
		serveraliases   => $apache_serveraliases,
		require  => File['opencart_home']
	}

	file { "${opencart_home}docroot/index.html":
		content => 'test',
		ensure => present,
	}
}


