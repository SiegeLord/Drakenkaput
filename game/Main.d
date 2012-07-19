module game.Main;

import game.Game;
import tango.io.Stdout;
import tango.core.tools.Demangler;

void main()
{	
	CGame game;
	try
	{
		game = new CGame();
		game.Run;
	}
	catch(Exception e)
	{
		Stdout.formatln("Exception: {}:{}", e.file, e.line).nl;
		Stdout(e.msg).nl.nl;
	}
	finally
	{
		game.Dispose;
	}
}
