module game.components.Velocity;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;

import game.GameObject;
import game.components.Position;
import game.components.Collision;

import tango.io.Stdout;
 
class CVelocity : CGameComponent
{	
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Position, holder, this);
		holder.Get(Collision);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		GameObject = game_obj;
		game_obj.Level.LogicEvent.Register(&Logic);
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.LogicEvent.UnRegister(&Logic);
	}
	
	void Logic(float dt)
	{
		if(Collision is null)
		{
			Position.Position += Velocity * dt;
		}
		else
		{
			if(Velocity != SVector2D(0, 0))
			{
				auto new_pos = Position.Position + Velocity * dt;
				Position.Position = GameObject.Level.CollisionManager.Move(Collision, Position.Position, new_pos);
			}
		}
	}
	
	alias Velocity this;
	SVector2D Velocity;
protected:
	CGameObject GameObject;
	CPosition Position;
	CCollision Collision;
}
