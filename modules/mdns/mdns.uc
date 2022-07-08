{%
	if (!services.is_present("umdns"))
		return;

	let interfaces = services.lookup_interfaces("mdns");
	let enable = length(interfaces);
	services.set_enabled("umdns", enable);
	if (!enable)
		return;

	for (let interface in interfaces): %}
add_list umdns.@umdns[0].network={{ s(ethernet.calculate_name(interface)) }}
{%	endfor
	for (let interface in interfaces):
		let name = ethernet.calculate_name(interface);
%}
add firewall rule
set firewall.@rule[-1].name='Allow-mdns-{{ name }}'
set firewall.@rule[-1].src='{{ name }}'
set firewall.@rule[-1].dest_port='5353'
set firewall.@rule[-1].proto='udp'
set firewall.@rule[-1].target='ACCEPT'
{%	endfor %}
