function generateStage()
{
	curStage = 'schoolEvil';

	var stageDir:String = 'stages/' + curStage + '/images';

	var bg:FNFSprite = new FNFSprite(400, 200);
	bg.frames = Paths.getSparrowAtlas('animatedEvilSchool', stageDir);
	bg.animation.addByPrefix('idle', 'background 2', 24);
	bg.animation.play('idle');
	bg.scrollFactor.set(0.8, 0.9);
	bg.scale.set(6, 6);
	add(bg);
}

function dadPosition(boyfriend:Character, gf:Character, dad:Character, camPos:FlxPoint)
{
	var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
	// add(evilTrail);
}
