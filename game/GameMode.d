module game.GameMode;

import engine.FontManager;
import engine.Font;
import engine.SoundManager;
import engine.Sound;
import engine.MathTypes;
import engine.BitmapManager;
import engine.ConfigManager;
import engine.Sprite;
import engine.TileSheet;
import engine.TileMap;
import engine.Camera;
import engine.Util;

import game.ParticleEmitter;
import game.Mode;
import game.IGame;

import tango.math.Math;
import tango.io.Stdout;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;

class CGameMode : CMode
{
	this(IGame game)
	{
		super(game);
		FontManager = new CFontManager;
		Font = FontManager.Load("data/fonts/Energon.ttf", 24);
		TitleFont = FontManager.Load("data/fonts/Energon.ttf", 48);
		Game.Sfx.PlayMusic("data/music/medium.xm");
		
		SoundManager = new CSoundManager;
		UISound = SoundManager.Load("data/sounds/gui.ogg");
		
		ConfigManager = new CConfigManager;
		BitmapManager = new CBitmapManager;
		Sprite = new CSprite("data/bitmaps/test.cfg", ConfigManager, BitmapManager);
		Emitter = new CParticleEmitter("data/bitmaps/particles.cfg", Game, ConfigManager, BitmapManager);
		Emitter.Position = Game.Gfx.ScreenSize / 2;
		Emitter.Theta = -ALLEGRO_PI / 2;
		
		TileSheet = new CTileSheet("data/tilesheets/test.cfg", ConfigManager, BitmapManager);
		TileMap = new CTileMap("data/maps/test.cfg", TileSheet, ConfigManager);
		
		Camera = new CCamera(Game.Gfx.ScreenSize / 2);
	}
	
	override
	EMode Logic(float dt)
	{
		Emitter.Logic(dt);
		Camera.Update(Game.Gfx.ScreenSize);
		
		return EMode.Game;
	}
	
	override
	void Draw()
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		
		Camera.UseTransform();
		
		TileMap.Draw(Camera.Position - Game.Gfx.ScreenSize / 2, Game.Gfx.ScreenSize);
		
		Sprite.Draw(Game.Time, 0, 0);
		
		Emitter.Draw();
		
		Game.Gfx.ResetTransform();
	}
	
	override
	EMode Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
			{
				return EMode.Exit;
				break;
			}
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_ESCAPE:
						return EMode.MainMenu;
						break;
					case ALLEGRO_KEY_UP:
						Camera.Position.Y -= 2;
						break;
					case ALLEGRO_KEY_DOWN:
						Camera.Position.Y += 2;
						break;
					case ALLEGRO_KEY_LEFT:
						Camera.Position.X -= 2;
						break;
					case ALLEGRO_KEY_RIGHT:
						Camera.Position.X += 2;
						break;
					default:
				}
				break;
			}
			default:
		}
		
		SVector2D min_pos = Game.Gfx.ScreenSize / 2;
		SVector2D max_pos = TileMap.PixelSize - Game.Gfx.ScreenSize / 2;
		max_pos.X = max(max_pos.X, min_pos.X);
		max_pos.Y = max(max_pos.Y, min_pos.Y);
		
		Clamp(Camera.Position.X, min_pos.X, max_pos.X);
		Clamp(Camera.Position.Y, min_pos.Y, max_pos.Y);
		
		return EMode.Game;
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
protected:
	CFont Font;
	CFont TitleFont;
	CFontManager FontManager;
	CSoundManager SoundManager;
	CSound UISound;
	
	CCamera Camera;
	CTileSheet TileSheet;
	CTileMap TileMap;
	CSprite Sprite;
	CParticleEmitter Emitter;
	CConfigManager ConfigManager;
	CBitmapManager BitmapManager;
}
