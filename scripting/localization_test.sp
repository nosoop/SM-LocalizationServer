/**
 * Localization Server test plugin
 */
#pragma semicolon 1
#include <sourcemod>

#pragma newdecls required

#include <localization_server>

#define PLUGIN_VERSION "0.0.1"
public Plugin myinfo = {
    name = "Localization Server Test Plugin",
    author = "nosoop",
    description = "Takes a few tokens and returns the string localized in the server's language.",
    version = PLUGIN_VERSION,
    url = "https://github.com/nosoop/SM-LocalizationServer/"
}

char TEST_TOKENS[][] = {
	"TF_Powerup_Pickup_Precision",
	"MMenu_BuyNow",
	"Rarity_Mythical",
	"TF_Pet_Balloonicorn_Promo",
	"KillEaterRank18",
	"TF_TournamentMedal_ESL_SeasonVI_Div3_2nd",
	"TF_Bundle_DrGrordbortMoonbrainPack_Desc",
	"StatPanel_MVM_PlayTime_Tie",
	"TF_TournamentMedal_OzFortress_OWL10_6v6_Premier_Division_First_Place",
	"TF_MEDIC_ACHIEVE_PROGRESS1_DESC",
};

public void OnPluginStart() {
	for (int i = 0; i < sizeof(TEST_TOKENS); i++) {
		LanguageServer_GetLocalizedString(GetServerLanguage(), TEST_TOKENS[i], LS_PrintResult, i);
	}
}

public void LS_PrintResult(int language, const char[] token, const char[] result, int counter) {
	// Remember, some strings might be caught up if passed as a format string argument
	PrintToServer("%2d. %s (%s)", counter + 1, result, token);
}