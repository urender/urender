/**
 * @class uRender.local_profile
 * @classdesc
 *
 * The local profile utility class provides access to the uRender runtome
 * profile information.
 */

/** @lends uRender.local_profile.prototype */

return {
	/**
	 * Retrieve the local uRender profile data.
	 *
	 * Parses the local uRender profile JSON data and returns the
	 * resulting object.
	 *
	 * @return {?object}
	 * Returns an object containing the profile data or `null` on error.
	 */
	get: function() {
		let profile_file = fs.open("/etc/urender/profile.json");

		if (!profile_file)
			return null;

		let profile = json(profile_file.read("all"));

		profile_file.close();

		return profile;
	}
};
