/**
 * Sourcemod 1.7 Plugin Template
 */
#pragma semicolon 1
#include <sourcemod>

#pragma newdecls required

#define PLUGIN_VERSION "0.1.0"
public Plugin myinfo = {
    name = "Localization Server",
    author = "nosoop",
    description = "Serves up localizations from a generated database.",
    version = PLUGIN_VERSION,
    url = "https://github.com/nosoop/SM-LocalizationServer/"
}

#define DATABASE_ENTRY "localization-db"
#define MAX_LANGUAGE_NAME_LENGTH 32

Database g_LanguageDatabase;
DBStatement g_StmtGetLocalizedString;

typedef LocalizedStringCallback = function void(int language, const char[] token, const char[] result, any data);

public void OnPluginStart() {
    if (SQL_CheckConfig(DATABASE_ENTRY)) {
		Database.Connect(SQLConnect_LanguageDB, DATABASE_ENTRY, _);
	} else {
		SetFailState("Database entry %s doesn't exist -- did you add it to databases.cfg?", DATABASE_ENTRY);
	}
	
	CreateConVar("localization_server_version", PLUGIN_VERSION, "Current version of Localization Server", FCVAR_NOTIFY | FCVAR_DONTRECORD);
}

public void SQLConnect_LanguageDB(Database db, const char[] error, any data) {
	if (db == null) {
		SetFailState("Could not connect to database %s", DATABASE_ENTRY);
	} else {
		char prepError[256];
		
		g_LanguageDatabase = db;
		
		g_StmtGetLocalizedString = SQL_PrepareQuery(g_LanguageDatabase,
				"SELECT string FROM localizations WHERE token = ? AND language = ?", prepError, sizeof(prepError));
		if (g_StmtGetLocalizedString == null) {
			SetFailState("Failed to create prepared statement for GetLocalizedString() -- %s", prepError);
		}
	}
}

/* Methods and natives */

public int Native_GetLocalizedString(Handle plugin, int nArgs) {
	int tokenLength;
	
	// off by 1?
	GetNativeStringLength(2, tokenLength);
	tokenLength++;
	
	char[] token = new char[tokenLength];
	
	int language = GetNativeCell(1);
	GetNativeString(2, token, tokenLength);
	LocalizedStringCallback callback = view_as<LocalizedStringCallback>(GetNativeFunction(3));
	any data = GetNativeCell(4);
	
	Handle fwd = CreateLocalizedStringCallbackForward(plugin, callback);
	Internal_GetLocalizedString(fwd, language, token, data);
}


/* Internal query methods */

Handle CreateLocalizedStringCallbackForward(Handle plugin = INVALID_HANDLE, LocalizedStringCallback callback) {
	Handle fwd = CreateForward(ET_Ignore, Param_Cell, Param_String, Param_String, Param_Cell);
	AddToForward(fwd, plugin, callback);
	return fwd;
}

void Internal_GetLocalizedString(Handle callbackFwd, int language, const char[] token, any data = 0) {
	char languageName[MAX_LANGUAGE_NAME_LENGTH];
	GetLanguageInfo(language, _, _, languageName, sizeof(languageName));
	
	g_StmtGetLocalizedString.BindString(0, token, true);
	g_StmtGetLocalizedString.BindString(1, languageName, true);
	
	// apparently prepared statements can't be threaded?
	SQL_Execute(g_StmtGetLocalizedString);
	SQL_FetchRow(g_StmtGetLocalizedString);
	
	// size does not include zero-termination
	int resultLength = SQL_FetchSize(g_StmtGetLocalizedString, 0) + 1;
	
	char[] resultString = new char[resultLength];
	SQL_FetchString(g_StmtGetLocalizedString, 0, resultString, resultLength);
	
	PerformLocalizedStringCallback(callbackFwd, language, token, resultString, data);
}

void PerformLocalizedStringCallback(Handle fwd, int language, const char[] token, const char[] result, any data) {
	Call_StartForward(fwd);
	Call_PushCell(language);
	Call_PushString(token);
	Call_PushString(result);
	Call_PushCell(data);
	Call_Finish();
	
	delete fwd;
}

public APLRes AskPluginLoad2(Handle hMySelf, bool bLate, char[] strError, int iMaxErrors) {
	RegPluginLibrary("localization-server");
	CreateNative("LanguageServer_GetLocalizedString", Native_GetLocalizedString);
}