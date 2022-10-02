package;

typedef LangDataDef =
{
	// GENERAL
	var difficulties:Array<String>;
	var personalBest:String;
	var tracksText:String;
	var weekScoreText:String;

	// HUD INFO BAR
	var scoreTxt:String;
	var missTxt:String;
	var accTxt:String;
}

class ForeverLocales
{
    public static var curLang:LangDataDef;

    public static function getLocale(language:String = 'english')
    {
		curLang = haxe.Json.parse(Paths.getTextFromFile('locales/$language/languageData.json'));
    }
}