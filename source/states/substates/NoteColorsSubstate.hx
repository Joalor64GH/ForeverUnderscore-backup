package states.substates;

import base.MusicBeat.MusicBeatSubstate;
import flixel.FlxSprite;

class NoteColorsSubstate extends MusicBeatSubstate
{
    public function new()
    {
        super();
        
		var bg = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.set(0, 0.18);
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xCE64DF;
		bg.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		add(bg);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.BACK)
            close();
    }
}