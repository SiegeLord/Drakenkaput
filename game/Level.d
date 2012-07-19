module game.Level;

import engine.FontManager;
import engine.Font;
import engine.SoundManager;
import engine.Sound;
import engine.MathTypes;
import engine.BitmapManager;
import engine.Config;
import engine.ConfigManager;
import engine.Sprite;
import engine.TileSheet;
import engine.TileMap;
import engine.Camera;
import engine.Util;
import engine.PriorityEvent;
import engine.UnorderedEvent;
import engine.GreasyBag;
import engine.Disposable;

import game.IGameMode;
import game.IGame;
import game.ILevel;
import game.GameObject;
import game.ParticleEmitter;

import game.components.Position;
import game.components.Controller;

import tango.math.Math;
import tango.io.Stdout;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;


final class CLevel : CDisposable, ILevel
{
	this(const(char)[] file, IGameMode mode)
	{
		GameMode = mode;
		
		FontManager = new CFontManager;
		Font = FontManager.Load("data/fonts/Energon.ttf", 24);
		TitleFont = FontManager.Load("data/fonts/Energon.ttf", 48);
		Game.Sfx.PlayMusic("data/music/medium.xm");
		
		SoundManager = new CSoundManager;
		UISound = SoundManager.Load("data/sounds/gui.ogg");
		
		ConfigManager = new CConfigManager;
		BitmapManager = new CBitmapManager;
		
		Emitter = new CParticleEmitter("data/bitmaps/particles.cfg", Game, ConfigManager, BitmapManager);
		Emitter.Position = Game.Gfx.ScreenSize / 2;
		Emitter.Theta = -ALLEGRO_PI / 2;
		
		TileSheet = new CTileSheet("data/tilesheets/test.cfg", ConfigManager, BitmapManager);
		TileMap = new CTileMap("data/maps/test.cfg", TileSheet, ConfigManager);
		
		Camera = new CCamera(Game.Gfx.ScreenSize / 2);
		
		DrawEvent = new typeof(DrawEvent)();
		LogicEvent = new typeof(LogicEvent)();
		Objects = new typeof(Objects)();
		
		Player = new CGameObject("data/objects/obj.cfg", this, ConfigManager);
		auto pos = Player.Get!(CPosition)();
		pos.X = 100;
		pos.Y = 100;
		PlayerController = Player.Get!(CController)();
	}
	
	void Logic(float dt)
	{
		Emitter.Logic(dt);
		Camera.Update(Game.Gfx.ScreenSize);
		
		LogicEvent.Trigger(dt);
		
		Objects.Prune();
		
		CPosition pos;
		if(Player.Get(pos))
		{
			Camera.Position = pos.Position;
		}
		
		SVector2D min_pos = Game.Gfx.ScreenSize / 2;
		SVector2D max_pos = TileMap.PixelSize - Game.Gfx.ScreenSize / 2;
		max_pos.X = max(max_pos.X, min_pos.X);
		max_pos.Y = max(max_pos.Y, min_pos.Y);
		
		Clamp(Camera.Position.X, min_pos.X, max_pos.X);
		Clamp(Camera.Position.Y, min_pos.Y, max_pos.Y);
		Camera.Position.X = floor(Camera.Position.X);
		Camera.Position.Y = floor(Camera.Position.Y);
	}
	
	void Draw()
	{
		Camera.UseTransform();
		
		TileMap.Draw(Camera.Position - Game.Gfx.ScreenSize / 2, Game.Gfx.ScreenSize);
		
		Emitter.Draw();
		
		DrawEvent.Trigger();
	}
	
	void Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_D:
						Player.Remove();
						break;
					default:
				}
				break;
			}
			default:
		}
		
		if(PlayerController !is null)
			PlayerController.Input(event);
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		FontManager.Dispose;
		SoundManager.Dispose;
		ConfigManager.Dispose;
		BitmapManager.Dispose;
	}
	
	override
	TObjHolder AddObject(CGameObject obj)
	{
		return Objects.Add(obj);
	}
	
	override
	void RemoveObject(CGameObject obj, TObjHolder holder)
	{
		Objects.RemoveLater(holder);
	}
	
	override @property
	IGame Game()
	{
		return GameMode.Game;
	}
	
	mixin(Prop!("IGameMode", "GameMode", "override", "protected"));
	mixin(Prop!("CPriorityEvent!()", "DrawEvent", "override", "protected"));
	mixin(Prop!("CUnorderedEvent!(float)", "LogicEvent", "override", "protected"));
	mixin(Prop!("CConfigManager", "ConfigManager", "override", "protected"));
	mixin(Prop!("CBitmapManager", "BitmapManager", "override", "protected"));
protected:
	IGameMode GameModeVal;

	CFont Font;
	CFont TitleFont;
	CFontManager FontManager;
	CSoundManager SoundManager;
	CSound UISound;
	
	CGameObject Player;
	CController PlayerController;
	
	CGreasyBag!(CGameObject) Objects;
	CPriorityEvent!() DrawEventVal;
	CUnorderedEvent!(float) LogicEventVal;
	
	CCamera Camera;
	CTileSheet TileSheet;
	CTileMap TileMap;

	CParticleEmitter Emitter;
	CConfigManager ConfigManagerVal;
	CBitmapManager BitmapManagerVal;
}
