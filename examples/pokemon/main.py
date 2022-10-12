from bottle import route, run, template
from pokemon.master import get_pokemon, catch_em_all
import json

@route("/avatar")
@route("/avatar/<name>")
def avatar(name=None):
    """generates a named pokemon avatar or a randomized one"""
    catch = None
    if name:
        catch = get_pokemon(name=name)
    else:
        catch = get_pokemon()

    pid, properties = catch.popitem()
    avatar, name = properties['ascii'], properties['name']
    return f'Avatar for {name} is <p>{avatar}</p>'

@route("/pokemon")
@route("/pokemon/<name>")
def pokemon(name=None):
    """show information about a randomized pokemon or a named one"""
    value = None
    if name:
        value = get_pokemon(name=name)
    else:
        value = get_pokemon()

    pid, properties = value.popitem()
    del properties['ascii']
    properties = json.dumps(properties, indent=2)
    return f'Pokemon with ID {pid} has the following properties <p>{properties}</p>'

@route("/")
@route("/pokemons")
def pokemons():
    """list all available pokemons"""
    pokemon_names = [v['name'] for k, v in catch_em_all().items()]
    return "<br>".join(pokemon_names)

run(host='0.0.0.0', port=10000, debug=True)