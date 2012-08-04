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
module game.ParticleEmitter;

import engine.Bitmap;
import engine.BitmapManager;
import engine.ConfigManager;
import engine.Util;
import engine.MathTypes;
import engine.Sprite;
import game.IGame;
import engine.Gfx;

import tango.math.Math;
import tango.math.random.Random;
import tango.io.Stdout;

import allegro5.allegro;

final class CParticleEmitter
{
	struct SParticle
	{
		SVector2D LinearPosition;
		SVector2D LinearVelocity;
		SVector2D LinearAcceleration;
		float LinearDamping;
		
		SVector2D PolarPosition;
		SVector2D PolarVelocity;
		SVector2D PolarAcceleration;
		float PolarDamping;
		
		float Life;
		float TimeOffset;
	}
	
	this(const(char)[] file, IGame game, CConfigManager config_manager, CBitmapManager bmp_manager)
	{
		Game = game;
		
		auto cfg = config_manager.Load(file);
		auto sprite_name = cfg.Get!(const(char)[])("", "sprite");
		if(sprite_name == "")
			throw new Exception("'" ~ file.idup ~ "' needs to specify a sprite file.");
		
		Sprite = new CSprite(sprite_name, config_manager, bmp_manager);
		
		LinearSpawnRadius = cfg.Get!(float)("", "linear_spawn_radius", 0.0f);
		PolarSpawnRadius[0] = cfg.Get!(float)("", "polar_spawn_radius_min", 0.0f);
		PolarSpawnRadius[1] = cfg.Get!(float)("", "polar_spawn_radius_max", 0.0f);
		
		void get_min_max(ref SVector2D[2] vals, const(char)[] name)
		{
			scope str = name ~ "_min";
			vals[0] = cfg.Get!(SVector2D)("", str, SVector2D(0, 0));
			str[$-3..$] = "max";
			vals[1] = cfg.Get!(SVector2D)("", str, SVector2D(0, 0));
		}
		
		get_min_max(LinearVelocity, "linear_velocity");
		get_min_max(LinearAcceleration, "linear_acceleration");
		
		get_min_max(PolarVelocity, "polar_velocity");
		get_min_max(PolarAcceleration, "polar_acceleration");
		
		LinearDamping[0] = cfg.Get!(float)("", "linear_damping_min", 0);
		LinearDamping[1] = cfg.Get!(float)("", "linear_damping_max", 0);
		
		PolarDamping[0] = cfg.Get!(float)("", "polar_damping_min", 0);
		PolarDamping[1] = cfg.Get!(float)("", "polar_damping_max", 0);
		
		Duration = cfg.Get!(float)("", "duration", -1);
		Life = cfg.Get!(float)("", "life", 1);
		ParticlesPerSecond = cfg.Get!(float)("", "particles_per_second", 5);
		Particles.length = cfg.Get!(size_t)("", "num_particles", 10);
		
		StartColor = cfg.Get!(ALLEGRO_COLOR)("", "start_color", al_map_rgb_f(1, 1, 1));
		MidColor = cfg.Get!(ALLEGRO_COLOR)("", "mid_color", StartColor);
		EndColor = cfg.Get!(ALLEGRO_COLOR)("", "start_color", MidColor);
		
		StartColorDuration = cfg.Get!(float)("", "start_color_duration", 0);
		EndColorDuration = cfg.Get!(float)("", "end_color_duration", 0);
		
		Reset();
	}
	
	void Reset()
	{
		foreach(ref particle; Particles)
			particle.Life = -1;
		StartTime = Game.Time;
	}
	
	void Logic(float dt)
	{
		ParticleCounter += dt * ParticlesPerSecond;
		
		Clamp(ParticleCounter, cast(float)Particles.length);
		
		while(ParticleCounter > 0 && (Duration < 0 || (Game.Time - StartTime) < Duration) && Active)
		{
			Spawn(Game.Time);
			ParticleCounter -= 1;
		}
		
		foreach(ref particle; Particles)
		{
			if(particle.Life > 0)
			{
				particle.LinearVelocity = (1.0 - dt * particle.LinearDamping) * (particle.LinearVelocity + particle.LinearAcceleration * dt);
				particle.LinearPosition += particle.LinearVelocity * dt;
				
				particle.PolarVelocity = (1.0 - dt * particle.PolarDamping) * (particle.PolarVelocity + particle.PolarAcceleration * dt);
				particle.PolarPosition += particle.PolarVelocity * dt;
				
				particle.Life -= dt;
			}
		}
	}
	
	void Draw()
	{
		bool was_held = al_is_bitmap_drawing_held();
		foreach(ref particle; Particles)
		{
			if(particle.Life > 0)
			{
				auto pos = SVector2D(particle.PolarPosition.X, 0);
				pos.Rotate(particle.PolarPosition.Y);
				pos += particle.LinearPosition;
				
				ALLEGRO_COLOR col;
				float time_lived = Life - particle.Life;
				
				if(time_lived < StartColorDuration)
				{
					col = BlendColors(StartColor, MidColor, time_lived / StartColorDuration);
				}
				else if(time_lived > Life - EndColorDuration)
				{
					col = BlendColors(MidColor, EndColor, (time_lived - (Life - EndColorDuration)) / EndColorDuration);
				}
				else
				{
					col = MidColor;
				}
				
				Sprite.Draw(Game.Time - particle.TimeOffset, Sprite.Width / 2, Sprite.Height / 2, pos.X, pos.Y, 0, col);
			}
		}
		if(!was_held)
			al_hold_bitmap_drawing(false);
	}
	
	SVector2D Position;
	float Theta = 0;
	bool Active = true;
protected:
	float LinearSpawnRadius;
	float[2] PolarSpawnRadius;
	SVector2D[2] LinearVelocity;
	SVector2D[2] LinearAcceleration;
	SVector2D[2] PolarVelocity;
	SVector2D[2] PolarAcceleration;
	float[2] LinearDamping;
	float[2] PolarDamping;
	ALLEGRO_COLOR StartColor;
	ALLEGRO_COLOR MidColor;
	ALLEGRO_COLOR EndColor;
	float StartColorDuration;
	float EndColorDuration;
	
	float Duration;
	float Life;
	float ParticlesPerSecond;
	SParticle[] Particles;
	
	float StartTime;
	float ParticleCounter = 0;
	IGame Game;
	CSprite Sprite;
	
	void Spawn(float time)
	{
		SVector2D randv()
		{
			return SVector2D(rand.uniformR(1.0f), rand.uniformR(1.0f));
		}
		
		foreach(ref particle; Particles)
		{
			if(particle.Life < 0)
			{
				SVector2D pos;
				if(LinearSpawnRadius > 0)
				{
					do
					{
						pos.Set(rand.uniformR(LinearSpawnRadius), rand.uniformR(LinearSpawnRadius));
					} while(pos.LengthSq > LinearSpawnRadius * LinearSpawnRadius);
				}
				
				particle.LinearPosition = pos + Position;
				particle.PolarPosition = SVector2D(Interpolate(PolarSpawnRadius[0], PolarSpawnRadius[1], rand.uniformR(1.0)), 
				                                   rand.uniformR(2.0 * ALLEGRO_PI));
				particle.LinearVelocity = Interpolate(LinearVelocity[0], LinearVelocity[1], randv());
				particle.LinearVelocity.Rotate(Theta);
				particle.PolarVelocity = Interpolate(PolarVelocity[0], PolarVelocity[1], randv());
				particle.LinearAcceleration = Interpolate(LinearAcceleration[0], LinearAcceleration[1], randv());
				particle.LinearAcceleration.Rotate(Theta);
				particle.PolarAcceleration = Interpolate(PolarAcceleration[0], PolarAcceleration[1], randv());
				particle.LinearDamping = Interpolate(LinearDamping[0], LinearDamping[1], rand.uniformR(1.0));
				particle.PolarDamping = Interpolate(PolarDamping[0], PolarDamping[1], rand.uniformR(1.0));
				particle.TimeOffset = time;
				particle.Life = Life;
				
				break;
			}
		}
	}
}

