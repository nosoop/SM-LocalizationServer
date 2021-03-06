/**
 * Localization Server test plugin
 */
#pragma semicolon 1
#include <sourcemod>

#pragma newdecls required

#include <localization_server>

#define PLUGIN_VERSION "0.1.2"
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
	"game_switch_in_sec"
};

char MORE_TEST_TOKENS[][] = {
	"TF_BigChief",
	"TF_Quickplay_Complexity2",
	"TF_Halloween_Merasmus_LevelUp_Escaped",
	"Scoreboard_ChangeOnRoundEnd",
	"Attrib_metal_pickup_decreased",
	"Attrib_HealthFromHealers_Increased",
	"TF_TAUNT_CONGA_KILL_NAME",
	"Attrib_RocketJumpDmgReduction",
	"TF_HEAVY_SURVIVE_CROCKET_DESC",
	"TF_MatchOption_PrivateSlots",
};

public void OnPluginStart() {
	// Threaded -- these use a callback
	for (int i = 0; i < sizeof(TEST_TOKENS); i++) {
		LanguageServer_GetLocalizedString(GetServerLanguage(), TEST_TOKENS[i], LS_PrintResult, i);
	}
	
	// Non-threaded -- these block until the query completes
	for (int i = 0; i < sizeof(MORE_TEST_TOKENS); i++) {
		char buffer[256];
		LanguageServer_ResolveLocalizedString(GetServerLanguage(), MORE_TEST_TOKENS[i], buffer, sizeof(buffer));
		PrintToServer("%2d. %s (%s)", i + 1, buffer, MORE_TEST_TOKENS[i]);
	}
	
	StringMap sandvichStrings = LanguageServer_ResolveAllLocalizedStrings("TF_Unique_Achievement_LunchBox");
	StringMapSnapshot sandvichLanguages = sandvichStrings.Snapshot();
	
	PrintToServer("Sandvich in %d languages:", sandvichLanguages.Length);
	for (int i = 0; i < sandvichLanguages.Length; i++) {
		char language[32], buffer[64];
		
		sandvichLanguages.GetKey(i, language, sizeof(language));
		sandvichStrings.GetString(language, buffer, sizeof(buffer));
		
		PrintToServer("%2d. Sandvich in %s: %s", i + 1, language, buffer);
	}
	
	{
		char formatBuffer[128];
		LanguageServer_Format(formatBuffer, sizeof(formatBuffer),
				"%s1 has found: %s2 %s3", "The Player", "The Sandvich", "(x5)");
		
		PrintToServer("%s", formatBuffer);
	}
	
	// TODO write tests to make sure format actually works as expected
}

public void LS_PrintResult(int language, const char[] token, const char[] result, int counter) {
	// Remember, some strings might be caught up if passed as a format string argument
	PrintToServer("%2d. %s (%s)", counter + 1, result, token);
}