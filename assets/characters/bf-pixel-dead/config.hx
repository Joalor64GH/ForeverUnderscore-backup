function loadAnimations()
{
	addByPrefix('firstDeath', "BF Dies pixel", 24, false);
	addByPrefix('deathLoop', "Retry Loop", 24, true);
	addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);

	addOffset('firstDeath', 0, -20);
	addOffset('deathLoop', -30, -20);
	addOffset('deathConfirm', 0, -20);

	setGraphicSize(get('width') * 6);
	set('antialiasing', false);

	if (curStage == 'stage')
	{
		setOffsets(0, 910);
		setCamOffsets(-30, -150);
	}
	if (curStage == 'school' || curStage == 'schoolEvil')
		setOffsets(15, 400);
	if (curStage == 'school')
		setCamOffsets(50, -80);
	if (curStage == 'schoolEvil')
		setCamOffsets(200, -80);

	if (isPlayer)
		set('flipX', true);
	else
		set('flipX', false);
}