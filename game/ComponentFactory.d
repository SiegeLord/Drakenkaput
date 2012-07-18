module game.ComponentFactory;

import game.GameObject;
import engine.Config;

alias CGameComponent function(CConfig config) TCreator;

TCreator[char[]] Creators;

CGameComponent CreatorFunc(T)(CConfig config)
{
	return new T(config);
}

CGameComponent CreateComponent(CConfig config, const(char)[] name)
{
	auto creator_ptr = name in Creators;
	if(creator_ptr is null)
		throw new Exception(name.idup ~ " is not a valid component");
	return (*creator_ptr)(config);
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

mixin(FactorySource("Position"));
