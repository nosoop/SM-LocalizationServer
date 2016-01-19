import vdf
import sqlite3
import os

# Prereq:
# pip install vdf

GAME_DIR = r'/path/to/tf'
LANGUAGE_DB = GAME_DIR + '/addons/sourcemod/data/sqlite/language-db.sq3'

LANGUAGE_FILES = [
	GAME_DIR + '/resource/tf_brazilian.txt',
	GAME_DIR + '/resource/tf_czech.txt',
	GAME_DIR + '/resource/tf_danish.txt',
	GAME_DIR + '/resource/tf_dutch.txt',
	GAME_DIR + '/resource/tf_english.txt',
	GAME_DIR + '/resource/tf_finnish.txt',
	GAME_DIR + '/resource/tf_french.txt',
	GAME_DIR + '/resource/tf_german.txt',
	GAME_DIR + '/resource/tf_greek.txt',
	GAME_DIR + '/resource/tf_hungarian.txt',
	GAME_DIR + '/resource/tf_italian.txt',
	GAME_DIR + '/resource/tf_japanese.txt',
	GAME_DIR + '/resource/tf_korean.txt',
	# GAME_DIR + '/resource/tf_koreana.txt', # (diffing this with tf_korean doesn't show any differences)
	GAME_DIR + '/resource/tf_norwegian.txt',
	GAME_DIR + '/resource/tf_polish.txt',
	GAME_DIR + '/resource/tf_portuguese.txt',
	GAME_DIR + '/resource/tf_romanian.txt',
	GAME_DIR + '/resource/tf_schinese.txt',
	GAME_DIR + '/resource/tf_spanish.txt',
	GAME_DIR + '/resource/tf_swedish.txt',
	GAME_DIR + '/resource/tf_tchinese.txt',
	GAME_DIR + '/resource/tf_turkish.txt',
	GAME_DIR + '/resource/tf_ukrainian.txt',
]

# Some of the tokens used in other language refer to the English-language version.
# Dropped them for deduplication.
DROP_LOCALIZED_ENGLISH_TOKEN = True

db = sqlite3.connect(LANGUAGE_DB)
dbc = db.cursor()

dbc.execute('DROP TABLE IF EXISTS localizations')

# Prepare table
dbc.execute('CREATE TABLE IF NOT EXISTS "localizations" ('
	'"language" TEXT NOT NULL,'
	'"token" TEXT NOT NULL,'
	'"string" TEXT,'
	'PRIMARY KEY ("language", "token"))'
)

total_local_strings = 0

for localization_file in LANGUAGE_FILES:
	# Decode VDF.  It has UCS2 encoding, so decode it as such
	tokens_included = 0
	with open(localization_file, 'r') as f:
	    data = vdf.parse(f.read().decode('UTF-16LE'))
	    data = data['lang']
	
	language = data['Language'].lower()
	for k, v in data['Tokens'].items():
		if not (k.startswith('[english]') and DROP_LOCALIZED_ENGLISH_TOKEN):
			dbc.execute('INSERT OR IGNORE INTO localizations (language,token,string) VALUES (?,?,?)', (language, k, v) )
			tokens_included += 1

	db.commit()
	print 'Localization file for {} ({}) has {} string entries (inserted {})'.format(data['Language'], os.path.basename(localization_file), len(data['Tokens']), tokens_included)
	total_local_strings += tokens_included

# Just do some housekeeping for size
print 'Performing a VACUUM on the database.'
dbc.execute('VACUUM')
db.commit()

print '{} localization strings submitted to database.'.format(total_local_strings)