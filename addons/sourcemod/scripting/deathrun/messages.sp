void DRPrintToChatAll(const char[] str, any...)
{
	char[] buffer = new char[strlen(str) + 255];
	VFormat(buffer, strlen(str) + 255, str, 2);
	
	//if(GameVersion == Engine_CSGO)
	//	CGOPrintToChatAll(buffer);
	
	//else if(GameVersion == Engine_CSS)
	CPrintToChatAll(buffer);
}

void DRPrintToChat(int client, const char[] str, any...)
{
	char[] buffer = new char[strlen(str) + 255];
	VFormat(buffer, strlen(str) + 255, str, 3);
	
	//if(GameVersion == Engine_CSGO)
	//	CGOPrintToChat(client, buffer);
	
	//else if(GameVersion == Engine_CSS)
	CPrintToChat(client, buffer);
}