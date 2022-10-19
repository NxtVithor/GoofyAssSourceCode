function loadAnimations()
{
	addByPrefix('idle', 'SONIC move IDLE', 24, false);
	addByPrefix('singUP', 'SONIC move UP', 24);
	addByPrefix('singRIGHT', 'SONIC move RIGHT', 24);
	addByPrefix('singDOWN', 'SONIC move DOWN', 24);
	addByPrefix('singLEFT', 'SONIC move LEFT', 24);
    addByPrefix('singDOWN-alt', 'SONIC laugh', 24);

 addOffset("idle", -20, -150);
 addOffset("singDOWN-alt", 0, -180);
 addOffset("singRIGHT", -90, -168);
 addOffset("singDOWN", 92, -290);
 addOffset("singUP", -66, -41);
 addOffset("singLEFT", 119, -178);

 setCamOffsets(0, 100);

	playAnim('idle');
	set('antialiasing', true);
	setBarColor([175, 102, 206]);
	setScale(1.1, 1.1);
	setOffsets(-120, 690);
}
