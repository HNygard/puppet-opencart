

class opencart (
	$opencart_home = '/var/opencart/',
	$apache_domain = 'www.example.com',
	$apache_serveradmin = 'webmaster@example.com',
	$apache_serveraliases = ['example.com', ],
	$mysql_user = 'opencart',
	$mysql_password = 'opencart',
	$opencart_database = 'opencart'
) {
	##########################
	##### OPENCART SETUP #####
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

	file { "${opencart_home}docroot/":
		path      => "${opencart_home}docroot/",
		recurse   => true,
		source    => 'puppet:///modules/opencart/opencart/upload/',
		require   => File['opencart_home']
	}

	file { [
		"${opencart_home}docroot/system/cache",
		"${opencart_home}docroot/system/logs",
#		"${opencart_home}docroot/system/download",
		"${opencart_home}docroot/download",
		"${opencart_home}docroot/image",
		"${opencart_home}docroot/image/cache",
		"${opencart_home}docroot/image/data",
	]:
		ensure    => directory,
		mode      => 0777,
		require   => File["${opencart_home}docroot/"]
	}
	
	# Config files created by installer
	file { "${opencart_home}docroot/config.php":
		mode      => 0777,
		require   => File["${opencart_home}docroot/"],
	#	content   => template('opencart/config.php.erb')
		source    => 'puppet:///modules/opencart/opencart/upload/config-dist.php',
	}
	file { "${opencart_home}docroot/admin/config.php":
		mode      => 0777,
		require   => File["${opencart_home}docroot/"],
	#	content   => template('opencart/config-admin.php.erb')
		source    => 'puppet:///modules/opencart/opencart/upload/admin/config-dist.php',
	}

	# Delete install directory
	#file { "${opencart_home}docroot/install":
	#	ensure    => absent,		
	#	require   => File["${opencart_home}docroot/"],
	#}

	##################
	##### APACHE #####
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

	#################
	##### MYSQL #####
	class { 'mysql': }
	class { 'mysql::php': }
	class { 'mysql::server':
		config_hash => { 'root_password' => 'foo' }
	}
	mysql::db { $opencart_database:
		user     => $mysql_user,
		password => $mysql_password,
		host     => 'localhost',
		grant    => ['all'],
	}

	###############
	##### PHP #####
	class { 'php::extension::gd':
		ensure   => present,
		provider => 'apt',
		notify   => service['httpd']
	}
	class { 'php::extension::curl':
		ensure   => present,
		provider => 'apt',
		notify   => service['httpd']
	}
	class { 'php::extension::mcrypt':
		ensure   => present,
		provider => 'apt',
		notify   => service['httpd']
	}
}


