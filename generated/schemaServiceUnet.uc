function moduleServiceUnet(location, value, errors) {
	if (type(value) == "object") {
		let obj = {};

		function parseProto(location, value, errors) {
			if (type(value) != "string")
				push(errors, [ location, "must be of type string" ]);

			if (value != "wireguard-overlay")
				push(errors, [ location, "must have value \"wireguard-overlay\"" ]);

			return value;
		}

		if (exists(value, "proto")) {
			obj.proto = parseProto(location + "/proto", value["proto"], errors);
		}

		function parsePrivateKey(location, value, errors) {
			if (type(value) != "string")
				push(errors, [ location, "must be of type string" ]);

			return value;
		}

		if (exists(value, "private-key")) {
			obj.private_key = parsePrivateKey(location + "/private-key", value["private-key"], errors);
		}

		function parsePeerPort(location, value, errors) {
			if (type(value) in [ "int", "double" ]) {
				if (value > 65535)
					push(errors, [ location, "must be lower than or equal to 65535" ]);

				if (value < 1)
					push(errors, [ location, "must be bigger than or equal to 1" ]);

			}

			if (type(value) != "int")
				push(errors, [ location, "must be of type integer" ]);

			return value;
		}

		if (exists(value, "peer-port")) {
			obj.peer_port = parsePeerPort(location + "/peer-port", value["peer-port"], errors);
		}
		else {
			obj.peer_port = 3456;
		}

		function parsePeerExchangePort(location, value, errors) {
			if (type(value) in [ "int", "double" ]) {
				if (value > 65535)
					push(errors, [ location, "must be lower than or equal to 65535" ]);

				if (value < 1)
					push(errors, [ location, "must be bigger than or equal to 1" ]);

			}

			if (type(value) != "int")
				push(errors, [ location, "must be of type integer" ]);

			return value;
		}

		if (exists(value, "peer-exchange-port")) {
			obj.peer_exchange_port = parsePeerExchangePort(location + "/peer-exchange-port", value["peer-exchange-port"], errors);
		}
		else {
			obj.peer_exchange_port = 3458;
		}

		function parseRootNode(location, value, errors) {
			if (type(value) == "object") {
				let obj = {};

				function parseKey(location, value, errors) {
					if (type(value) != "string")
						push(errors, [ location, "must be of type string" ]);

					return value;
				}

				if (exists(value, "key")) {
					obj.key = parseKey(location + "/key", value["key"], errors);
				}

				function parseEndpoint(location, value, errors) {
					if (type(value) == "string") {
						if (!matchUcIp(value))
							push(errors, [ location, "must be a valid IPv4 or IPv6 address" ]);

					}

					if (type(value) != "string")
						push(errors, [ location, "must be of type string" ]);

					return value;
				}

				if (exists(value, "endpoint")) {
					obj.endpoint = parseEndpoint(location + "/endpoint", value["endpoint"], errors);
				}

				function parseIpaddr(location, value, errors) {
					if (type(value) == "array") {
						function parseItem(location, value, errors) {
							if (type(value) == "string") {
								if (!matchUcIp(value))
									push(errors, [ location, "must be a valid IPv4 or IPv6 address" ]);

							}

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

				if (exists(value, "ipaddr")) {
					obj.ipaddr = parseIpaddr(location + "/ipaddr", value["ipaddr"], errors);
				}

				return obj;
			}

			if (type(value) != "object")
				push(errors, [ location, "must be of type object" ]);

			return value;
		}

		if (exists(value, "root-node")) {
			obj.root_node = parseRootNode(location + "/root-node", value["root-node"], errors);
		}

		function parseHosts(location, value, errors) {
			if (type(value) == "array") {
				function parseItem(location, value, errors) {
					if (type(value) == "object") {
						let obj = {};

						function parseName(location, value, errors) {
							if (type(value) != "string")
								push(errors, [ location, "must be of type string" ]);

							return value;
						}

						if (exists(value, "name")) {
							obj.name = parseName(location + "/name", value["name"], errors);
						}

						function parseKey(location, value, errors) {
							if (type(value) != "string")
								push(errors, [ location, "must be of type string" ]);

							return value;
						}

						if (exists(value, "key")) {
							obj.key = parseKey(location + "/key", value["key"], errors);
						}

						function parseEndpoint(location, value, errors) {
							if (type(value) == "string") {
								if (!matchUcIp(value))
									push(errors, [ location, "must be a valid IPv4 or IPv6 address" ]);

							}

							if (type(value) != "string")
								push(errors, [ location, "must be of type string" ]);

							return value;
						}

						if (exists(value, "endpoint")) {
							obj.endpoint = parseEndpoint(location + "/endpoint", value["endpoint"], errors);
						}

						function parseSubnet(location, value, errors) {
							if (type(value) == "array") {
								function parseItem(location, value, errors) {
									if (type(value) == "string") {
										if (!matchUcCidr(value))
											push(errors, [ location, "must be a valid IPv4 or IPv6 CIDR" ]);

									}

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

						if (exists(value, "subnet")) {
							obj.subnet = parseSubnet(location + "/subnet", value["subnet"], errors);
						}

						function parseIpaddr(location, value, errors) {
							if (type(value) == "array") {
								function parseItem(location, value, errors) {
									if (type(value) == "string") {
										if (!matchUcIp(value))
											push(errors, [ location, "must be a valid IPv4 or IPv6 address" ]);

									}

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

						if (exists(value, "ipaddr")) {
							obj.ipaddr = parseIpaddr(location + "/ipaddr", value["ipaddr"], errors);
						}

						return obj;
					}

					if (type(value) != "object")
						push(errors, [ location, "must be of type object" ]);

					return value;
				}

				return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
			}

			if (type(value) != "array")
				push(errors, [ location, "must be of type array" ]);

			return value;
		}

		if (exists(value, "hosts")) {
			obj.hosts = parseHosts(location + "/hosts", value["hosts"], errors);
		}

		function parseVxlan(location, value, errors) {
			if (type(value) == "object") {
				let obj = {};

				function parsePort(location, value, errors) {
					if (type(value) in [ "int", "double" ]) {
						if (value > 65535)
							push(errors, [ location, "must be lower than or equal to 65535" ]);

						if (value < 1)
							push(errors, [ location, "must be bigger than or equal to 1" ]);

					}

					if (type(value) != "int")
						push(errors, [ location, "must be of type integer" ]);

					return value;
				}

				if (exists(value, "port")) {
					obj.port = parsePort(location + "/port", value["port"], errors);
				}
				else {
					obj.port = 4789;
				}

				function parseMtu(location, value, errors) {
					if (type(value) in [ "int", "double" ]) {
						if (value > 65535)
							push(errors, [ location, "must be lower than or equal to 65535" ]);

						if (value < 256)
							push(errors, [ location, "must be bigger than or equal to 256" ]);

					}

					if (type(value) != "int")
						push(errors, [ location, "must be of type integer" ]);

					return value;
				}

				if (exists(value, "mtu")) {
					obj.mtu = parseMtu(location + "/mtu", value["mtu"], errors);
				}
				else {
					obj.mtu = 1420;
				}

				function parseIsolate(location, value, errors) {
					if (type(value) != "bool")
						push(errors, [ location, "must be of type boolean" ]);

					return value;
				}

				if (exists(value, "isolate")) {
					obj.isolate = parseIsolate(location + "/isolate", value["isolate"], errors);
				}
				else {
					obj.isolate = true;
				}

				return obj;
			}

			if (type(value) != "object")
				push(errors, [ location, "must be of type object" ]);

			return value;
		}

		if (exists(value, "vxlan")) {
			obj.vxlan = parseVxlan(location + "/vxlan", value["vxlan"], errors);
		}

		return obj;
	}

	if (type(value) != "object")
		push(errors, [ location, "must be of type object" ]);

	return value;
}

return {
	validate: function(location, value, errors) {
		return moduleServiceUnet(location, value, errors);
	}
};
