define projects::project (
  $dependencies = [],
  $directories = [],
  $django = '',
  $init = [],
  $group = $title,
  $tls = false,
  $php = false,
  $project = $title,
  $user = $title,
  $vhost = '',
  $aliases = [],
) {
  include ::projects::params

  $project_dir = "${::projects::params::basedir}/${title}"

  file { $project_dir:
    ensure => directory,
    owner  => root,
    group  => $group,
    mode   => '2750',
  }

  $dirs_to_create = regsubst($directories, '^', "${project_dir}/")

  file { $dirs_to_create:
    ensure => directory,
    owner  => root,
    group  => $group,
    mode   => '2770',
  }

  package { $dependencies:
    ensure => present,
  }

  if $vhost != '' {
    acl {  $project_dir:
      action     => set,
      permission => [
        'user:www-data:r-x',
        'group:www-data:r-x',
      ],
    }
    if $django != '' {
      file { "${project_dir}/lib/django":
        ensure => directory,
        owner  => root,
        group  => $group,
        mode   => 2770,
      }
      acl { "${project_dir}/lib":
        action     => set,
        permission => [
          'user:www-data:r-x',
          'group:www-data:r-x',
        ],
      }
      acl { "${project_dir}/lib/django":
        action     => set,
        permission => [
          'user:www-data:r-x',
          'group:www-data:r-x',
          'default:user::rwx',
          'default:group::rwx',
          'default:user:www-data:r-x',
          'default:group:www-data:r-x',
        ],
      }
      $wsgi_daemon_process = $title
      $wsgi_daemon_process_options = {
        display-name => $title,
      }
      $wsgi_process_group = $title
      $wsgi_script_aliases = hash_from_keys_and_value($django, "${project_dir}/lib/django/${title}/${title}/wsgi.py process-group=${title}")
    }
    if $php {
      ::php::fpm::pool { $title:
        listen               => "${project_dir}/run/php5-fpm.sock",
        listen_owner         => 'www-data',
        listen_group         => 'www-data',
        user                 => $user,
        group                => $group,
      }
      acl {  "${project_dir}/run":
        action     => set,
        permission => [
          'user:www-data:r-x',
          'group:www-data:r-x',
        ],
      }
      $proxy_pass_match = {
        path => '^/(.*\.php(/.*)?)$',
        url  => "unix://${project_dir}/run/php5-fpm.sock|fcgi://127.0.0.1:9000${project_dir}/var/www$1",
      }
    }
    file { "${project_dir}/etc/apache2":
      ensure => directory,
      owner  => root,
      group  => $group,
      mode   => 2750,
    }
    file { "${project_dir}/var/www":
      ensure => directory,
      owner  => root,
      group  => $group,
      mode   => 2770,
    }
    ::apache::vhost { "${vhost}_80":
      docroot               => "${project_dir}/var/www",
      port                  => 80,
      docroot_owner         => $user,
      docroot_group         => $group,
      serveraliases         => $aliases,
      servername            => $vhost,
      logroot               => "${project_dir}/var/log/httpd",
      proxy_pass_match      => $proxy_pass_match,
      additional_includes   => ["${project_dir}/etc/apache2/*"],
      use_optional_includes => true,
    }
    if $tls {
      ::apache::vhost { "${vhost}_443":
        docroot               => "${project_dir}/var/www",
        port                  => 443,
        docroot_owner         => $user,
        docroot_group         => $group,
        serveraliases         => $aliases,
        servername            => $vhost,
        ssl                   => true,
        ssl_cert              => "${project_dir}/etc/ssl/certs/${vhost}.crt",
        ssl_key               => "${project_dir}/etc/ssl/private/${vhost}.key",
        logroot               => "${project_dir}/var/log/httpd",
        proxy_pass_match      => $proxy_pass_match,
        additional_includes   => ["${project_dir}/etc/apache2/*"],
        use_optional_includes => true,
      }
      file { "${project_dir}/etc/ssl":
        ensure => directory,
        owner  => root,
        group  => $group,
        mode   => 750,
      }
      file { "${project_dir}/etc/ssl/certs":
        ensure => directory,
        owner  => root,
        group  => $group,
        mode   => 750,
      }
      file { "${project_dir}/etc/ssl/certs/${vhost}.crt":
        content => hiera("tls::projects::${title}::crt"),
        owner   => root,
        group   => $group,
        mode    => 640,
      }
      file { "${project_dir}/etc/ssl/private":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 700,
      }
      file { "${project_dir}/etc/ssl/private/${vhost}.key":
        content => hiera("tls::projects::${title}::key"),
        owner   => root,
        group   => root,
        mode    => 600,
      }
    }
    acl { "${project_dir}/var":
      action     => set,
      permission => [
        'user:www-data:r-x',
        'group:www-data:r-x',
      ],
    }
    acl { "${project_dir}/var/www":
      action     => set,
      permission => [
        'user:www-data:r-x',
        'group:www-data:r-x',
        'default:user::rwx',
        'default:group::rwx',
        'default:user:www-data:r-x',
        'default:group:www-data:r-x',
      ],
    }
  }
}
