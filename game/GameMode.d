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

import game.Mode;
import game.IGame;
import game.IGameMode;
import game.Level;

import tango.io.Stdout;

import allegro5.allegro;

class CGameMode : CMode, IGameMode
{
	this(IGame game)
	{
		super(game);
		Level = new CLevel("data/maps/test.cfg", this);
	}
	
	override
	EMode Logic(float dt)
	{
		Level.Logic(dt);
		
		return EMode.Game;
	}
	
	override
	void Draw()
	{
		al_clear_to_color(al_map_rgb_f(0, 0, 0));
		Level.Draw();
		Game.Gfx.ResetTransform();
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
		
		Level.Input(event);

		return EMode.Game;
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		Level.Dispose;
	}
	
	override @property
	IGame Game()
	{
		return super.Game();
	}
protected:
	CLevel Level;
}
