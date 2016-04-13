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

/**
 * Called after GetLocalizedString() is done quering the language database.
 * 
 * @param language		The language ID for the associated localization string.
 * @param token			The token whose localization string is being retrieved.
 * @param result		The localized string.  If the localization string could not be found,
 * 						an empty string will be passed.
 * @param data			Data passed to the callback.
 * @noreturn
 */
typedef LocalizedStringCallback = function void(int language, const char[] token,
		const char[] result, any data);

/**
 * Perform a threaded search for a token in a given language.
 * 
 * @param language		The language ID for the associated localization string.
 * @param token			The token whose localization string is being retrieved.
 * @param callback		The LocalizedStringCallback to be called when the query is finished.
 * @param data			Data to be passed to the callback.
 * @noreturn
 */
native void LanguageServer_GetLocalizedString(int language, const char[] token,
		LocalizedStringCallback callback, any data = 0);

/**
 * Perform a non-threaded search for a token in a given language.
 * 
 * @param language		The language ID for the associated localization string.
 * @param token			The token whose localization string is being retrieved.
 * @param buffer		A character buffer to store the result in.
 * @param maxlen		The size of the buffer.
 * 
 * @return True if a localization string was retrieved, false otherwise.
 */
native bool LanguageServer_ResolveLocalizedString(int language, const char[] token,
		char[] buffer, int maxlen);