function generateStage()
{
	stageName = 'mallEvil';
	setStageZoom(0.90);

	createSprite('bg', 'backgrounds/' + stageName + '/evilBG', -500, -500);
	createSprite('evilTree', 'backgrounds/' + stageName + '/evilTree', 300, -300);
	createSprite('evilSnow', 'backgrounds/' + stageName + '/evilSnow', -500, 700);

	setSpriteScrollFactor('bg', 0.2, 0.2);
	setSpriteScrollFactor('evilTree', 0.2, 0.2);
	setSpriteSize('bg', 0.8);

    addSprite('bg');
    addSprite('evilTree');
    addSprite('evilSnow');
}

function repositionPlayers(boyfriend, dad, gf)
{
	boyfriend.x += 320;
}