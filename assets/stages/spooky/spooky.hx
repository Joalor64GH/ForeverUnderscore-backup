var halloweenBG:FNFSprite;

function generateStage()
{
	curStage = 'spooky';
	PlayState.defaultCamZoom = 1.05;

	var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'stages/' + curStage + '/images');
	halloweenBG = new FNFSprite(-200, -100);
	halloweenBG.frames = hallowTex;
	halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	halloweenBG.animation.play('idle');
	halloweenBG.antialiasing = true;
	add(halloweenBG);
}

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dadOpponent:Character)
{
	if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
	{
		lightningStrikeBeat = curBeat;

		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if (!Init.getSetting('Disable Flashing Lights'))
			halloweenBG.animation.play('lightning');
		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.animOffsets.exists('scared'))
		{
			boyfriend.playAnim('scared', true);
			boyfriend.specialAnim = true;
			boyfriend.heyTimer = 0.4;
		}
	
		if (gf.animOffsets.exists('scared'))
		{
			gf.playAnim('scared', true);
			gf.specialAnim = true;
			gf.heyTimer = 0.4;
		}
	}
}