package magic.utils;

class FileUtil {
	public static function moveUpdate(directory:String, ?ignore:Array<String>) {
		if(FileSystem.exists(directory)) {
            for (folder in FileSystem.readDirectory(directory)) {
                var path = haxe.io.Path.join([directory, folder]);
				if(check(folder, path, ignore)) move(path, 'assets/$folder');
            }
        }
	}

    public static function delete(path:String) {
		if (FileSystem.isDirectory(path)) {
			for (file in FileSystem.readDirectory(path)) {
				delete(Path.join([path, file]));
			}
			FileSystem.deleteDirectory(path);
		}
		else
			FileSystem.deleteFile(path);
	}

	public static function copy(from:String, to:String) {
		trace('moving from: $from, to: $to');
		if (!FileSystem.exists(Path.directory(to)))
			FileSystem.createDirectory(Path.directory(to));
		
		if (FileSystem.isDirectory(from)) 
			for (file in FileSystem.readDirectory(from)) 
				copy(Path.join([from, file]), Path.join([to, file]));
		else 
			File.copy(from, to);
	}
	
	public static function openFile(path:String) 
		Sys.command('start ' + Path.normalize(path));

    public static var list:Array<String> = [];
    public static function parse(directory:String, fileExt:String, ?force:Array<String>) {
		list = force;
        if(FileSystem.exists(directory)) {
            for (file in FileSystem.readDirectory(directory)) {
                var path = haxe.io.Path.join([directory, file]);
                if(list.contains(file))  continue;
                if (!FileSystem.isDirectory(path)){
                    if(file.contains(fileExt))
                        list.push(file);
                }
            }
        }
    }

	public static function move(from:String, to:String) {
        from = Path.normalize(from);
		to = Path.normalize(to);

		copy(from, to);
		delete(from);
    }

	public static function check(folder:String, path:String, ?ignore:Array<String>) {
		if (FileSystem.isDirectory(path) && !ignore.contains(folder))
			return true;
		else 
			return false;
	}
}