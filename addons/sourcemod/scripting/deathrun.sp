/*TODO
* Fix Colors for CSGO
* The new choosen is sometimes printed 2 times on the chat
* The Activator/Runner ratio dosent work properly
*/

#include <sdktools>
#include <cstrike>
//#include <csgo_colors.inc> // is unavailable
#include <morecolors>
#include <sdkhooks>
#include <smlib/clients>

#define loop for(;;)
#define PLUGIN_VERSION "2.0.dev11-B"

#define ROUNDEND_CTS_WIN 8
#define ROUNDEND_TERRORISTS_WIN 9

EngineVersion GameVersion;

ConVar config_Enabled, config_BlockUsePickup, config_WinPoint, config_AutoRespawn, config_AutoRespawnHint, config_AutoBan, config_MinPlayers, config_RandomPlayers, config_RandomRate, config_Scores, config_KillForSuicide, config_AntiSuicide, config_ChangeSuicideAttacker;

bool OldChoosens[MAXPLAYERS + 1], NewChoosens[MAXPLAYERS + 1];
int kills[MAXPLAYERS + 1], deaths[MAXPLAYERS + 1], a_iScore[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "Deathrun", 
	author = "selax (Playa Edit)", 
	description = "Deathrun manager for CS:S and CS:GO", 
	version = PLUGIN_VERSION, 
	url = "FunForBattle"
};

public void OnPluginStart()
{
	GameVersion = GetEngineVersion();
	
	CreateConVar("dr_version", PLUGIN_VERSION, "Plugin Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	config_Enabled = CreateConVar("dr_enable", "1", "Enable the deathrun manager plugin?", FCVAR_NONE, true, 0.0, true, 1.0);
	config_BlockUsePickup = CreateConVar("dr_blockusepickup", "1", "Block pickup weapons by use?", FCVAR_NONE, true, 0.0, true, 1.0);
	
	LoadTranslations("plugin.deathrun");
	
	AutoExecConfig(false, "main", "deathrun");
	
	PluginStart_AntiSuicide();
	PluginStart_Events();
	PluginStart_AutoRespawn();
	PluginStart_Scores();
	PluginStart_Bans();
	PluginStart_Random();
	PluginStart_WinPoints();
}

// Need to be included at this Position
#include "deathrun/messages.sp"
#include "deathrun/random.sp"
#include "deathrun/antisuicide.sp"
#include "deathrun/autorespawn.sp"
#include "deathrun/bans.sp"
#include "deathrun/events.sp"
#include "deathrun/savescores.sp"
#include "deathrun/winpoints.sp"

public void OnMapStart()
{
	if(!config_Enabled.BoolValue)
		return;
		
	OnMapStart_Random();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	
	if(!config_Enabled.BoolValue)
		return;
		
	OnClientPutInServer_SaveScores(client);
}

public Action OnWeaponCanUse(int client, int weapon)
{
	if(!config_Enabled.BoolValue)
		return Plugin_Continue;
		
	if(config_BlockUsePickup.BoolValue)
		if(GetClientButtons(client) & IN_USE)
			return Plugin_Handled;
			
	return Plugin_Continue;
}

public Action OnWeaponDrop(int client, int weapon)
{
	if(!config_Enabled.BoolValue)
		return Plugin_Continue;
		
	if(config_BlockUsePickup.BoolValue)
		if(GetClientButtons(client) & IN_USE)
			return Plugin_Handled;
			
	return Plugin_Continue;
}

public void OnGameFrame()
{
	if(!config_Enabled.BoolValue)
		return;
		
	OnGameFrame_SaveScores();
}

int GetPlayersCount()
{
	return GetTeamClientCount(CS_TEAM_T) + GetTeamClientCount(CS_TEAM_CT);
}

int GetPlayersTeam()
{
	return AnotherTeam(config_RandomPlayers.IntValue);
}

int AnotherTeam(int team)
{
	if(team == CS_TEAM_T)
		return CS_TEAM_CT;
		
	else
		return CS_TEAM_T;
} 