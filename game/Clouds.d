module game.Clouds;

import game.IGameMode;

import engine.MathTypes;
import engine.Bitmap;

import tango.math.random.Random;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CClouds
{
	this(CBitmap cloud_bitmap, IGameMode game_mode, SVector2D ini_offset, float zoom_fraction, size_t num_clouds)
	{
		GameMode = game_mode;
		ZoomFraction = zoom_fraction;
		CloudBitmap = cloud_bitmap;
		
		Clouds.length = num_clouds;
		
		auto sz = GameMode.Game.Gfx.ScreenSize / zoom_fraction;
		
		foreach(ref star; Clouds)
		{
			star.X = ini_offset.X + rand.uniformR2(-cast(float)CloudBitmap.Width, cast(float)sz.X);
			star.Y = ini_offset.Y + rand.uniformR2(-cast(float)CloudBitmap.Height, cast(float)sz.Y);
		}
	}
	
	void Draw(SVector2D offset)
	{
		foreach(star; Clouds)
		{
			auto screen_pos = (star - offset) * ZoomFraction;
			al_draw_bitmap(CloudBitmap.Get, screen_pos.X, screen_pos.Y, 0);
		}
	}
	
	void Update(SVector2D offset)
	{
		auto sz = GameMode.Game.Gfx.ScreenSize;
		
		foreach(ref star; Clouds)
		{
			auto screen_pos = (star - offset) * ZoomFraction;
			
			if(screen_pos.X < -CloudBitmap.Width)
				screen_pos.X = sz.X;
			
			if(screen_pos.X > sz.X)
				screen_pos.X = -CloudBitmap.Width;
			
			if(screen_pos.Y < -CloudBitmap.Height)
				screen_pos.Y = sz.Y;
			
			if(screen_pos.Y > sz.Y)
				screen_pos.Y = -CloudBitmap.Height;
			
			star = (screen_pos / ZoomFraction + offset);
		}
	}
protected:
	IGameMode GameMode;
	float ZoomFraction;
	SVector2D[] Clouds;
	CBitmap CloudBitmap;
}
