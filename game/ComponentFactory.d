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

mixin(FactorySource("Position", "SimpleAnimation", "Velocity", "Controller"));
