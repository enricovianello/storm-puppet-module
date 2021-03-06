# @summary StoRM WebDAV config class
#
class storm::webdav::config (

  $manage_storage_areas = $storm::webdav::manage_storage_areas,
  $storage_areas = $storm::webdav::storage_areas,

  $hostnames = $storm::webdav::hostnames,

  $http_port = $storm::webdav::http_port,
  $https_port = $storm::webdav::https_port,

  $trust_anchors_refresh_interval = $storm::webdav::trust_anchors_refresh_interval,

  $max_concurrent_connections = $storm::webdav::max_concurrent_connections,
  $max_queue_size = $storm::webdav::max_queue_size,
  $connector_max_idle_time = $storm::webdav::connector_max_idle_time,

  $vo_map_files_enable = $storm::webdav::vo_map_files_enable,
  $vo_map_files_config_dir = $storm::webdav::vo_map_files_config_dir,
  $vo_map_files_refresh_interval = $storm::webdav::vo_map_files_refresh_interval,

  $tpc_max_connections = $storm::webdav::tpc_max_connections,
  $tpc_verify_checksum = $storm::webdav::tpc_verify_checksum,

  $jvm_opts = $storm::webdav::jvm_opts,

  $authz_server_enable = $storm::webdav::authz_server_enable,
  $authz_server_issuer = $storm::webdav::authz_server_issuer,
  $authz_server_max_token_lifetime_sec = $storm::webdav::authz_server_max_token_lifetime_sec,
  $authz_server_secret = $storm::webdav::authz_server_secret,
  $require_client_cert = $storm::webdav::require_client_cert,

  $use_conscrypt = $storm::webdav::use_conscrypt,
  $tpc_use_conscrypt = $storm::webdav::tpc_use_conscrypt,
  $enable_http2 = $storm::webdav::enable_http2,

  $debug = $storm::webdav::debug,
  $debug_port = $storm::webdav::debug_port,
  $debug_suspend = $storm::webdav::debug_suspend,

  $storm_limit_nofile = $storm::webdav::storm_limit_nofile,

) {

  file { '/var/lib/storm-webdav/work':
    ensure  => directory,
    owner   => 'storm',
    group   => 'storm',
    mode    => '0755',
    recurse => true,
  }

  # Service's host credentials directory
  file { '/etc/grid-security/storm-webdav':
    ensure  => directory,
    owner   => 'storm',
    group   => 'storm',
    mode    => '0755',
    recurse => true,
  }
  # Service's hostcert
  file { '/etc/grid-security/storm-webdav/hostcert.pem':
    ensure  => present,
    mode    => '0644',
    owner   => 'storm',
    group   => 'storm',
    source  => '/etc/grid-security/hostcert.pem',
    require => File['/etc/grid-security/storm-webdav'],
  }
  # Service's hostkey
  file { '/etc/grid-security/storm-webdav/hostkey.pem':
    ensure  => present,
    mode    => '0400',
    owner   => 'storm',
    group   => 'storm',
    source  => '/etc/grid-security/hostkey.pem',
    require => File['/etc/grid-security/storm-webdav'],
  }

  if $manage_storage_areas {

    ## Use class variables to configure storage areas
    if $storage_areas {
      $sa_properties_template_file='storm/etc/storm/webdav/sa.d/sa.properties.erb'
      $storage_areas.each | $sa | {
        # define template variables
        # mandatory fields
        $name = $sa[name]
        $root_path = $sa[root_path]
        $access_points = $sa[access_points]
        $vos = $sa[vos]
        # optional fileds
        $orgs = $sa[orgs]
        $authenticated_read_enabled = $sa[authenticated_read_enabled]
        $anonymous_read_enabled = $sa[anonymous_read_enabled]
        $vo_map_enabled = $sa[vo_map_enabled]
        $vo_map_grants_write_permission = $sa[vo_map_grants_write_permission]
        $orgs_grant_read_permission = $sa[orgs_grant_read_permission]
        $orgs_grant_write_permission = $sa[orgs_grant_write_permission]
        $wlcg_scope_authz_enabled = $sa[wlcg_scope_authz_enabled]
        $fine_grained_authz_enabled = $sa[fine_grained_authz_enabled]
        # use template
        file { "/etc/storm/webdav/sa.d/${name}.properties":
          ensure  => present,
          content => template($sa_properties_template_file),
          owner   => 'root',
          group   => 'storm',
          notify  => Service['storm-webdav'],
        }
      }
    }
  }

  # Directory '/etc/systemd/system/storm-webdav.service.d' is created by rpm
  $service_dir='/etc/systemd/system/storm-webdav.service.d'

  $limit_template_file='storm/etc/systemd/system/storm-webdav.service.d/filelimit.conf.erb'
  $limit_file="${service_dir}/filelimit.conf"
  # configuration of filelimit.conf
  file { $limit_file:
    ensure  => present,
    content => template($limit_template_file),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => [Service['storm-webdav']],
  }

  $environment_file="${service_dir}/storm-webdav.conf"
  $environment_template_file='storm/etc/systemd/system/storm-webdav.service.d/storm-webdav.conf.erb'
  file { $environment_file:
    ensure  => present,
    content => template($environment_template_file),
    notify  => [Service['storm-webdav']],
  }
}
