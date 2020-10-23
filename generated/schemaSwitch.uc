function moduleSwitch(location, value, errors) {
	if (type(value) == "object") {
		let obj = {};

		function parsePortMirror(location, value, errors) {
			if (type(value) == "object") {
				let obj = {};

				function parseMonitorPorts(location, value, errors) {
					if (type(value) == "array") {
						function parseItem(location, value, errors) {
							if (type(value) != "string")
								push(errors, [ location, "must be of type string" ]);

							return value;
						}

						return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
					}

					if (type(value) != "array")
						push(errors, [ location, "must be of type array" ]);

					return value;
				}

				if (exists(value, "monitor-ports")) {
					obj.monitor_ports = parseMonitorPorts(location + "/monitor-ports", value["monitor-ports"], errors);
				}

				function parseAnalysisPort(location, value, errors) {
					if (type(value) != "string")
						push(errors, [ location, "must be of type string" ]);

					return value;
				}

				if (exists(value, "analysis-port")) {
					obj.analysis_port = parseAnalysisPort(location + "/analysis-port", value["analysis-port"], errors);
				}

				return obj;
			}

			if (type(value) != "object")
				push(errors, [ location, "must be of type object" ]);

			return value;
		}

		if (exists(value, "port-mirror")) {
			obj.port_mirror = parsePortMirror(location + "/port-mirror", value["port-mirror"], errors);
		}

		function parseLoopDetection(location, value, errors) {
			if (type(value) == "object") {
				let obj = {};

				function parseProtocol(location, value, errors) {
					if (type(value) != "string")
						push(errors, [ location, "must be of type string" ]);

					if (!(value in [ "rstp" ]))
						push(errors, [ location, "must be one of \"rstp\"" ]);

					return value;
				}

				if (exists(value, "protocol")) {
					obj.protocol = parseProtocol(location + "/protocol", value["protocol"], errors);
				}
				else {
					obj.protocol = "rstp";
				}

				function parseRoles(location, value, errors) {
					if (type(value) == "array") {
						function parseItem(location, value, errors) {
							if (type(value) != "string")
								push(errors, [ location, "must be of type string" ]);

							if (!(value in [ "upstream", "downstream" ]))
								push(errors, [ location, "must be one of \"upstream\" or \"downstream\"" ]);

							return value;
						}

						return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
					}

					if (type(value) != "array")
						push(errors, [ location, "must be of type array" ]);

					return value;
				}

				if (exists(value, "roles")) {
					obj.roles = parseRoles(location + "/roles", value["roles"], errors);
				}

				return obj;
			}

			if (type(value) != "object")
				push(errors, [ location, "must be of type object" ]);

			return value;
		}

		if (exists(value, "loop-detection")) {
			obj.loop_detection = parseLoopDetection(location + "/loop-detection", value["loop-detection"], errors);
		}

		return obj;
	}

	if (type(value) != "object")
		push(errors, [ location, "must be of type object" ]);

	return value;
}

return {
	validate: function(location, value, errors) {
		return moduleSwitch(location, value, errors);
	}
};
