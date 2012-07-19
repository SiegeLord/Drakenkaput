module game.components.SimpleAnimation;

import engine.MathTypes;
import engine.Config;
import engine.Sprite;
import engine.ComponentHolder;

import game.GameObject;

import game.components.Position;
 
class CSimpleAnimation : CGameComponent
{
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Position, holder, this);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		game_obj.Level.DrawEvent.Register(&Draw);
		
		auto sprite_file = config.Get!(const(char)[])(ComponentName!(typeof(this)), "sprite", "");
		if(sprite_file == "")
			throw new Exception("'" ~ ComponentName!(typeof(this)) ~ "' needs a sprite file.");
		Sprite = new CSprite(sprite_file, game_obj.Level.ConfigManager, game_obj.Level.BitmapManager);
		Time = &game_obj.Level.Game.Time;
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.DrawEvent.UnRegister(&Draw);
	}
	
	void Draw()
	{
		Sprite.Draw(Time(), Position.X, Position.Y);
	}
protected:
	double delegate() Time;
	CSprite Sprite;
	CPosition Position;
}
