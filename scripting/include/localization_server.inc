#if defined _localization_server_included
  #endinput
#endif
#define _localization_server_included

public SharedPlugin __pl_localization_server = {
    name = "localization-server",
    file = "localization_server.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

public void __pl_localization_server_SetNTVOptional() {
}

typedef LocalizedStringCallback = function void(int language, const char[] token, const char[] result, any data);

native void LanguageServer_GetLocalizedString(int language, const char[] token, LocalizedStringCallback callback, any data = 0);

native bool LanguageServer_ResolveLocalizedString(int language, const char[] token, char[] buffer, int maxlen);