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
module engine.Sfx;

import engine.Disposable;

import allegro5.allegro;
import allegro5.allegro_audio;
import allegro5.allegro_acodec;

import tango.io.Stdout;
import tango.stdc.stringz;

class CSfx : CDisposable
{
	this()
	{
		al_install_audio();
		al_init_acodec_addon();
		al_reserve_samples(1);
	}
	
	override
	void Dispose()
	{
		StopMusic();
		super.Dispose;
	}
	
	void PlayMusic(const(char)[] song)
	{
		StopMusic();
		
		char[256] cache;
		MusicStream = al_load_audio_stream(toStringz(song, cache), 4, 2048);
		
		if(MusicStream !is null)
		{
			al_attach_audio_stream_to_mixer(MusicStream, al_get_default_mixer());
			al_set_audio_stream_playmode(MusicStream, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_LOOP);
			al_set_audio_stream_loop_secs(MusicStream, 0.0, al_get_audio_stream_length_secs(MusicStream));
		}
	}
	
	void StopMusic()
	{
		if(MusicStream !is null)
		{
			al_set_audio_stream_playing(MusicStream, false);
			al_destroy_audio_stream(MusicStream);
			MusicStream = null;
		}
	}
protected:
	ALLEGRO_AUDIO_STREAM* MusicStream;
}
