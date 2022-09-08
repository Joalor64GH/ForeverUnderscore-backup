package;

import base.CoolUtil;
import sys.FileSystem;
import sys.io.File;

/**
 * a class to handle mod folders and such
 * the code from it is NOT MINE
 * it's from Psych Engine, so all credit goes to shadowmario and his team
 * while i'd like to make my own system, I don't even know how or where to start
 * this system is **temporary**;
 */
class ModHandler
{
	public static final modDirectory:String = 'mods';
	public static final modListPath:String = 'mods/mods.txt';

	public static var modDirs:Array<String> = [];
	public static var currentModDir:String = '';

    public static var modList:Map<String, Bool> = new Map<String, Bool>();

	inline public static function getMod(key:String)
	{
		#if MOD_HANDLER
		return '${modDirectory}/$key';
		#end
	}

	public static function getModPath(key:String)
	{
		#if MOD_HANDLER
        if (currentModDir != null && currentModDir.length > 0)
        {
            var newModDir:String = getMod(currentModDir + '/' + key);
            if (modList.get(currentModDir) && FileSystem.exists(newModDir))
                return newModDir;
        }
        var path:String = getMod('$currentModDir/$key');
        if (FileSystem.exists(path))
        {
            return path;
			#if DEBUG_TRACES trace('new path: ' + path); #end
        }
        #if DEBUG_TRACES trace('oh no, $path is returning null, NOOOOOOOOOO'); #end
        return null;
		#end
    }

	public static function saveModList()
	{
		#if MOD_HANDLER
		var fileStr:String = '';
		for (mod in modList.keys())
		{
			if (fileStr.length > 0)
				fileStr += '\n';
			fileStr += mod + '=' + (modList.get(mod) ? 'true' : 'false');
		}
		File.saveContent(modListPath, fileStr);
		#end
	}

	public static function loadModList()
	{
		#if MOD_HANDLER
		if (!FileSystem.exists(modListPath))
			saveModList();
		// first read the file
		var rawModList:Array<String> = CoolUtil.coolTextFile(modListPath);
		for (mod in rawModList)
		{
			if (rawModList.length > 1 && rawModList[0].length > 0)
			{
				var modSplit:Array<String> = mod.split('|');
				modList.set(modSplit[0], modSplit[1] == 'true');
			}
		}
		for (directory in modDirs)
			if (!modList.exists(directory))
				modList.set(directory, false);
		#end
	}

	public static function loadModDirs()
	{
		#if MOD_HANDLER
		var dirs:Array<String> = FileSystem.readDirectory(modDirectory);
		modDirs = [];
		for (dir in dirs)
		{
			if (FileSystem.isDirectory(getMod(dir)))
				modDirs.push(dir);
		}
		#if DEBUG_TRACES trace('MODS: ' + modDirs); #end
		#end
	}

	public static function loadFirst()
	{
		#if MOD_HANDLER
		currentModDir = 'default';
		for (mod in modList.keys())
		{
			if (modList.get(mod))
			{
				currentModDir = mod;
				break;
			}
		}
		#if DEBUG_TRACES trace('CURRENT MOD: ' + currentModDir); #end
		#end
	}
}