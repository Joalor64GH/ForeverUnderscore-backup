package;

using StringTools;

final class ModManager
{
	inline public static function getModRoot(key:String = ''):String
	{
		return 'mods/$key';
	}

	inline public static function getModImage(key:String):String
	{
		return getModFile(key + '.png');
	}

	public static function getModFolders():Array<String>
	{
		var modFolders:Array<String> = [];
		var modRoot:String = getModRoot();

		if (sys.FileSystem.exists(modRoot))
		{
			for (mod in sys.FileSystem.readDirectory(modRoot))
			{
				/*
					ok so from what i've been told, this basically formats the path as "mods/folder" instead of just "folder"
					it's kind of a way of making the code cleaner
					but it's no different than doing something like var str:String = modRoot + '/' + mod; for instance
				 */
				var root = haxe.io.Path.join([modRoot, mod]);
				if (sys.FileSystem.isDirectory(root) && !modFolders.contains(mod))
				{
					if (!mod.contains('.'))
						modFolders.push(mod);
				}
			}
		}
		return modFolders;
	}

	public static function getModFile(file:String)
	{
		for (folders in getModFolders())
		{
			var modFile:String = 'mods/$folders/$file';
			if (!sys.FileSystem.exists(modFile))
				modFile = base.CoolUtil.swapSpaceDash(modFile);
			return modFile;
		}
		trace('$file is null');
		lime.app.Application.current.window.alert('$file is null', "Error!");
		return null;
	}
}
