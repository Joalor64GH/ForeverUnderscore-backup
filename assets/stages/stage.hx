function generateStage()
{
	stageName = 'stage';
	setStageZoom(0.9);

	if (song == 'tutorial')
    spawnGirlfriend(false);
  else
    spawnGirlfriend(true);
  
  createSprite('bgBack', 'backgrounds/' + stageName + '/stageback', -600, -300, false);
  setSpriteScrollFactor('bgBack', 0.9, 0.9);
	addSprite('bgBack');
  
  createSprite('bgFront', 'backgrounds/' + stageName + '/stageFront', -650, 600, false);
  setSpriteScrollFactor('bgFront', 0.9, 0.9);
	addSprite('bgFront');
  
  createSprite('bgCurtains', 'backgrounds/' + stageName + '/stagecurtains', -500, -300, false);
  setSpriteScrollFactor('bgCurtains', 0.9, 0.9);
  addSprite('bgCurtains');
}
