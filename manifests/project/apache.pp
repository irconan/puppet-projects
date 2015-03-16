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
