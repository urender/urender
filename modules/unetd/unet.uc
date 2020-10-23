{%
let wireguard = length(services.lookup_interfaces("unet-wireguard"));
let vxlan = length(services.lookup_interfaces("unet-vxlan"));

if (!wireguard && !vxlan)
	return;

if (wireguard + vlxan > 1) {
	warn('only a single wireguard/vxlan-overlay is allowed\n');
	return;
}

if (!unet.root_node.key ||
    !unet.root_node.endpoint) {
	warn('root node is not configured correctly\n');
	return;
}

let ips = [];

unet.root_node.name = "gateway";
unet.root_node.groups = [ "gateway" ];

for (let ip in unet.root_node.ipaddr)
	push(ips, ip);

if (wireguard)
	unet.root_node.subnet = [ '0.0.0.0/0' ];


let cfg = {
	'config': {
		'port': unet.peer_port,
		'peer-exchange-port': unet.peer_exchange_port,
		'keepalive': 10
	},
	'hosts': {
		gateway: unet.root_node,
	}
};

let pipe = require('fs').popen(sprintf('echo "%s" | wg pubkey', unet.private_key));
let pubkey = replace(pipe.read("all"), '\n', '');
pipe.close();
for (let host in unet.hosts)
	if (host.name) {
		if (!host.name || !host.key) {
			warn('host is not configured correctly\n');
			return;
		}

		cfg.hosts[host.name] = host;
		cfg.hosts[host.name].groups = [ 'ap' ];
		if (host.key == pubkey)
			continue;
		for (let ip in host.ipaddr)
			push(ips, ip);
	}
if (vxlan) {
	cfg.services = {
		"l2-tunnel": {
			"type": "vxlan",
			"config": {
				port: unet?.vxlan?.port || 3457,
			},
			"members": [ "gateway", "@ap" ]
		}
	};

	if (unet?.vxlan?.isolate ?? true)
		cfg.services['l2-tunnel'].config.forward_ports = [ "gateway" ];
}
files.add_named('/tmp/unet.json', cfg);

include('../interface/firewall.uc', { name: 'unet', ipv4_mode: true, ipv6_mode: true, interface: { role: 'upstream' }, networks: [ 'unet' ] });
%}


# Wireguard Overlay Configuration
set network.unet=interface
set network.unet.proto=unet
set network.unet.device=unet
set network.unet.file='/tmp/unet.json'
set network.unet.key={{ s(unet.private_key) }}
set network.unet.domain=unet
set network.unet.ip4table='{{ routing_table.get('unet') }}'
{% if (vxlan): %}
set network.unet.tunnels='vx-unet=l2-tunnel'

add firewall rule
set firewall.@rule[-1].name='Allow-VXLAN-unet'
set firewall.@rule[-1].src='unet'
set firewall.@rule[-1].proto='udp'
set firewall.@rule[-1].target='ACCEPT'
set firewall.@rule[-1].dest_port={{ unet?.vxlan?.port || 3457 }}
{% endif %}

{% for (let ip in ips): %}
add network route
set network.@route[-1].interface='unet'
set network.@route[-1].target={{ s(ip) }}
set network.@route[-1].table='local'
{% endfor %}
