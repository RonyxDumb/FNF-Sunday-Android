package;

import flixel.FlxState;
import flixel.FlxG;

import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.system.FlxSound;
import openfl.utils.Assets;

import openfl.Lib;

using StringTools;

class VideoState extends MusicBeatState
{
	public var leSource:String = "";
	//public var transClass:FlxState;
	public var transFunction:Void->Void;
	public var txt:FlxText;
	public var fuckingVolume:Float = 1;
	public var notDone:Bool = true;
	public var vidSound:FlxSound;
	public var useSound:Bool = false;
	public var soundMultiplier:Float = 1;
	public var prevSoundMultiplier:Float = 1;
	public var videoFrames:Int = 0;
	public var defaultText:String = "";
	public var doShit:Bool = false;
	public var pauseText:String = "Press P To Pause/Unpause";
	public var videoSprite:FlxSprite = new FlxSprite();
	var ishit = 0;

	public function new(source:String, toTrans:Void->Void)
	{
		super();
		
		leSource = source;
		//transClass = toTrans;
		transFunction = toTrans;
	}
	
	override function create()
	{
		super.create();
		FlxG.autoPause = false;
		doShit = false;
		
		if (GlobalVideo.isWebm)
		{
		videoFrames = Std.parseInt(Assets.getText(leSource.replace(".webm", ".txt")));
		}
		
		fuckingVolume = FlxG.sound.music.volume;
		FlxG.sound.music.volume = 0;
		var isHTML:Bool = false;
		#if web
		isHTML = true;
		#end
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var skipText:FlxText = new FlxText(0, 0, 0, "Press ENTER to Skip", 16);
		skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE,0xFF000000,2,1);
		skipText.y = 720 - skipText.height;
		var html5Text:String = "You Are Not Using HTML5...\nThe Video Didnt Load!";
		if (isHTML)
		{
			html5Text = "You Are Using HTML5!";
		}
		defaultText = "If Your On HTML5\nTap Anything...\nThe Bottom Text Indicates If You\nAre Using HTML5...\n\n" + html5Text;
		txt = new FlxText(0, 0, FlxG.width,
			defaultText,
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
		add(videoSprite);
		add(skipText);

		if (GlobalVideo.isWebm)
		{
			//if (Assets.exists(leSource.replace(".webm", ".ogg"), MUSIC) || Assets.exists(leSource.replace(".webm", ".ogg"), SOUND))
			//{
				useSound = true;
				vidSound = FlxG.sound.play(leSource.replace(".webm", ".ogg"));
			//}
		}

		GlobalVideo.get().source(Asset2File.getPath(leSource));
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		} else {
			GlobalVideo.get().play();
		}
		
		/*if (useSound)
		{*/
			//vidSound = FlxG.sound.play(leSource.replace(".webm", ".ogg"));
		
			/*new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{*/
				vidSound.time = vidSound.length * soundMultiplier;
				/*new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					if (useSound)
					{
						vidSound.time = vidSound.length * soundMultiplier;
					}
				}, 0);*/
				doShit = false;
			//}, 1);
		//}
		var data = Main.webmHandle.webm.bitmapData;
		videoSprite.loadGraphic(data);
		videoSprite.setGraphicSize(Std.int(videoSprite.width * 2));
		videoSprite.updateHitbox();
		
		FlxG.camera.flash(FlxColor.BLACK, 0.5);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (ishit < 8) pauseShit();
		ishit++;
		if (useSound)
		{
			var wasFuckingHit = GlobalVideo.get().webm.wasHitOnce;
			soundMultiplier = GlobalVideo.get().webm.renderedCount / videoFrames;
			
			if (soundMultiplier > 1)
			{
				soundMultiplier = 1;
			}
			if (soundMultiplier < 0)
			{
				soundMultiplier = 0;
			}
			if (doShit)
			{
				var compareShit:Float = 50;
				if (vidSound.time >= (vidSound.length * soundMultiplier) + compareShit || vidSound.time <= (vidSound.length * soundMultiplier) - compareShit)
					vidSound.time = vidSound.length * soundMultiplier;
			}
			if (wasFuckingHit)
			{
			if (soundMultiplier == 0)
			{
				if (prevSoundMultiplier != 0)
				{
					vidSound.pause();
					vidSound.time = 0;
				}
			} else {
				if (prevSoundMultiplier == 0)
				{
					vidSound.resume();
					vidSound.time = vidSound.length * soundMultiplier;
				}
			}
			prevSoundMultiplier = soundMultiplier;
			}
		}
		
		if (notDone)
		{
			FlxG.sound.music.volume = 0;
		}
		GlobalVideo.get().update(elapsed);

		if (controls.RESET)
		{
			GlobalVideo.get().restart();
		}
		
		/*
		if (FlxG.keys.justPressed.P)
		{
			pauseShit();
		}*/

		#if mobile
		var justTouched:Bool = false;

		for (touch in FlxG.touches.list)
		{
			justTouched = false;
			
			if (touch.justReleased){
				justTouched = true;
			}
		}
		#end
		
		if (justTouched || GlobalVideo.get().ended || GlobalVideo.get().stopped)
		{
			txt.visible = false;
			GlobalVideo.get().hide();
			GlobalVideo.get().stop();
		}
		
		if (justTouched || GlobalVideo.get().ended)
		{
			notDone = false;
			FlxG.sound.music.volume = fuckingVolume;
			txt.text = pauseText;
			FlxG.autoPause = true;
			//FlxG.switchState(transClass);
			transFunction();
		}
		
		if (GlobalVideo.get().played || GlobalVideo.get().restarted)
		{
			GlobalVideo.get().show();
		}
		
		GlobalVideo.get().restarted = false;
		GlobalVideo.get().played = false;
		GlobalVideo.get().stopped = false;
		GlobalVideo.get().ended = false;
	}
	
	public function pauseShit() 
	{
		
			txt.text = pauseText;
			trace("PRESSED PAUSE");
			GlobalVideo.get().togglePause();
			if (GlobalVideo.get().paused)
			{
				videoSprite.alpha = 0.5;
				GlobalVideo.get().alpha();
			} else {
				videoSprite.alpha = 1;
				GlobalVideo.get().unalpha();
				txt.text = defaultText;
			}
	}
}