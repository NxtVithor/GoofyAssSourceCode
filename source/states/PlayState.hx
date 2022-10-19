package states;

import base.*;
import base.Controls.Control;
import base.MusicBeat.MusicBeatState;
import base.SongLoader.LegacySong;
import base.SongLoader.Song;
import dependency.*;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.OverlayShader;
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import funkin.*;
import funkin.Strumline.Receptor;
import funkin.ui.*;
import lime.app.Application;
import openfl.display.BlendMode;
import openfl.display.GraphicsShader;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import states.editors.*;
import states.menus.*;
import states.substates.*;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if VIDEO_PLUGIN
import vlc.MP4Handler;
#end

class PlayState extends MusicBeatState
{
	public static var startTimer:FlxTimer;

	public static var curStage:String = '';
	public static var SONG:LegacySong;
	public static var isStoryMode:Bool = false;
	public static var clearStored:Bool = true;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 2;
	public static var contents:PlayState;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Character;

	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';
	public static var changeableSound:String = 'default';

	public var notes:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();
	public var unspawnNotes:Array<Note> = [];

	// get it cus release
	// I'm funny just trust me
	var curSection:Int = 0;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	// Discord RPC variables
	public static var songDetails:String = "";
	public static var detailsSub:String = "";
	public static var detailsPausedText:String = "";

	static var prevCamFollow:FlxObject;

	public var curSong:String = "";
	public var gfSpeed:Int = 1;

	public static var health:Float = 1; // mario
	public static var combo:Int = 0;

	public static var misses:Int = 0;
	public static var hits:Int = 0;

	public static var deaths:Int = 0;

	public var generatedMusic:Bool = false;
	public var endingSong:Bool = false;

	public var startingSong:Bool = false;
	public var paused:Bool = false;

	public var startedCountdown:Bool = false;
	public var skipCountdown:Bool = false;
	public var inCutscene:Bool = false;

	public var canPause:Bool = true;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public var scriptArray:Array<ScriptHandler> = [];

	// cameras
	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var camAlt:FlxCamera;
	public static var dialogueHUD:FlxCamera;
	public static var comboHUD:FlxCamera;
	public static var strumHUD:Array<FlxCamera>;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0; // might not use depending on result

	public static var cameraSpeed:Float = 1;
	public static var defaultCamZoom:Float = 1.05;
	public static var forceZoom:Array<Float>;
	public static var camZooming:Bool = true;

	public static var songScore:Int = 0;
	public static var accuracy:Float = 0.00;
	public static var rank:String = 'N/A';

	var storyDifficultyText:String = "";

	public static var iconRPC:String = "";
	public static var songLength:Float = 0;

	// darkness background for stages / notes
	public var darknessBG:FlxSprite;

	public var darknessLine1:FlxSprite;
	public var darknessLine2:FlxSprite;

	// i hate that i have to do this shit twice for the opponent strumlines but eh
	public var darknessOpponent:FlxSprite;

	public var darknessLine3:FlxSprite;
	public var darknessLine4:FlxSprite;

	public var stageBuild:Stage;

	public static var uiHUD:ClassHUD;
	public static var daPixelZoom:Float = 6;

	// strumlines
	public static var dadStrums:Strumline;
	public static var bfStrums:Strumline;

	public static var strumLines:FlxTypedGroup<Strumline>;

	public var allUIs:Array<FlxCamera> = [];

	public static var preventScoring:Bool = false;
	public static var chartingMode:Bool = false;
	public static var practiceMode:Bool = false;
	public static var scriptDebugMode:Bool = false;

	public static var lastEditor:Int = 0;

	public var ratingsGroup:FlxTypedGroup<FNFSprite>;
	public var comboGroup:FlxTypedGroup<FNFSprite>;

	public var charGroup:FlxSpriteGroup;

	// stores the last judgement sprite object
	public static var lastJudgement:FNFSprite;
	// stores the last combo sprite objects in an array
	public static var lastCombo:Array<FNFSprite> = [];

	function resetVariables()
	{
		songScore = 0;
		rank = 'N/A';
		combo = 0;
		health = 1;
		misses = 0;
		hits = 0;
		scriptDebugMode = false;

		defaultCamZoom = 1.05;
		cameraSpeed = 1 * Conductor.playbackRate;
		forceZoom = [0, 0, 0, 0];

		assetModifier = 'base';
		changeableSkin = 'default';
		changeableSound = 'default';
	}

	/**
	 * Simply put, a Function to Precache Sounds and Songs;
	 * when adding yours, make sure to use `FlxSound` and `volume = 0.00000001`;
	**/
	function precacheSounds()
	{
		var soundArray:Array<String> = [];

		var pauseSong = Init.trueSettings.get('Pause Song');

		var pauseMusic:FlxSound = new FlxSound().loadEmbedded(Paths.music('menus/pause/$pauseSong/$pauseSong'), true, true);
		pauseMusic.volume = 0.000001;
		pauseMusic.play();

		var editorMusic:FlxSound = new FlxSound().loadEmbedded(Paths.music('menus/main/prototype/prototype'), true, true);
		editorMusic.volume = 0.000001;
		editorMusic.play();

		// push your sound paths to this array
		if (Init.getSetting('Hitsound Volume') > 0)
			soundArray.push('hitsounds/$changeableSound/hit');

		for (i in soundArray)
		{
			var allSounds:FlxSound = new FlxSound().loadEmbedded(Paths.sound(i));
			allSounds.volume = 0.000001;
			allSounds.play();
		}

		for (i in 0...4)
		{
			var missSounds:FlxSound = new FlxSound().loadEmbedded(Paths.sound('missnote' + i));
			missSounds.volume = 0.000001;
			missSounds.play();

			// stopping the pause music once these are done;
			missSounds.onComplete = function():Void
			{
				pauseMusic.stop();
				pauseMusic.destroy();
				editorMusic.stop();
				editorMusic.destroy();
			}
		}
	}

	/*
		a Function to Precache Images;
		will improve this system eventually;
	 */
	function precacheImages()
	{
		Paths.image('UI/default/base/alphabet');
		if (!boyfriend.psychChar)
			Paths.getSparrowAtlas(GameOverSubstate.character, 'characters/' + GameOverSubstate.character);
	}

	/**
	 * Sorts through possible notes, author @Shadow_Mario
	 */
	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, Std.int(a.strumTime), Std.int(b.strumTime));
	}

	// at the beginning of the playstate
	override public function create()
	{
		super.create();

		// for scripts
		contents = this;

		// reset any values and variables that are static
		resetVariables();

		Timings.callAccuracy();

		// stop any existing music tracks playing
		Conductor.stopMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		// create an alternative camera, in case you need a third one for scripts
		camAlt = new FlxCamera();
		camAlt.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camAlt, false);

		allUIs.push(camHUD);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		// default song
		if (SONG == null)
			SONG = Song.loadSong('test', 'test');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		GameOverSubstate.resetGameOver();

		curStage = "";

		// call the song's stage if it exists
		if (SONG.stage != null)
			curStage = SONG.stage;
		else
			curStage = 'unknown';

		ScriptHandler.callScripts(scriptArray);
		callFunc('create', []);

		stageBuild = new Stage(PlayState.curStage);
		add(stageBuild);

		defaultCamZoom = stageBuild.stageJson.defaultZoom;

		// set up characters here too

		if (SONG.gfVersion.length < 1 || SONG.gfVersion == null)
			gf = new Character(300, 100, false, stageBuild.returnGFtype(curStage));
		else
			gf = new Character(300, 100, false, SONG.gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		gf.dance(true);

		dad = new Character(100, 100, false, SONG.player2);
		dad.dance(true);

		boyfriend = new Character(770, 450, true, SONG.player1);
		boyfriend.dance(true);

		charGroup = new FlxSpriteGroup();
		charGroup.alpha = 0.00001;

		var camPos:FlxPoint = new FlxPoint(gf.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

		changeableSkin = Init.getSetting("UI Skin");
		changeableSound = Init.getSetting("Hitsound Type");

		assetModifier = SONG.assetModifier;

		// add characters
		if (stageBuild.spawnGirlfriend)
			add(gf);

		add(stageBuild.layers);

		add(dad);
		add(boyfriend);
		add(stageBuild.foreground);

		add(charGroup); // for changecharacter;

		// force them to dance
		dad.dance();
		gf.dance();
		boyfriend.dance();

		stageBuild.repositionPlayers(curStage, boyfriend, gf, dad);
		stageBuild.dadPosition(curStage, boyfriend, gf, dad, camPos);

		// set song position before beginning
		Conductor.songPosition = -(Conductor.crochet * 4);

		// EVERYTHING SHOULD GO UNDER THIS, IF YOU PLAN ON SPAWNING SOMETHING LATER ADD IT TO STAGEBUILD OR FOREGROUND
		// darkens the notes / stage according to the opacity type option
		if (Init.getSetting('Opacity Type') == 'Notes')
		{
			// unoptimized darkness background for notes;
			darknessBG = new FlxSprite(0, 0).makeGraphic(100 * 4 + 50, FlxG.height, FlxColor.BLACK);

			var lineColorP1 = 0xFF66FF33;

			if (Init.getSetting('Colored Health Bar'))
				lineColorP1 = FlxColor.fromRGB(boyfriend.barColor[0], boyfriend.barColor[1], boyfriend.barColor[2]);

			darknessLine1 = new FlxSprite(0, 0).makeGraphic(5, FlxG.height, lineColorP1);
			darknessLine2 = new FlxSprite(0, 0).loadGraphicFromSprite(darknessLine1);

			add(darknessBG);
			add(darknessLine1);
			add(darknessLine2);

			for (dark in [darknessBG, darknessLine1, darknessLine2])
			{
				dark.alpha = 0;
				dark.cameras = [camHUD];
				dark.scrollFactor.set();
				dark.screenCenter(Y);
			}

			// for the opponent
			if (!Init.getSetting('Centered Receptors'))
			{
				var lineColorP2 = 0xFFFF0000;

				if (Init.getSetting('Colored Health Bar'))
					lineColorP2 = FlxColor.fromRGB(dad.barColor[0], dad.barColor[1], dad.barColor[2]);

				darknessOpponent = new FlxSprite(0, 0).loadGraphicFromSprite(darknessBG);
				darknessLine3 = new FlxSprite(0, 0).makeGraphic(5, FlxG.height, lineColorP2);
				darknessLine4 = new FlxSprite(0, 0).loadGraphicFromSprite(darknessLine3);

				add(darknessOpponent);
				add(darknessLine3);
				add(darknessLine4);

				for (dark in [darknessOpponent, darknessLine3, darknessLine4])
				{
					dark.alpha = 0;
					dark.cameras = [camHUD];
					dark.scrollFactor.set();
					dark.screenCenter(Y);
				}
			}
		}
		else
		{
			darknessBG = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			darknessBG.alpha = (Init.getSetting('Darkness Opacity') * 0.01);
			darknessBG.scrollFactor.set(0, 0);
			add(darknessBG);
		}

		// strum setup
		strumLines = new FlxTypedGroup<Strumline>();

		// generate the song
		generateSong(SONG.song);

		// set the camera position to the center of the stage
		camPos.set(gf.x + (gf.frameWidth / 2), gf.y + (gf.frameHeight / 2));

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(camPos.x, camPos.y);
		// check if the camera was following someone previously
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		add(camFollowPos);

		// actually set the camera up
		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		startingSong = true;
		startedCountdown = true;

		// initialize ui elements
		var bfPlacement:Float = FlxG.width / 2 + (!Init.getSetting('Centered Receptors') ? FlxG.width / 4 : 0);
		var dadPlacement:Float = (FlxG.width / 2) - FlxG.width / 4;

		var strumVertPos:Int = (Init.getSetting('Downscroll') ? FlxG.height - 200 : 0);

		dadStrums = new Strumline(dadPlacement, strumVertPos, dad, true, false, 4);
		bfStrums = new Strumline(bfPlacement, strumVertPos, boyfriend, false, true, 4);

		dadStrums.visible = !Init.getSetting('Hide Opponent Receptors');

		strumLines.add(dadStrums);
		strumLines.add(bfStrums);

		// generate a new strum camera
		strumHUD = [];
		for (i in 0...strumLines.length)
		{
			// generate a new strum camera
			strumHUD[i] = new FlxCamera();
			strumHUD[i].bgColor.alpha = 0;

			strumHUD[i].cameras = [camHUD];
			allUIs.push(strumHUD[i]);
			FlxG.cameras.add(strumHUD[i], false);
			// set this strumline's camera to the designated camera
			strumLines.members[i].cameras = [strumHUD[i]];
			// for whatever reason notes would spawn outside the strumline camera
			strumLines.members[i].allNotes.cameras = [strumHUD[i]];
		}

		if (Init.getSetting('Centered Receptors'))
		{
			// psych-like Opponent Strumlines;
			for (i in 0...dadStrums.receptors.members.length)
			{
				if (i > 1)
				{
					dadStrums.receptors.members[i].x += FlxG.width / 2 + 25;
				}

				dadStrums.members[i].alpha = 0.35;
				dadStrums.receptors.members[i].setAlpha = 0.35;
				dadStrums.receptors.members[i].lightConfirms = false;
			}
		}

		add(strumLines);

		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.visible = !Init.getSetting('Hide User Interface');
		uiHUD.cameras = [camHUD];

		ratingsGroup = new FlxTypedGroup<FNFSprite>();
		comboGroup = new FlxTypedGroup<FNFSprite>();
		add(ratingsGroup);
		add(comboGroup);

		comboHUD = new FlxCamera();
		comboHUD.bgColor.alpha = 0;
		comboHUD.cameras = [camHUD];
		allUIs.push(comboHUD);

		FlxG.cameras.add(comboHUD, false);

		// precache judgements and combo before using them;
		popJudgement('sick', false, true, true);

		// create a hud over the hud camera for dialogue
		dialogueHUD = new FlxCamera();
		dialogueHUD.bgColor.alpha = 0;
		FlxG.cameras.add(dialogueHUD, false);

		keysArray = [
			copyKey(Init.gameControls.get('LEFT')[0]),
			copyKey(Init.gameControls.get('DOWN')[0]),
			copyKey(Init.gameControls.get('UP')[0]),
			copyKey(Init.gameControls.get('RIGHT')[0])
		];
		for (i in 0...noteControls.length)
			bindsArray[i] = controls.getInputsFor(noteControls[i], Gamepad(0));

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		Paths.clearUnusedMemory();

		// call the funny intro cutscene depending on the song
		if (!skipCutscenes())
			songIntroCutscene();
		else
			startCountdown();

		callFunc('postCreate', []);
	}

	public function playVideo(name:String)
	{
		#if VIDEO_PLUGIN
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if (!FileSystem.exists(filepath))
		#else
		if (!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			callTextbox();
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}

	/*
		input system functions
		for pressing and releasing notes
	 */
	public var keysArray:Array<Array<FlxKey>>;
	public var holdingKeys:Array<Bool> = [];

	public function handleInput(key:Int, down:Bool)
	{
		holdingKeys[key] = down;

		if (down)
		{
			if (generatedMusic)
			{
				var previousTime:Float = Conductor.songPosition;
				Conductor.songPosition = Conductor.songMusic.time;
				// improved this a little bit, maybe its a lil
				var possibleNoteList:Array<Note> = [];
				var pressedNotes:Array<Note> = [];

				bfStrums.allNotes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.noteData == key) && daNote.canBeHit && !daNote.isSustain && !daNote.tooLate && !daNote.wasGoodHit)
						possibleNoteList.push(daNote);
				});
				possibleNoteList.sort(sortHitNotes);

				// if there is a list of notes that exists for that control
				if (possibleNoteList.length > 0)
				{
					var eligable = true;
					// loop through the possible notes
					for (coolNote in possibleNoteList)
					{
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - coolNote.strumTime) >= 10)
								eligable = false;
						}

						if (eligable)
						{
							goodNoteHit(coolNote, bfStrums); // then hit the note
							pressedNotes.push(coolNote);
						}
						// end of this little check
					}
					//
				}
				else
				{ // else just call bad notes
					if (!Init.getSetting('Ghost Tapping'))
					{
						if (startingSong) // mash warning
							uiHUD.tweenScoreColor('miss', false);
						else if (!inCutscene || !endingSong)
							missNoteCheck(true, key, bfStrums, true);
					}
				}

				Conductor.songPosition = previousTime;
			}

			if (bfStrums.receptors.members[key] != null && bfStrums.receptors.members[key].animation.curAnim.name != 'confirm')
				bfStrums.receptors.members[key].playAnim('pressed', true);
		}
		else
			// receptor reset
			if (key >= 0 && bfStrums.receptors.members[key] != null)
				bfStrums.receptors.members[key].playAnim('static');
	}

	public function onKeyPress(event:KeyboardEvent):Void
	{
		if (!bfStrums.autoplay && FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate))
		{
			var eventKey:FlxKey = event.keyCode;
			var key:Int = getKeyFromEvent(eventKey);

			if (key >= 0 && !holdingKeys[key])
				handleInput(key, true);
		}
	}

	public function onKeyRelease(event:KeyboardEvent):Void
	{
		if (!bfStrums.autoplay && FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate))
		{
			var eventKey:FlxKey = event.keyCode;
			var key:Int = getKeyFromEvent(eventKey);

			if (key >= 0)
				handleInput(key, false);
		}
	}

	function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
						return i;
				}
			}
		}
		return -1;
	}

	var noteControls:Array<Control> = [NOTE_LEFT, NOTE_DOWN, NOTE_UP, NOTE_RIGHT];
	var bindsArray:Array<Array<Int>> = [];

	function controllerInput()
	{
		if (controls.gamepadsAdded.length > 0)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.getByID(controls.gamepadsAdded[0]);
			if (gamepad != null)
			{
				for (i in 0...noteControls.length)
				{
					var bind:Array<Int> = bindsArray[i];
					if (gamepad.anyJustPressed(bind))
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
					if (gamepad.anyJustReleased(bind))
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	var lastSection:Int = 0;

	public static var songSpeed(get, default):Float = 0;

	static function get_songSpeed()
		return songSpeed * Conductor.playbackRate;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		callFunc('update', [elapsed]);

		stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dad);

		if (health > 2)
			health = 2;

		// dialogue checks
		if (dialogueBox != null && dialogueBox.alive)
		{
			// wheee the shift closes the dialogue
			if (FlxG.keys.justPressed.SHIFT)
				dialogueBox.closeDialog();

			// the change I made was just so that it would only take accept inputs
			if (controls.ACCEPT && dialogueBox.textStarted)
			{
				var sound = 'cancelMenu';

				if (dialogueBox.portraitData.confirmSound != null)
					sound = dialogueBox.portraitData.confirmSound;

				try
				{
					if (sound == null)
						FlxG.sound.play(Paths.sound('cancelMenu'));
					else
						FlxG.sound.play(Paths.sound(sound));
				}
				dialogueBox.curPage += 1;

				if (dialogueBox.curPage == dialogueBox.dialogueData.dialogue.length)
					dialogueBox.closeDialog();
				else
					dialogueBox.updateDialog();

				// for custom fonts
				if (dialogueBox.boxData.textType == 'custom')
				{
					dialogueBox.alphabetText.finishedLine = false;
					dialogueBox.handSelect.visible = false;
				}
			}
		}

		if (!inCutscene)
		{
			// pause the game if the game is allowed to pause and enter is pressed
			if (controls.PAUSE && startedCountdown && canPause)
			{
				pauseGame();
				// open pause substate
				openSubState(new PauseSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}

			// make sure you're not cheating lol
			if (!isStoryMode)
			{
				if (controls.CHEAT)
				{
					pauseGame();
					openSubState(new EditorMenuSubstate(true, true));
				}

				if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.FIVE)
				{
					preventScoring = true;
					practiceMode = !practiceMode;
				}

				if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.SIX)
				{
					preventScoring = true;
					bfStrums.autoplay = !bfStrums.autoplay;
					uiHUD.autoplayMark.visible = bfStrums.autoplay;
					uiHUD.autoplayMark.alpha = 1;
					uiHUD.autoplaySine = 0;
				}
			}

			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += elapsed * 1000 * Conductor.playbackRate;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
			{
				Conductor.songPosition += elapsed * 1000 * Conductor.playbackRate;
				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
					}
				}
			}

			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				var curSection = Std.int(curStep / 16);
				if (curSection != lastSection)
				{
					// section reset stuff
					var lastMustHit:Bool = PlayState.SONG.notes[lastSection].mustHitSection;
					if (PlayState.SONG.notes[curSection].mustHitSection != lastMustHit)
					{
						camDisplaceX = 0;
						camDisplaceY = 0;
					}
					lastSection = Std.int(curStep / 16);
				}

				var mustHit = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
				var gfSection = PlayState.SONG.notes[Std.int(curStep / 16)].gfSection;

				setVar('mustHit', mustHit);
				setVar('gfSection', gfSection);

				if (!mustHit && !gfSection)
				{
					var char = dad;

					var getCenterX = char.getMidpoint().x + 100;
					var getCenterY = char.getMidpoint().y - 100;

					camFollow.setPosition(getCenterX + camDisplaceX + char.cameraOffset.x, getCenterY + camDisplaceY + char.cameraOffset.y);

					if (char.curCharacter == 'mom')
						Conductor.songVocals.volume = 1;
				}
				else if (mustHit && !gfSection)
				{
					var char = boyfriend;

					var getCenterX = char.getMidpoint().x - 100;
					var getCenterY = char.getMidpoint().y - 100;
					switch (curStage)
					{
						case 'limo':
							getCenterX = char.getMidpoint().x - 300;
						case 'mall':
							getCenterY = char.getMidpoint().y - 200;
						case 'school':
							getCenterX = char.getMidpoint().x - 200;
							getCenterY = char.getMidpoint().y - 200;
						case 'schoolEvil':
							getCenterX = char.getMidpoint().x - 200;
							getCenterY = char.getMidpoint().y - 200;
					}

					camFollow.setPosition(getCenterX + camDisplaceX - char.cameraOffset.x, getCenterY + camDisplaceY + char.cameraOffset.y);
				}
				else if (gfSection && !mustHit || gfSection && mustHit)
				{
					var char = gf;

					var getCenterX = char.getMidpoint().x + 100;
					var getCenterY = char.getMidpoint().y - 100;

					camFollow.setPosition(getCenterX + camDisplaceX + char.cameraOffset.x, getCenterY + camDisplaceY + char.cameraOffset.y);
				}
			}

			var lerpVal = (elapsed * 2.4) * cameraSpeed;
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

			var easeLerp = 1 - Main.framerateAdjust(0.05);

			// camera stuffs
			if (camZooming)
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
				for (hud in allUIs)
					hud.zoom = FlxMath.lerp(1 + forceZoom[1], hud.zoom, easeLerp);
			}

			// not even forcezoom anymore but still
			FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
			for (hud in allUIs)
				hud.angle = FlxMath.lerp(0 + forceZoom[3], hud.angle, easeLerp);

			// Controls

			// RESET = Quick Game Over Screen
			if (controls.RESET && !startingSong && !isStoryMode)
			{
				health = 0;
			}
			if (!startingSong && !endingSong)
				doGameOverCheck();

			// spawn in the notes from the array
			if ((unspawnNotes[0] != null) && ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500))
			{
				var dunceNote:Note = unspawnNotes[0];
				var dunceIndex = unspawnNotes.indexOf(dunceNote);
				var keyAmount = (dunceNote.mustPress ? bfStrums.keyAmount : dadStrums.keyAmount);

				// push note to its correct strumline
				strumLines.members[Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / keyAmount)].push(dunceNote);

				callFunc('noteSpawn', [
					dunceNote,
					dunceIndex,
					dunceNote.noteData,
					dunceNote.noteType,
					dunceNote.isSustain
				]);
				unspawnNotes.splice(dunceIndex, 1);
			}

			noteCalls();
		}

		if (!isStoryMode && !startingSong && !endingSong && scriptDebugMode)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				preventScoring = true;
				endSong();
			}
			if (FlxG.keys.justPressed.TWO)
			{
				// apparently this can kill you??? huh
				if (Conductor.songPosition + 10000 < Conductor.songMusic.length)
				{ // Go 10 seconds into the future, @author Shadow_Mario_
					preventScoring = true;
					Conductor.songMusic.pause();
					Conductor.songVocals.pause();
					Conductor.songPosition += 10000;

					noteCleanup(Conductor.songPosition);

					Conductor.songMusic.time = Conductor.songPosition;
					Conductor.songVocals.time = Conductor.songPosition;

					Conductor.songMusic.play();
					Conductor.songVocals.play();
				}
			}
		}

		callFunc('postUpdate', [elapsed]);
	}

	function noteCleanup(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}
	}

	function noteCalls()
	{
		for (strumline in strumLines)
		{
			for (receptor in strumline.receptors)
			{
				if (strumline.autoplay && receptor.animation.curAnim.name == 'confirm' && receptor.animation.curAnim.finished)
					receptor.playAnim('static', true);
			}

			if (strumline.splashNotes != null)
			{
				for (i in 0...strumline.splashNotes.length)
				{
					strumline.splashNotes.members[i].x = strumline.receptors.members[i].x - 48;
					strumline.splashNotes.members[i].y = strumline.receptors.members[i].y + (Receptor.swagWidth / 6) - 56;
				}
			}
		}

		// set the notes x and y
		var downscrollMultiplier = (Init.getSetting('Downscroll') ? -1 : 1) * FlxMath.signOf(songSpeed);
		if (generatedMusic && startedCountdown)
		{
			for (strumline in strumLines)
			{
				strumline.allNotes.forEachAlive(function(strumNote:Note)
				{
					// set custom note speeds and stuff;
					if (strumNote.useCustomSpeed)
						strumNote.noteSpeed = Init.getSetting('Scroll Speed');
					else
						strumNote.noteSpeed = Math.abs(songSpeed);

					var receptorX:Float = strumline.receptors.members[Math.floor(strumNote.noteData)].x;
					var receptorY:Float = strumline.receptors.members[Math.floor(strumNote.noteData)].y;
					var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - strumNote.strumTime) * (0.45 * strumNote.noteSpeed)));
					var psuedoX = 25 + strumNote.noteVisualOffset;

					strumNote.y = receptorY
						+ strumNote.offsetY
						+ (Math.cos(flixel.math.FlxAngle.asRadians(strumNote.noteDirection)) * psuedoY)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(strumNote.noteDirection)) * psuedoX);
					// painful math equation
					strumNote.x = receptorX
						+ (Math.cos(flixel.math.FlxAngle.asRadians(strumNote.noteDirection)) * psuedoX)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(strumNote.noteDirection)) * psuedoY);

					// also set note rotation
					strumNote.angle = -strumNote.noteDirection;

					// shitty note hack I hate it so much
					var center:Float = receptorY + Receptor.swagWidth / (1.85 * (assetModifier == 'pixel' ? 3 : 1));
					if (strumNote.isSustain)
					{
						strumNote.y -= ((strumNote.height / 2) * downscrollMultiplier);
						if ((strumNote.animation.curAnim.name.endsWith('holdend') || strumNote.animation.curAnim.name.endsWith('rollend'))
							&& (strumNote.prevNote != null))
						{
							strumNote.y -= ((strumNote.prevNote.height / 2) * downscrollMultiplier);
							if (downscrollMultiplier < 0) // downscroll;
							{
								strumNote.y += (strumNote.height * 2);
								if (strumNote.endHoldOffset == Math.NEGATIVE_INFINITY)
									strumNote.endHoldOffset = (strumNote.prevNote.y - (strumNote.y + strumNote.height));
								else
									strumNote.y += strumNote.endHoldOffset;
							}
							else if (downscrollMultiplier > 0) // upscroll;
								strumNote.y += ((strumNote.height / 2) * downscrollMultiplier);
							// this system is funny like that
						}

						if (downscrollMultiplier < 0)
						{
							strumNote.flipY = true;
							if (strumNote.y - strumNote.offset.y * strumNote.scale.y + strumNote.height >= center
								&& (strumline.autoplay
									|| (strumNote.wasGoodHit || (strumNote.prevNote != null && strumNote.prevNote.wasGoodHit))))
							{
								var swagRect = new FlxRect(0, 0, strumNote.frameWidth, strumNote.frameHeight);
								swagRect.height = (center - strumNote.y) / strumNote.scale.y;
								swagRect.y = strumNote.frameHeight - swagRect.height;
								strumNote.clipRect = swagRect;
							}
						}
						else if (downscrollMultiplier > 0)
						{
							if (strumNote.y + strumNote.offset.y * strumNote.scale.y <= center
								&& (strumline.autoplay
									|| (strumNote.wasGoodHit || (strumNote.prevNote != null && strumNote.prevNote.wasGoodHit))))
							{
								var swagRect = new FlxRect(0, 0, strumNote.width / strumNote.scale.x, strumNote.height / strumNote.scale.y);
								swagRect.y = (center - strumNote.y) / strumNote.scale.y;
								swagRect.height -= swagRect.y;
								strumNote.clipRect = swagRect;
							}
						}
					}

					// hell breaks loose here, we're using nested scripts!
					mainControls(strumNote, strumline);
					if (!strumline.autoplay)
						controllerInput();

					// check where the note is and make sure it is either active or inactive
					if (strumNote.y > FlxG.height)
					{
						strumNote.active = false;
						strumNote.visible = false;
					}
					else
					{
						strumNote.visible = true;
						strumNote.active = true;
					}

					if (!strumNote.tooLate
						&& strumNote.strumTime < Conductor.songPosition - (Timings.msThreshold)
						&& !strumNote.wasGoodHit)
					{
						if ((!strumNote.tooLate) && (strumNote.mustPress) && (!strumNote.canHurt))
						{
							if (!strumNote.isSustain)
							{
								strumNote.tooLate = true;
								for (note in strumNote.childrenNotes)
									note.tooLate = true;

								Conductor.songVocals.volume = 0;
								strumNote.noteMissActions(strumNote);

								callFunc('noteMiss', [strumNote]);

								missNoteCheck((Init.getSetting('Ghost Tapping') && !startingSong) ? true : false, strumNote.noteData, strumline, true);
								// ambiguous name
								if (strumNote.updateAccuracy)
									Timings.updateAccuracy(0);
							}
							else if (strumNote.isSustain)
							{
								if (strumNote.parentNote != null)
								{
									var parentNote = strumNote.parentNote;
									if (!parentNote.tooLate)
									{
										var breakFromLate:Bool = false;
										if (!breakFromLate)
										{
											missNoteCheck((Init.getSetting('Ghost Tapping') && !startingSong) ? true : false, strumNote.noteData, strumline,
												true);
											for (note in parentNote.childrenNotes)
												note.tooLate = true;
										}
									}
								}
							}
						}
					}

					// if the note is off screen (above)
					if ((((!Init.getSetting('Downscroll')) && (strumNote.y < -strumNote.height))
						|| ((Init.getSetting('Downscroll')) && (strumNote.y > (FlxG.height + strumNote.height))))
						&& (strumNote.tooLate || strumNote.wasGoodHit))
						destroyNote(strumline, strumNote);
				});

				// unoptimised asf camera control based on strums
				strumCameraRoll(strumline.receptors, (strumline == bfStrums));
			}
		}

		// reset boyfriend's animation
		if ((boyfriend != null && boyfriend.animation != null)
			&& (boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration)
			&& (!holdingKeys.contains(true) || bfStrums.autoplay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}
	}

	public function addCharacter(newCharacter:String)
	{
		var char:Character = new Character(0, 0, newCharacter);
		charGroup.add(char);
	}

	public function changeCharacter(newCharacter:String, targetCharacter:String, x:Float, y:Float)
	{
		var charType:Int = 0;
		switch (targetCharacter)
		{
			case 'dad' | 'opponent' | 'dadOpponent':
				charType = 1;
			case 'gf' | 'girlfriend' | 'player3':
				charType = 2;
			case 'boyfriend' | 'bf' | 'player':
				charType = Std.parseInt(targetCharacter);
				if (Math.isNaN(charType))
					charType = 0;
			default:
				charType = Std.parseInt(targetCharacter);
				if (Math.isNaN(charType))
					charType = 0;
		}

		switch (charType)
		{
			case 0:
				boyfriend.setCharacter(x, y, newCharacter);
				uiHUD.iconP1.updateIcon(newCharacter, true);
				uiHUD.updateBar();
			case 1:
				dad.setCharacter(x, y, newCharacter);
				uiHUD.iconP2.updateIcon(newCharacter, false);
				uiHUD.updateBar();
			case 2:
				gf.setCharacter(x, y, newCharacter);
		}
	}

	function destroyNote(strumline:Strumline, daNote:Note)
	{
		daNote.active = false;
		daNote.exists = false;

		var chosenGroup = (daNote.isSustain ? strumline.holdsGroup : strumline.notesGroup);
		// note damage here I guess
		daNote.kill();
		if (strumline.allNotes.members.contains(daNote))
			strumline.allNotes.remove(daNote, true);
		if (chosenGroup.members.contains(daNote))
			chosenGroup.remove(daNote, true);
		daNote.destroy();
	}

	function goodNoteHit(coolNote:Note, strumline:Strumline)
	{
		if (!coolNote.wasGoodHit)
		{
			// lmao;
			callFunc(!coolNote.mustPress ? 'opponentNoteHit' : 'goodNoteHit', [coolNote, strumline]);
			strumline.character.noteHit();

			coolNote.wasGoodHit = true;
			Conductor.songVocals.volume = 1;

			if (strumline.receptors.members[coolNote.noteData] != null)
				strumline.receptors.members[coolNote.noteData].playAnim('confirm', true);

			coolNote.goodNoteHit(coolNote, (coolNote.strumTime < Conductor.songPosition ? "late" : "early"));

			var gfSection = PlayState.SONG.notes[Std.int(curStep / 16)].gfSection;
			characterPlayAnimation(coolNote, (coolNote.gfNote || gfSection ? gf : strumline.character));

			// special thanks to sam, they gave me the original system which kinda inspired my idea for this new one
			if (strumline.displayJudgements)
			{
				// get the note ms timing
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);

				// loop through all avaliable judgements
				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}

				if (!coolNote.canHurt)
				{
					if (!coolNote.isSustain)
					{
						increaseCombo(foundRating, coolNote.noteData, strumline);
						popUpScore(foundRating, coolNote.strumTime < Conductor.songPosition, Timings.perfectCombo, strumline, coolNote);

						if (coolNote.childrenNotes.length > 0)
							Timings.notesHit++;

						healthCall(Timings.judgementsMap.get(foundRating)[3]);
					}
					else
					{
						// call updated accuracy stuffs
						if (coolNote.parentNote != null)
						{
							if (coolNote.updateAccuracy)
								Timings.updateAccuracy(100, true, coolNote.parentNote.childrenNotes.length);
							healthCall(100 / coolNote.parentNote.childrenNotes.length);
						}

						hits++;
					}
				}
			}

			if (!coolNote.isSustain)
				destroyNote(strumline, coolNote);
		}
	}

	public function missNoteCheck(?includeAnimation:Bool = false, direction:Int = 0, strumline:Strumline, popMiss:Bool = false, lockMiss:Bool = false)
	{
		if (strumline.autoplay)
			return;

		if (includeAnimation)
		{
			var stringDirection:String = Receptor.arrowDir[direction];

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			if (strumline.character != null)
				strumline.character.playAnim('sing' + stringDirection.toUpperCase() + 'miss', lockMiss);
		}
		decreaseCombo(popMiss);
	}

	public function characterPlayAnimation(coolNote:Note, character:Character)
	{
		// alright so we determine which animation needs to play
		// get alt strings and stuffs
		var stringArrow:String = '';
		var altString:String = '';

		var baseString = 'sing' + Receptor.arrowDir[coolNote.noteData].toUpperCase();

		// I tried doing xor and it didnt work lollll
		if (coolNote.noteAlt > 0)
			altString = '-alt';

		var altSection = (SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim);
		if ((altSection) && (character.animOffsets.exists(baseString + '-alt')) || (coolNote.noteType == 1))
		{
			if (altString != '-alt')
				altString = '-alt';
			else
				altString = '';
		}

		switch (coolNote.noteType)
		{
			case 2: // hey notes
				stringArrow = 'hey'; // sets the animation string for this note;
				character.specialAnim = true;
				character.heyTimer = 0.6;
			case 3: // mines
				if (character.curCharacter == 'bf-psych')
					stringArrow = 'hurt';
				else
					stringArrow = baseString + 'miss';
				character.specialAnim = true;
				character.heyTimer = 0.6;
			case 5: // no animation notes
				stringArrow = '';
				altString = '';
			default: // anything else
				stringArrow = baseString + altString;
				character.specialAnim = false;
		}

		if (character != null)
		{
			character.playAnim(stringArrow, true);
			character.holdTimer = 0;
		}
	}

	function mainControls(daNote:Note, strumline:Strumline):Void
	{
		var notesPressedAutoplay = [];

		// here I'll set up the autoplay functions
		if (strumline.autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition)
			{
				// kill the note, then remove it from the array
				if (strumline.displayJudgements)
					notesPressedAutoplay.push(daNote);

				if (!daNote.canHurt)
					goodNoteHit(daNote, strumline);
			}
		}

		if (!strumline.autoplay)
		{
			// check for hold notes
			strumline.holdsGroup.forEachAlive(function(coolNote:Note)
			{
				if ((coolNote.parentNote != null && coolNote.parentNote.wasGoodHit)
					&& coolNote.canBeHit
					&& coolNote.mustPress
					&& !coolNote.tooLate
					&& holdingKeys[coolNote.noteData])
					goodNoteHit(coolNote, strumline);
			});
		}
	}

	function strumCameraRoll(cStrum:FlxTypedSpriteGroup<Receptor>, mustHit:Bool)
	{
		if (!Init.getSetting('No Camera Note Movement'))
		{
			var noteStep = PlayState.SONG.notes[Std.int(curStep / 16)];
			var camDisplaceExtend:Float = 15;
			if (noteStep != null)
			{
				if ((noteStep.mustHitSection && mustHit) || (!noteStep.mustHitSection && !mustHit))
				{
					camDisplaceX = 0;
					if (cStrum.members[0].animation.curAnim.name == 'confirm')
						camDisplaceX -= camDisplaceExtend;
					if (cStrum.members[3].animation.curAnim.name == 'confirm')
						camDisplaceX += camDisplaceExtend;

					camDisplaceY = 0;
					if (cStrum.members[1].animation.curAnim.name == 'confirm')
						camDisplaceY += camDisplaceExtend;
					if (cStrum.members[2].animation.curAnim.name == 'confirm')
						camDisplaceY -= camDisplaceExtend;
				}
			}
		}
		//
	}

	public function pauseGame()
	{
		callFunc('pauseGame', []);

		// pause discord rpc
		updateRPC(true);

		// pause game
		paused = true;

		// pause music
		Conductor.pauseMusic();

		// update drawing stuffs
		persistentUpdate = false;
		persistentDraw = true;

		// stop all tweens and timers
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
		{
			if (!tmr.finished)
				tmr.active = false;
		});

		FlxTween.globalManager.forEach(function(twn:FlxTween)
		{
			if (!twn.finished)
				twn.active = false;
		});
	}

	override public function onFocus():Void
	{
		if (!paused)
			updateRPC(false);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		var strumline:Strumline = null;
		for (strum in strumLines)
			strumline = strum;
		if (canPause && !paused && !inCutscene && !strumline.autoplay && !Init.getSetting('Auto Pause') && startedCountdown)
		{
			pauseGame();
			// open pause substate
			openSubState(new PauseSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		super.onFocusLost();
	}

	public static function updateRPC(pausedRPC:Bool)
	{
		#if DISCORD_RPC
		var displayRPC:String = (pausedRPC) ? detailsPausedText : songDetails;

		if (health > 0)
		{
			if (Conductor.songPosition > 0 && !pausedRPC)
				Discord.changePresence(displayRPC, detailsSub, null, null, iconRPC, true, songLength - Conductor.songPosition);
			else
				Discord.changePresence(displayRPC, detailsSub, null, null, iconRPC);
		}
		#end
	}

	function popUpScore(baseRating:String, timing:Bool, perfect:Bool, strumline:Strumline, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// create the note splash if you hit a sick
		if (baseRating == "sick")
			popNoteSplash(coolNote, coolNote.noteType, strumline);
		else
			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (Timings.perfectCombo)
				Timings.perfectCombo = false;

		if (!strumline.autoplay)
			popJudgement(baseRating, timing, perfect);
		else
			popJudgement('sick', false, Timings.perfectCombo);
		if (coolNote.updateAccuracy)
			Timings.updateAccuracy(Timings.judgementsMap.get(baseRating)[3]);
		score = Std.int(Timings.judgementsMap.get(baseRating)[2]);

		if (!practiceMode)
			songScore += score;

		// tween score color based on your rating;
		uiHUD.tweenScoreColor(baseRating, perfect);
	}

	public function popNoteSplash(coolNote:Note, noteType:Int, strumline:Strumline)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		if (strumline.splashNotes != null)
			strumline.splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom, true);
	}

	var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popJudgement(newRating:String, lateHit:Bool, perfect:Bool, ?cached:Bool = false)
	{
		/*
			so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss judgements can pop, and they dont mess with your sick combo
		 */
		var rating = ForeverAssets.generateRating('$newRating', perfect, lateHit, ratingsGroup, assetModifier, changeableSkin, 'UI');

		if (!cached)
		{
			if (!Init.getSetting('Judgement Stacking'))
			{
				if (lastJudgement != null)
					lastJudgement.kill();
				for (i in 0...ratingsGroup.members.length)
					lastJudgement = ratingsGroup.members[i];

				FlxTween.tween(rating, {y: rating.y + 20}, 0.2, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
				FlxTween.tween(rating, {"scale.x": 0, "scale.y": 0}, (Conductor.stepCrochet) / 1000, {
					onComplete: function(tween:FlxTween)
					{
						rating.kill();
					},
					startDelay: ((Conductor.crochet + Conductor.stepCrochet * 2) / 1000)
				});
			}

			Timings.gottenJudgements.set(newRating, Timings.gottenJudgements.get(newRating) + 1);
			if (Timings.smallestRating != newRating)
			{
				if (Timings.judgementsMap.get(Timings.smallestRating)[0] < Timings.judgementsMap.get(newRating)[0])
					Timings.smallestRating = newRating;
			}
		}

		if (Init.getSetting('Fixed Judgements'))
		{
			// bound to camera
			if (!cached)
				rating.cameras = [comboHUD];
		}

		if (cached)
			rating.alpha = 0.000001;

		var comboString:String = Std.string(combo);
		var stringArray:Array<String> = comboString.split("");

		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;

		if (lastCombo != null)
		{
			while (lastCombo.length > 0)
			{
				lastCombo[0].kill();
				lastCombo.remove(lastCombo[0]);
			}
		}

		for (scoreInt in 0...stringArray.length)
		{
			var comboNum = ForeverAssets.generateCombo('combo_numbers', stringArray[scoreInt], (!negative ? perfect : false), comboGroup, assetModifier,
				changeableSkin, 'UI', negative, createdColor, scoreInt);

			if (!Init.getSetting('Judgement Stacking'))
			{
				for (i in 0...comboGroup.members.length)
					lastCombo.push(comboGroup.members[i]);
			}

			if (Init.getSetting('Fixed Judgements'))
			{
				if (!cached)
					comboNum.cameras = [comboHUD];
				comboNum.y += 50;
			}
			comboNum.x += 100;

			if (cached)
				comboNum.alpha = 0.000001;
		}

		ratingsGroup.sort(FNFSprite.depthSorting, FlxSort.DESCENDING);
		comboGroup.sort(FNFSprite.depthSorting, FlxSort.DESCENDING);
	}

	public function decreaseCombo(?popMiss:Bool = false)
	{
		if (combo > 5 && gf.animOffsets.exists('sad'))
			gf.playAnim('sad');

		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		if (!practiceMode)
			songScore -= 10;

		if (!endingSong)
			misses++;

		if (popMiss)
		{
			uiHUD.tweenScoreColor("miss", false);
			popJudgement("miss", true, false);
			healthCall(Timings.judgementsMap.get("miss")[3]);
		}

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo(?baseRating:String, ?direction = 0, ?strumline:Strumline)
	{
		// trolled this can actually decrease your combo if you get a bad/shit/miss
		if (baseRating != null)
		{
			if (Timings.judgementsMap.get(baseRating)[3] > 0)
			{
				if (combo < 0)
					combo = 0;
				combo += 1;
			}
			else
				missNoteCheck(true, direction, strumline, false, true);
		}
	}

	function healthCall(?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.06;
		health += (healthBase * (ratingMultiplier / 100));
	}

	function startSong():Void
	{
		callFunc('startSong', []);

		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			Conductor.startMusic();
			Conductor.songMusic.onComplete = endSong.bind();
			FlxTween.tween(uiHUD.centerMark, {alpha: 1});

			#if DISCORD_RPC
			// Song duration in a float, useful for the time left feature
			songLength = Conductor.songMusic.length;

			// Updating Discord Rich Presence (with Time Left)
			updateRPC(false);
			#end
		}
	}

	function generateSong(dataPath:String):Void
	{
		Conductor.changeBPM(SONG.bpm);

		songDetails = CoolUtil.dashToSpace(SONG.song)
			+ ' ['
			+ CoolUtil.difficultyFromString()
			+ '] - by '
			+ SONG.author
			+ ' (${Conductor.playbackRate}x)';

		detailsPausedText = "Paused - " + songDetails;
		detailsSub = "";

		updateRPC(false);

		curSong = SONG.song;

		// call song
		Conductor.bindMusic();

		// generate the chart and sort through notes
		unspawnNotes = ChartParser.loadChart(SONG);

		songSpeed = SONG.speed;

		generatedMusic = true;
	}

	override function stepHit()
	{
		super.stepHit();

		Conductor.resyncBySteps();

		stageBuild.stageUpdateSteps(curStep, boyfriend, gf, dad);

		callFunc('stepHit', [curStep]);
	}

	function charactersDance(curBeat:Int)
	{
		for (i in strumLines)
		{
			if (curBeat % i.character.bopSpeed == 0)
			{
				if (i.character != null && i.character.animation.curAnim.name.startsWith("idle") // check the idle before dancing
					|| i.character.animation.curAnim.name.startsWith("dance"))
					i.character.dance();
			}
		}

		if (curBeat % Math.round(gfSpeed * gf.bopSpeed) == 0)
		{
			if (gf != null && gf.animation.curAnim.name.startsWith("idle") // check the idle before dancing
				|| gf.animation.curAnim.name.startsWith("dance"))
				gf.dance();
		}
	}

	public var isDead:Bool = false;

	function doGameOverCheck()
	{
		callFunc('doGameOverCheck', []);

		if (!practiceMode && health <= 0 && !isDead)
		{
			paused = true;
			boyfriend.stunned = true;
			persistentUpdate = false;
			persistentDraw = false;

			Conductor.stopMusic();

			deaths += 1;

			//openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			//FlxG.sound.play(Paths.sound(GameOverSubstate.deathSound));
            //Coiso pra n ter gameover @Minhapica
			Main.switchState(this, new LockState());

			#if DISCORD_RPC
			Discord.changePresence("Game Over - " + songDetails, detailsSub, null, null, iconRPC);
			#end
			isDead = true;
			return true;
		}
		return false;
	}

	override function beatHit()
	{
		super.beatHit();

		if (camZooming)
		{
			if ((FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) && (!Init.getSetting('Reduced Movements')))
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.05;
				for (hud in strumHUD)
					hud.zoom += 0.05;
			}
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
		}

		uiHUD.beatHit(curBeat);

		charactersDance(curBeat);

		// stage stuffs
		stageBuild.stageUpdate(curBeat, boyfriend, gf, dad);

		callFunc('beatHit', [curBeat]);
	}

	//
	//
	/// substate stuffs
	//
	//

	override function openSubState(SubState:FlxSubState)
	{
		// trace('open substate');
		super.openSubState(SubState);
		// trace('open substate end ');
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (Conductor.songMusic != null && !startingSong)
				Conductor.startMusic();

			// if ((startTimer != null) && (!startTimer.finished))
			//	startTimer.active = true;
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
			{
				if (!tmr.finished)
					tmr.active = true;
			});

			FlxTween.globalManager.forEach(function(twn:FlxTween)
			{
				if (!twn.finished)
					twn.active = true;
			});
			paused = false;

			///*
			updateRPC(false);
			// */
		}

		Paths.clearUnusedMemory();

		callFunc('closeSubState', []);

		super.closeSubState();
	}

	/*
		Extra functions and stuffs
	 */
	/// song end function at the end of the playstate lmao ironic I guess
	var endSongEvent:Bool = false;

	function endSong():Void
	{
		callFunc('endSong', []);

		canPause = false;
		endingSong = true;

		if (!endSongEvent)
		{
			if (checkTextbox())
				endSongEvent = true;
		}

		Conductor.stopMusic();
		deaths = 0;
        //Lock game shits @NxtVithor
		FlxG.stage.application.window.onClose.add(function()
		{
			if (FlxG.save.data.closed == null)
				FlxG.save.data.closed = -1;
			FlxG.save.data.closed = ++FlxG.save.data.closed;
			FlxG.save.flush();
		});

		// set ranking
		rank = Timings.returnScoreRating().toUpperCase();
		accuracy = Math.floor(Timings.getAccuracy() * 100) / 100;

		if (SONG.validScore && !preventScoring)
		{
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			Highscore.saveRank(SONG.song, rank, storyDifficulty);
			Highscore.saveAccuracy(SONG.song, accuracy, storyDifficulty);
		}

		// CoolUtil.difficulties = CoolUtil.baseDifficulties;

		if (FlxG.save.data.closed > -1)
			{
				Sys.exit(0);
				return;
			}

		if (chartingMode)
		{
			// enable memory cleaning
			clearStored = true;
			Main.switchState(this, (lastEditor == 1 ? new ChartEditor() : new OriginalChartEditor()));
		}
		else if (!isStoryMode)
		{
			if ((!endSongEvent))
			{
				// enable memory cleaning
				clearStored = true;
				Main.switchState(this, new LockState());
			}
			else if (!skipCutscenes())
				songEndCutscene();
		}
		else
		{
			// set the campaign's score higher
			campaignScore += songScore;
			campaignMisses += misses;

			// remove a song from the story playlist
			storyPlaylist.remove(storyPlaylist[0]);

			// check if there aren't any songs left
			if ((storyPlaylist.length <= 0) && (!endSongEvent))
			{
				// play menu music
				ForeverTools.resetMenuMusic();

				// enable memory
				clearStored = true;

				// set up transitions
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;

				// change to the menu state
				Main.switchState(this, new LockState());

				// save the week's score if the score is valid
				if (SONG.validScore && !preventScoring)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				// flush the save
				FlxG.save.flush();
			}
			else if (!skipCutscenes())
				songEndCutscene();
		}
		//
	}

	function songEndCutscene()
	{
		callFunc('songEndCutscene', []);
		switch (SONG.song.toLowerCase())
		{
			case 'eggnog':
				// make the lights go out
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;

				// oooo spooky
				FlxG.sound.play(Paths.sound('Lights_Shut_off'));

				// call the song end
				new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer)
				{
					callDefaultSongEnd();
				}, 1);

			default:
				callTextbox();
		}
	}

	function callDefaultSongEnd()
	{
		if (isStoryMode)
		{
			var difficulty:String = CoolUtil.returnDifficultySuffix().toLowerCase();

			PlayState.SONG = Song.loadSong(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
			Conductor.killMusic();

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			clearStored = false;

			// deliberately did not use the main.switchstate as to not unload the assets
			FlxG.switchState(new PlayState());
		}
		else
		{
			// enable memory cleaning
			clearStored = true;
			Main.switchState(this, new FreeplayMenuState());
		}
	}

	var dialogueBox:DialogueBox;

	public function songIntroCutscene()
	{
		callFunc('songIntroCutscene', []);
		switch (curSong.toLowerCase())
		{
			case "winter-horrorland":
				inCutscene = true;
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					remove(blackScreen);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				});
			case 'roses':
				// the same just play angery noise LOL
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				callTextbox();
			case 'thorns':
				inCutscene = true;
				for (hud in allUIs)
					hud.visible = false;

				var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
				red.scrollFactor.set();

				var senpaiEvil:FlxSprite = new FlxSprite();
				senpaiEvil.frames = Paths.getSparrowAtlas('cutscene/senpai/senpaiCrazy');
				senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();

				add(red);
				add(senpaiEvil);
				senpaiEvil.alpha = 0;
				new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
				{
					senpaiEvil.alpha += 0.15;
					if (senpaiEvil.alpha < 1)
						swagTimer.reset();
					else
					{
						senpaiEvil.animation.play('idle');
						FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
						{
							remove(senpaiEvil);
							remove(red);
							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
							{
								for (hud in allUIs)
									hud.visible = true;
								callTextbox();
							}, true);
						});
						new FlxTimer().start(3.2, function(deadTime:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});

			default:
				callTextbox();
		}
	}

	function checkTextbox():Bool
	{
		var dialogueFileStr:String = 'dialogue';
		dialogueFileStr = (endingSong ? '${ForeverLocales.curLang.dialogueFileEnd}' : '${ForeverLocales.curLang.dialogueFile}');
		var dialogPath = Paths.file('songs/' + SONG.song.toLowerCase() + '/$dialogueFileStr.json');

		if (sys.FileSystem.exists(dialogPath))
			return true;

		return false;
	}

	function callTextbox()
	{
		if (checkTextbox())
		{
			if (!endingSong)
				startedCountdown = false;

			var dialogueFileStr:String = 'dialogue';
			dialogueFileStr = (endingSong ? '${ForeverLocales.curLang.dialogueFileEnd}' : '${ForeverLocales.curLang.dialogueFile}');

			dialogueBox = DialogueBox.createDialogue(sys.io.File.getContent(Paths.file('songs/' + SONG.song.toLowerCase() + '/$dialogueFileStr.json')));
			dialogueBox.cameras = [dialogueHUD];
			dialogueBox.whenDaFinish = (endingSong ? callDefaultSongEnd : startCountdown);

			add(dialogueBox);
		}
		else
			(endingSong ? callDefaultSongEnd() : startCountdown());
	}

	public static function skipCutscenes():Bool
	{
		// pretty messy but an if statement is messier
		if (Init.getSetting('Skip Text') != null && Std.isOfType(Init.getSetting('Skip Text'), String))
		{
			switch (cast(Init.getSetting('Skip Text'), String))
			{
				case 'never':
					return false;
				case 'freeplay only':
					if (!isStoryMode)
						return true;
					else
						return false;
				default:
					return true;
			}
		}
		return false;
	}

	public static var swagCounter:Int = 0;

	function startCountdown():Void
	{
		inCutscene = false;

		Conductor.songPosition = -(Conductor.crochet * 5);
		swagCounter = 0;

		camHUD.visible = true;

		precacheImages();
		precacheSounds();

		if (Init.getSetting('Opacity Type') == 'Notes')
		{
			darknessBG.x = bfStrums.receptors.members[0].x + 20;
			darknessLine1.x = darknessBG.x - 5;
			darknessLine2.x = FlxG.width - darknessBG.x + 2;
			FlxTween.tween(darknessBG, {alpha: (Init.getSetting('Darkness Opacity') * 0.01)}, 0.5, {ease: FlxEase.circOut});
			if (Init.getSetting('Darkness Opacity') > 0)
			{
				FlxTween.tween(darknessLine1, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
				FlxTween.tween(darknessLine2, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			}

			if (!Init.getSetting('Centered Receptors'))
			{
				darknessOpponent.x = dadStrums.receptors.members[0].x + 20;
				darknessLine3.x = darknessOpponent.x - 5;
				darknessLine4.x = FlxG.width - darknessOpponent.x + 2;
				FlxTween.tween(darknessOpponent, {alpha: (Init.getSetting('Darkness Opacity') * 0.01)}, 0.5, {ease: FlxEase.circOut});
				if (Init.getSetting('Darkness Opacity') > 0)
				{
					FlxTween.tween(darknessLine3, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
					FlxTween.tween(darknessLine4, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
				}
			}
		}

		callFunc('startCountdown', []);

		if (skipCountdown)
		{
			startedCountdown = true;
			swagCounter = 4;
			Conductor.songPosition = -5; // delay start position so the ends before it
			return;
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000 / Conductor.playbackRate, function(tmr:FlxTimer)
		{
			startedCountdown = true;

			charactersDance(curBeat);

			stageBuild.stageUpdate(curBeat, boyfriend, gf, dad);

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', [
				ForeverTools.returnSkin('prepare', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkin('ready', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkin('set', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkin('go', assetModifier, changeableSkin, 'UI')
			]);

			var introAlts:Array<String> = introAssets.get('default');
			for (value in introAssets.keys())
			{
				if (value == PlayState.curStage)
					introAlts = introAssets.get(value);
			}

			switch (swagCounter)
			{
				case 0:
					var prepare:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					prepare.scrollFactor.set();
					prepare.updateHitbox();

					prepare.cameras = [camHUD];

					if (assetModifier == 'pixel')
						prepare.setGraphicSize(Std.int(prepare.width * PlayState.daPixelZoom));

					prepare.screenCenter();
					add(prepare);
					FlxTween.tween(prepare, {y: prepare.y += 50, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							prepare.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdown/intro3-' + assetModifier), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 4);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.cameras = [camHUD];

					if (assetModifier == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * PlayState.daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 50, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdown/intro2-' + assetModifier), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 3);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					set.scrollFactor.set();

					set.cameras = [camHUD];

					if (assetModifier == 'pixel')
						set.setGraphicSize(Std.int(set.width * PlayState.daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 50, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdown/intro1-' + assetModifier), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 2);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
					go.scrollFactor.set();

					go.cameras = [camHUD];

					if (assetModifier == 'pixel')
						go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 50, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdown/introGo-' + assetModifier), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 1);
			}
			swagCounter += 1;
			callFunc('countdownTick', [swagCounter]);
		}, 5);
	}

	override public function destroy()
	{
		callFunc('destroy', []);

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		super.destroy();
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.getSetting('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	public function callFunc(key:String, args:Array<Dynamic>)
	{
		for (i in scriptArray)
			i.call(key, args);

		if (generatedMusic)
			setPlayStateVars();
	}

	public function setVar(key:String, value:Dynamic)
	{
		var allSucceed:Bool = true;
		for (i in scriptArray)
		{
			i.set(key, value);

			if (!i.exists(key))
			{
				trace('${i.scriptFile} failed to set $key for its interpreter, continuing.');
				allSucceed = false;
				continue;
			}
		}
		return allSucceed;
	}

	function setPlayStateVars()
	{
		// GENERAL
		setVar('game', PlayState.contents);
		setVar('songName', PlayState.SONG.song.toLowerCase());
		setVar('add', add);
		setVar('remove', remove);
		setVar('openSubState', openSubState);

		// CHARACTERS
		setVar('bf', boyfriend);
		setVar('boyfriend', boyfriend);
		setVar('dad', dad);
		setVar('dadOpponent', dad);
		setVar('PlayState.dadOpponent', dad);
		setVar('game.dadOpponent', dad);
		setVar('gf', gf);
		setVar('girlfriend', gf);
		setVar('dadName', PlayState.dad.curCharacter);
		setVar('gfName', PlayState.gf.curCharacter);
		setVar('bfName', PlayState.boyfriend.curCharacter);

		setVar('setProperty', function(key:String, value:Dynamic)
		{
			var dotList:Array<String> = key.split('.');

			if (dotList.length > 1)
			{
				var reflector:Dynamic = Reflect.getProperty(this, dotList[0]);

				for (i in 1...dotList.length - 1)
					reflector = Reflect.getProperty(reflector, dotList[i]);

				Reflect.setProperty(reflector, dotList[dotList.length - 1], value);
				return true;
			}

			Reflect.setProperty(this, key, value);
			return true;
		});

		setVar('getProperty', function(variable:String)
		{
			var dotList:Array<String> = variable.split('.');

			if (dotList.length > 1)
			{
				var reflector:Dynamic = Reflect.getProperty(this, dotList[0]);

				for (i in 1...dotList.length - 1)
					reflector = Reflect.getProperty(reflector, dotList[i]);

				return Reflect.getProperty(reflector, dotList[dotList.length - 1]);
			}

			return Reflect.getProperty(this, variable);
		});
	}
}
