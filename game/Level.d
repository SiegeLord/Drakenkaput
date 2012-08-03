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
module game.Level;

import engine.FontManager;
import engine.Font;
import engine.SoundManager;
import engine.Sound;
import engine.MathTypes;
import engine.BitmapManager;
import engine.Config;
import engine.ConfigManager;
import engine.Sprite;
import engine.TileSheet;
import engine.TileMap;
import engine.Camera;
import engine.Util;
import engine.PriorityEvent;
import engine.UnorderedEvent;
import engine.GreasyBag;
import engine.Disposable;

import game.IGameMode;
import game.IGame;
import game.ILevel;
import game.GameObject;
import game.ParticleEmitter;
import game.ICollisionManager;
import game.CollisionManager;

import game.components.Destroyable;
import game.components.Position;
import game.components.Controller;

import tango.math.Math;
import tango.io.Stdout;
import tango.text.convert.Format;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;


final class CLevel : CDisposable, ILevel
{
	this(const(char)[] file, IGameMode mode)
	{
		GameMode = mode;
		
		FontManager = new CFontManager;
		Font = FontManager.Load("data/fonts/Energon.ttf", 24);
		TitleFont = FontManager.Load("data/fonts/Energon.ttf", 48);
		//Game.Sfx.PlayMusic("data/music/medium.xm");
		
		SoundManager = new CSoundManager;
		UISound = SoundManager.Load("data/sounds/gui.ogg");
		
		ConfigManager = new CConfigManager;
		BitmapManager = new CBitmapManager;
		
		Emitter = new CParticleEmitter("data/bitmaps/particles.cfg", Game, ConfigManager, BitmapManager);
		Emitter.Position = Game.Gfx.ScreenSize / 2;
		Emitter.Theta = -ALLEGRO_PI / 2;
		
		TileMap = new CTileMap(file, ConfigManager, BitmapManager);
		
		auto cfg = ConfigManager.Load(file);
		
		Camera = new CCamera(Game.Gfx.ScreenSize / 2);
		
		DrawEvent = new typeof(DrawEvent)();
		LogicEvent = new typeof(LogicEvent)();
		Objects = new typeof(Objects)();
		
		CollisionManager = new CCollisionManager(TileMap.Width, TileMap.Height, TileMap.TileWidth, TileMap.TileHeight);
		CollisionManagerVal.UpdateTileMap(TileMap);
		
		Player = new CGameObject("data/objects/player.cfg", this, ConfigManager);
		auto pos_comp = Player.Get!(CPosition)();
		pos_comp.X = 100;
		pos_comp.Y = 100;
		PlayerController = Player.Get!(CController)();
		
		int n = 0;
		while(true)
		{
			auto section = Format("enemy_{}", n);
			auto enemy_name = cfg.Get!(const(char)[])(section, "name", "");
			if(enemy_name == "")
				break;
			
			int m = 0;
			while(true)
			{
				auto pos_str = Format("pos_{}", m);
				auto pos = cfg.Get!(SVector2D)(section, pos_str, SVector2D(-1, -1));
				if(pos.X < 0)
					break;
				pos.X *= TileMap.TileWidth;
				pos.Y *= TileMap.TileHeight;
				
				auto obj = new CGameObject(enemy_name, this, ConfigManager);
				assert(obj);
				pos_comp = obj.Get!(CPosition)();
				pos_comp = pos;
				
				m++;
			}
			
			n++;
		}
	}
	
	void Logic(float dt)
	{
		Emitter.Logic(dt);
		
		LogicEvent.Trigger(dt);
		
		Objects.Prune();
		
		CPosition pos;
		if(Player && Player.Get(pos))
			Camera.Position = pos.Position;
		
		SVector2D min_pos = Game.Gfx.ScreenSize / 2;
		SVector2D max_pos = TileMap.PixelSize - Game.Gfx.ScreenSize / 2;
		max_pos.X = max(max_pos.X, min_pos.X);
		max_pos.Y = max(max_pos.Y, min_pos.Y);
		
		Clamp(Camera.Position.X, min_pos.X, max_pos.X);
		Clamp(Camera.Position.Y, min_pos.Y, max_pos.Y);
		Camera.Position.X = floor(Camera.Position.X);
		Camera.Position.Y = floor(Camera.Position.Y);
		
		Camera.Update(Game.Gfx.ScreenSize);
		
		if(Game.Time() > TimeOutTime)
			EnemyCounter = 0;
	}
	
	void Draw()
	{
		Camera.UseTransform();
		
		TileMap.Draw(Camera.Position - Game.Gfx.ScreenSize / 2, Game.Gfx.ScreenSize);
		
		Emitter.Draw();
		
		DrawEvent.Trigger();
		
		GameMode.Game.Gfx.ResetTransform();
		
		if(EnemyCounter > 0)
			al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), 20, 20, 0, "Combo: %d", EnemyCounter); 
	}
	
	void Input(ALLEGRO_EVENT* event)
	{
		switch(event.type)
		{
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_D:
						Player.Remove();
						break;
					default:
				}
				break;
			}
			default:
		}
		
		if(PlayerController !is null)
			PlayerController.Input(event);
	}
	
	override
	void Dispose()
	{
		super.Dispose;
		FontManager.Dispose;
		SoundManager.Dispose;
		ConfigManager.Dispose;
		BitmapManager.Dispose;
	}
	
	override
	TObjHolder AddObject(CGameObject obj)
	{
		return Objects.Add(obj);
	}
	
	override
	void RemoveObject(CGameObject obj, TObjHolder holder)
	{
		Objects.RemoveLater(holder);
		if(obj == Player)
		{
			Player = null;
			PlayerController = null;
		}
	}
	
	override @property
	IGame Game()
	{
		return GameMode.Game;
	}
	
	override @property
	ICollisionManager CollisionManager()
	{
		return CollisionManagerVal;
	}
	
	protected @property
	CCollisionManager CollisionManager(CCollisionManager val)
	{
		return CollisionManagerVal = val;
	}
	
	override
	void DamageRectangle(SRect rect, const(char)[] damage_type, float damage)
	{
		foreach(col; CollisionManagerVal.Collisions)
		{
			if(col.WorldCollisionRect.Collide(rect))
			{
				auto damager = col.GameObject.Get!(CDestroyable);
				if(damager !is null)
					damager.Damage(damage_type, damage);
			}
		}
	}
	
	override
	void EnemyDead()
	{
		EnemyCounter++;
		TimeOutTime = Game.Time() + 5;
	}
	
	mixin(Prop!("IGameMode", "GameMode", "override", "protected"));
	mixin(Prop!("CPriorityEvent!()", "DrawEvent", "override", "protected"));
	mixin(Prop!("CUnorderedEvent!(float)", "LogicEvent", "override", "protected"));
	mixin(Prop!("CConfigManager", "ConfigManager", "override", "protected"));
	mixin(Prop!("CBitmapManager", "BitmapManager", "override", "protected"));
	mixin(Prop!("CGameObject", "Player", "override", "protected"));
protected:
	float TimeOutTime = -float.infinity;
	int EnemyCounter = 0;
	IGameMode GameModeVal;

	CFont Font;
	CFont TitleFont;
	CFontManager FontManager;
	CSoundManager SoundManager;
	CSound UISound;
	
	CGameObject PlayerVal;
	CController PlayerController;
	
	CGreasyBag!(CGameObject) Objects;
	CPriorityEvent!() DrawEventVal;
	CUnorderedEvent!(float) LogicEventVal;
	
	CCamera Camera;
	CTileMap TileMap;

	CParticleEmitter Emitter;
	CConfigManager ConfigManagerVal;
	CBitmapManager BitmapManagerVal;
	CCollisionManager CollisionManagerVal;
}
