#db.pp
# This is a define statement, followed by some variables that will be used by the manifest with values being stored in hiera
# (note values are not encrypted for this example in hiera, I highly recommend in any non-sandbox environment to use eyaml 
# in hiera to encrypt sensitive values). 
# The rest of the manifest is pretty self explanatory as we are configuring MySQL with a database and table. At the end of 
# the manifest is where we are producing the Sql service resource that will be consumed by our Http service resource in our next manifest.

define ao_website::db (
  $user         = hiera('ao_website::db_username'),
  $password     = hiera('ao_website::db_password'),
  $rootpassword = hiera('ao_website::root_password'),
  $host         = $::clientcert,
  $database     = $name,
  $port         = 3306
){
  #This file holds SQL statements to create database tables in MySQL
  file { '/tmp/mysql.sql':
    ensure  => file,
    content => "use $database; CREATE TABLE countdetail (Id int(11) NOT NULL AUTO_INCREMENT,  Section varchar(500) NOT NULL,  `Date` date NOT NULL,  IP varchar(50) DEFAULT NULL,  PRIMARY KEY (Id)) ENGINE=InnoDB  DEFAULT CHARSET=latin1;",
  }

  #Install a MySQL server and listen to all IP-addresses
  class { '::mysql::server':
    create_root_user        => true,
    root_password           => $rootpassword,
    remove_default_accounts => true,
    restart                 => true,
    override_options        => {
      mysqld => {
        bind-address => '0.0.0.0'
      },
    }
  }
        
  #Create a database and calling MySQL statement file.
  mysql::db { $name:
    user     => $user,
    password => $password,
    host     => "%",
    sql      => "/tmp/mysql.sql",
    grant    => ["ALL"]
  }
}

#Important part of the code: here we define our service resource and bind our variables to the attributes
Ao_website::Db produces Sql {
  user     => $user,
  password => $password,
  host     => $host,
  database => $database,
  port     => $port
}

