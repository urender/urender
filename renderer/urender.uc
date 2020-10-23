#!/usr/bin/ucode

let param = json(ARGV[0]);

push(REQUIRE_SEARCH_PATH,
	'/usr/lib/ucode/*.so',
	'/usr/share/urender/*.uc');

let schemareader = require('schemareader');
let renderer = require('renderer');
let fs = require('fs');

let inputfile = fs.open(param.config, 'r');
let inputjson = json(inputfile.read('all'));

let error = 0;

inputfile.close();
let logs = [];

function set_service_state(state) {
	for (let service, enable in renderer.services_state()) {
		if (enable != state)
			continue;
		printf('%s %s\n', service, enable ? 'starting' : 'stopping');
		system(`/etc/init.d/${ service} ${enable ? 'start' : 'stop'}`);
	}
	system('/etc/init.d/dnsmasq restart');
}

try {
	for (let cmd in [ 'rm -rf /tmp/urender',
			  'mkdir /tmp/urender',
			  'rm -f /tmp/dnsmasq.conf',
			  'touch /tmp/dnsmasq.conf' ])
		system(cmd);

	let state = schemareader.validate(inputjson, logs);

	let batch = state ? renderer.render(state, logs) : '';

	fs.stdout.write('Log messages:\n' + join('\n', logs) + '\n\n');

	if (param.verbose)
		fs.stdout.write('UCI batch output:\n' + batch + '\n');

	if (!param.test && state) {
		let outputjson = fs.open('/tmp/urender.uci', 'w');
		outputjson.write(batch);
		outputjson.close();

		for (let cmd in [ 'rm -rf /tmp/config-shadow',
				  'cp -r /etc/config-shadow /tmp' ])
			system(cmd);

		let apply = fs.popen('/sbin/uci -q -c /tmp/config-shadow batch', 'w');
		apply.write(batch);
		apply.close();

		renderer.write_files(logs);

		set_service_state(false);

		for (let cmd in [ 'uci -q -c /tmp/config-shadow commit',
				  'cp /tmp/config-shadow/* /etc/config/',
				  'rm -rf /tmp/config-shadow',
				  'reload_config',
				  '/etc/init.d/dnsmasq restart',
				  'wifi'])
			system(cmd);

		set_service_state(true);
	} else {
		error = 1;
	}
	if (!length(batch))
		error = 2;
	else if (length(logs))
		error = 1;
}
catch (e) {
	error = 2;
	warn('Fatal error while generating UCI: ', e, '\n');
	if (param.debug)
		warn(e.stacktrace[0].context, '\n');
}
