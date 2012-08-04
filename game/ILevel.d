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
module game.ILevel;

import engine.PriorityEvent;
import engine.UnorderedEvent;
import engine.GreasyBag;
import engine.BitmapManager;
import engine.ConfigManager;
import engine.MathTypes;

import game.IGame;
import game.IGameMode;
import game.GameObject;
import game.ICollisionManager;

alias CGreasyBag!(CGameObject).CElemHolder TObjHolder;

interface ILevel
{	
	@property
	CPriorityEvent!() DrawEvent();
	
	@property
	CUnorderedEvent!(float) LogicEvent();
	
	@property
	IGameMode GameMode();
	
	@property
	IGame Game();
	
	TObjHolder AddObject(CGameObject obj);
	void RemoveObject(CGameObject obj, TObjHolder holder);
	
	@property
	CBitmapManager BitmapManager();
	
	@property
	CConfigManager ConfigManager();
	
	@property
	ICollisionManager CollisionManager();
	
	@property
	CGameObject Player();
	
	void DamageRectangle(SRect rect, const(char)[] damage_type, float damage, bool fire = false);
	
	void EnemyDead();
	
	void LaunchBullet(const(char)[] bullet_name, SVector2D pos, SVector2D vel);
	
	bool CheckCollision(SRect rect);
	
	bool Dragon();
	
	void delegate() AddFireEffect(CGameObject obj);
	
	void SpawnExplosion(const(char)[] bullet_name, SVector2D pos, float theta);
}
