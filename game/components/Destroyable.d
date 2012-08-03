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
module game.components.Destroyable;

import engine.MathTypes;
import engine.Config;
import engine.Util;
import engine.ComponentHolder;

import game.GameObject;

import tango.io.Stdout;
 
class CDestroyable : CGameComponent
{
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		MaxHealth = config.Get!(float)(ComponentName!(typeof(this)), "health", 10);
		Health = MaxHealth;
		ImmuneDuration = config.Get!(float)(ComponentName!(typeof(this)), "immune_dur", 0.5);
		DamageType = config.Get!(const(char)[])(ComponentName!(typeof(this)), "damage_type", "");
		
		Time = &game_obj.Level.Game.Time;
		GameObject = game_obj;
	}
	
	void Damage(const(char)[] type, float ammount)
	{
		if(!Immune() && type == DamageType)
		{
			Health = Health - ammount;
			if(ammount > 0)
				ImmuneUntil = Time() + ImmuneDuration;
			
			Clamp(HealthVal, 0.0f, MaxHealth);
			if(Health == 0)
				GameObject.Remove();
		}
	}
	
	bool Immune()
	{
		return Time() < ImmuneUntil;
	}
	
	mixin(Prop!("float", "Health", "", "protected"));
protected:
	CGameObject GameObject;
	double delegate() Time;
	float HealthVal;
	float MaxHealth;
	float ImmuneDuration;
	float ImmuneUntil = -float.infinity;
	const(char)[] DamageType;
}
