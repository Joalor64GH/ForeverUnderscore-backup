package;

typedef LangDataDef =
{
	// MENUS
	var difficulties:Array<String>;
	var personalBest:String;
	var delScore:String;
	var delConfirm:String;
	var tracksText:String;
	var weekScoreText:String;
	var rateText:String;

	// PAUSE MENU
	var resumeSong:String;
	var restartSong:String;
	var editors:String;
	var changeDiff:String;
	var leaveChartingMode:String;
	var togglePractice:String;
	var toggleAutoplay:String;
	var exitOptions:String;
	var exitMenu:String;
	var songByTxt:String;
	var blueballedTxt:String;
	var backButton:String;
	// HUD INFO BAR
	var scoreTxt:String;
	var missTxt:String;
	var accTxt:String;
	var botTxt:String;
	// FILES
	var dialogueFileEnd:String;
	var dialogueFile:String;
}

/*
	a class used to set up typedefs for Game Localizations
	these are used by the game language option!
 */
class ForeverLocales
{
	public static var curLang:LangDataDef;

	public static function getLocale(language:String = 'english')
	{
		curLang = haxe.Json.parse(Paths.getTextFromFile('locales/$language/languageData.json'));
	}
}
