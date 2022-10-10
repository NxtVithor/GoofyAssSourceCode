function loadAnimations()
{
	addByPrefix('firstDeath', "BF Dies pixel", 24, false);
	addByPrefix('deathLoop', "Retry Loop", 24, true);
	addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);

	addOffset("firstDeath", 9, 24);
	addOffset("deathConfirm", 10, 24);
	addOffset("deathLoop", 10, 24);

	setGraphicSize(get('width') * 6);
	set('antialiasing', false);

	if (PlayState.curStage == 'stage')
	{
		setOffsets(0, 910);
		setCamOffsets(-30, -150);
	}
	if (PlayState.curStage == 'school' || PlayState.curStage == 'schoolEvil')
		setOffsets(15, 480);
	if (PlayState.curStage == 'school')
		setCamOffsets(50, -80);
	if (PlayState.curStage == 'schoolEvil')
		setCamOffsets(200, -80);

	if (isPlayer)
		set('flipX', true);
	else
		set('flipX', false);
}
