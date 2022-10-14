var limo:FNFSprite;
var dancer:FNFSprite;
var grpLimoDancers:FlxSpriteGroup;

function generateStage()
{
	var stageDir:String = 'stages/highway/images';

	var skyBG:FNFSprite = new FNFSprite(-120, -50).loadGraphic(Paths.image('limoSunset', stageDir));
	skyBG.scrollFactor.set(0.1, 0.1);
	add(skyBG);

	var bgLimo:FNFSprite = new FNFSprite(-200, 480);
	bgLimo.frames = Paths.getSparrowAtlas('bgLimo', stageDir);
	bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
	bgLimo.animation.play('drive');
	bgLimo.scrollFactor.set(0.4, 0.4);
	add(bgLimo);

	grpLimoDancers = new FlxSpriteGroup();
	add(grpLimoDancers);

	for (i in 0...5)
	{
		createDancer((370 * i) + 130, bgLimo.y - 380);
		grpLimoDancers.add(dancer);
	}

	limo = new FNFSprite(-120, 550);
	limo.frames = Paths.getSparrowAtlas('limoDrive', stageDir);
	limo.animation.addByPrefix('drive', "Limo stage", 24);
	limo.animation.play('drive');
	limo.antialiasing = !Init.getSetting('Disable Antialiasing');
	layers.add(limo);

	fastCar = new FNFSprite(-300, 160).loadGraphic(Paths.image('fastCarLol', stageDir));
	fastCar.active = true;
	resetFastCar();
	layers.add(fastCar);
}

// fast car lol;

var fastCarCanDrive:Bool = true;

function resetFastCar():Void
{
	fastCar.x = -12600;
	fastCar.y = FlxG.random.int(140, 250);
	fastCar.velocity.x = 0;
	fastCarCanDrive = true;
}

var carTimer:FlxTimer;
function fastCarDrive()
{
	//trace('Car drive');
	FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

	fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
	fastCarCanDrive = false;
	carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
	{
		resetFastCar();
		carTimer = null;
	});
}

// BACKGROUND DANCERS;

var danceDir:Bool = false;

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
{
	grpLimoDancers.forEach(function(dancer:FNFSprite)
	{
		dancer.scrollFactor.set(0.4, 0.4);

		danceDir = !danceDir;

		if (danceDir)
			dancer.animation.play('danceRight', true);
		else
			dancer.animation.play('danceLeft', true);
	});

	if (FlxG.random.bool(10) && fastCarCanDrive)
		fastCarDrive();
}

function createDancer(x:Float, y:Float)
{
	dancer = new FNFSprite(x, y);
	dancer.frames = Paths.getSparrowAtlas("limoDancer", "stages/highway/images");
	dancer.animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 30, false);
	dancer.animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 30, false);
	dancer.animation.play('danceLeft');
	dancer.antialiasing = !Init.getSetting('Disable Antialiasing');
}
