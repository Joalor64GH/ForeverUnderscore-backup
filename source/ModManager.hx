package;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

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

	public static function getModFile(file:String, ?type:AssetType)
	{
		for (folder in getModFolders())
		{
			var modFile:String = 'mods/$folder/$file';
			try
			{
				if (!sys.FileSystem.exists(modFile))
					modFile = base.CoolUtil.swapSpaceDash(modFile);
				return modFile;
			}
			catch(e)
			{
				//trace('$modFile is null, trying method 2');
				try
				{
					if (OpenFlAssets.exists(modFile, type))
						return modFile;
				}
				catch (e)
				{
					//trace('$file is null');
					return null;
				}
			}
		}
		//trace('$file is null');
		return null;
	}
}
