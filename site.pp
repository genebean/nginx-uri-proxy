$website_owner = 'vagrant'

exec { 'create localhost cert':
  # lint:ignore:80chars
  # lint:ignore:140chars
  command   => "/bin/openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -sha256 -subj '/CN=domain.com/O=My Company Name LTD./C=US' -keyout /etc/pki/tls/private/localhost.key -out /etc/pki/tls/certs/localhost.crt",
  # lint:endignore
  creates   => '/etc/pki/tls/certs/localhost.crt',
  logoutput => true,
  before    => [
    Class['::apache'],
    Class['::nginx_proxy'],
  ],
}

exec { 'create old-site cert':
  # lint:ignore:80chars
  # lint:ignore:140chars
  command   => "/bin/openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -sha256 -subj '/CN=domain.com/O=My Company Name LTD./C=US' -keyout /etc/pki/tls/private/old-site.key -out /etc/pki/tls/certs/old-site.crt",
  # lint:endignore
  creates   => '/etc/pki/tls/certs/old-site.crt',
  logoutput => true,
  before    => [
    Class['::apache'],
    Class['::nginx_proxy'],
  ],
}

exec { 'create new-site cert':
  # lint:ignore:80chars
  # lint:ignore:140chars
  command   => "/bin/openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -sha256 -subj '/CN=domain.com/O=My Company Name LTD./C=US' -keyout /etc/pki/tls/private/new-site.key -out /etc/pki/tls/certs/new-site.crt",
  # lint:endignore
  creates   => '/etc/pki/tls/certs/new-site.crt',
  logoutput => true,
  before    => [
    Class['::apache'],
    Class['::nginx_proxy'],
  ],
}

user { $website_owner:
  ensure => present,
  before => Class['::apache'],
}

package { 'centos-release-scl-rh':
  ensure => installed,
  before => Class['::apache'],
}

$scl_httpd = '/opt/rh/httpd24/root'

class { '::apache':
  apache_name           => 'httpd24-httpd',
  apache_version        => '2.4',
  conf_dir              => "${scl_httpd}/etc/httpd/conf",
  confd_dir             => "${scl_httpd}/etc/httpd/conf.d",
  default_mods          => true,
  default_ssl_vhost     => false,
  default_vhost         => false,
  dev_packages          => 'httpd24-httpd-devel',
  docroot               => "${scl_httpd}/var/www/html",
  httpd_dir             => "${scl_httpd}/etc/httpd",
  log_formats           => {
    combined => '%a %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"',
  },
  logroot               => '/var/log/httpd24',
  mod_dir               => "${scl_httpd}/etc/httpd/conf.modules.d",
  mpm_module            => 'worker',
  pidfile               => '/opt/rh/httpd24/root/var/run/httpd/httpd.pid',
  ports_file            => "${scl_httpd}/etc/httpd/conf/ports.conf",
  purge_configs         => true,
  serveradmin           => 'root@localhost',
  servername            => 'demobox.example.com',
  server_root           => "${scl_httpd}/etc/httpd",
  service_name          => 'httpd24-httpd',
  trace_enable          => false,
  vhost_dir             => "${scl_httpd}/etc/httpd/conf.d",
  vhost_include_pattern => '*.conf',
}

apache::custom_config { 'php-fpm':
  confdir        => "${scl_httpd}/etc/httpd/conf.modules.d",
  priority       => false,
  source         => '/vagrant/php-fpm.conf',
  verify_command => '/bin/scl enable httpd24 "apachectl -t"',
  notify         => Service['httpd'],
}

if ($::apache::mod_dir != $::apache::config_dir) {
  apache::custom_config { 'mod_ssl_fix':
    name           => 'ssl',
    confdir        => "${scl_httpd}/etc/httpd/conf.d",
    priority       => false,
    content        => "# This file has moved to ${::apache::mod_dir}",
    verify_command => '/bin/scl enable httpd24 "apachectl -t"',
    require        => Class['apache::mod::ssl'],
    notify         => Service['httpd'],
  }
}

apache::vhost { 'old-site-nonssl':
  ip              => '*',
  ip_based        => true,
  port            => '8081',
  docroot         => "${scl_httpd}/var/www/old-site",
  redirect_status => 'permanent',
  redirect_dest   => 'https://localhost:8444/',
  docroot_owner   => $website_owner,
  docroot_group   => $website_owner,
  directories     => [
    { path           => '/opt/rh/httpd24/root/var/www/old-site',
      allow_override => ['All'],
    },
  ],
  rewrites        => [
    {
      comment      => 'use index.php for everything that does not exist',
      rewrite_cond => [
        '%{REQUEST_FILENAME} !-d',
        '%{REQUEST_FILENAME} !-f',
      ],
      rewrite_rule => [
        '^ /index.php [L]',
      ],
    },
  ],
}

apache::vhost { 'old-site-ssl':
  ip            => '*',
  ip_based      => true,
  port          => '8444',
  docroot       => "${scl_httpd}/var/www/old-site",
  docroot_owner => $website_owner,
  docroot_group => $website_owner,
  ssl           => true,
  ssl_cert      => '/etc/pki/tls/certs/old-site.crt',
  ssl_key       => '/etc/pki/tls/private/old-site.key',
  directories   => [
    { path           => '/opt/rh/httpd24/root/var/www/old--site',
      allow_override => ['All'],
    },
  ],
  rewrites      => [
    {
      comment      => 'use index.php for everything that does not exist',
      rewrite_cond => [
        '%{REQUEST_FILENAME} !-d',
        '%{REQUEST_FILENAME} !-f',
      ],
      rewrite_rule => [
        '^ /index.php [L]',
      ],
    },
  ],
}

apache::vhost { 'new-site-ssl-1':
  ip            => '*',
  ip_based      => true,
  port          => '9444',
  docroot       => "${scl_httpd}/var/www/new-site",
  docroot_owner => $website_owner,
  docroot_group => $website_owner,
  ssl           => true,
  ssl_cert      => '/etc/pki/tls/certs/new-site.crt',
  ssl_key       => '/etc/pki/tls/private/new-site.key',
  directories   => [
    { path           => '/opt/rh/httpd24/root/var/www/new-site',
      allow_override => ['All'],
    },
  ],
  rewrites      => [
    {
      comment      => 'use index.php for everything that does not exist',
      rewrite_cond => [
        '%{REQUEST_FILENAME} !-d',
        '%{REQUEST_FILENAME} !-f',
      ],
      rewrite_rule => [
        '^ /index.php [L]',
      ],
    },
  ],
}

apache::vhost { 'new-site-ssl-2':
  ip            => '*',
  ip_based      => true,
  port          => '10444',
  docroot       => "${scl_httpd}/var/www/new-site",
  docroot_owner => $website_owner,
  docroot_group => $website_owner,
  ssl           => true,
  ssl_cert      => '/etc/pki/tls/certs/new-site.crt',
  ssl_key       => '/etc/pki/tls/private/new-site.key',
  directories   => [
    { path           => '/opt/rh/httpd24/root/var/www/new-site',
      allow_override => ['All'],
    },
  ],
  rewrites      => [
    {
      comment      => 'use index.php for everything that does not exist',
      rewrite_cond => [
        '%{REQUEST_FILENAME} !-d',
        '%{REQUEST_FILENAME} !-f',
      ],
      rewrite_rule => [
        '^ /index.php [L]',
      ],
    },
  ],
}

class { '::apache::dev': }
class { '::apache::mod::proxy': }
class { '::apache::mod::remoteip':
  header    => 'X-Forwarded-For',
  proxy_ips => [
    '127.0.0.1',
  ],
}
class { '::apache::mod::ssl':
  package_name => 'httpd24-mod_ssl',
}

file { '/var/log/php-fpm':
  ensure => directory,
  mode   => '0700',
  before => Class['phpfpm'],
}

class {'::phpfpm':
  package_name    => 'rh-php56-php-fpm',
  service_name    => 'rh-php56-php-fpm',
  config_dir      => '/etc/opt/rh/rh-php56',
  pool_dir        => '/etc/opt/rh/rh-php56/php-fpm.d',
  pid_file        => '/var/opt/rh/rh-php56/run/php-fpm/php-fpm.pid',
  restart_command => 'systemctl reload rh-php56-php-fpm',
}

$php_packages = [
  rh-php56-php-bcmath,
  rh-php56-php-cli,
  rh-php56-php-common,
  rh-php56-php-devel,
  rh-php56-php-gd,
  rh-php56-php-mbstring,
  rh-php56-php-mysqlnd,
  rh-php56-php-pdo,
  rh-php56-php-pear,
  rh-php56-php-pecl-jsonc,
  rh-php56-php-pecl-jsonc-devel,
  rh-php56-php-process,
  rh-php56-php-xml,
]

package { $php_packages:
  ensure => installed,
  notify => Service['rh-php56-php-fpm'],
}

package { 'mariadb55-mariadb-server':
  ensure => installed,
  notify => Service['mariadb55-mariadb.service'],
}

service { 'mariadb55-mariadb.service':
  ensure  => running,
  enable  => true,
  require => Package['mariadb55-mariadb-server'],
}

package { 'nginx':
  ensure => installed,
}

class { '::nginx_proxy':
  locations => [
    {
      order          => '001',
      exact          => true,
      path           => '/',
      redirect       => true,
      https_upstream => 'new_backend_https',
    },
    {
      order          => '002',
      exact          => true,
      path           => '/index.php',
      redirect       => true,
      https_upstream => 'new_backend_https',
    },
    {
      order          => '003',
      exact          => false,
      path           => '/part1',
      redirect       => true,
      https_upstream => 'new_backend_https',
    },
    {
      order          => '004',
      exact          => true,
      path           => '/part2/special/page.php',
      redirect       => true,
      https_upstream => 'new_backend_https',
    },
    {
      order          => '999',
      exact          => false,
      path           => '/',
      redirect       => false,
      http_upstream  => 'old_backend_http',
      https_upstream => 'old_backend_https',
    },
    {
      order          => '005',
      exact          => false,
      path           => '/part3',
      redirect       => true,
      https_upstream => 'new_backend_https',
    },
  ],
  upstreams => [
    {
      title   => 'old_backend_http',
      servers => [
        '127.0.0.1:8081',
      ],
    },
    {
      title   => 'old_backend_https',
      servers => [
        '127.0.0.1:8444',
      ],
    },
    {
      title     => 'new_backend_https',
      lb_method => 'ip_hash',
      servers   => [
        '127.0.0.1:9444',
        '127.0.0.1:10444',
      ],
    },
  ],
}

service { 'nginx':
  ensure  => running,
  enable  => true,
  require => Class['::nginx_proxy'],
}
