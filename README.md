# Frontier MOO Soundpack (MUSHclient)

Sounds for Frontier MOO at **adultlife.chrisduffley.com, port 4000**.

## For players

1. Download the pack: [frontier-soundpack ZIP](https://github.com/jlvp1998/frontier-soundpack/archive/refs/heads/main.zip).
2. Unzip it somewhere, like your Documents folder.
3. Open `MUSHclient.exe`. The game opens and connects by itself.

When you connect, the pack checks for updates. If there's one, it tells you. Type **spupdate** to get it.
You can also close MUSHclient and run `updater\update.bat`.

Soundpack commands: `sphelp`, `spvol <0-100>`, `ambvol <0-100>`, `spmute`, `spcheck`, `spupdate`.

## For people helping with the pack

You need to be added to this repository first (ask jlvp1998).

- Sounds go in `worlds/frontier/sounds/`.
- `worlds/frontier/soundmap.lua` says which file plays for each game sound, for example
  `["ship/launch"] = "ships/launch.ogg",`. A list like `{"a.ogg", "b.ogg"}` picks one at random.
  If a sound isn't in the map, the pack looks for `sounds/<name>.ogg` (or .wav or .mp3).
- The full list of sound names the game sends is in `worlds/frontier/sounds/SOUND LIST.txt`.
- Triggers and commands are in `worlds/plugins/frontier_soundpack.xml`. The code is in `worlds/frontier/frontier.lua`.

Upload your changes (with GitHub Desktop, git, or the GitHub website). Write a short note about what you changed, because players see that note when they update.
Players get your changes the next time they connect and type spupdate. You don't need to change any version number.

Files the updater never replaces once a player has them: `worlds/world.MCL` and `mushclient_prefs.sqlite`.
