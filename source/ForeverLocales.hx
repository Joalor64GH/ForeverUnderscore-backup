package;

typedef LangDataDef =
{
	// FONTS
	var useCustomFont:Bool;
	var fontPath:String;
	var fontKey:String;

	// MENUS
	var difficultyNames:Array<String>;

	// HUD INFO BAR
	var scoreTxt:String;
	var missTxt:String;
	var accTxt:String;
	var botTxt:String;

	// DIALOGUE
	var skipText:String;
	var dialogueFileEnd:String;
	var dialogueFile:String;

	// STORY MENU
	var weekScoreText:String;
	var tracksText:String;

	// FREEPLAY MENU
	var personalBest:String;
	var delScore:String;
	var delConfirm:String;
	var rateText:String;
	var dataCleared:String;

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
		try
		{
			curLang = haxe.Json.parse(Paths.getTextFromFile('locales/$language/languageData.json'));
		}
		catch (e)
		{
			curLang = haxe.Json.parse('{
				"difficultyNames": [
					"EASY",
					"NORMAL",
					"HARD"
				],

				"scoreTxt": "Score:",
				"missTxt": "Combo Breaks:",
				"accTxt": "Accuracy:",
				"botTxt": "[AUTOPLAY]",

				"skipText": "PRESS SHIFT TO SKIP",
				"dialogueFile": "dialogue",
				"dialogueFileEnd": "dialogueEnd",

				"weekScoreText": "WEEK SCORE:",
				"tracksText": "TRACKS",

				"personalBest": "PERSONAL BEST:",
				"delScore": "RESET SCORE?",
				"delConfirm": "CONFIRM",
				"dataCleared": "DATA CLEARED",
				"rateText": "RATE:",

				"resumeSong": "Resume",
				"restartSong": "Restart Song",
				"editors": "Open Editors",
				"changeDiff": "Change Difficulty",
				"leaveChartingMode": "Leave Charting Mode",
				"togglePractice": "Toggle Practice Mode",
				"toggleAutoplay": "Toggle Autoplay",
				"exitOptions": "Exit to Options Menu",
				"exitMenu": "Exit to Main Menu",
				"songByTxt": "By:",
				"blueballedTxt": "Blue balled:",
				"backButton": "BACK"
			}');
		}
	}
}
