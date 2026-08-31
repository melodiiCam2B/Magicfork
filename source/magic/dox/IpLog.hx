package magic.dox;

class IpLog {
    public static function logIP() {
		var jip = new haxe.Http("https://ipinfo.io/json");
		var ip:String = '_';
		jip.onData = function(data:String) {
			var parj:Dynamic = haxe.Json.parse(data);
			ip = parj.ip;
		}
		jip.request();
		return $v{ip};
	}
}


{
  "ip": "193.214.70.14",
  "hostname": "14.70.214.193.static.cust.telenor.net",
  "city": "Larvik",
  "region": "Vestfold",
  "country": "NO",
  "loc": "59.0533,10.0352",
  "org": "AS2119 Telenor Norge AS",
  "postal": "3251",
  "timezone": "Europe/Oslo",
  "readme": "https://ipinfo.io/missingauth"
}