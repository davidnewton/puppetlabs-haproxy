# == Define Resource Type: haproxy::backend
#
# This type will setup a balancer member inside a listening service
#  configuration block in /etc/haproxy/haproxy.cfg on the load balancer.
#  currently it only has the ability to specify the instance name,
#  ip address, port, and whether or not it is a backup. More features
#  can be added as needed. The best way to implement this is to export
#  this resource for all haproxy balancer member servers, and then collect
#  them on the main haproxy load balancer.
#
# === Requirement/Dependencies:
#
# Currently requires the ripienaar/concat module on the Puppet Forge and
#  uses storeconfigs on the Puppet Master to export/collect resources
#  from all balancer members.
#
# === Parameters
#
# [*name*]
#   The title of the resource is arbitrary and only utilized in the concat
#    fragment name.
#
# [*listening_service*]
#    The haproxy service's instance name (or, the title of the
#     haproxy::listen resource). This must match up with a declared
#     haproxy::listen resource.
#
# [*ports*]
#     An array or commas-separated list of ports for which the balancer member
#     will accept connections from the load balancer. Note that cookie values
#     aren't yet supported, but shouldn't be difficult to add to the
#     configuration. If you use an array in server_names and ipaddresses, the
#     same port is used for all backends.
#
# [*server_names*]
#     The name of the balancer member server as known to haproxy in the
#      listening service's configuration block. This defaults to the
#      hostname. Can be an array of the same length as ipaddresses,
#      in which case a backend is created for each pair of
#      server_names and ipaddresses (in lockstep).
#
# [*ipaddresses*]
#      The ip address used to contact the balancer member server.
#      Can be an array, see documentation to server_names.
#
# [*options*]
#      An array of options to be specified after the server declaration
#       in the listening service's configuration block.
#
# [*blockoptions*]
#     A hash array of options to be specified before the server declaration, eg: srvtcpka.
#
# === Examples
#
#  Exporting the resource for a balancer member:
#
#  @@haproxy::backend { 'haproxy':
#    listening_service => 'puppet00',
#    ports             => '8140',
#    server_names      => $::hostname,
#    ipaddresses       => $::ipaddress,
#    options           => 'check',
#  }
#
#
#  Collecting the resource on a load balancer
#
#  Haproxy::Backend <<| listening_service == 'puppet00' |>>
#
#  Creating the resource for multiple balancer members at once
#  (for single-pass installation of haproxy without requiring a first
#  pass to export the resources if you know the members in advance):
#
#  haproxy::backend { 'haproxy':
#    listening_service => 'puppet00',
#    ports             => '8140',
#    server_names      => ['server01', 'server02'],
#    ipaddresses       => ['192.168.56.200', '192.168.56.201'],
#    options           => 'check',
#    blockoptions      => {'option' => [ 'srvtcpka' ],  'balance' => [ 'roundrobin' ], },
#  }
#
#  (this resource can be declared anywhere)
#
define haproxy::backend (
  $blockoptions = { ' '  => ' '  },
  $listening_service,
  $ports,
  $server_names = $::hostname,
  $ipaddresses  = $::ipaddress,
  $options      = '',
  $mode         = 'tcp'
) {
  # Template uses $ipaddresses, $server_name, $ports, $option, $mode
  concat::fragment { "${listening_service}_backend_${name}":
    order   => "30-${listening_service}-${name}",
    target  => '/etc/haproxy/haproxy.cfg',
    content => template('haproxy/backend.erb'),
  }
}
