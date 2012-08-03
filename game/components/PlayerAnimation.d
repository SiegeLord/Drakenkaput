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
module game.components.PlayerAnimation;

import engine.MathTypes;
import engine.Config;
import engine.Sprite;
import engine.ComponentHolder;

import game.GameObject;

import game.components.Position;
 
class CPlayerAnimation : CGameComponent
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
