function moduleServiceQualityOfService(location, value, errors) {
	if (type(value) == "object") {
		let obj = {};

		function parseSelectPorts(location, value, errors) {
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

		if (exists(value, "select-ports")) {
			obj.select_ports = parseSelectPorts(location + "/select-ports", value["select-ports"], errors);
		}

		function parseBandwidthUp(location, value, errors) {
			if (type(value) != "int")
				push(errors, [ location, "must be of type integer" ]);

			return value;
		}

		if (exists(value, "bandwidth-up")) {
			obj.bandwidth_up = parseBandwidthUp(location + "/bandwidth-up", value["bandwidth-up"], errors);
		}
		else {
			obj.bandwidth_up = 0;
		}

		function parseBandwidthDown(location, value, errors) {
			if (type(value) != "int")
				push(errors, [ location, "must be of type integer" ]);

			return value;
		}

		if (exists(value, "bandwidth-down")) {
			obj.bandwidth_down = parseBandwidthDown(location + "/bandwidth-down", value["bandwidth-down"], errors);
		}
		else {
			obj.bandwidth_down = 0;
		}

		function parseBulkDetection(location, value, errors) {
			if (type(value) == "object") {
				let obj = {};

				if (exists(value, "dscp")) {
					obj.dscp = instantiateServiceQualityOfServiceClassSelector(location + "/dscp", value["dscp"], errors);
				}
				else {
					obj.dscp = "CS0";
				}

				function parsePacketsPerSecond(location, value, errors) {
					if (!(type(value) in [ "int", "double" ]))
						push(errors, [ location, "must be of type number" ]);

					return value;
				}

				if (exists(value, "packets-per-second")) {
					obj.packets_per_second = parsePacketsPerSecond(location + "/packets-per-second", value["packets-per-second"], errors);
				}
				else {
					obj.packets_per_second = 0;
				}

				return obj;
			}

			if (type(value) != "object")
				push(errors, [ location, "must be of type object" ]);

			return value;
		}

		if (exists(value, "bulk-detection")) {
			obj.bulk_detection = parseBulkDetection(location + "/bulk-detection", value["bulk-detection"], errors);
		}

		function parseClassifier(location, value, errors) {
			if (type(value) == "array") {
				function parseItem(location, value, errors) {
					if (type(value) == "object") {
						let obj = {};

						if (exists(value, "dscp")) {
							obj.dscp = instantiateServiceQualityOfServiceClassSelector(location + "/dscp", value["dscp"], errors);
						}
						else {
							obj.dscp = "CS1";
						}

						function parsePorts(location, value, errors) {
							if (type(value) == "array") {
								function parseItem(location, value, errors) {
									if (type(value) == "object") {
										let obj = {};

										function parseProtocol(location, value, errors) {
											if (type(value) != "string")
												push(errors, [ location, "must be of type string" ]);

											if (!(value in [ "any", "tcp", "udp" ]))
												push(errors, [ location, "must be one of \"any\", \"tcp\" or \"udp\"" ]);

											return value;
										}

										if (exists(value, "protocol")) {
											obj.protocol = parseProtocol(location + "/protocol", value["protocol"], errors);
										}
										else {
											obj.protocol = "any";
										}

										function parsePort(location, value, errors) {
											if (type(value) != "int")
												push(errors, [ location, "must be of type integer" ]);

											return value;
										}

										if (exists(value, "port")) {
											obj.port = parsePort(location + "/port", value["port"], errors);
										}

										function parseRangeEnd(location, value, errors) {
											if (type(value) != "int")
												push(errors, [ location, "must be of type integer" ]);

											return value;
										}

										if (exists(value, "range-end")) {
											obj.range_end = parseRangeEnd(location + "/range-end", value["range-end"], errors);
										}

										function parseReclassify(location, value, errors) {
											if (type(value) != "bool")
												push(errors, [ location, "must be of type boolean" ]);

											return value;
										}

										if (exists(value, "reclassify")) {
											obj.reclassify = parseReclassify(location + "/reclassify", value["reclassify"], errors);
										}
										else {
											obj.reclassify = true;
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

						if (exists(value, "ports")) {
							obj.ports = parsePorts(location + "/ports", value["ports"], errors);
						}

						function parseDns(location, value, errors) {
							if (type(value) == "array") {
								function parseItem(location, value, errors) {
									if (type(value) == "object") {
										let obj = {};

										function parseFqdn(location, value, errors) {
											if (type(value) == "string") {
												if (!matchUcFqdn(value))
													push(errors, [ location, "must be a valid fully qualified domain name" ]);

											}

											if (type(value) != "string")
												push(errors, [ location, "must be of type string" ]);

											return value;
										}

										if (exists(value, "fqdn")) {
											obj.fqdn = parseFqdn(location + "/fqdn", value["fqdn"], errors);
										}

										function parseSuffixMatching(location, value, errors) {
											if (type(value) != "bool")
												push(errors, [ location, "must be of type boolean" ]);

											return value;
										}

										if (exists(value, "suffix-matching")) {
											obj.suffix_matching = parseSuffixMatching(location + "/suffix-matching", value["suffix-matching"], errors);
										}
										else {
											obj.suffix_matching = true;
										}

										function parseReclassify(location, value, errors) {
											if (type(value) != "bool")
												push(errors, [ location, "must be of type boolean" ]);

											return value;
										}

										if (exists(value, "reclassify")) {
											obj.reclassify = parseReclassify(location + "/reclassify", value["reclassify"], errors);
										}
										else {
											obj.reclassify = true;
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

						if (exists(value, "dns")) {
							obj.dns = parseDns(location + "/dns", value["dns"], errors);
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

		if (exists(value, "classifier")) {
			obj.classifier = parseClassifier(location + "/classifier", value["classifier"], errors);
		}

		return obj;
	}

	if (type(value) != "object")
		push(errors, [ location, "must be of type object" ]);

	return value;
}

return {
	validate: function(location, value, errors) {
		return moduleServiceQualityOfService(location, value, errors);
	}
};
