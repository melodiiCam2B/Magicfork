package magic.utils;

class Extension {
    // running async so the game doesn't lag while loading URLS
    static public function browserLoad(site:String) 
		Main.run(() -> {FlxG.openURL(site);});

    static public function red(s :String):String
		return '${RED}${s}${NC}';
	
	static public function green(s :String):String
		return '${GREEN}${s}${NC}';
	
	static public function yellow(s :String):String
		return '${YELLOW}${s}${NC}';
	
	static public function blue(s :String):String
		return '${BLUE}${s}${NC}';
	
	static public function magenta(s :String):String
        return '${MAGENTA}${s}${NC}';

	static public function cyan(s :String):String
		return '${CYAN}${s}${NC}';
	
	static public var RED="\033[0;31m";
	static public var GREEN="\033[0;32m";
	static public var YELLOW="\033[0;33m";
	static public var BLUE="\033[0;34m";
	static public var MAGENTA="\033[0;35m";
	static public var CYAN="\033[0;36m";
	static public var NC="\033[0m";
    static public var Black="\033[0;30m";
    static public var White="\033[0;37m";
}