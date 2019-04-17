void PluginStart_Scores ( )
{
	config_Scores					= CreateConVar ( "dr_scores",					"1", "Enable the scores manager?",				FCVAR_NONE, true, 0.0, true, 1.0 );
	config_KillForSuicide			= CreateConVar ( "dr_killforsuicide",			"0", "Add kill for choosen when CT suicide?",	FCVAR_NONE, true, 0.0, true, 1.0 );
	config_ChangeSuicideAttacker	= CreateConVar ( "dr_changesuicideattacker",	"0", "Change suicide attacker to choosen?",		FCVAR_NONE, true, 0.0, true, 1.0 );
	
	RegConsoleCmd ( "sm_rs",			command_ResetScore	);
	RegConsoleCmd ( "sm_resetscore",	command_ResetScore	);
}

void OnGameFrame_SaveScores ( )
{
	if ( !config_Scores.BoolValue )
	{
		return;
	}
	
	for ( int i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientInGame ( i ) )
		{
			SetEntProp ( i,	Prop_Data, "m_iFrags",	kills	[ i ] );
			SetEntProp ( i,	Prop_Data, "m_iDeaths", deaths	[ i ] );
			
			if ( GameVersion == Engine_CSGO )
			{
				CS_SetClientContributionScore ( i,	score   [ i ] );
			}
		}
	}
}

void PlayerDeath_SaveScores ( Event ev )
{
	if ( !config_Scores.BoolValue )
	{
		return;
	}
	
	int client		= GetClientOfUserId ( ev.GetInt ( "userid"		) );
	int attacker	= GetClientOfUserId ( ev.GetInt ( "attacker"	) );
	
	if ( ( client != attacker ) && ( client != 0 )  )
	{
		kills	[ attacker ] ++ ;
		score	[ attacker ] ++ ;
	}
	
	if ( ( attacker == 0 ) && ( GetClientTeam ( client ) == GetPlayersTeam ( ) ) && ( config_RandomPlayers.IntValue > 1 ) && config_KillForSuicide.BoolValue )
	{
		if ( config_KillForSuicide.BoolValue )
		{
			for ( int i = 1; i <= MaxClients; i++ )
			{
				if ( !IsClientInGame ( i ) )
				{
					continue;
				}
				
				if ( GetClientTeam ( i ) == config_RandomPlayers.IntValue )
				{
					kills [ i ] ++ ;
				}
			}
		}
		
		if ( config_ChangeSuicideAttacker.BoolValue )
		{
			int choosen = GetChoosenID ( );
			
			if ( choosen )
			{
				ev.SetInt ( "attacker",	GetClientUserId ( choosen )	);
			}
			
			ev.SetString ( "weapon", "inferno" );
		}
	}

	deaths [ client ] ++ ;
}

void OnClientPutInServer_SaveScores ( int client )
{
	if ( config_Scores.BoolValue )
	{
		ResetPlayerScoreCounters ( client );
	}
}

void ResetPlayerScoreCounters ( int client )
{
	kills	[ client ] = 0 ;
	deaths	[ client ] = 0 ;
	score	[ client ] = 0 ;
}

public Action command_ResetScore ( int client, int args )
{
	if ( !config_Enabled.BoolValue || !config_Scores.BoolValue )
	{
		return Plugin_Continue;
	}
	
	ResetPlayerScoreCounters ( client );
	
	return Plugin_Continue;
}