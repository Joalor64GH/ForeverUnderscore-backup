function generateStage()
{
	stageName = 'spooky';
	setStageZoom(1.05);
	spawnGirlfriend(true);

	createAnimatedSprite('halloweenBG', 'backgrounds/' + stageName + '/halloween_bg', 'sparrow', -200, -100,
		[['idle', 'halloweem bg0', 'lightning', 'halloweem bg lightning strike']], 'idle');

	addRandomSound('thunder', 'thunder_', 1, 2);
}

var lightningBeat = 0;

function stageUpdate(curBeat, boyfriend, gf, dadOpponent)
{
	lightningBeat = curBeat;
	if (FlxG.random.bool(10) && curBeat > lightningBeat + FlxG.random.int(8, 24))
	{
		spritePlayAnimation('halloweenBG', 'halloweem bg lightning strike');
		if (boyfriend.animOffsets.exists('scared'))
			boyfriend.playAnim('scared', true);

		if (gf.animOffsets.exists('scared'))
			gf.playAnim('scared', true);
	}
}