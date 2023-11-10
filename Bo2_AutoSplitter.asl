state("t6zm")
{
    int round: 0x02510E4C, 0x510;
    int isDead: 0x01369C54, 0x0, 0x300; //true is 1, when the player gets down (Not useful but i found it so might as well keep it)
    int isAfterlife: 0x0261050C, 0x36C; // true is 1, when the player gets in afterlife
    int gameTicks: 0x00D192A0, 0x0;
    int gameOver: 0x00F321CC, 0x308, 0x8; //0 is alive in game, 1 is in menu, 5 is in game over screen (And also first afterlife for some reason)
}

startup
{
	refreshRate = 100;
	settings.Add("round", true, "round splits");
	for(int i = 2; i <= 255; i++)
		settings.Add(Convert.ToString(i), false, Convert.ToString(i), "round");
}

start
{
    vars.pausegame_ticks = 0;
    vars.totalTime = 0;
    vars.timeToRemoveForRealStartTime = 0;
    //Necessary to start the timer in MOTD
    if(current.isAfterlife == 1){
        vars.timeToRemoveForRealStartTime = current.gameTicks;
        return true;
    }
    else if(current.round > old.round){
        vars.timeToRemoveForRealStartTime = current.gameTicks;
        return true;
    }
}

reset
{
    if(current.gameOver == 5 && current.round > 0){
        return true;
    }
}

isLoading
{
	if(current.gameTicks == old.gameTicks)
	{
        //The 2 is random, but it works (1 is not enough, it pauses sometimes randomly, probably because of the check rate)
		if(vars.pausegame_ticks > 2)
		{
			timer.CurrentPhase = TimerPhase.Paused;
			return true;
		}
		else
		{
			vars.pausegame_ticks++;
			return false;
		}		
	}	
	else
	{
		vars.pausegame_ticks = 0;
		timer.CurrentPhase = TimerPhase.Running;
		return false;
	}
}

gameTime{
    if(current.gameTicks > old.gameTicks){
        //Game ticks are in ms
        //Removing some time from the total gameTicks since gameTicks start before we can even move
        vars.totalTime = (current.gameTicks-vars.timeToRemoveForRealStartTime);
    }
    if(current.gameTicks == 0){
        vars.totalTime = 0;
    }
    return TimeSpan.FromMilliseconds(vars.totalTime);
}

split
{
    if(current.round > old.round && settings[current.round.ToString()]){
	    return true;
    }
}
