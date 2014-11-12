node default {
    include apt
    include stdlib
    include git

    case $::environment {
    	production: {
    	    include app::database
            include app::webserver
            include app::codebase
    	}
        development: {
            include app::database
            include app::webserver
            include app::codebase
        }
    }

    package { 'unzip' :
       ensure => present
    }

    package { 'vim' :
        ensure => present
    }

    exec { "apt-get clean" :
      command => "/usr/bin/apt-get clean"
    }

    exec { "apt-update":
      command => "/usr/bin/apt-get update",
      require => [ Exec['apt-get clean'] ]
    }

    Exec["apt-update"] -> Package <| |>
}
