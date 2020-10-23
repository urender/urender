/* UCI batch output main script */

"use strict";

let uci = require("uci");
let ubus = require("ubus");
let fs = require("fs");

let cursor = uci ? uci.cursor() : null;
let conn = ubus ? ubus.connect() : null;

let capabfile = fs.open("/etc/urender/capabilities.json", "r");
let capab = capabfile ? json(capabfile.read("all")) : null;

let serial = cursor.get("urender", "config", "serial");

assert(cursor, "Unable to instantiate uci");
assert(conn, "Unable to connect to ubus");
assert(capab, "Unable to load capabilities");

global.topdir = sourcepath(0, true);
global.fs = fs;
global.cursor = cursor;
global.conn = conn;
global.capab = capab;

push(REQUIRE_SEARCH_PATH, sprintf('%s/lib/*.uc', topdir));

/**
 * Formats a given input value as uci boolean value.
 *
 * @memberof uRender.prototype
 * @param {*} val The value to format
 * @returns {string}
 * Returns '1' if the given value is truish (not `false`, `null`, `0`,
 * `0.0` or an empty string), or `0` in all other cases.
 */
function b(val) {
	return val ? '1' : '0';
}

/**
 * Formats a given input value as single quoted string, honouring uci
 * specific escaping semantics.
 *
 * @memberof uRender.prototype
 * @param {*} str The string to format
 * @returns {string}
 * Returns an empty string if the given input value is `null` or an
 * empty string. Returns the escaped and quoted string in all other
 * cases.
 */
function s(str) {
	if (str === null || str === '')
		return '';

	return sprintf("'%s'", replace(str, /'/g, "'\\''"));
}

/**
 * Attempt to include a file, catching potential exceptions.
 *
 * Try to include the given file path in a safe manner. The
 * path is resolved relative to the path of the currently
 * executed template and may only contain the character `A-Z`,
 * `a-z`, `0-9`, `_`, `/` and `-` as must contain a final
 * `.uc` file extension.
 *
 * Exception occuring while including the file are catched
 * and a warning is emitted instead.
 *
 * @memberof uRender.prototype
 * @param {string} path Path of the file to include
 * @param {object} scope The scope to pass to the include file
 */
function tryinclude(path, scope) {
	if (!match(path, /^[A-Za-z0-9_\/-]+\.uc$/)) {
		warn("Refusing to handle invalid include path '%s'", path);
		return;
	}

	let parent_path = sourcepath(1, true);

	assert(parent_path, "Unable to determine calling template path");

	try {
		include(parent_path + "/" + path, scope);
	}
	catch (e) {
		warn("Unable to include path '%s': %s\n%s", path, e, e.stacktrace[0].context);
	}
}

/* include all the helper libraries */
let ethernet = require('ethernet');
let files = require('files');
let ipcalc = require('ipcalc');
let local_profile = require('local_profile');
let routing_table = require('routing_table');
let services = require('services');
let shell = require('shell');
let wiphy = require('wiphy');

/**
 * @constructs
 * @name uRender
 * @classdesc
 *
 * The uRender namespace is not an actual class but merely a virtual
 * namespace for documentation purposes.
 *
 * From the perspective of a template author, the uRender namespace
 * is the global root level scope available to embedded code, so
 * methods like `uRender.b()` or `uRender.info()` or utlity classes
 * like `uRender.files` or `uRender.wiphy` are available to templates
 * as `b()`, `info()`, `files` and `wiphy` respectively.
 */
return /** @lends uRender.prototype */ {
	render: function(state, logs) {
		logs = logs || [];

		/** @lends uRender.prototype */
		return render('templates/toplevel.uc', {
			b,
			s,
			tryinclude,
			state,

			/** @member {uRender.wiphy} */
			wiphy,

			/** @member {uRender.ethernet} */
			ethernet,

			/** @member {uRender.ipcalc} */
			ipcalc,

			/** @member {uRender.services} */
			services,

			/** @member {uRender.local_profile} */
			local_profile,
			location: '/',
			cursor,
			capab,

			/** @member {uRender.files} */
			files,

			/** @member {uRender.shell} */
			shell,

			/** @member {uRender.routing_table} */
			routing_table,
			serial,

			/**
			 * Emit a warning message.
			 *
			 * @memberof uRender.prototype
			 * @param {string} fmt  The warning message format string
			 * @param {...*} args	Optional format arguments
			 */
			warn: (fmt, ...args) => push(logs, sprintf("[W] (In %s) ", location || '/') + sprintf(fmt, ...args)),

			/**
			 * Emit an informational message.
			 *
			 * @memberof uRender.prototype
			 * @param {string} fmt  The information message format string
			 * @param {...*} args	Optional format arguments
			 */
			info: (fmt, ...args) => push(logs, sprintf("[!] (In %s) ", location || '/') + sprintf(fmt, ...args))
		});
	},

	write_files: function(logs) {
		logs = logs || [];

		files.purge(logs);

		return files.write(logs);
	},

	files_state: function() {
		return files.files;
	},

	services_state: function() {
		return services.state;
	}
};
