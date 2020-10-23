/**
 * @class uRender.files
 * @classdesc
 *
 * The files utility class manages non-uci file attachments which are
 * produced during schema rendering.
 */

/** @lends uRender.files.prototype */

return {
	/** @private */
	files: {},

	/**
	 * The base directory for file attachments.
	 *
	 * @readonly
	 */
	basedir: '/tmp/urender',

	/**
	 * Escape the given string.
	 *
	 * Escape any slash and tilde characters in the given string to allow
	 * using it as part of a JSON pointer expression.
	 *
	 * @param {string} s  The string to escape
	 * @returns {string}  The escaped string
	 */
	escape: function(s) {
		return replace(s, /[~\/]/g, m => (m == '~' ? '~0' : '~1'));
	},

	/**
	 * Add a named file attachment.
	 *
	 * Stores the given content in a file at the given path. Expands the
	 * path relative to the `basedir` if it is not absolute.
	 *
	 * @param {string} path  The file path
	 * @param {*} content    The content to store
	 */
	add_named: function(path, content) {
		if (index(path, '/') != 0)
			path = this.basedir + '/' + path;

		this.files[path] = content;
	},

	/**
	 * Add an anonymous file attachment.
	 *
	 * Stores the given content in a file with a random name derived from
	 * the given location pointer and name hint.
	 *
	 * @param {string} location  The current location within the state we're traversing
	 * @param {string} name      The name hint
	 * @param {*} content        The content to store
	 *
	 * @returns {string}
	 * Returns the generated random file path.
	 */
	add_anonymous: function(location, name, content) {
		let path = this.basedir + '/' + this.escape(location) + '/' + this.escape(name);

		this.files[path] = content;

		return path;
	},

	/**
	 * Purge the file attachment storage.
	 *
	 * Recursively deletes the file attachment storage and places any error
	 * messages in the given logs array.
	 *
	 * @param {array} logs  The array to store log messages into
	 */
	purge: function(logs, dir) {
		if (dir == null)
			dir = this.basedir;

		let d = fs.opendir(dir);

		if (d) {
			let e;

			while ((e = d.read()) != null) {
				if (e == '.' || e == '..')
					continue;
				let p = dir + '/' + e,
				    s = fs.lstat(p);

				if (s == null)
					push(logs, sprintf("[W] Unable to lstat() path '%s': %s", p, fs.error()));
				else if (s.type == 'directory')
					this.purge(logs, p);
				else if (!fs.unlink(p))
					push(logs, sprintf("[W] Unable to unlink() path '%s': %s", p, fs.error()));
			}

			d.close();

			if (dir != this.basedir && !fs.rmdir(dir))
				push(logs, sprintf("[W] Unable to rmdir() path '%s': %s", dir, fs.error()));
		}
		else {
			push(logs, sprintf("[W] Unable to opendir() path '%s': %s", dir, fs.error()));
		}
	},

	/**
	 * Recursively create the parent directories of the given path.
	 *
	 * Recursively creates the parent directory structure of the given
	 * path and places any error messages in the given logs array.
	 *
	 * @param {array} logs   The array to store log messages into
	 * @param {string} path  The path to create directories for
	 * @return {boolean}
	 * Returns `true` if the parent directories were successfully created
	 * or did already exist, returns `false` in case an error occurred.
	 */
	mkdir_path: function(logs, path) {
		assert(index(path, '/') == 0, "Expecting absolute path");

		let segments = split(path, '/'),
		    tmppath = shift(segments);

		for (let i = 0; i < length(segments) - 1; i++) {
			tmppath += '/' + segments[i];

			let s = fs.stat(tmppath);

			if (s != null && s.type == 'directory')
				continue;

			if (fs.mkdir(tmppath))
				continue;

			push(logs, sprintf("[E] Unable to mkdir() path '%s': %s", tmppath, fs.error()));

			return false;
		}

		return true;
	},

	/**
	 * Write the staged file attachement contents to the filesystem.
	 *
	 * Writes the staged attachment contents that were gathered during state
	 * rendering to the file system and places any encountered errors into
	 * the logs array.
	 *
	 * @param {array} logs  The array to store error messages into
	 * @return {boolean}
	 * Returns `true` if all attachments were written succefully, returns
	 * `false` if one or more attachments could not be written.
	 */
	write: function(logs) {
		let success = true;

		for (let path, content in this.files) {
			if (!this.mkdir_path(logs, path)) {
				success = false;
				continue;
			}

			let f = fs.open(path, "w");

			if (f) {
				f.write(content);
				f.close();
			}
			else {
				push(logs, sprintf("[E] Unable to open() path '%s' for writing: %s", path, fs.error()));
				success = false;
			}
		}

		return success;
	}
};
