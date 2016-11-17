class projects (
  $basedir = $::projects::params::basedir,
) inherits projects::params {
  file { $basedir:
    ensure => directory,
    group  => root,
    mode   => '0775',
    owner  => root,
  }

  $projects = hiera_hash('projects', {})
  create_resources('projects::project', $projects)
}
