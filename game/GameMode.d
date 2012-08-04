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
module game.GameMode;

import engine.FontManager;
import engine.Font;

import game.Mode;
import game.IGame;
import game.IGameMode;
import game.Level;

import tango.core.Array;
import tango.io.Stdout;
import tango.io.Path;
import tango.text.convert.Format;

import allegro5.allegro;
import allegro5.allegro_font;

const int[] Passwords = [2063, 2069, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2129, 2131, 2137, 2141, 2143, 2153, 2161, 2179, 2203, 2207, 2213,
                         2221, 2237, 2239, 2243, 2251, 2267, 2269, 2273, 2281, 2287];

class CGameMode : CMode, IGameMode
{
	this(IGame game)
	{
		super(game);
		
		LevelIdx = cast(int)Passwords.find(Game.Password);
		if(LevelIdx == Passwords.length)
			LevelIdx = 0;
		
		auto ret = LoadLevel();
		if(!ret)
		{
			LevelIdx = 0;
			Game.Password = 0;
			ret = LoadLevel();
			assert(ret);
		}
		
		FontManager = new CFontManager;
		Font = FontManager.Load("data/fonts/Energon.ttf", 24);
	}
	
	override
	EMode Logic(float dt)
	{
		if(!Intermission)
		{
			auto exit = Level.Logic(dt);
			if(exit != ELevelExit.NotYet)
			{
				Level.Dispose();
				Level = null;
				Died = exit == ELevelExit.RestartLevel;
				if(!Died)
					LevelIdx++;
				LoadLevel();
				Intermission = true;
				
				if(Level !is null)
					Game.Password = Passwords[LevelIdx];
			}
		}
		
		return EMode.Game;
	}
	
	override
	void Draw()
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		if(Intermission)
		{
			float sh = Game.Gfx.ScreenHeight;
			float sw = Game.Gfx.ScreenWidth;
				
			Game.Gfx.ResetTransform();
			if(Level !is null)
			{
				if(Died)
				{
					al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), sw / 2, sh / 2 - 40, ALLEGRO_ALIGN_CENTRE, "You died...", LevelIdx - 1);
					al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), sw / 2, sh / 2, ALLEGRO_ALIGN_CENTRE, "Press ENTER"); 
					al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), sw / 2, sh / 2 + 40, ALLEGRO_ALIGN_CENTRE, "to restart level.");
				}
				else
				{
					al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), sw / 2, sh / 2 - 40, ALLEGRO_ALIGN_CENTRE, "Cleared level %d!", LevelIdx - 1);
					al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), sw / 2, sh / 2, ALLEGRO_ALIGN_CENTRE, "Password: %d", Passwords[LevelIdx]); 
					al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), sw / 2, sh / 2 + 40, ALLEGRO_ALIGN_CENTRE, "Press ENTER..."); 
				}
			}
			else
			{
				al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), sw / 2, sh / 2, ALLEGRO_ALIGN_CENTRE, "You've won the game!"); 
			}
		}
		else
		{
			Level.Draw();
		}
	}
	
	override
	EMode Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_ESCAPE:
						return EMode.MainMenu;
					case ALLEGRO_KEY_ENTER:
						Intermission = false;
						if(!Level)
							return EMode.MainMenu;
						break;
					default:
				}
				break;
			}
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
			{
				return EMode.Exit;
			}
			default:
		}
		
		if(!Intermission)
			Level.Input(event);

		return EMode.Game;
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		if(Level)
			Level.Dispose;
		FontManager.Dispose();
	}
	
	override @property
	IGame Game()
	{
		return super.Game();
	}
protected:
	CFont Font;
	CFont TitleFont;
	CFontManager FontManager;

	bool LoadLevel()
	{
		auto level_name = Format("data/maps/level_{}.cfg", LevelIdx);
		if(!exists(level_name))
			return false;
		Level = new CLevel(level_name, this);
		return true;
	}
	bool Intermission = false;
	CLevel Level;
	int LevelIdx = 0;
	bool Died;
}
