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

import game.ParticleEmitter;
import game.Mode;
import game.IGame;

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
	}
	
	override
	EMode Logic(float dt)
	{
		Emitter.Logic(dt);
		return EMode.Game;
	}
	
	override
	void Draw()
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		
		TileMap.Draw(Pos, Game.Gfx.ScreenSize / 2);
		al_draw_rectangle(Pos.X, Pos.Y, Pos.X + (Game.Gfx.ScreenSize / 2).X, Pos.Y + (Game.Gfx.ScreenSize / 2).Y, al_map_rgb_f(1, 0, 0), 1);
		
		Sprite.Draw(Game.Time, 0, 0);
		
		Emitter.Draw();
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
						Pos.Y -= 2;
						break;
					case ALLEGRO_KEY_DOWN:
						Pos.Y += 2;
						break;
					case ALLEGRO_KEY_LEFT:
						Pos.X -= 2;
						break;
					case ALLEGRO_KEY_RIGHT:
						Pos.X += 2;
						break;
					default:
				}
				break;
			}
			default:
		}
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
	
	SVector2D Pos;
	CTileSheet TileSheet;
	CTileMap TileMap;
	CSprite Sprite;
	CParticleEmitter Emitter;
	CConfigManager ConfigManager;
	CBitmapManager BitmapManager;
}
