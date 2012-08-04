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
import game.Clouds;

import game.components.Destroyable;
import game.components.Position;
import game.components.Controller;
import game.components.Enemy;
import game.components.Velocity;

import tango.math.Math;
import tango.io.Stdout;
import tango.text.convert.Format;
import tango.core.Array;

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_primitives;

const float PowerMax = 100;

const size_t[] Primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47];

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
		auto pos = cfg.Get!(SVector2D)("level", "player_start", SVector2D(-1, -1));
		if(pos.X < 0)
			pos = SVector2D(0, 0);
		pos.X *= TileMap.TileWidth;
		pos.Y *= TileMap.TileHeight;
		auto pos_comp = Player.Get!(CPosition)();
		pos_comp = pos;
		PlayerController = Player.Get!(CController)();
		
		Clouds = new CClouds(BitmapManager.Load("data/bitmaps/cloud.png"), GameMode, pos, 0.5, 10);
		
		EnemiesLeft = 0;
		
		int n = 0;
		while(true)
		{
			auto section = Format("object_{}", n);
			auto enemy_name = cfg.Get!(const(char)[])(section, "name", "");
			if(enemy_name == "")
				break;
			
			int m = 0;
			while(true)
			{
				auto pos_str = Format("pos_{}", m);
				pos = cfg.Get!(SVector2D)(section, pos_str, SVector2D(-1, -1));
				if(pos.X < 0)
					break;
				pos.X *= TileMap.TileWidth;
				pos.Y *= TileMap.TileHeight;
				
				auto obj = new CGameObject(enemy_name, this, ConfigManager);
				assert(obj);
				pos_comp = obj.Get!(CPosition)();
				pos_comp = pos;
				auto enemy = obj.Get!(CEnemy);
				if(enemy !is null)
					EnemiesLeft++;
				
				m++;
			}
			
			n++;
		}
		
		PowerMeter = 0;
	}
	
	ELevelExit Logic(float dt)
	{
		Emitter.Logic(dt);
		
		LogicEvent.Trigger(dt);
		
		Objects.Prune();
		
		CPosition pos;
		if(Player)
		{
			if(Player.Get(pos))
				Camera.Position = pos.Position;
			CDestroyable dest;
			if(Player.Get(dest))
			{
				HealthFrac += 0.05 * (dest.HealthFrac - HealthFrac);
				Clamp(HealthFrac, 0.0f, 1.0f);
			}
		}
		
		if(Dragon)
		{
			PowerMeter -= 5 * dt;
			if(PowerMeter < 0)
			{
				PowerMeter = 0;
				DragonTransformation(false);
			}
		}
		
		PowerMeterDisp += 0.05 * (PowerMeter - PowerMeterDisp);
		Clamp(PowerMeterDisp, 0.0f, cast(float)PowerMax);
		
		SVector2D min_pos = Game.Gfx.ScreenSize / 2;
		SVector2D max_pos = TileMap.PixelSize - Game.Gfx.ScreenSize / 2;
		max_pos.X = max(max_pos.X, min_pos.X);
		max_pos.Y = max(max_pos.Y, min_pos.Y);
		
		Clamp(Camera.Position.X, min_pos.X, max_pos.X);
		Clamp(Camera.Position.Y, min_pos.Y, max_pos.Y);
		//Camera.Position.X = floor(Camera.Position.X);
		//Camera.Position.Y = floor(Camera.Position.Y);
		
		Camera.Update(Game.Gfx.ScreenSize);
		
		Clouds.Update(Camera.Position);
		
		if(Game.Time() > TimeOutTime)
			ComboCounter = 0;
		
		if(Player is null)
			return ELevelExit.RestartLevel;
		if(EnemiesLeft <= 0)
			return ELevelExit.NextLevel;
		return ELevelExit.NotYet;
	}
	
	void Draw()
	{
		GameMode.Game.Gfx.ResetTransform();
		
		al_clear_to_color(al_map_rgb_f(0.3, 0.3, 0.9));
		
		Clouds.Draw(Camera.Position);
		
		Camera.UseTransform();
		
		TileMap.Draw(Camera.Position - Game.Gfx.ScreenSize / 2, Game.Gfx.ScreenSize);
		
		Emitter.Draw();
		
		DrawEvent.Trigger();
		
		GameMode.Game.Gfx.ResetTransform();
		
		if(Player !is null)
		{
			float spacing = 5;
			float sh = Game.Gfx.ScreenHeight;
			float sw = Game.Gfx.ScreenWidth;
			float h = 200;
			float w = 15;
			
			float health_frac = Dragon ? 1.0f : HealthFrac;
			auto health_color = Dragon ? al_map_rgb_f(1, 1, 1) : al_map_rgb_f(1, 0, 0);
			al_draw_filled_rectangle(spacing, sh - spacing - h * health_frac, spacing + w, sh - spacing, health_color);
			
			al_draw_filled_rectangle(sw - spacing, sh - spacing - h * (PowerMeterDisp / PowerMax), sw - spacing - w, sh - spacing, al_map_rgb_f(1, 0.5, 0));
			
			if(ComboCounter > 0)
				al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), sw / 2, 20, ALLEGRO_ALIGN_CENTRE, "Combo: %d", ComboCounter); 
			
			al_draw_textf(Font.Get, al_map_rgb_f(1, 1, 1), sw / 2, sh - 20 - al_get_font_line_height(Font.Get), ALLEGRO_ALIGN_CENTRE, "Enemies left: %d", EnemiesLeft); 
		}
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
		if(obj == Player && !Transforming)
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
	bool CheckCollision(SRect rect)
	{
		return CollisionManagerVal.TestRectangle(rect);
	}
	
	override
	void LaunchBullet(const(char)[] bullet_name, SVector2D pos, SVector2D vel)
	{
		auto bullet = new CGameObject(bullet_name, this, ConfigManager);
		CPosition pos_comp;
		CVelocity vel_comp;
		if(bullet.Get(pos_comp))
			pos_comp = pos;
		if(bullet.Get(vel_comp))
			vel_comp = vel;
	}
	
	override
	void EnemyDead()
	{
		ComboCounter++;
		EnemiesLeft--;
		
		auto idx = Primes.find(ComboCounter);
		if(idx < Primes.length)
		{
			PowerMeter += (idx + 1) * 30;
			
			if(PowerMeter >= PowerMax)
			{
				PowerMeter = PowerMax;
				DragonTransformation(true);
			}
		}
		TimeOutTime = Game.Time() + 5;
	}
	
	void DragonTransformation(bool into_dragon)
	{
		Transforming = true;
		auto pos = Player.Get!(CPosition);
		assert(pos);
		SVector2D old_pos = pos;
		
		Transforming = false;
		Dragon = into_dragon;
		
		auto new_player = new CGameObject(into_dragon ? "data/objects/dragon.cfg" : "data/objects/player.cfg", this, ConfigManager);
		auto new_controller = new_player.Get!(CController)();
		PlayerController.CopyInto(new_controller);
		
		pos = new_player.Get!(CPosition)();
		pos = old_pos;
		
		Player.Remove();
		Player = new_player;
		PlayerController = new_controller;
	}
	
	mixin(Prop!("IGameMode", "GameMode", "override", "protected"));
	mixin(Prop!("CPriorityEvent!()", "DrawEvent", "override", "protected"));
	mixin(Prop!("CUnorderedEvent!(float)", "LogicEvent", "override", "protected"));
	mixin(Prop!("CConfigManager", "ConfigManager", "override", "protected"));
	mixin(Prop!("CBitmapManager", "BitmapManager", "override", "protected"));
	mixin(Prop!("CGameObject", "Player", "override", "protected"));
	mixin(Prop!("bool", "Dragon", "override", "protected"));
protected:
	bool Transforming = false;
	bool DragonVal = false;
	
	float HealthFrac = 0;
	float PowerMeter = 0;
	float PowerMeterDisp = 0;
	
	float TimeOutTime = -float.infinity;
	int ComboCounter = 0;
	int EnemiesLeft;
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
	CClouds Clouds;

	CParticleEmitter Emitter;
	CConfigManager ConfigManagerVal;
	CBitmapManager BitmapManagerVal;
	CCollisionManager CollisionManagerVal;
}
