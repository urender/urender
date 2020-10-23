function moduleServiceLldp(location, value, errors) {
	if (type(value) == "object") {
		let obj = {};

		function parseDescribe(location, value, errors) {
			if (type(value) != "string")
				push(errors, [ location, "must be of type string" ]);

			return value;
		}

		if (exists(value, "describe")) {
			obj.describe = parseDescribe(location + "/describe", value["describe"], errors);
		}
		else {
			obj.describe = "OpenWrt Access Point";
		}

		function parseLocation(location, value, errors) {
			if (type(value) != "string")
				push(errors, [ location, "must be of type string" ]);

			return value;
		}

		if (exists(value, "location")) {
			obj.location = parseLocation(location + "/location", value["location"], errors);
		}
		else {
			obj.location = "OpenWrt Network";
		}

		return obj;
	}

	if (type(value) != "object")
		push(errors, [ location, "must be of type object" ]);

	return value;
}

return {
	validate: function(location, value, errors) {
		return moduleServiceLldp(location, value, errors);
	}
};
