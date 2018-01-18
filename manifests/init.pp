#init.pp
# In the init.pp file we are declaring our application "ao_website" with our different components db, web, and lb. 
# In order to create multiple web and load balancer servers we are using the Ruby map array method to iterate X 
# number of times to create Http and Lb service resources with a unique name and store it in the respective $webs 
# and $lbs variables. 
# These variables will then be used by the Http and Lb components by a Ruby array each method further down in the 
# manifest to create X amount of each component which will either get its default value from the init.pp file or 
# can be overridden in the site.pp file for the environment.

application ao_website(
  # An application is defined like a class: applciation(){}
  # default number of web and loadbalancer servers in application. Can be overwritten via input parameters
  $number_webs = 1,
  $number_lbs = 1,
){
  # iterate X number of times and create a Http service resource with a unique name and store it in the $webs variable, 
  # along with a Lb service resource stored in the $lbs variable.
  $webs = $number_webs.map |$i| {Http["http-${name}-${i}"]}
  $lbs = $number_lbs.map |$i| {Ao_website::Lb["lb-${name}-${i}"]}
  
  #Definition of the database component. Here we define that the database component will export a SQL service resource
  ao_website::db{$name:
    export => Sql["ao_website-${name}"],
  }

  # Loop over $webs and create a unique resource each time. 
  # In the definition we declare that the SQL service resource will be consumed and a HTTP service resource is exported
  $webs.each |$i, $web|{
    ao_website::web { "${name}-web-${i}":
      consume => Sql["ao_website-${name}"],
      export => $web
    }
  }
  # Loop over the $lbs variable and create a unique resource each time.
  # The load balancer definition does not use export or consume statements. We just pass the $webs service resources as an input
  # note: we have a require statement here. This will halt the configuration of the load balancer until the HTTP service resources are created
  # Creating Ruby array with the each method
  $lbs.each |$i, $lb| {
    ao_website::lb { "${name}-lb-${i}":
      balancemembers => $webs,
      require => $webs,
    }
  }

}

