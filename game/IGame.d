module game.IGame;

import engine.Gfx;
import engine.Sfx;
import engine.Config;

enum EMode
{
	MainMenu,
	Game,
	Exit
}

enum FixedDt = 1.0f/60.0f;

interface IGame
{
	float Time();
	@property
	CGfx Gfx();
	@property
	CSfx Sfx();
	CConfig Options();
}
