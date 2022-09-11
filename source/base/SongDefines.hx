package base;

/**
 * just an idea, I don't think i'm actually doing so;
 * Custom Song Note and Event Format;
 */

//
typedef SongNote =
{
	var noteData:Int;
    var strumTime:Float;
    var sustainLength:Float;
    var noteType:String;
    var animString:String;
}

typedef SongEvent =
{
	var strumTime:Float;
	var name:String;
	var value1:String;
	var value2:String;
	var ?description:String;
}
