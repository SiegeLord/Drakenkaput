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
module game.ComponentFactory;

import game.GameObject;
import engine.Config;

alias CGameComponent function() TCreator;

TCreator[char[]] Creators;

CGameComponent CreatorFunc(T)()
{
	return new T;
}

CGameComponent CreateComponent(const(char)[] name)
{
	auto creator_ptr = name in Creators;
	if(creator_ptr is null)
		throw new Exception(name.idup ~ " is not a valid component");
	return (*creator_ptr)();
}

const(char)[] FactorySource(const(char)[][] components...)
{
	const(char)[] ret;
	foreach(component; components)
		ret ~= `import game.components.` ~ component ~ `;`;
	
	ret ~= "shared static this() {";
	foreach(component; components)
		ret ~= `Creators["` ~ component ~ `"] = &CreatorFunc!(C` ~ component ~ `);`;
	
	ret ~= "}";
	return ret;
}

mixin(FactorySource("Position", "SimpleAnimation", "Velocity", "Controller", "Collision", "Direction", "Moving", "Attacking", "Sword", "AIController",
"Destroyable", "Enemy", "Gun", "Kamikaze", "BulletAnimation", "Flammable", "FireEffect", "Explosion"));
