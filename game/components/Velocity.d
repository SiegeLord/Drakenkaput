module game.components.Velocity;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;

import game.GameObject;
import game.components.Position;

import tango.io.Stdout;
 
class CVelocity : CGameComponent
{	
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Position, holder, this);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		game_obj.Level.LogicEvent.Register(&Logic);
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.LogicEvent.UnRegister(&Logic);
	}
	
	void Logic(float dt)
	{
	//	Stdout(Velocity.X, Velocity.Y).nl;
		Position.Position += Velocity * dt;
	}
	
	alias Velocity this;
	SVector2D Velocity;
protected:
	CPosition Position;
}
