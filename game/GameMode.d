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
