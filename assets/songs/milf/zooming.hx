function beatHit(curBeat)
{
    if (curBeat >= 168 && curBeat < 200
		&& !getSetting('Reduced Movements')
		&& FlxG.camera.zoom < 1.35)
	{
		FlxG.camera.zoom += 0.015;
		for (hud in game.allUIs)
			hud.zoom += 0.03;
	}
}