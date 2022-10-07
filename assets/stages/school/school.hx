var bgGirls:FNFSprite;

function generateStage()
{
	curStage = 'school';

	var bgSky = new FNFSprite().loadGraphic(Paths.image('weebSky', 'stages/' + curStage + '/images'));
	bgSky.scrollFactor.set(0.1, 0.1);
	add(bgSky);

	var repositionShit:Int = -200;
	var widShit = Std.int(bgSky.width * 6);

	var bgSchool:FNFSprite = new FNFSprite(repositionShit, 0).loadGraphic(Paths.image('weebSchool', 'stages/' + curStage + '/images'));
	bgSchool.scrollFactor.set(0.6, 0.90);
	add(bgSchool);

	var bgStreet:FNFSprite = new FNFSprite(repositionShit).loadGraphic(Paths.image('weebStreet', 'stages/' + curStage + '/images'));
	bgStreet.scrollFactor.set(0.95, 0.95);
	add(bgStreet);

	var fgTrees:FNFSprite = new FNFSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weebTreesBack', 'stages/' + curStage + '/images'));
	fgTrees.scrollFactor.set(0.9, 0.9);
	add(fgTrees);

	var bgTrees:FNFSprite = new FNFSprite(repositionShit - 380, -800);
	bgTrees.frames = Paths.getPackerAtlas('weebTrees', 'stages/' + curStage + '/images');
	bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
	bgTrees.animation.play('treeLoop');
	bgTrees.scrollFactor.set(0.85, 0.85);
	add(bgTrees);

	var treeLeaves:FNFSprite = new FNFSprite(repositionShit, -40);
	treeLeaves.frames = Paths.getSparrowAtlas('petals', 'stages/' + curStage + '/images');
	treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
	treeLeaves.animation.play('leaves');
	treeLeaves.scrollFactor.set(0.85, 0.85);
	add(treeLeaves);

	bgGirls = new FNFSprite(-100, 190);
	bgGirls.frames = Paths.getSparrowAtlas('bgFreaks', 'stages/' + curStage + '/images');
	bgGirls.animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
	bgGirls.animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);
	bgGirls.animation.play('danceLeft');
	bgGirls.scrollFactor.set(0.9, 0.9);
	bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
	bgGirls.updateHitbox();
	add(bgGirls);

	bgSky.setGraphicSize(widShit);
	bgSchool.setGraphicSize(widShit);
	bgStreet.setGraphicSize(widShit);
	bgTrees.setGraphicSize(Std.int(widShit * 1.4));
	fgTrees.setGraphicSize(Std.int(widShit * 0.8));
	treeLeaves.setGraphicSize(widShit);

	fgTrees.updateHitbox();
	bgSky.updateHitbox();
	bgSchool.updateHitbox();
	bgStreet.updateHitbox();
	bgTrees.updateHitbox();
	treeLeaves.updateHitbox();

	if (PlayState.SONG.song.toLowerCase() == 'roses')
		girlsGetScared();
}

var danceDir:Bool = false;

function girlsDance()
{
	danceDir = !danceDir;

	if (danceDir)
		bgGirls.animation.play('danceRight', true);
	else
		bgGirls.animation.play('danceLeft', true);
}

function girlsGetScared()
{
	bgGirls.animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
	bgGirls.animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
	girlsDance();
}

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dadOpponent:Character)
{
	girlsDance();
}
