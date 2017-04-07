class misomongo (
  $kernel_min   = undef,
  $kernel_max   = undef,
  $server_name  = "$::hostname",
  $admin_name   = 'mongoadmin', $admin_pswd = 'superSecret1',
  $user1_name   = 'mongouser', $user1_pswd = 'superSecret2',
  $db_port      = '27017',
  $db_name      = 'testdb',
) {
        
  package {
    
    ksh:
    ensure => [latest, installed],
    install_options => ['--nogpgcheck'];

    mongodb:
      ensure => [latest, installed],
      install_options => ['--nogpgcheck'];

    mongodb-server:
      ensure => [latest, installed],
      install_options => ['--nogpgcheck'];
  }

  service {
    mongod:
      require => [Package['mongodb'], Package['mongodb-server']],
      enable => true,
      ensure => running,
      flags => "";
  }

  file {
    '/etc/hosts':
      content => template('misomongo/hosts.erb'),
      owner   => root,
      group   => root,
      mode    => "0644";

    '/tmp/setup_mongodb':
      require => File['/etc/hosts'],
      ensure  => [file, present],
      source  => 'puppet:///modules/misomongo/setup_mongodb',
      mode    => "755",
      owner   => root;
  }
  notify { "$server_name": }
  notify { "$db_port": }
  notify { "$user1_name": }
  notify { "$user1_pswd": }
  notify { "$admin_name": }
  notify { "$admin_pswd": }
  notify { "$db_name": }
  
  exec {
    'setup':
      require => [Service['mongod'], File['/tmp/setup_mongodb']], 
      command => "/tmp/setup_mongodb -n ${server_name} -p $db_port -u ${user1_name}:${user1_pswd} -a ${admin_name}:${admin_pswd} -d ${db_name}";
  }
}
