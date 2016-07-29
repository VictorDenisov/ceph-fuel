notice('MODULAR: standalone-ceph/radosgw-endpoint.pp')

$network_metadata = hiera_hash('network_metadata')
$storage_hash     = hiera('storage', {})
$use_neutron      = hiera('use_neutron')
$keystone_hash    = hiera('keystone', {})
$service_endpoint = hiera('service_endpoint')
$public_ssl_hash  = hiera('public_ssl')
$mon_address_map  = get_node_to_ipaddr_map_by_network_role(hiera_hash('ceph_monitor_nodes'), 'ceph/public')

$keystone_vip   = hiera('public_vip')
$access_hash    = hiera_hash('access',{})
$admin_tenant   = $access_hash['tenant']
$admin_user     = $access_hash['user']
$admin_password = $access_hash['password']
$region         = hiera('region', 'RegionOne')
$murano_settings_hash = hiera('murano_settings', {})
if has_key($murano_settings_hash, 'murano_repo_url') {
  $murano_repo_url = $murano_settings_hash['murano_repo_url']
} else {
  $murano_repo_url = 'http://storage.apps.openstack.org'
}

if $network_metadata {
  $public_vip = $network_metadata['vips']['public_rados_ep']['ipaddr']
  $management_vip = $network_metadata['vips']['rados_ep']['ipaddr']
} else {
  fail("No network metadata")
}


if ($storage_hash['volumes_ceph'] or
  $storage_hash['images_ceph'] or
  $storage_hash['objects_ceph']
) {
  $use_ceph = true
} else {
  $use_ceph = false
}

if $use_ceph and $storage_hash['objects_ceph'] {

  Keystone_endpoint<| title == 'RegionOne/swift' |> {
    name => "$region/swift",
  }
}
