package states.menus;

import base.Conductor;
import base.MusicBeat;
import dependency.Discord;
import dependency.FNFSprite;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.Alphabet;
import funkin.ui.menu.Checkmark;
import funkin.ui.menu.Selector;

/**
	Options menu rewrite because I'm unhappy with how it was done previously
**/
class OptionsMenuState extends MusicBeatState
{
	var categoryMap:Map<String, Dynamic>;
	var activeSubgroup:FlxTypedGroup<Alphabet>;
	var attachments:FlxTypedGroup<FlxBasic>;

	var curSelection = 0;
	var curSelectedScript:Void->Void;
	var curCategory:String;

	var lockedMovement:Bool = false;

	override public function create():Void
	{
		super.create();

		// define the categories
		/* 
			To explain how these will work, each main category is just any group of options, the options in the category are defined
			by the first array. The second array value defines what that option does.
			These arrays are within other arrays for information storing purposes, don't worry about that too much.
			If you plug in a value, the script will run when the option is hovered over.
		 */

		// NOTE : Make sure to check Init.hx if you are trying to add options.

		#if DISCORD_RPC
		Discord.changePresence('ADJUSTING PREFERENCES', 'Options Menu');
		#end

		categoryMap = [
			'main' => [
				[
					['preferences', callNewGroup],
					['appearance', callNewGroup],
					#if mobile ['mobile controls', openMobileControls], #end
					['controls', openDesktopControls],
					['accessibility', callNewGroup],
					#if unstableBuild ['note colors', openNotemenu], #end
					['exit', exitMenu]
				]
			],
			'accessibility' => [
				[
					['Graphic Settings', null],

					['Disable Antialiasing', getFromOption],
					['Disable Flashing Lights', getFromOption],
					['Disable Shaders', getFromOption],
					['', null],
					['Screen Settings', null],
					['Filter', getFromOption],
					["Darkness Opacity", getFromOption],
					["Opacity Type", getFromOption],
					['Reduced Movements', getFromOption],
					['No Camera Note Movement', getFromOption],
					['', null],
					['Miscellaneous Settings', null],

					['Menu Song', getFromOption],
					['Pause Song', getFromOption],
					['Discord Rich Presence', getFromOption],
				]
			],
			'preferences' => [
				[
					['Gameplay Settings', null],

					['Downscroll', getFromOption],
					['Centered Receptors', getFromOption],
					['Hide Opponent Receptors', getFromOption],
					['Ghost Tapping', getFromOption],
					['Hitsound Type', getFromOption],
					['Hitsound Volume', getFromOption],
					['Use Custom Note Speed', getFromOption],
					['Scroll Speed', getFromOption],
					['', null],
					['Text Settings', null],

					['Display Accuracy', getFromOption],
					['Skip Text', getFromOption],
					['', null],
					['Meta Settings', null],

					['Auto Pause', getFromOption],
					['Allow Console Window', getFromOption],
					#if GAME_UPDATER ['Check for Updates', getFromOption], #end
					['GPU Rendering', getFromOption],
					#if !neko ["Framerate Cap", getFromOption], #end
					['FPS Counter', getFromOption],
					['Memory Counter', getFromOption],
					['State Object Count', getFromOption],
					['Engine Mark', getFromOption],
				]
			],
			'appearance' => [
				[
					['User Interface', null],

					["UI Skin", getFromOption],
					['Colored Health Bar', getFromOption],
					['Animated Score Color', getFromOption],
					['Language', getFromOption],
					['Hide User Interface', getFromOption],
					['', null],
					["Judgements and Combo", null],

					['Judgement Stacking', getFromOption],
					['Fixed Judgements', getFromOption],
					['Adjust Judgements', openJudgeState],
					['Counter', getFromOption],
					['', null],
					['Notes and Holds', null],

					["Note Skin", getFromOption],
					['Arrow Opacity', getFromOption],
					['Splash Opacity', getFromOption],
					['Hold Opacity', getFromOption],
				]
			]
		];

		for (category in categoryMap.keys())
		{
			categoryMap.get(category)[1] = returnSubgroup(category);
			categoryMap.get(category)[2] = returnExtrasMap(categoryMap.get(category)[1]);
		}

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		// reload locales
		ForeverLocales.getLocale(Init.trueSettings.get('Language'));

		// call the options menu
		var bg = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.set(0, 0.18);
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xCE64DF;
		bg.antialiasing = !Init.getSetting('Disable Antialiasing');
		add(bg);

		infoText = new FlxText(5, FlxG.height - 24, 0, "", 32);
		infoText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.textField.background = true;
		infoText.textField.backgroundColor = FlxColor.BLACK;
		add(infoText);

		loadSubgroup('main');
	}

	var currentAttachmentMap:Map<Alphabet, Dynamic>;

	function loadSubgroup(subgroupName:String)
	{
		// unlock the movement
		if (lockedMovement)
		{
			new FlxTimer().start(0.3, function(timer:FlxTimer)
			{
				lockedMovement = false;
			}, 1);
		}

		// lol we wanna kill infotext so it goes over checkmarks later
		if (infoText != null)
			remove(infoText);

		// kill previous subgroup attachments
		if (attachments != null)
			remove(attachments);

		// kill previous subgroup if it exists
		if (activeSubgroup != null)
			remove(activeSubgroup);

		// load subgroup lmfao
		activeSubgroup = categoryMap.get(subgroupName)[1];
		add(activeSubgroup);

		// set the category
		curCategory = subgroupName;

		// add all group attachments afterwards
		currentAttachmentMap = categoryMap.get(subgroupName)[2];
		attachments = new FlxTypedGroup<FlxBasic>();
		for (setting in activeSubgroup)
			if (currentAttachmentMap.get(setting) != null)
				attachments.add(currentAttachmentMap.get(setting));
		add(attachments);

		// re-add
		add(infoText);
		regenInfoText();

		// reset the selection
		curSelection = 0;
		selectOption(curSelection);
	}

	function selectOption(newSelection:Int, shouldPlaySound:Bool = true)
	{
		if ((newSelection != curSelection) && (shouldPlaySound))
			playSound('scrollMenu');

		// direction increment finder
		var directionIncrement = ((newSelection < curSelection) ? -1 : 1);

		// updates to that new selection
		curSelection = newSelection;

		// wrap the current selection
		if (curSelection < 0)
			curSelection = activeSubgroup.length - 1;
		else if (curSelection >= activeSubgroup.length)
			curSelection = 0;

		// set the correct group stuffs lol
		for (i in 0...activeSubgroup.length)
		{
			activeSubgroup.members[i].alpha = 0.6;
			if (currentAttachmentMap != null)
				setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[i]), 0.6);
			activeSubgroup.members[i].targetY = (i - curSelection) / 1.8;
			// activeSubgroup.members[i].xTo = 200 + ((i - curSelection) * 25);

			// check for null members and hardcode the dividers
			if (categoryMap.get(curCategory)[0][i][1] == null)
			{
				var sepMem = activeSubgroup.members[i]; // shortening.

				var decreaseVal:Int = 250;
				var divideVal:Int = 40;

				// horizontal offsets for each category label
				switch (sepMem.text)
				{
					case 'Meta Settings' | 'Text Settings':
						decreaseVal = 300;
					case 'Judgements':
						decreaseVal = 360;
					case 'Notes':
						decreaseVal = 450;
					case 'Miscellaneous Settings' | 'Judgements and Combo':
						decreaseVal = 55;
						divideVal = 50;
					default:
						decreaseVal = 250;
						divideVal = 40;
				}

				sepMem.alpha = 1;
				sepMem.xTo = Std.int((FlxG.width / 2) - ((sepMem.text.length / 2) * divideVal)) - decreaseVal;
			}
		}

		activeSubgroup.members[curSelection].alpha = 1;
		if (currentAttachmentMap != null)
			setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[curSelection]), 1);

		// what's the script of the current selection?
		for (i in 0...categoryMap.get(curCategory)[0].length)
			if (categoryMap.get(curCategory)[0][i][0] == activeSubgroup.members[curSelection].text)
				curSelectedScript = categoryMap.get(curCategory)[0][i][1];
		// wow thats a dumb check lmao

		// skip line if the selected script is null (indicates line break)
		if (curSelectedScript == null)
			selectOption(curSelection + directionIncrement, false);
	}

	function setAttachmentAlpha(attachment:FlxSprite, newAlpha:Float)
	{
		// oddly enough, you can't set alphas of objects that arent directly and inherently defined as a value.
		// ya flixel is weird lmao
		if (attachment != null)
			attachment.alpha = newAlpha;
		// therefore, I made a script to circumvent this by defining the attachment with the `attachment` variable!
		// pretty neat, huh?
	}

	var infoText:FlxText;
	var finalText:String;
	var textValue:String = '';
	var infoTimer:FlxTimer;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// just uses my outdated code for the main menu state where I wanted to implement
		// hold scrolling but I couldnt because I'm dumb and lazy
		// check for the current selection
		if (curSelectedScript != null)
			curSelectedScript();

		updateSelections();

		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			// lol had to set this or else itd tell me expected }
			var currentSetting = Init.gameSettings.get(activeSubgroup.members[curSelection].text);
			var textValue = currentSetting[2];
			if (textValue == null)
				textValue = "";

			if (finalText != textValue)
			{
				// trace('call??');
				// trace(textValue);
				regenInfoText();

				var textSplit = [];
				finalText = textValue;
				textSplit = finalText.split("");

				var loopTimes = 0;
				infoTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
				{
					//
					infoText.text += textSplit[loopTimes];
					infoText.screenCenter(X);

					loopTimes++;
				}, textSplit.length);
			}
		}

		// move the attachments if there are any
		for (setting in currentAttachmentMap.keys())
		{
			if ((setting != null) && (currentAttachmentMap.get(setting) != null))
			{
				var thisAttachment = currentAttachmentMap.get(setting);
				thisAttachment.x = setting.x - 100;
				thisAttachment.y = setting.y - 50;
			}
		}

		if (controls.BACK || FlxG.mouse.justPressedRight)
		{
			// reload locales
			ForeverLocales.getLocale(Init.trueSettings.get('Language'));
			playSound('cancelMenu');

			switch (lastChanged)
			{
				case 'pauseSong':
					if (FlxG.sound.music != null && FlxG.sound.music.playing)
					{
						FlxG.sound.music.stop();
						ForeverTools.resetMenuMusic();
					}
			}
			lastChanged = '';

			if (curCategory != 'main')
			{
				loadSubgroup('main');
			}
			else if (states.substates.PauseSubstate.toOptions)
			{
				Conductor.stopMusic();
				Main.switchState(this, new PlayState());
			}
			else
			{
				Main.switchState(this, new MainMenuState());
			}
		}
	}

	function regenInfoText()
	{
		if (infoTimer != null)
			infoTimer.cancel();
		if (infoText != null)
			infoText.text = "";
	}

	function updateSelections()
	{
		var controlArray:Array<Bool> = [
			controls.UI_UP,
			controls.UI_DOWN,
			controls.UI_UP_P,
			controls.UI_DOWN_P,
			FlxG.mouse.wheel == 1,
			FlxG.mouse.wheel == -1
		];
		if (controlArray.contains(true))
		{
			for (i in 0...controlArray.length)
			{
				if (controlArray[i] == true)
				{
					// up = 2, down = 3
					if (i > 1)
					{
						if (i == 2 || i == 4)
							selectOption(curSelection - 1);
						else if (i == 3 || i == 5)
							selectOption(curSelection + 1);
					}
				}
			}
		}
	}

	function returnSubgroup(groupName:String):FlxTypedGroup<Alphabet>
	{
		//
		var newGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

		for (i in 0...categoryMap.get(groupName)[0].length)
		{
			if (Init.gameSettings.get(categoryMap.get(groupName)[0][i][0]) == null
				|| Init.gameSettings.get(categoryMap.get(groupName)[0][i][0])[3] != Init.FORCED)
			{
				var thisOption:Alphabet = new Alphabet(0, 0, categoryMap.get(groupName)[0][i][0], true, false);
				thisOption.screenCenter();
				thisOption.y += (80 * (i - Math.floor(categoryMap.get(groupName)[0].length / 2)));
				#if unstableBuild
				thisOption.y += 50;
				#else
				thisOption.y += 10;
				#end
				thisOption.targetY = i;
				thisOption.disableX = true;
				// hardcoded main so it doesnt have scroll
				if (groupName != 'main')
					thisOption.isMenuItem = true;
				thisOption.alpha = 0.6;
				newGroup.add(thisOption);
			}
		}

		return newGroup;
	}

	function returnExtrasMap(alphabetGroup:FlxTypedGroup<Alphabet>):Map<Alphabet, Dynamic>
	{
		var extrasMap:Map<Alphabet, Dynamic> = new Map<Alphabet, Dynamic>();
		for (letter in alphabetGroup)
		{
			if (Init.gameSettings.get(letter.text) != null)
			{
				switch (Init.gameSettings.get(letter.text)[1])
				{
					case Init.SettingTypes.Checkmark:
						// checkmark
						var checkmark = ForeverAssets.generateCheckmark(10, letter.y, 'checkboxThingie', 'base', 'default', 'UI');
						checkmark.playAnim(Std.string(Init.getSetting(letter.text)) + ' finished');

						extrasMap.set(letter, checkmark);
					case Init.SettingTypes.Selector:
						// selector
						var selector:Selector = new Selector(10, letter.y, letter.text, Init.gameSettings.get(letter.text)[4], [
							// wow this SUCKS, I need to rewrite this already;
							(letter.text == 'Framerate Cap') ? true : false,
							(letter.text == 'Darkness Opacity')
							? true : false,
							(letter.text == 'Hitsound Volume')
							? true : false,
							(letter.text == 'Scroll Speed')
							? true : false,
							(letter.text == 'Arrow Opacity')
							? true : false,
							(letter.text == 'Splash Opacity')
							? true : false,
							(letter.text == 'Hold Opacity' ? true : false)
						]);

						extrasMap.set(letter, selector);
					default:
						// dont do ANYTHING
				}
				//
			}
		}

		return extrasMap;
	}

	/*
		This is the base option return
	 */
	public function getFromOption()
	{
		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			switch (Init.gameSettings.get(activeSubgroup.members[curSelection].text)[1])
			{
				case Init.SettingTypes.Checkmark:
					// checkmark basics lol
					if (controls.ACCEPT || FlxG.mouse.justPressed)
					{
						playSound('scrollMenu');
						lockedMovement = true;
						// LMAO THIS IS HUGE
						Init.setSetting(activeSubgroup.members[curSelection].text, !Init.getSetting(activeSubgroup.members[curSelection].text));
						updateCheckmark(currentAttachmentMap.get(activeSubgroup.members[curSelection]),
							Init.getSetting(activeSubgroup.members[curSelection].text));

						// save the setting
						Init.saveSettings();
						optionOnChange();
					}
				case Init.SettingTypes.Selector:
					#if !html5
					var selector:Selector = currentAttachmentMap.get(activeSubgroup.members[curSelection]);
					if (!controls.UI_LEFT)
						selector.selectorPlay('left');
					if (!controls.UI_RIGHT)
						selector.selectorPlay('right');

					if (controls.UI_RIGHT_P)
					{
						updateSelector(selector, 1);
						optionOnChange();
					}
					else if (controls.UI_LEFT_P)
					{
						updateSelector(selector, -1);
						optionOnChange();
					}
					#end
				default:
					// none
			}
		}
	}

	var lastChanged:String = '';

	function updateCheckmark(checkmark:FNFSprite, animation:Bool)
	{
		if (checkmark != null)
			checkmark.playAnim(Std.string(animation));
	}

	function optionOnChange()
	{
		if (lockedMovement)
		{
			new FlxTimer().start(0.3, function(timer:FlxTimer)
			{
				lockedMovement = false;
			}, 1);
		}

		switch (activeSubgroup.members[curSelection].text.toLowerCase())
		{
			case 'menu song':
				lastChanged = 'menuSong';
				FlxG.sound.music.stop();
				ForeverTools.resetMenuMusic();
			case 'pause song':
				lastChanged = 'pauseSong';
				FlxG.sound.music.stop();
				FlxG.sound.playMusic(Paths.music('menus/pause/${Init.trueSettings.get('Pause Song')}/${Init.trueSettings.get('Pause Song')}'));

			default:
				if (lastChanged != 'pauseSong')
					lastChanged = '';
		}
	}

	function updateSelector(selector:Selector, updateBy:Int)
	{
		var fps = selector.optionBooleans[0];
		var bgdark = selector.optionBooleans[1];
		var hitVol = selector.optionBooleans[2];
		var scrollspeed = selector.optionBooleans[3];
		var strumlineOp = selector.optionBooleans[4];
		var notesplashOp = selector.optionBooleans[5];
		var holdOp = selector.optionBooleans[6];

		/**
		 * left to right, minimum value, maximum value, change value
		 * rest is default stuff that I needed to keep
		**/
		if (fps)
			generateSelector(30, 360, 15, updateBy, selector);
		else if (bgdark || hitVol)
			generateSelector(0, 100, 5, updateBy, selector);
		else if (scrollspeed)
			generateSelector(1, 6, 0.1, updateBy, selector);
		else if (strumlineOp || notesplashOp || holdOp)
			generateSelector(0, 100, 10, updateBy, selector);
		if (!fps && !bgdark && !hitVol && !scrollspeed && !strumlineOp && !notesplashOp && !holdOp)
		{
			// get the current option as a number
			var storedNumber:Int = 0;
			var newSelection:Int = storedNumber;
			if (selector.options != null)
			{
				for (curOption in 0...selector.options.length)
				{
					if (selector.options[curOption] == selector.optionChosen.text)
						storedNumber = curOption;
				}

				newSelection = storedNumber + updateBy;
				if (newSelection < 0)
					newSelection = selector.options.length - 1;
				else if (newSelection >= selector.options.length)
					newSelection = 0;
			}

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			playSound('scrollMenu');

			selector.chosenOptionString = selector.options[newSelection];
			selector.optionChosen.text = selector.chosenOptionString;

			Init.setSetting(activeSubgroup.members[curSelection].text, selector.chosenOptionString);
			Init.saveSettings();
		}
	}

	function generateSelector(min:Float = 0, max:Float = 100, inc:Float = 5, updateBy:Int, selector:Selector)
	{
		// lazily hardcoded selector generator.
		var originalValue = Init.getSetting(activeSubgroup.members[curSelection].text);
		var increase = inc * updateBy;
		// min
		if (originalValue + increase < min)
			increase = 0;
		// max
		if (originalValue + increase > max)
			increase = 0;

		if (updateBy == -1)
			selector.selectorPlay('left', 'press');
		else
			selector.selectorPlay('right', 'press');

		playSound('scrollMenu');

		originalValue += increase;
		selector.chosenOptionString = Std.string(originalValue);
		selector.optionChosen.text = Std.string(originalValue);
		Init.setSetting(activeSubgroup.members[curSelection].text, originalValue);
		Init.saveSettings();
	}

	public function callNewGroup()
	{
		if (controls.ACCEPT || FlxG.mouse.justPressed)
		{
			playSound('scrollMenu');
			lockedMovement = true;
			loadSubgroup(activeSubgroup.members[curSelection].text);
		}
	}

	public function openDesktopControls()
	{
		if (controls.ACCEPT || FlxG.mouse.justPressed)
			openSubState(new states.substates.ControlsSubstate());
	}

	public function openMobileControls()
	{
		if (controls.ACCEPT || FlxG.mouse.justPressed)
		{
			playSound('scrollMenu');
			openSubState(new mobile.controls.MobileControlsSubState());
		}
	}

	public function openJudgeState()
	{
		if (controls.ACCEPT)
		{
			playSound('scrollMenu');
			Main.switchState(this, new states.JudgementOffsetState());
		}
	}

	public function exitMenu()
	{
		if (controls.ACCEPT || FlxG.mouse.justPressed)
		{
			playSound('cancelMenu');
			if (states.substates.PauseSubstate.toOptions)
			{
				Conductor.stopMusic();
				Main.switchState(this, new PlayState());
			}
			else
			{
				Main.switchState(this, new MainMenuState());
			}
		}
	}

	function playSound(soundToPlay:String)
	{
		FlxG.sound.play(Paths.sound(soundToPlay));
	}
}
