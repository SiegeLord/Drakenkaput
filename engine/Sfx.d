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
