module game.components.Position;

import engine.MathTypes;
import engine.Config;

import game.GameObject;
 
class CPosition : CGameComponent
{
	this(CConfig config)
	{
		super(config);
	}
	
	alias Position this;
	
	SVector2D Position;
}
