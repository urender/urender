function discover_ports() {
	let roles = {};

	/* Derive ethernet port names and roles from default config */
	for (let role, spec in capab.network) {
		for (let i, ifname in spec) {
			role = uc(role);
			push(roles[role] = roles[role] || [], {
				netdev: ifname,
				index: i
			});
		}
	}

	/* Sort ports in each role group according to their index, then normalize
	 * names into uppercase role name with 1-based index suffix in case of multiple
	 * ports or just uppercase role name in case of single ports */
	let rv = {};

	for (let role, ports in roles) {
		switch (length(ports)) {
		case 0:
			break;

		case 1:
			rv[role] = ports[0];
			break;

		default:
			map(sort(ports, (a, b) => (a.index - b.index)), (port, i) => {
				rv[role + (i + 1)] = port;
			});
		}
	}

	return rv;
}

/**
 * @class uRender.ethernet
 * @classdesc
 *
 * This is the ethernet base class. It is automatically instantiated and
 * accessible using the global 'ethernet' variable.
 */

/** @lends uRender.ethernet.prototype */

return {
	ports: discover_ports(),

	port_roles: {},

	/**
	 * Get a list of all wireless PHYs for a specific wireless band
	 *
	 * @param {string} band
	 *
	 * @returns {object}
	 * Returns an array of all wireless PHYs for a specific wireless
	 * band.
	 */
	lookup: function(globs) {
		let matched = {};

		for (let glob, tag_state in globs) {
			for (let name, spec in this.ports) {
				if (wildcard(name, glob)) {
					if (spec.netdev)
						matched[spec.netdev] = tag_state;
					else
						warn("Not implemented yet: mapping switch port to netdev");
				}
			}
		}

		return matched;
	},

	lookup_by_interface_vlan: function(interface) {
		/* Gather the glob patterns in all `ethernet: [ { select-ports: ... }]` specs,
		 * dedup them and turn them into one global regular expression pattern, then
		 * match this pattern against all known system ethernet ports, remember the
		 * related netdevs and return them.
		 */
		let globs = {};
		map(interface.ethernet, eth => map(eth.select_ports, glob => globs[glob] = eth.vlan_tag));

		return this.lookup(globs);
	},

	lookup_by_interface_spec: function(interface) {
		return sort(keys(this.lookup_by_interface_vlan(interface)));
	},

	lookup_by_select_ports: function(select_ports) {
		let globs = {};
		map(select_ports, glob => globs[glob] = true);

		return sort(keys(this.lookup(globs)));
	},

	lookup_by_ethernet: function(ethernets) {
		let result = [];

		for (let ethernet in ethernets)
			result = [ ...result,  ...this.lookup_by_select_ports(ethernet.select_ports) ];
		return result;
	},

	reserve_port: function(port) {
		delete this.ports[port];
	},

	assign_port_role: function(ports, role) {
		for (let port in keys(ports)) {
			this.port_roles[port] ??= role;
			if (this.port_roles[port] != role) {
				warn(`trying to use ${ port } as an ${ role } port, but it is already assigned to ${ this.port_roles[port] }\n`);
				die(`trying to use ${ port } as an ${ role } port, but it is already assigned to ${ this.port_roles[port] }\n`);
			}
		}
	},

	is_single_config: function(interface) {
		let ipv4_mode = interface.ipv4 ? interface.ipv4.addressing : 'none';
		let ipv6_mode = interface.ipv6 ? interface.ipv6.addressing : 'none';

		return (
			(ipv4_mode == 'none') || (ipv6_mode == 'none') ||
			(ipv4_mode == 'static' && ipv6_mode == 'static')
		);
	},

	calculate_name: function(interface) {
		let vid = interface.vlan.id;

		return (interface.role == 'upstream' ? 'up' : 'down') + interface.index + 'v' + vid;
	},

	calculate_names: function(interface) {
		let name = this.calculate_name(interface);

		return this.is_single_config(interface) ? [ name ] : [ name + '_4', name + '_6' ];
	},

	calculate_ipv4_name: function(interface) {
		let name = this.calculate_name(interface);

		return this.is_single_config(interface) ? name : name + '_4';
	},

	calculate_ipv6_name: function(interface) {
		let name = this.calculate_name(interface);

		return this.is_single_config(interface) ? name : name + '_6';
	},

	has_vlan: function(interface) {
		return interface.vlan && interface.vlan.id;
	},

	port_vlan: function(interface, port) {
		if (port == "tagged")
			return ':t';
		if (port == "un-tagged")
			return '';
		return ((interface.role == 'upstream') && this.has_vlan(interface)) ? ':t' : '';
	},

	find_interface: function(role, vid) {
		for (let interface in state.interfaces)
			if (interface.role == role &&
			    interface.vlan?.id == vid)
				return this.calculate_name(interface);
		return '';
	},

	get_interface: function(role, vid) {
		for (let interface in state.interfaces)
			if (interface.role == role &&
			    interface.vlan.id == vid)
				return interface;
		return null;
	},

	get_speed: function(dev) {
		let fp = fs.open(sprintf("/sys/class/net/%s/speed", dev));
		if (!fp)
			return 1000;
		let speed = fp.read("all");
		fp.close();
		return +speed;
	}
};
