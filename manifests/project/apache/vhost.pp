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
