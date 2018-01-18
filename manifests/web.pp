# In our web component manifest we are setting up Apache and PHP but first we are declaring our variables with no value
# that will be defined at the bottom of the manifest by the consume Sql statement. There is also the produce Http 
# statement which the values will be used by our load balancer component. 
# NOTE I am deploying my different website components utilizing RPM packages I am storing on Gemfury in a YUM repository. 
# The YUM configuration is being defined in my hieradata common.yaml file for the environment.

define ao_website::web (
  $user,
  $password,
  $host,
  $database,
  $http_port = '8080',
){
  $website_version  =lookup('ao_website::version')
  $website_dns      =lookup('ao_website::dns')
  $counter_dns      =lookup('ao_website::counter_dns')
 
  notify{"This is ${name}":}

  #Require yum Gemfury repo
  require yum
        
  #Include apache
  class { 'apache':
    default_vhost => false,
    mpm_module    => 'prefork',
  }        
        
  apache::vhost { "$website_dns": 
    port          =>  "$http_port",
    docroot       => '/var/www/ao_website',
    default_vhost => true,
  }
        
  apache::vhost { "$counter_dns": 
    port    =>  "$http_port",
    docroot => '/var/www/html/counter',
  }
        
  #Include extra apache modules
  include '::apache::mod::php'

  class { '::mysql::bindings': php_enable => true, }
        
  file { 'index.html':
    ensure  => file,
    path    => '/var/www/ao_website/index.html',
    content => template('ao_website/index.html.erb'),
    require => Package['ao_website'],
  }
        
  file { 'configuration.php':
    ensure  => file,
    path    => '/var/www/html/counter/configuration.php',
    content => template('ao_website/configuration.php.erb'),
    require => Package['web_counter'],
  }
        
  #To clean Yum cache only when Puppet resources are modified
  exec { 'yum-clean-expire-cache':
    command     => '/usr/bin/yum clean expire-cache',
    refreshonly => true,
  }
        
  #Install web_counter package
  package { 'web_counter' :
    ensure  => latest,
    require => Exec['yum-clean-expire-cache'],
  }
        
  #Install ao_website package
  package { 'ao_website' :
    ensure  => "$website_version", 
    require => Exec['yum-clean-expire-cache'],
  }
        
  #Allow Apache through SELinux to Talk to MySQL
  selboolean { 'httpd_can_network_connect_db':
    value     => on,
    persistent => true,
  }
}

#Multiple resource statements here: we define our consume statement and the produce statement.

#Note: produce, NOT export
Ao_website::Web consumes Sql {
  username => $user,
  password => $password,
  host     => $host,
  database => $database,
  port     => $http_port
}

Ao_website::Web produces Http {
  http_name => $::clientcert,
  http_ip => $::ipaddress,
  http_port => $http_port
}
