# Moon phases
Make your moon follow a realistic cycle

__Important__: This mod requires at least Minetest 5.2.0 for the game's new sky API.
Make sure you have the latest version installed or [update your game](https://www.minetest.net/downloads/).

## Dependencies
This mod has no hard dependencies whatsoever, so you can use it as you will.
However, I do recommend using the [skylayer](https://gitlab.com/rautars/skylayer) mod.
With the Minetest's new sky API it is likely for more mods to change the sky configuration,
possibly resulting in conflict. This utility mod can help circumvent these issues if both mods use it.

## Commands
This mod comes with two commands to print or change the current moon phase.
- Use ``/moonphase`` to view the currently active phase.
- Use ``/set_moonphase <phase>`` to change it. ``<phase>`` has to be a full number between 1 and 8.
- Use ``/set_moonstyle <style>`` to choose a texture preset. ``classic`` will result in a quadratic moon
	inspired by default Minetest. ``realistic`` will result in 256x images of the real moon.

In order to change the phase, you will need the corresponding privilege.
Use ``/grant <player> moonphase`` to grant it.

## Mod Integration
Just like the chat commands, this mod provides a LUA api for accessing the moon phase.
It contains a method called ``moon_phases.get_phase()`` that will return a numeric value representing the current moon phase.
You can also set the phase via ``moon_phases.set_phase(phase)`` where ``phase`` is an integer between 1 and 8.
The texture style of a specific player can be set with ``moon_phases.set_style(player, style)`` where ``style`` referes to either
``classic`` or ``realistic``.

## Configuration
The mod provides the option to change the length of the moon cycle.
By default, the moon texture will change every four (in-game) nights.
This results in a total cycle of 32 days.

You can also set the default texture style for all players. You can choose between the same options as with the ``/set_moonstyle`` command.

## LICENSE
All source code is licensed under GNU LESSER GENERAL PUBLIC LICENSE version 3.
You can find a copy of that license in the repository.

## Media
All moon textures marked as "classic" are made by me. You can use them under a CC0 license.

All included "realistic" moon textures are resized versions of graphics from *NASA's Scientific Visualization Studio* by [Ernie Wright](https://svs.gsfc.nasa.gov/cgi-bin/search.cgi?person=1059).
These images are part of the Public Domain as CC-BY-SA 3.0.
You can access the entire (high resolution) album on [their website](https://svs.gsfc.nasa.gov/4769#28564). See [NASA's media guidelines](https://www.nasa.gov/multimedia/guidelines/index.html) for more information on licensing.
