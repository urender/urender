/**
 * @class uRender.shell
 * @classdesc
 *
 * The shell utility class provides high level abstractions for various
 * shell interaction tasks.
 */

/** @lends uRender.shell.prototype */

return {
	/**
	 * Set a random root password.
	 *
	 * Generate a random passphrase and set it as root password,
	 * do not change the password if a random password has been
	 * set already since the last reboot.
	 */
	password: function(random) {
		let passwd = "OpenWrt";

		if (random) {
			let math = require("math");
			passwd = '';
			for (let i = 0; i < 32; i++) {
				let r = math.rand() % 62;
				if (r < 10)
					passwd += r;
			else if (r < 36)
					passwd += sprintf("%c", 55 + r);
				else
					passwd += sprintf("%c", 61 + r);
			}
		}
		system("(echo " + passwd + "; sleep 1; echo " + passwd + ") | passwd root");
		conn.call("urender", "password", { passwd });
	}
};
