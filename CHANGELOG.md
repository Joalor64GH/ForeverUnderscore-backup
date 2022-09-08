# Changelog
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - [SEP-8-2022]

### Added


### Fixed
- Transitions should no longer skip themselves if you leave a song during story mode;


### Adjusted
- Controls should now be properly formatted along with bold numbers and symbols having correct offsets;


## [0.2.1.1] - [AUG-23-2022 - SEP-8-2022]

### Added
- Full Video Support (with PolybiusProxy's hxCodec extension, we are currently using the stable version);
- Menu Items are now separated on their own unique spritesheets, allowing for easier setup;
- Judgements are now separated on their own unique images;
- `noteMissActions` function for Notetypes;
- New Chart Editor now has infinite scrolling;
- You can now select Characters and Ghost Characters on the Character Debug Menu;
- Engine Watermarks are now displayed on the FPS and can be disabled;
- Both Chart Editors now have Playback Rates, press CTRL+Z to increase speed, CTRL+X to decrease, and CTRL+C to reset;
- The Score Bar now (optionally) flashes depending on your last gotten judgement;
- You can now Change the Song's Difficulty using the Pause Menu;
- Charts made in Psych Engine v0.6 should now work properly;
- Scripts can now specify variable types, things like `function goodNoteHit(coolNote:Note)` shouldn't crash anymore;
- Fully Softcoded Weeks via JSON files;
- Tweens can now be customized on scripts, example use: `doTween('scoreZoom', 'scale.x', hud.scoreBar, 1, 0.2);`, with `scale.x` being the custom value;


### Fixed
- Characters with dancing idles (think gf or skid and pump) will no longer loop on their last animation;
- Antialiasing now works properly for Stages and Menus;
- the BPM Limit was increased to 350 on the Chart Editor;
- Stutters when Pausing shouldn't happen anymore;
- Notetypes should be properly working now;


### Adjusted
- you can now specify character offsets on their script file;
- script files now have the extension `hx`, allowing for VSCode extensions to be properly used with it;
- Credits Menu was completely rewritten, meaning that both the code for it and the json file are different;
- You can now mess with Accuracy and ranking values on scripts using `accuracy`, `trueAccuracy`, `ratingFinal` and `comboRating`;
* there's also the formatted counterparts for making custom score texts, `formattedAccuracy` and `formattedRanking`;
- `Hits` variable for Scripts, returns all your hits on the current song;

## [0.2.1] - [AUG-8-2022 - AUG-23-2022]

### Added
- Notetypes were rewritten as an integer, they should properly save on songs now;
- New Accessibility Options (Notesplash Opacity, Arrow Opacity);
- You can optionally enable a commit hash, mostly something made for bug reporting on the base repository and such;
- Song Metadata will now be injected via a separated file named `meta.json` on your Song's Folder;
- with the Metadata change, you can now add colors to your songs as an RGB format;
- Shaders can now be called via Scripts;
- you can now have Animated Icons via Sparrow Atlas (XML);
- Campaign UI Characters are now separated into Folders and fully Softcoded via JSON Files;
- Dialogues can now use Text Files, meaning that you are no longer limited to just using the Hardcoded `Alphabet.hx` for them;
- Scripted Tweens can now have a `onComplete` function by calling `completeTween(tweenID)` on a script;
- Strumlines can now be moved freely, allowing for **Modcharts** to be made (still planning to make it easier though!);


### Fixed
- Newgrounds Logo now shows up on Title Screen
- Winter Horrorland now has a proper Background;
- Week 6 is completely Fixed;


### Adjusted
- Scripts now use the "hx" file extension, allowing for Haxe Extensions to be used;
- All Menus (excluding Story and Options) now have persistent variables for the item you are currently highlighting;
- Song Information is now available on the `ChartParser.hx` file, rather than being separated by both `Song.hx` and `Section.hx`;
- `Conductor.hx` now handles Song Playback;
- Improved Notetype Handling, Notetypes can now be fully set up on `Note.hx`;
- The Codebase has been entirely formatted (thanks @otallynotdoggogit);
- The `README.md` file has been entirely rewritten (thanks @otallynotdoggogit);

