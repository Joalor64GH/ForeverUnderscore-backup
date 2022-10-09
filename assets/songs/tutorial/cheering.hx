function beatHit(curBeat:Int)
{
	if (curBeat % 16 == 15 && curBeat > 16 && curBeat < 48)
	{
		PlayState.boyfriend.playAnim('hey', true);
		PlayState.boyfriend.specialAnim = true;
		PlayState.boyfriend.heyTimer = 0.6;

		PlayState.dad.playAnim('cheer', true);
		PlayState.dad.specialAnim = true;
		PlayState.dad.heyTimer = 0.6;
	}
}
