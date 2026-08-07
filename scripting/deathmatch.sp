#include <sourcemod>
#include <cstrike>
#include <sdktools>

public Plugin myinfo =
{
    name = "Simple Deathmatch",
    author = "bilxdi",
    description = "Simple Deathmatch Gamemode for CS Source",
    version = "1.0",
    url = "https://github.com/bilxdi/cssource-smplugin-simpledeathmatch"
};

// Gameover switch
bool g_bGameEnding = false;

public void OnMapStart() {
	// Assign to false
	g_bGameEnding = false;
}
 
public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));

	// Ignore if already changing maps
	if (g_bGameEnding) {
		return Plugin_Continue;
	}
   
	// Check the kill
	if (attacker > 0 && IsClientInGame(attacker) && GetClientFrags(attacker) >= 29) { // Change the "29" to change kill limit 
	    g_bGameEnding = true;
		PrintToChatAll("\x03%N \x05is the winner!", attacker);
		PrintToChatAll("Changing level...");
		CreateTimer(5.0, ForceLevel);
	}
   
	// Respawn client
	CreateTimer(0.1, Respawn, GetClientSerial(client));
   
	return Plugin_Continue;
}
 
public Action ForceLevel(Handle timer) {
	// Maps list in rotation
	decl String:maps[][] = 
	{
		"$2000$",
		"aim_ag_texture_city_advanced",
		"aim_ag_texture2",
		"aim_dust2",
		"cs_office",
		"de_port",
		"de_dust2",
		"fy_pool_day_gx",
		"fy_poolparty_v6",
		"fy_snow",
		"fy_twotowers"
	}

	// Change the maps
	ForceChangeLevel(maps[GetRandomInt(0, 10)], "Changing level...");
	return Plugin_Continue;
}
 
public Action GiveWeapon(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	// Primary array
	decl String:weapons[][] = 
	{
		"weapon_m3",
		"weapon_xm1014",
		"weapon_mac10",
		"weapon_tmp",
		"weapon_mp5navy",
		"weapon_ump45",
		"weapon_p90",
		"weapon_galil",
		"weapon_famas",
		"weapon_ak47",
		"weapon_m4a1",
		"weapon_scout",
		"weapon_sg552",
		"weapon_aug",
		"weapon_awp",
		"weapon_g3sg1",
		"weapon_sg550",
		"weapon_m249"
	}
	
	// Secondary array
	decl String:weapons2[][] =
	{
		"weapon_glock",
		"weapon_usp",
		"weapon_p228",
		"weapon_deagle",
		"weapon_elite",
		"weapon_fiveseven"
	}

	// If client secondary is not empty, remove the secondary
	int weapon2 = GetPlayerWeaponSlot(client, 1); // Slot 1 = secondary
	if (weapon2 != -1) {
		RemovePlayerItem(client, weapon2);
		RemoveEdict(weapon2);
	}

	GivePlayerItem(client, weapons[GetRandomInt(0, 17)]);

	// Uncomment to give client kevlar
	// GivePlayerItem(client, "item_kevlar");
	// Uncomment to give client kevlar helmet
	// GivePlayerItem(client, "item_assaultsuit");

	GivePlayerItem(client, weapons2[GetRandomInt(0, 5)]);

	return Plugin_Continue;
}
 
public Action Respawn(Handle timer, any serial) {
    int client = GetClientFromSerial(serial); // Validate client serial
   
	if (client == 0) {
        return Plugin_Stop;
    }
 
    if (GetClientTeam(client) != 1) { // if not spectate continue
        CS_RespawnPlayer(client);
    }
	
    return Plugin_Continue;
}

// Uncomment to disable buy in game
// public Action CS_OnBuyCommand(int client, const char[] weapon) {
//    return Plugin_Handled;
// }

public void OnPluginStart() {
	HookEvent("player_death", PlayerDeath);
	HookEvent("player_spawn", GiveWeapon);
}