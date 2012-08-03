/*
Copyright 2012 Pavel Sountsov

This file is part of TINSEngine.

TINSEngine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

TINSEngine is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with TINSEngine.  If not, see <http://www.gnu.org/licenses/>.
*/
module game.MainMenuMode;

import engine.FontManager;
import engine.Font;
import engine.SoundManager;
import engine.Sound;
import engine.MathTypes;
import engine.BitmapManager;
import engine.ConfigManager;

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
		//Game.Sfx.PlayMusic("data/music/medium.xm");
		
		SoundManager = new CSoundManager;
		UISound = SoundManager.Load("data/sounds/gui.ogg");
		
		ConfigManager = new CConfigManager;
		BitmapManager = new CBitmapManager;
	}
	
	override
	EMode Logic(float dt)
	{
		return EMode.MainMenu;
	}
	
	override
	void Draw()
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		
		auto mid = Game.Gfx.ScreenSize / 2 + SVector2D(0, 50);
		
		auto title_mid = Game.Gfx.ScreenSize / 2 - SVector2D(0, 70);
		
		auto select_color = al_map_rgb_f(1, 1, 1);
		auto normal_color = al_map_rgb_f(0.5, 1, 0.5);
		
		al_draw_text(Font.Get, CurChoice == 0 ? select_color : normal_color, mid.X, mid.Y - 45, ALLEGRO_ALIGN_CENTRE, "Continue Game");
		al_draw_text(Font.Get, CurChoice == 1 ? select_color : normal_color, mid.X, mid.Y, ALLEGRO_ALIGN_CENTRE, "New Game");
		al_draw_text(Font.Get, CurChoice == 2 ? select_color : normal_color, mid.X, mid.Y + 45, ALLEGRO_ALIGN_CENTRE, "Quit");
		
		al_draw_text(TitleFont.Get, al_map_rgb_f(0.5, 0.5, 1), title_mid.X, title_mid.Y, ALLEGRO_ALIGN_CENTRE, "Drakenkaput");
	}
	
	override
	EMode Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
			{
				return EMode.Exit;
			}
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_ESCAPE:
						return EMode.Exit;
					case ALLEGRO_KEY_ENTER:
						switch(CurChoice)
						{
							case 0:
								return EMode.Game;
							case 1:
								return EMode.Game;
							default: goto case;
							case 2:
								return EMode.Exit;
						}
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
		ConfigManager.Dispose;
		BitmapManager.Dispose;
	}
protected:
	int CurChoice = 0;
	CFont Font;
	CFont TitleFont;
	CFontManager FontManager;
	CSoundManager SoundManager;
	CSound UISound;
	
	CConfigManager ConfigManager;
	CBitmapManager BitmapManager;
}
