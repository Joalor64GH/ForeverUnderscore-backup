function beatHit(curBeat:Int)
{
    if (curBeat % 16 == 15 && curBeat > 16 && curBeat < 48)
	{
		PlayState.boyfriend.playAnim('hey', true);
		PlayState.boyfriend.specialAnim = true;
		PlayState.boyfriend.heyTimer = 0.6;

        PlayState.dadOpponent.playAnim('cheer', true);
		PlayState.dadOpponent.specialAnim = true;
		PlayState.dadOpponent.heyTimer = 0.6;
	}
}