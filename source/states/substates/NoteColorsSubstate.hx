package states.substates;

import base.MusicBeat.MusicBeatSubstate;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.Alphabet;

class NoteColorsSubstate extends MusicBeatSubstate
{
    public var alphabetGroup:FlxTypedGroup<Alphabet>;

    public var menuThing:Array<String> = ['WORK IN PROGRESS', 'NOTHING TO SEE HERE'];

    public function new()
    {
        super();
        
		var bg = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.set(0, 0.18);
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xCE64DF;
		bg.antialiasing = !Init.getSetting('Disable Antialiasing');
		add(bg);

        alphabetGroup = new FlxTypedGroup<Alphabet>();
        add(alphabetGroup);

        for (i in 0...menuThing.length)
        {
			var baseAlphabet:Alphabet = new Alphabet(0, 0, menuThing[i], true, false);
			baseAlphabet.screenCenter();
			baseAlphabet.y += (80 * (i - Math.floor(menuThing.length / 2)));
			baseAlphabet.y += 50;
			baseAlphabet.targetY = i;
			baseAlphabet.disableX = true;
			baseAlphabet.alpha = 0.6;
			alphabetGroup.add(baseAlphabet);
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.BACK)
            close();
    }
}