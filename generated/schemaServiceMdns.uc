function moduleServiceMdns(location, value, errors) {
	if (type(value) == "object") {
		let obj = {};

		return obj;
	}

	if (type(value) != "object")
		push(errors, [ location, "must be of type object" ]);

	return value;
}

return {
	validate: function(location, value, errors) {
		return moduleServiceMdns(location, value, errors);
	}
};
