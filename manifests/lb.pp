# The lb manifest is utilizing the $balancemembers variable that is defined in the init.pp file,
# and the different variables produced in the web.pp file.

define ao_website::lb(
  #Input variables: the balancemembers will contain our HTTP service resources
  $balancemembers,
){
  # Include the HAProxy class
  class { 'haproxy': }

  # The load balancer must listen on certain ports and IPs
  haproxy::listen { $::clientcert:
    ipaddress => '*',
    ports     => '80',
    mode      => 'http',
    options   => {
      'option'  => ['httplog'],
      'balance' => 'roundrobin',
    }
  }

  #Loop over each over the HTTP service resources and create a balance member resource of each of them.
  #The service resource contains all data for the balance members to be instantiated
  $balancemembers.each |$balancemember |{
    haproxy::balancermember { $balancemember['http_name']:
      server_names => $balancemember['http_name'],
      listening_service => $::clientcert,
      options => "check",
      ipaddresses => $balancemember['http_ip'],
      ports => $balancemember['http_port']
    }
  }
}
#Note: no consume or produce statements here.
