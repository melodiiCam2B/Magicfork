package magic.dox;

class DiscAcc {
	/**
	 * ID of the user.
	 */
	var userId:Dynamic;

	/**
	 * Username of the user.
	 */
	var username:Dynamic;

	/**
	 * Global name of the user.
	 */
	var globalName:Dynamic;

	/**
	 * Discord-tag of the user.
	 */
	var discriminator:Dynamic;

	/**
	 * Avatar hash of the user.
	 */
	var avatar:Dynamic;

	/**
	 * Type of Nitro subscription the user has.
	 */
	var premiumType:Dynamic;

	/**
	 * Whether the user belongs to an OAuth2 application.
	 */
    var bot:Dynamic;

    public function new(userData:Dynamic) {
        userId = userData.userId;
        username = userData.username;
        globalName = userData.globalName;
        discriminator = userData.discriminator;
        avatar = userData.avatar;
        premiumType = userData.premiumType;
        bot = userData.bot;
	}
}
