package funkin;

import base.Controls;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;

/**
	I quite honestly have no use for this yet, I just wouldn't like to change how the meta information works
	so I'm importing it to keep it the same. I'm mostly going to overhaul some things like gameplay and will 
	give the game an options menu but I won't change the song system because I have no idea how to do that lmao
**/
class PlayerSettings
{
	// static public var numPlayers(default, null) = 0;
	// static public var numAvatars(default, null) = 0;
	static public var player1(default, null):PlayerSettings;

	// static public var player2(default, null):PlayerSettings;
	// #if (haxe >= "4.0.0")
	// static public final onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
	// static public final onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();
	// #else
	// static public var onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
	// static public var onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();
	// #end
	public var id(default, null):Int;

	#if (haxe >= "4.0.0")
	public final controls:Controls;
	#else
	public var controls:Controls;
	#end

	// public var avatar:Player;
	// public var camera(get, never):PlayCamera;

	function new(id)
	{
		this.id = id;
		this.controls = new Controls('player$id');
	}

	/* 
		static public function addAvatar(avatar:Player):PlayerSettings
		{
			var settings:PlayerSettings;

			if (player1 == null)
			{
				player1 = new PlayerSettings(0, Solo);
				++numPlayers;
			}

			if (player1.avatar == null)
				settings = player1;
			else
			{
				if (player2 == null)
				{
					if (player1.controls.keyboardScheme.match(Duo(true)))
						player2 = new PlayerSettings(1, Duo(false));
					else
						player2 = new PlayerSettings(1, None);
					++numPlayers;
				}

				if (player2.avatar == null)
					settings = player2;
				else
					throw throw 'Invalid number of players: ${numPlayers + 1}';
			}
			++numAvatars;
			settings.avatar = avatar;
			avatar.settings = settings;

			splitCameras();

			onAvatarAdd.dispatch(settings);

			return settings;
		}

		static public function removeAvatar(avatar:Player):Void
		{
			var settings:PlayerSettings;

			if (player1 != null && player1.avatar == avatar)
				settings = player1;
			else if (player2 != null && player2.avatar == avatar)
			{
				settings = player2;
				if (player1.controls.keyboardScheme.match(Duo(_)))
					player1.reloadKeyboardScheme();
			}
			else
				throw "Cannot remove avatar that is not for a player";

			settings.avatar = null;
			while (settings.controls.gamepadsAdded.length > 0)
			{
				final id = settings.controls.gamepadsAdded.shift();
				settings.controls.removeGamepad(id);
				DeviceManager.releaseGamepad(FlxG.gamepads.getByID(id));
			}

			--numAvatars;

			splitCameras();

			onAvatarRemove.dispatch(avatar.settings);
		}

	 */
	static public function init():Void
	{
		if (player1 == null)
		{
			player1 = new PlayerSettings(0);
			// ++numPlayers;
		}

		var numGamepads = FlxG.gamepads.numActiveGamepads;
		if (numGamepads > 0)
		{
			var gamepad = FlxG.gamepads.getByID(0);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:0';

			player1.controls.addDefaultGamepad(0);
		}

		// if (numGamepads > 1)
		// {
		// 	if (player2 == null)
		// 	{
		// 		player2 = new PlayerSettings(1, None);
		// 		++numPlayers;
		// 	}

		// 	var gamepad = FlxG.gamepads.getByID(1);
		// 	if (gamepad == null)
		// 		throw 'Unexpected null gamepad. id:0';

		// 	player2.controls.addDefaultGamepad(1);
		// }

		FlxG.gamepads.deviceConnected.add(onGamepadConnection);
	}

	static function onGamepadConnection(pad:FlxGamepad)
	{
		player1.controls.addDefaultGamepad(pad.id);
	}

	static public function reset()
	{
		player1 = null;
		// player2 = null;
		// numPlayers = 0;
		FlxG.gamepads.deviceConnected.remove(onGamepadConnection);
	}
}
