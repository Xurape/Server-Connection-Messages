#include <sourcemod>
#include <multicolors>
#include <geoip>
#pragma tabsize 0

/* HANDLES */
Handle h_scm_joinmessage = INVALID_HANDLE;
Handle h_scm_leftmessage = INVALID_HANDLE;
Handle SCM;

/* CONVARS */
ConVar g_scm_cvar_holdtime;

ConVar g_scm_cvar_red;
ConVar g_scm_cvar_green;
ConVar g_scm_cvar_blue;
ConVar g_scm_cvar_transparency;

ConVar g_scm_cvar_x;
ConVar g_scm_cvar_y;

ConVar g_scm_cvar_effecttype;

ConVar g_scm_cvar_effectduration;
ConVar g_scm_cvar_fadeinduration;
ConVar g_scm_cvar_fadeoutduration;

ConVar g_scm_hud;
ConVar g_scm_chat;

/* FLOATS */
float scm_holdtime;

public Plugin myinfo = 
{
	name = "Server Conection Messages +",
	author = "ShutAP",
	description = "This plugin show a chat message and a hud message when a player connect/disconnect to the server.",
	version = "1.2",
	url = "https://steamcommunity.com/id/ShutAP1337"
};

public OnPluginStart()
{	
	h_scm_joinmessage = CreateConVar("sm_scm_join_enable", "1", "Shows a message when a player join the server.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	h_scm_leftmessage = CreateConVar("sm_scm_left_enable", "1", "Shows a message when a player left the server.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	
	g_scm_hud = CreateConVar("sm_scm_hud", "1", "Shows a message in the HUD.");
	g_scm_chat = CreateConVar("sm_scm_chat", "1", "Shows a message on the Chat.");
	
	g_scm_cvar_x = CreateConVar("sm_scm_x", "-1.0", "Horizontal Position to show the displayed message (To be centered, set as -1.0).", _, true, -1.0, true, 1.0);
	g_scm_cvar_y = CreateConVar("sm_scm_y", "0.1", "Vertical Position to show the displayed message (To be centered, set as -1.0).", _, true, -1.0, true, 1.0);
	g_scm_cvar_holdtime = CreateConVar("sm_scm_holdtime", "2.0", "Time that the message is shown.", _, true, 0.0, true, 5.0);
	g_scm_cvar_red = CreateConVar("sm_scm_r", "255", "RGB Red Color to the displayed message.", _, true, 0.0, true, 255.0);
	g_scm_cvar_green = CreateConVar("sm_scm_g", "255", "RGB Green Color to the displayed message.", _, true, 0.0, true, 255.0);
	g_scm_cvar_blue = CreateConVar("sm_scm_b", "255", "RGB Blue Color to the displayed message.", _, true, 0.0, true, 255.0);
	g_scm_cvar_transparency = CreateConVar("sm_scm_transparency", "100", "Message Transparency Value.");	
	g_scm_cvar_effecttype = CreateConVar("sm_scm_effect", "1.0", "0 - Fade In; 1 - Fade out; 2 - Flash", _, true, 0.0, true, 2.0);
	g_scm_cvar_effectduration = CreateConVar("sm_scm_effectduration", "0.5", "Duration of the selected effect. Not always aplicable");
	g_scm_cvar_fadeinduration = CreateConVar("sm_scm_fadeinduration", "0.5", "Duration of the selected effect.");
	g_scm_cvar_fadeoutduration = CreateConVar("sm_scm_fadeoutduration", "0.5", "Duration of the selected effect.");	
	
	SCM = CreateHudSynchronizer(); 
	
	LoadTranslations("shutap_scm.phrases");
	
	AutoExecConfig(true, "plugin.shutap_scm");
}

public void OnConfigsExecuted()
{
	scm_holdtime = GetConVarFloat(g_scm_cvar_holdtime);
}

public OnClientPutInServer(client)
{
	int Connect = GetConVarInt(h_scm_joinmessage);
	if(Connect == 1)
	{
		char name[99];
		char authid[99];
		char IP[99];
		char Country[99];
		
		int hud_enabled = GetConVarInt(g_scm_hud);
		int chat_enabled = GetConVarInt(g_scm_chat);
		
		GetClientName(client, name, sizeof(name));
		
		GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));
		
		GetClientIP(client, IP, sizeof(IP), true);
		
   		if(!GeoipCountry(IP, Country, sizeof Country))
    	{
			char traducao[256];
			Format(traducao, sizeof(traducao), "%t", "Unknown_Country");
    		Format(Country, sizeof(Country), traducao);
    	}  
    
		int scm_red = GetConVarInt(g_scm_cvar_red);
		int scm_green = GetConVarInt(g_scm_cvar_green);
		int scm_blue = GetConVarInt(g_scm_cvar_blue);
		int scm_transparency = GetConVarInt(g_scm_cvar_transparency);
		int scm_effect = GetConVarInt(g_scm_cvar_effecttype);
		float scm_x = GetConVarFloat(g_scm_cvar_x);
		float scm_y = GetConVarFloat(g_scm_cvar_y);
		float scm_effectduration = GetConVarFloat(g_scm_cvar_effectduration);
		float scm_fadein = GetConVarFloat(g_scm_cvar_fadeinduration);
		float scm_fadeout = GetConVarFloat(g_scm_cvar_fadeoutduration);
    
		SetHudTextParams(scm_x, scm_y, scm_holdtime, scm_red, scm_green, scm_blue, scm_transparency, scm_effect, scm_effectduration, scm_fadein, scm_fadeout);
		for (int i = 1; i <= MaxClients;i++) 
		{ 
		    if (!IsClientInGame(i) || IsFakeClient(i))continue; 
     
     		if(hud_enabled == 1) {
				char traducao[256];
				Format(traducao, sizeof(traducao), "%t", "HUD_Join", name, Country);
		 		ShowSyncHudText(i, SCM, traducao); 
		 	}
		}   
		
		if(chat_enabled == 1) {
			char traducao[256];
			Format(traducao, sizeof(traducao), "%t", "Chat_Join", name, authid, Country);
			PrintToChatAll(traducao);
		}
    	PrintToServer("Player %s <%s> has joined the server from [%s]", name, authid, Country);
        
    } else {
  
    CloseHandle(h_scm_joinmessage);
    
   }
}

public OnClientDisconnect(client)
{
	int Disconnect = GetConVarInt(h_scm_leftmessage);
	if(Disconnect == 1)
	{
		char name[99];
		char authid[99];
		char IP[99];
		char Country[99];
		
		int hud_enabled = GetConVarInt(g_scm_hud);
		int chat_enabled = GetConVarInt(g_scm_chat);
		
		GetClientName(client, name, sizeof(name));
		
		GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));
		
		GetClientIP(client, IP, sizeof(IP), true);
		
   		if(!GeoipCountry(IP, Country, sizeof Country))
    	{
			char traducao[256];
			Format(traducao, sizeof(traducao), "%t", "Unknown_Country");
    		Format(Country, sizeof(Country), traducao);
    	}
    
		int scm_red = GetConVarInt(g_scm_cvar_red);
		int scm_green = GetConVarInt(g_scm_cvar_green);
		int scm_blue = GetConVarInt(g_scm_cvar_blue);
		int scm_transparency = GetConVarInt(g_scm_cvar_transparency);
		int scm_effect = GetConVarInt(g_scm_cvar_effecttype);
		float scm_x = GetConVarFloat(g_scm_cvar_x);
		float scm_y = GetConVarFloat(g_scm_cvar_y);
		float scm_effectduration = GetConVarFloat(g_scm_cvar_effectduration);
		float scm_fadein = GetConVarFloat(g_scm_cvar_fadeinduration);
		float scm_fadeout = GetConVarFloat(g_scm_cvar_fadeoutduration);
	
		SetHudTextParams(scm_x, scm_y, scm_holdtime, scm_red, scm_green, scm_blue, scm_transparency, scm_effect, scm_effectduration, scm_fadein, scm_fadeout);
		for (int i = 1; i <= MaxClients;i++) 
		{ 
		    if (!IsClientInGame(i) || IsFakeClient(i))continue; 
     
     		if(hud_enabled == 1) {
				char traducao[256];
				Format(traducao, sizeof(traducao), "%t", "HUD_Left", name, Country);
		 		ShowSyncHudText(i, SCM, traducao); 
		 	}
		}    


		if(chat_enabled == 1) {
			char traducao[256];
			Format(traducao, sizeof(traducao), "%t", "Chat_Left", name, authid, Country);
			PrintToChatAll(traducao);
    	}
    	PrintToServer("Player %s <%s> has left the server from [%s]", name, authid, Country);    	
        
    } else {  
    	
	    CloseHandle(h_scm_leftmessage);
	    
	}
}