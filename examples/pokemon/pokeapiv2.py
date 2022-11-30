from bottle import route, run, template

'''
/pokeapiv2/name/<name>
/pokeapiv2/number/<id>
/pokeapiv2/stats/<name>
/pokeapiv2/random/
'''
database = '/var/pokemon/pokemon.db'

import sqlite3