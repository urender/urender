function moduleServiceGps(location, value, errors) {
	if (type(value) == "object") {
		let obj = {};

		function parseAdjustTime(location, value, errors) {
			if (type(value) != "bool")
				push(errors, [ location, "must be of type boolean" ]);

			return value;
		}

		if (exists(value, "adjust-time")) {
			obj.adjust_time = parseAdjustTime(location + "/adjust-time", value["adjust-time"], errors);
		}
		else {
			obj.adjust_time = false;
		}

		return obj;
	}

	if (type(value) != "object")
		push(errors, [ location, "must be of type object" ]);

	return value;
}

return {
	validate: function(location, value, errors) {
		return moduleServiceGps(location, value, errors);
	}
};
