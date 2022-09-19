function loadAnimations()
{
	addByPrefix('idle', 'BF idle dance', 24, false);
	addByPrefix('singUP', 'BF NOTE UP0', 24, false);
	addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
	addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
	addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
	addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
	addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
	addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
	addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);

	addOffset("idle", -5, 30);

	addOffset("singLEFT", 2, 24);
	addOffset("singDOWN", -10, -20);
	addOffset("singUP", -49, 64);
	addOffset("singRIGHT", -44, 23);

	addOffset("singLEFTmiss", 2, 51);
	addOffset("singDOWNmiss", -11, 11);
	addOffset("singUPmiss", -39, 57);
	addOffset("singRIGHTmiss", -40, 51);

	playAnim('idle');

	set('antialiasing', true);

	setBarColor([49, 176, 209]);
	if (isPlayer)
	{
		setOffsets(80, 410);
		set('flipX', false);
	}
	else
	{
		setOffsets(80, 810);
		set('flipX', true);
		flipLeftRight();
	}
}