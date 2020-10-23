{%
	if (!services.is_present("ulldpd"))
		return;
	let interfaces = services.lookup_interfaces("lldp");
	let enable = length(interfaces);
	services.set_enabled("ulldpd", enable);
	if (!enable)
		return;
%}
set lldp.@global[-1].description={{ s(lldp.describe) }}
set lldp.@global[-1].location={{ s(lldp.location) }}
{%
	for (let interface in interfaces):
		for (let port in ethernet.lookup_by_interface_spec(interface)):
%}
add_list lldp.@global[-1].device={{ s(port) }}
{%		endfor
	endfor %}
