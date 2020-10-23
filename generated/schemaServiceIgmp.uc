function moduleServiceIgmp(location, value, errors) {
	if (type(value) == "object") {
		let obj = {};

		function parseEnable(location, value, errors) {
			if (type(value) != "bool")
				push(errors, [ location, "must be of type boolean" ]);

			return value;
		}

		if (exists(value, "enable")) {
			obj.enable = parseEnable(location + "/enable", value["enable"], errors);
		}
		else {
			obj.enable = false;
		}

		return obj;
	}

	if (type(value) != "object")
		push(errors, [ location, "must be of type object" ]);

	return value;
}

return {
	validate: function(location, value, errors) {
		return moduleServiceIgmp(location, value, errors);
	}
};
