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

import tango.text.convert.Format;
import tango.util.Convert;

class CMainMenuMode : CMode
{
	this(IGame game)
	{
		super(game);
		FontManager = new CFontManager;
		Font = FontManager.Load("data/fonts/Font.ttf", 14);
		TitleFont = FontManager.Load("data/fonts/Font.ttf", 28);
		//Game.Sfx.PlayMusic("data/music/medium.xm");
		
		SoundManager = new CSoundManager;
		
		ConfigManager = new CConfigManager;
		BitmapManager = new CBitmapManager;
		
		PasswordText = Game.Password == 0 ? "" : Format("{}", Game.Password);
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
		
		Game.Gfx.ResetTransform();
		
		auto mid = Game.Gfx.ScreenSize / 2 + SVector2D(0, 50);
		
		auto title_mid = Game.Gfx.ScreenSize / 2 - SVector2D(0, 70);
		
		auto select_color = al_map_rgb_f(1, 1, 1);
		auto normal_color = al_map_rgb_f(1, 1, 0.5);
		
		al_draw_text(Font.Get, CurChoice == 0 ? select_color : normal_color, mid.X, mid.Y - 20, ALLEGRO_ALIGN_CENTRE, "New Game");
		al_draw_textf(Font.Get, CurChoice == 1 ? select_color : normal_color, mid.X, mid.Y, ALLEGRO_ALIGN_CENTRE, Format("Password: {}\0", PasswordText).ptr);
		al_draw_text(Font.Get, CurChoice == 2 ? select_color : normal_color, mid.X, mid.Y + 20, ALLEGRO_ALIGN_CENTRE, "Quit");
		
		al_draw_text(TitleFont.Get, al_map_rgb_f(1, 0.2, 0.2), title_mid.X, title_mid.Y, ALLEGRO_ALIGN_CENTRE, "Drakenkaput");
		
		al_draw_text(Font.Get, al_map_rgb_f(0.5, 0.5, 0.5), title_mid.X, Game.Gfx.ScreenHeight - 20, ALLEGRO_ALIGN_CENTRE, "SiegeLord TINS 2012");
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
								Game.Password = 0;
								return EMode.Game;
							case 1:
								try
								{
									Game.Password = to!(int)(PasswordText);
								}
								catch(Exception e)
								{
									Game.Password = 0;
								}
								return EMode.Game;
							default: goto case;
							case 2:
								return EMode.Exit;
						}
					case ALLEGRO_KEY_BACKSPACE:
						if(CurChoice == 1)
						{
							if(PasswordText.length)
								PasswordText = PasswordText[0..$-1];
						}
						break;
					case ALLEGRO_KEY_UP:
						CurChoice--;
						
						if(CurChoice < 0)
							CurChoice = 2;
						break;
					case ALLEGRO_KEY_DOWN:
						CurChoice++;
						
						if(CurChoice > 2)
							CurChoice = 0;
						break;
					default:
				}
				break;
			}
			case ALLEGRO_EVENT_KEY_CHAR:
			{
				if(CurChoice == 1)
				{
					auto character = event.keyboard.unichar;
					if(character > 32 && character < 127 && PasswordText.length < 4)
						PasswordText ~= cast(char)character;
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
	const(char)[] PasswordText;
	
	CConfigManager ConfigManager;
	CBitmapManager BitmapManager;
}
