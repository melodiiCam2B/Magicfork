package magic.utils;

class GitUtil {
    public static macro  function getNum():haxe.macro.Expr.ExprOf<String>{
		var commit = new sys.io.Process('git', ['rev-list', 'HEAD', '--count'], false);
		var commitNumn:String = "";
		try {
			commitNumn = commit.stdout.readLine();
			commit.exitCode(true);
		}catch (e){}

        return macro $v{commitNumn};
    }

    public static macro  function getHash():haxe.macro.Expr.ExprOf<String>{
		var hash = new sys.io.Process('git', ['rev-parse', '--short', 'HEAD'], false);
		var commitHash:String = "";
		try {
            commitHash = hash.stdout.readLine();
            hash.exitCode(true);
		}catch (e){}

        return macro $v{commitHash};
    }
    public static macro  function getBranch():haxe.macro.Expr.ExprOf<String>{
		var branch = new sys.io.Process('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
		var branchName:String = "";
		try {
			branchName = branch.stdout.readLine();
			branch.exitCode(true);
		}catch (e){}

        return macro $v{branchName};
    }
}