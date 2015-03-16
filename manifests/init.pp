# == Class: projects
#
# A puppet module to manage top level projects.
#
# === Examples
#
# === Authors
#
# Dan Foster <dan@zem.org.uk>
#
# === Copyright
#
# Copyright 2015 Dan Foster, unless otherwise noted.
#
class projects (
  $basedir = '/srv/projects'
) inherits ::projects::params {

  file { $basedir:
    ensure => directory,
    mode   => 0775,
    owner  => root,
    group  => root
  }

  $projects = hiera_hash('projects',{})
  create_resources('projects::project', $projects)


}

# == Resource type: project
#
# A top level project type.
define projects::project (
  $apache = {},
  $uid = undef,
  $gid = undef,
  $users = [],
  $description = ""
) {

  # If least one project definition exists for this host, create the base structure
  if ($apache != {}) {
    user { $title:
      comment => $description,
      uid     => $uid,
      gid     => $gid,
      home    => "$::projects::basedir/$title"
    }

    group { $title:
      gid     => $gid,
    }

    file { [ "$::projects::basedir/$title",
    	     "$::projects::basedir/$title/var",
    	     "$::projects::basedir/$title/etc",
           ] :
      ensure => directory,
      owner  => $title,
      group  => $title
    }

  }

  # Create apache vhosts
  if ($apache != {}) {
    projects::project::apache { $title:
      vhosts => $apache
    }
  }
}

# -- Resource type: project::apache
#
# Defines an apache project
define projects::project::apache (
  $vhosts = {}
) {

  file { "$::projects::basedir/$title/var/www":
    ensure  => directory,
    owner   => $title,
    group   => $title,
    seltype => 'httpd_sys_content_t',
    require => File["$::projects::basedir/$title/var"],
  }

  file { "$::projects::basedir/$title/etc/apache":
    ensure  => directory,
    owner   => $title,
    group   => $title,
    require => File["$::projects::basedir/$title/etc"],
  }

  file { "$::projects::basedir/$title/etc/apache/conf.d":
    ensure  => directory,
    owner   => $title,
    group   => $title,
    require => File["$::projects::basedir/$title/etc/apache"],
  }

  create_resources('::projects::project::apache::vhost', $vhosts, {
    'projectname' => $title,
  })
  create_resources('::apache::vhost', $vhosts, {
    'docroot'     => "$::projects::basedir/$title/var/www",
  })

}


# -- Resource type: project::apache::vhost
#
# Configures an project apache vhost.
define projects::project::apache::vhost (
  $projectname = undef,
  $docroot = undef,
  $port = undef,
  $vhost_name = undef,
  $ssl = false
) {

  file { "$::projects::basedir/$projectname/etc/apache/conf.d/$title":
    ensure  => directory,
    owner   => $projectname,
    group   => $projectname,
    require => File["$::projects::basedir/$projectname/etc/apache/conf.d"],
  }

}
