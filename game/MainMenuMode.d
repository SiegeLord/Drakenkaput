module game.MainMenuMode;

import engine.FontManager;
import engine.Font;
import engine.SoundManager;
import engine.Sound;
import engine.MathTypes;

import game.Mode;
import game.IGame;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;

class CMainMenuMode : CMode
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
	}
	
	override
	EMode Logic(float dt)
	{
		return EMode.MainMenu;
	}
	
	override
	void Draw(float physics_alpha)
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		
		auto mid = Game.Gfx.ScreenSize / 2 + SVector2D(0, 50);
		
		auto title_mid = Game.Gfx.ScreenSize / 2 - SVector2D(0, 70);
		
		auto select_color = al_map_rgb_f(1, 1, 1);
		auto normal_color = al_map_rgb_f(0.5, 1, 0.5);
		
		al_draw_text(Font.Get, CurChoice == 0 ? select_color : normal_color, mid.X, mid.Y - 45, ALLEGRO_ALIGN_CENTRE, "Continue Game");
		al_draw_text(Font.Get, CurChoice == 1 ? select_color : normal_color, mid.X, mid.Y, ALLEGRO_ALIGN_CENTRE, "New Game");
		al_draw_text(Font.Get, CurChoice == 2 ? select_color : normal_color, mid.X, mid.Y + 45, ALLEGRO_ALIGN_CENTRE, "Quit");
		
		al_draw_text(TitleFont.Get, al_map_rgb_f(0.5, 0.5, 1), title_mid.X, title_mid.Y, ALLEGRO_ALIGN_CENTRE, "Cortex Terror");
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
						return EMode.Exit;
						break;
					case ALLEGRO_KEY_ENTER:
						switch(CurChoice)
						{
							case 0:
								return EMode.Game;
								break;
							case 1:
								return EMode.Game;
								break;
							default: goto case;
							case 2:
								return EMode.Exit;
						}
						break;
					case ALLEGRO_KEY_UP:
						CurChoice--;
						UISound.Play;
						
						if(CurChoice < 0)
							CurChoice = 2;
						break;
					case ALLEGRO_KEY_DOWN:
						CurChoice++;
						UISound.Play;
						
						if(CurChoice > 2)
							CurChoice = 0;
						break;
					default:
				}
				break;
			}
			default:
		}
		return EMode.MainMenu;
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		FontManager.Dispose;
		SoundManager.Dispose;
	}
protected:
	int CurChoice = 0;
	CFont Font;
	CFont TitleFont;
	CFontManager FontManager;
	CSoundManager SoundManager;
	CSound UISound;
}
