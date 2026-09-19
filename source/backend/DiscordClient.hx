package backend;

import lime.app.Application;

import backend.discord.ClientICP;
import backend.discord.DiscordDefs.UserData;
import backend.discord.DiscordDefs.PresenceData;
import backend.discord.DiscordDefs.ButtonData;

using StringTools;
/**
 * wrapper class for the discord RPC!
 */
class DiscordClient {
    public static var client:ClientICP;

    public static var user:UserData;
    
    // the actual data being pushed through
    public static var new_presence:PresenceData;

    // manual set 'old' as a failsave
    public static var old_presence:PresenceData;

    public static var toggle:Bool;
    private inline static final _defaultID:String = "1539657385650684064";
    public static var clientId(default, set):String = _defaultID;

    /**
     * Starts the Rich Presence status.
     */
    public static function prepare(?_toggle:Bool):Void {
        #if (!windows && !cpp)
        Sys.println('You are compiling this library on a non windows target');
        return;
        #end
        toggle = _toggle;
        new_presence = null;
        old_presence = { 
            state: 'initializing',
            details: 'booting up rpc',

            smallImageKey: 'icon',
            smallImageText: 'temp',

            largeImageKey: 'icon',
            largeImageText: 'temp',
        }
        client = new ClientICP(clientId, onFinish, toggle);
        client.initialize();

        Application.current.window.onClose.add(function() {
			if(client.initialized()) shutdown();
		});
    }

    public static function onFinish(connected:Bool, user:UserData):Void {
        if (connected && user != null)
            client.logger.log('Connected successfully to ${user.username} (${user.userId})!');
        else if (connected && user == null) 
            client.logger.log("Discord IPC failed to connect or user data was invalid.");
        
    }

    public static function check():Void {
		if(ClientPrefs.data.discordRPC) client.initialize();
		else if(client != null) shutdown();
	}

    inline public static function resetClient():Void {
		clientId = _defaultID;
    }

	public static function set_clientId(newID:String) {
		var change:Bool = (clientId != newID);
		clientId = newID;

		if(change && client != null) {
			client.shutdown();
			client = new ClientICP(clientId, onFinish, toggle);
            client.initialize();
			revertPresence();
            updatePresence();
		}
		return newID;
	}

	#if MODS_ALLOWED
	public static function loadModRPC() {
		var pack:Dynamic = Mods.getPack();
		if(pack != null && pack.discordRPC != null && pack.discordRPC != clientId)
			clientId = pack.discordRPC;
	}
	#end

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "changeDiscordPresence", changePresence);
		Lua_helper.add_callback(lua, "changeDiscordclientId", function(?newID:String) {
			if(newID == null) newID = _defaultID;
			clientId = newID;
		});
	}
	#end
  
    public static function changePresence(details:String = 'In the Menus', ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?et:Float = 0, largeImageKey:String = 'icon') {
        if (client == null) return;
		var st:Float = 0;
		if (et < 0) st = Date.now().getTime();
		if (et > 0) et = st + et;

        new_presence = {
            state: state,
            details: details,
            smallImageKey: smallImageKey,
            largeImageKey: largeImageKey,
            largeImageText: 'Magicfork version: 1.0',
            startTimestamp: Std.int(st / 1000),
            endTimestamp: Std.int(et / 1000)
        }

        if (new_presence == null) 
            revertPresence();
            
        updatePresence();
    }

    /**
     * run before `changePresence` to take effect, this changes party things
    */
    public static function changeParty(i:String, ?s:Int, ?m:Int, ?k:String) {
        if (client == null) return;
        new_presence = {
            partyId: i,
            partySize: s,
            partyMax: m,
            joinSecret: k
        }

        if (new_presence == null) 
            revertPresence();
            
        updatePresence();
	}

    /**
     * Updates the Rich Presence status.
     */
    public static function _changePresence(s:String, d:String, ?skey:String, ?sstr:String, ?lkey:String, ?lstr:String, ?et:Float = 0) {
        if (client == null) return;
		var st:Float = 0;
		if (et < 0) st = Date.now().getTime();
		if (et > 0) et = st + et;

        new_presence = {
            state: s,
            details: d,
            smallImageKey: skey,
            smallImageText: sstr,
            largeImageKey: lkey,
            largeImageText: lstr,
            startTimestamp: Std.int(st / 1000),
            endTimestamp: Std.int(et / 1000)
        }

        if (new_presence == null) 
            revertPresence();
            
        updatePresence();
	}

    /**
     * adds buttons to the active rich presence
     */
    public static function changeButton(?fname:String, ?flink:String, ?sname:String, ?slink:String) {
        if (client == null) return;
        var buttons:Array<ButtonData> = [];

        if(validate(flink)){
            if (fname != null && flink != null) 
                buttons.push({ label: fname, url: flink });
            else client.logger.log('Invalid arguments flagged: $fname and $flink are null');
        } else client.logger.log('Invalid link flagged: $flink should be https://');

        if(validate(slink)){
            if (sname != null && slink != null) 
                buttons.push({ label: sname, url: slink });
            else client.logger.log('Invalid arguments flagged: $sname and $slink are null');
        } else client.logger.log('Invalid link flagged: $slink should be https://');

        new_presence.buttons = buttons;

        if (new_presence == null) 
            revertPresence();
            
        updatePresence();
	}


    // \t pretty print
    public static function updatePresence():Void 
        client.setPresence(new_presence, null, backupPresence);

    // backs up the last presence only if the change was successful
    public static function backupPresence():Void {
        if (old_presence != new_presence)
            old_presence = new_presence;
    }

    // set 'new' to old in case 'new' is null
    public static function revertPresence():Void 
        new_presence = old_presence;
        
    /**
     * Stops the Rich Presence status. and clears the data
     */
    public static function shutdown():Void {
        user = null;
        new_presence = null;
        old_presence = null;
        client.shutdown();
        client = null;
    }

    public static function validate(url:String):Bool 
        return url != null && url != "" && (url.indexOf("http://") == 0 || url.indexOf("https://") == 0);
}