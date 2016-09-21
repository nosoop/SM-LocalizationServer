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

/**
 * Performs a non-threaded query for a token, returning the results in a StringMap with the
 * language name as keys.  Any languages not containing a localized version of the token will
 * not be present in the StringMap.
 * 
 * @param token			The token whose localization string is being retrieved.
 * 
 * @return A StringMap with present language names (in lowercase) as keys and localized strings
 * as values.
 */
native StringMap LanguageServer_ResolveAllLocalizedStrings(const char[] token);

/**
 * Formats a Valve-style translation string, filling in the specifiers with strings if
 * available.  Character iteration is used so format parameters that happen to look like
 * specifiers are not overwritten.
 * 
 * @param buffer		Destination string buffer.
 * @param maxlen		Maximum length of output string buffer.
 * @param localization	Valve-style translation string, with %s1, %s2, %s3...
 * @param ...			Variable number of format parameters.  %s1 will be replaced with the
 * 						first string, %s2 with the second, and so on.
 */
native void LanguageServer_Format(char[] buffer, int maxlen, const char[] localization,
		const char[] ...);