function moduleServiceWifiSteering(location, value, errors) {
	if (type(value) == "object") {
		let obj = {};

		function parseAssocSteering(location, value, errors) {
			if (type(value) != "bool")
				push(errors, [ location, "must be of type boolean" ]);

			return value;
		}

		if (exists(value, "assoc-steering")) {
			obj.assoc_steering = parseAssocSteering(location + "/assoc-steering", value["assoc-steering"], errors);
		}
		else {
			obj.assoc_steering = false;
		}

		function parseRequiredSnr(location, value, errors) {
			if (type(value) != "int")
				push(errors, [ location, "must be of type integer" ]);

			return value;
		}

		if (exists(value, "required-snr")) {
			obj.required_snr = parseRequiredSnr(location + "/required-snr", value["required-snr"], errors);
		}
		else {
			obj.required_snr = 0;
		}

		function parseRequiredProbeSnr(location, value, errors) {
			if (type(value) != "int")
				push(errors, [ location, "must be of type integer" ]);

			return value;
		}

		if (exists(value, "required-probe-snr")) {
			obj.required_probe_snr = parseRequiredProbeSnr(location + "/required-probe-snr", value["required-probe-snr"], errors);
		}
		else {
			obj.required_probe_snr = 0;
		}

		function parseRequiredRoamSnr(location, value, errors) {
			if (type(value) != "int")
				push(errors, [ location, "must be of type integer" ]);

			return value;
		}

		if (exists(value, "required-roam-snr")) {
			obj.required_roam_snr = parseRequiredRoamSnr(location + "/required-roam-snr", value["required-roam-snr"], errors);
		}
		else {
			obj.required_roam_snr = 0;
		}

		function parseLoadKickThreshold(location, value, errors) {
			if (type(value) != "int")
				push(errors, [ location, "must be of type integer" ]);

			return value;
		}

		if (exists(value, "load-kick-threshold")) {
			obj.load_kick_threshold = parseLoadKickThreshold(location + "/load-kick-threshold", value["load-kick-threshold"], errors);
		}
		else {
			obj.load_kick_threshold = 0;
		}

		return obj;
	}

	if (type(value) != "object")
		push(errors, [ location, "must be of type object" ]);

	return value;
}

return {
	validate: function(location, value, errors) {
		return moduleServiceWifiSteering(location, value, errors);
	}
};
