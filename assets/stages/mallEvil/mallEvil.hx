function generateStage()
{
	curStage = 'mallEvil';

	var bg:FNFSprite = new FNFSprite(-500, -500).loadGraphic(Paths.image('evilBG', 'stages/' + curStage + '/images'));
	bg.antialiasing = true;
	bg.scrollFactor.set(0.2, 0.2);
	bg.active = false;
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();
	add(bg);

	var evilTree:FNFSprite = new FNFSprite(300, -300).loadGraphic(Paths.image('evilTree', 'stages/' + curStage + '/images'));
	evilTree.antialiasing = true;
	evilTree.scrollFactor.set(0.2, 0.2);
	add(evilTree);

	var evilSnow:FNFSprite = new FNFSprite(-500, 700).loadGraphic(Paths.image("evilSnow", 'stages/' + curStage + '/images'));
	evilSnow.antialiasing = true;
	add(evilSnow);
}

function repositionPlayers(boyfriend:Character, gf:Character, dad:Character)
{
	boyfriend.x += 320;
}
