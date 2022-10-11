from bottle import route, run, template
from pokemon.skills import get_ascii, get_avatar
from pokemon.master import get_pokemon, catch_em_all

@route("/avatar")
@route("/avatar/<name>")
def avatar(name=None):
    """generates a named pokemon avatar or a randomized one"""
    catch = None
    if name:
        catch = get_pokemon(pid=name)
    else:
        catch = get_pokemon()
    pid, ascii = catch.popitem()
    _avatar = get_avatar(pid, print_screen=False)
    return template('Avatar for {{pid}} is {{avatar}}', pid, _avatar)

@route("/pokemon")
@route("/pokemon/<name>")
def pokemon(name=None):
    """show information about a randomized pokemon or a named one"""
    if name:
        return get_pokemon(name=name)
    else:
        return get_pokemon()

@route("/")
@route("/pokemons")
def pokemons():
    """list all available pokemons"""
    pokemon_names = [v['name'] for k, v in catch_em_all().items()]
    return "<br>".join(pokemon_names)

run(host='0.0.0.0', port=10000, debug=True)