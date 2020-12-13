# Headquarters

[![Demonstration](https://img.youtube.com/vi/KUCQYEhgo5k/0.jpg)](https://www.youtube.com/watch?v=KUCQYEhgo5k)

This is an experimental mod for GZDoom that allows the player to go to another
map for a while, and then return back.

Basically, this is an extension for GZDoom hub feature. This mod saves the
player position and the current map name so player can return back.

## What this can be used for

- [Slayer Gate](https://doomwiki.org/wiki/Slayer_Gate) analog.
- Scroll of Town Portal for RPG-like dungeon/town game loop.
- Injecting more levels in an existing mappack mid-level.

## Features

- works with existing maps, no map editing required.
- works in multiplayer.
- accessible via hotkey (see `keyconf.txt`), or from arbitrary ZScript code (see
  API).

## Caveats

- HQ map should be defined for each cluster.
- every cluster/hub must have its own "headquarters" map. It's possible to edit
  the code so every map has its own HQ map.
- for the HQ map to save its state clusters must be hubs or manually redefined
  as hubs in mapinfo. If player moves between hubs, the HQ map loses its
  state. No problems for typical Doom/Heretic/Hexen episodes, problematic for
  Doom 2 clusters: player may not realize that moving to the next map resets HQ
  map.
- making a cluster a hub may result in savefile bloat (all maps in cluster
  become stored in a savefile).

## API

`hq_Api` class has two functions:
1. request() - requests transportation to an HQ map.
2. requestBack() - requests transportation back to a normal map from an HQ map.

request() will do nothing if the player is already in an HQ map. requestBack()
will do nothing if the player is in a normal map.

Both functions are data scope, meaning that they can be called from all all
scopes, including UI. The actual code that makes the change is synchronized with
network events.

Examples:
```
// For transportation to an HQ map:
hq_Api.request();

// For transportation back from an HQ map:
hq_Api.requestBack();
```

## Thanks to

- Netheritor for a question that inspired this script library.
- Nash Muhandes for helpful thoughts.

## License

GPLv3.
