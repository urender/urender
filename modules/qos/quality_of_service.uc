{%
	if (!services.is_present('qosify'))
		return;

	let egress = ethernet.lookup_by_select_ports(quality_of_service.select_ports);
	let enable = length(egress);
	services.set_enabled('qosify', enable);
	if (!enable)
		return;

	function get_speed(dev, speed) {
		if (!speed)
			speed = ethernet.get_speed(dev);
		return speed;
	}

	function get_proto(proto) {
		return (proto == 'any') ? [ 'udp', 'tcp' ] : [ proto ];
	}

	function get_range(port) {
		return port.range_end ? ('-' + port.range_end) : '';
	}

	function get_reclassify(val) {
		return val ? '+' : '';
	}

	let fs = require('fs');
	let file = fs.open('/tmp/qosify.conf', 'w');
	for (let class in quality_of_service.classifier) {
		for (let port in class.ports)
			for (let proto in get_proto(port.protocol))
				file.write(`${proto}:${port.port}${get_range(port)} ${get_reclassify(port.reclassify)}${class.dscp}`);
		for (let fqdn in class.dns)
			file.write(`dns:${fqdn.suffix_matching ? '*.' : ''}${fqdn.fqdn} ${get_reclassify(fqdn.reclassify)}${class.dscp}`);
	}
	file.close();
%}
set qosify.@defaults[0].bulk_trigger_pps={{ quality_of_service?.bulk_detection?.packets_per_second || 0}}
set qosify.@defaults[0].dscp_bulk={{ quality_of_service?.bulk_detection?.dscp }}
{%	for (let dev in egress): %}
set qosify.{{ dev }}=device
set qosify.{{ dev }}.name={{ s(dev) }}
set qosify.{{ dev }}.bandwidth_up='{{ get_speed(dev, quality_of_service.bandwidth_up) }}mbit'
set qosify.{{ dev }}.bandwidth_down='{{ get_speed(dev, quality_of_service.bandwidth_down) }}mbit'
{%	endfor %}
