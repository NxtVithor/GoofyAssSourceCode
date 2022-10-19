var white:FlxSprite;
var textField:FlxText;
var fieldTween:FlxTween;
var vignette:FlxSprite;

function postCreate()
{
	white = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFFFFFFF);
	white.scrollFactor.set(0, 0);
	add(white);
	PlayState.uiHUD.iconP2.alpha = 0;
	vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('vinagrete'));
	vignette.width = 1280;
	vignette.height = 720;
	vignette.updateHitbox();
	vignette.cameras = [PlayState.camAlt];
	vignette.alpha = 0;
	add(vignette);
}

function stepHit(curStep:Int)
{
	// bad apple lights;
	if (curStep == 128)
	{
		FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.3);
	}
	if (curStep == 160)
	{
		FlxG.camera.flash(0xFFFFFFFF, 1.5, null, true);
		FlxTween.tween(white, {alpha: 0}, 0.3);
		FlxTween.tween(PlayState.uiHUD.iconP2, {alpha: 1}, 0.3);
		FlxTween.tween(PlayState.camHUD, {alpha: 1}, 0.3);
		PlayState.songSpeed = 2.8;
	}
	if (curStep == 576)
		PlayState.songSpeed = 3.0;
	if (curStep == 704 || curStep == 720)
		callLyrics('drowing drowing', 0.5);
	if (curStep == 712 || curStep == 726)
		callLyrics('sinking sinking', 0.5);

	if (curStep == 832)
	{
		PlayState.defaultCamZoom += 0.1;
		FlxTween.tween(vignette, {alpha: 0.6}, 0.3);
	}
	if (curStep == 1104)
	{
		white.color = 0xFF000000;
		FlxTween.tween(white, {alpha: 1}, 0.3);
	}
	if (curStep == 1216)
	{
		FlxTween.tween(PlayState.camHUD, {alpha: 0}, 0.3);
		for (i in 0...PlayState.strumLines.length)
			FlxTween.tween(PlayState.strumHUD[i], {alpha: 0}, 0.3);
	}
}

function callLyrics(input:String, duration:Float)
{
	if (textField != null)
	{
		var oldField:FlxText = textField;
		FlxTween.tween(oldField, {alpha: 0}, 0.2, {
			onComplete: function(twn:FlxTween)
			{
				remove(oldField);
				oldField.destroy();
			}
		});
		textField = null;
	}

	if (fieldTween != null)
	{
		fieldTween.cancel();
		fieldTween = null;
	}

	if (input != '' && duration > 0)
	{
		textField = new FlxText(0, 0, FlxG.width, input);
		textField.setFormat(Paths.font("vcr"), 32, 0xFFFFFFFF, ForeverTools.setTextAlign('center'), FlxTextBorderStyle.OUTLINE, 0xFF000000);
		textField.alpha = 0;
		textField.screenCenter(FlxAxes.X, FlxAxes.Y);
		textField.y += 520;
		textField.cameras = [PlayState.camAlt];
		add(textField);

		fieldTween = FlxTween.tween(textField, {alpha: 1}, 0.2, {
			onComplete: function(twn:FlxTween)
			{
				trace("done");
				fieldTween = FlxTween.tween(textField, {alpha: 0}, 0.2, {
					startDelay: duration,
					onComplete: function(twn:FlxTween)
					{
						remove(textField);
						textField.destroy();
						textField = null;
						if (fieldTween == twn)
							fieldTween = null;
					}
				});
			}
		});
	}
}
