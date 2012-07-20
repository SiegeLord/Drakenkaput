module game.components.Collision;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;
import engine.Util;

import game.ICollisionManager;
import game.GameObject;
import game.components.Position;

import tango.io.Stdout;
 
class CCollision : CGameComponent
{
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Position, holder, this);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		CollisionRect = SRect(config.Get!(SVector2D)(ComponentName!(typeof(this)), "top_left", SVector2D(0, 0)),
		                      config.Get!(SVector2D)(ComponentName!(typeof(this)), "bottom_right", SVector2D(0, 0)));
		Holder = game_obj.Level.CollisionManager.AddCollision(this);
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.CollisionManager.RemoveCollision(this, Holder);
	}
	
	@property
	SRect WorldCollisionRect()
	{
		return SRect(CollisionRect.Min + Position.Position, CollisionRect.Max + Position.Position);
	}
	
	mixin(Prop!("SRect", "CollisionRect", "", "protected"));
protected:
	CPosition Position;
	SRect CollisionRectVal;
	TColHolder Holder;
}

