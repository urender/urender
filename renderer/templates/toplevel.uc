{%
	/* reject the config if there is no valid UUID */
	if (!state.uuid) {
		warn('Configuration must contain a valid UUID. Rejecting whole file');
		die('Configuration must contain a valid UUID. Rejecting whole file');
	}

	/* reject the config if there is no valid upstream configuration */
	let upstream;
	for (let i, interface in state.interfaces) {
		if (interface.role != 'upstream')
			continue;
		upstream = interface;
	}

	if (!upstream) {
		warn('Configuration must contain at least one valid upstream interface. Rejecting whole file');
		die('Configuration must contain at least one valid upstream interface. Rejecting whole file');
	}

	/* assign an index to each interface */
	for (let i, interface in state.interfaces)
		interface.index = i;

	/* find out which vlans are used and which should be assigned dynamically */
	let vlans = [];
	let vlans_upstream = [];
	for (let i, interface in state.interfaces)
		if (ethernet.has_vlan(interface)) {
			push(vlans, interface.vlan.id);
			if (interface.role == 'upstream')
				push(vlans_upstream, interface.vlan.id);
		} else
			interface.vlan = { id: 0 };

	/* populate the broad-band profile if present. This needs to happen after the default vlans 
	 * and before the dynamic vlan are assigned */
	let profile = local_profile.get();
	if (profile && profile.broadband)
		include('broadband.uc', { broadband: profile.broadband });

	/* dynamically assigned vlans start at 4090 counting backwards */
	let vid = 4090;
	function next_free_vid() {
		while (vid in vlans)
			vid--;
		return vid--;
	}

	/* dynamically assign vlan ids to all interfaces that have none yet */
	for (let i, interface in state.interfaces)
		if (!interface.vlan.id)
			interface.vlan.dyn_id = next_free_vid();

	/* render the basic UCI setup */
	include('base.uc');

	/* render the unit configuration */
	include('unit.uc', { location: '/unit', unit: state.unit });

	state.services ??= {};
	for (let service in services.lookup_services())
		tryinclude('services/' + service + '.uc', {
			location: '/services/' + service,
			[service]: state.services[service] || {}
		});

	state.metrics ??= {};
	for (let metric in services.lookup_metrics())
		tryinclude('metric/' + metric + '.uc', {
			location: '/metric/' + metric,
			[metric]: state.metrics[metric] || {}
		});

	/* render the switch-fabric configuration */
	if (state.switch)
		tryinclude('switch.uc', {
			location: '/switch/'
		});

	/* render the ethernet port configuration */
	tryinclude('ethernet.uc', { location: '/ethernet/' + i, ports });

	/* render the wireless PHY configuration */
	for (let i, radio in state.radios)
		tryinclude('radio.uc', { location: '/radios/' + i, radio });

	/* render the logical interface configuration (includes SSIDs) */
	function iterate_interfaces(role) {
		for (let i, interface in state.interfaces) {
			if (interface.role != role)
				continue;
			include('interface.uc', { location: '/interfaces/' + i, interface, vlans_upstream });
		}
	}

	iterate_interfaces("upstream");
	iterate_interfaces("downstream");
%}
