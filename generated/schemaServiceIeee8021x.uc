function moduleServiceIeee8021x(location, value, errors) {
	if (type(value) == "object") {
		let obj = {};

		function parseCaCertificate(location, value, errors) {
			if (type(value) != "string")
				push(errors, [ location, "must be of type string" ]);

			return value;
		}

		if (exists(value, "ca-certificate")) {
			obj.ca_certificate = parseCaCertificate(location + "/ca-certificate", value["ca-certificate"], errors);
		}

		function parseUseLocalCertificates(location, value, errors) {
			if (type(value) != "bool")
				push(errors, [ location, "must be of type boolean" ]);

			return value;
		}

		if (exists(value, "use-local-certificates")) {
			obj.use_local_certificates = parseUseLocalCertificates(location + "/use-local-certificates", value["use-local-certificates"], errors);
		}
		else {
			obj.use_local_certificates = false;
		}

		function parseServerCertificate(location, value, errors) {
			if (type(value) != "string")
				push(errors, [ location, "must be of type string" ]);

			return value;
		}

		if (exists(value, "server-certificate")) {
			obj.server_certificate = parseServerCertificate(location + "/server-certificate", value["server-certificate"], errors);
		}

		function parsePrivateKey(location, value, errors) {
			if (type(value) != "string")
				push(errors, [ location, "must be of type string" ]);

			return value;
		}

		if (exists(value, "private-key")) {
			obj.private_key = parsePrivateKey(location + "/private-key", value["private-key"], errors);
		}

		function parseUsers(location, value, errors) {
			if (type(value) == "array") {
				return map(value, (item, i) => instantiateInterfaceSsidRadiusLocalUser(location + "/" + i, item, errors));
			}

			if (type(value) != "array")
				push(errors, [ location, "must be of type array" ]);

			return value;
		}

		if (exists(value, "users")) {
			obj.users = parseUsers(location + "/users", value["users"], errors);
		}

		return obj;
	}

	if (type(value) != "object")
		push(errors, [ location, "must be of type object" ]);

	return value;
}

return {
	validate: function(location, value, errors) {
		return moduleServiceIeee8021x(location, value, errors);
	}
};
