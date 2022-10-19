package states;

import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;

class LockState extends MusicBeatState
{
	var whiteNoise:FlxSound;
	var bg:FlxSprite;

	override function create()
	{
		// precache song
		whiteNoise = new FlxSound().loadEmbedded(Paths.music('closedmind'), false, true);
		FlxG.sound.list.add(whiteNoise);

		new FlxTimer().start(1, function(timer:FlxTimer)
		{
			whiteNoise.play();
		}, 1);

		bg = new FlxSprite().loadGraphic(Paths.image('menus/closedmind/error'));
		bg.scrollFactor.set(0, 0.17);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = !Init.getSetting('Disable Antialiasing');
		add(bg);

	}
}