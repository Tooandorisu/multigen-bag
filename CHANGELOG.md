# Changelog

MultiGen Bag changes, newest first. Entries before 0.33.0 are from the
original Useful Bag by Paperboi (ShaneMcGovernIE) and its Gen 1 history.

## [0.35.1] - 2026-11-20

### Fixed

- Gen 2: START sorted the PACK in battle, although sorting is meant to be off
  there (the SORT menu row already was).
- Gen 3: bigger pockets are applied when the mod loads, not only once the game
  is ready, so a save loaded first can't hit the cart limit while the game
  moves an item that was filed in the wrong pocket.
- Gen 3 (FRLG / Emerald): wrapping the bag cursor now shakes the bag like a
  normal cursor move.

## [0.35.0] - 2026-11-18

### Changed

- Renamed to **MultiGen Bag** (mod id `multigen_bag`) so it is not mistaken
  for the original Gen 1-only Useful Bag by Paperboi, which this forks and
  expands. Credit added to the README and mod card.
- Declared a conflict with `useful_bag`: both patch the Gen 1 bag.
- Repository moved to https://github.com/Tooandorisu/multigen-bag.
- The new id starts with fresh mod options (`BIGGER POCKETS` and the Gen 1
  fullscreen option are back to on). Saves and items are unaffected.

## [0.34.1] - 2026-11-17

### Fixed

- Gen 2: the SORT choice "COUNT" ran past the menu border; it reads "QTY" now
  (the box fits four letters).

## [0.34.0] - 2026-11-17

### Added

- Third sort mode: item number (the game's own order). START cycles
  name -> count -> number.
- Gen 2: SORT row in the item menu with NAME / QTY / NO., where the box has
  room.
- Gen 2: battle-aware PACK. LEFT/RIGHT in battle skips TM/HM and any pocket
  with nothing usable in battle; the battle PACK never opens on one of them.
- Gen 2 item PC holds 999 stacks (was 50); Gen 3 item PC holds 999 items (was
  30 FRLG / 50 RSE). A Gen 3 save reload never trims the PC.

### Fixed

- Gen 1: on engine builds that split items into x99 stacks, adding past x999
  (bag or PC) quietly opened another stack. x999 per item is enforced again,
  and the headless Gen 1 test passes in full (188/188).

## [0.33.0] - 2026-11-17

### Added

- Gen 2 (Gold / Silver / Crystal) and Gen 3 (FireRed / LeafGreen / Ruby /
  Sapphire / Emerald) support, on top of each game's own PACK / BAG screen.
- Bigger pockets: Gen 2 ITEM / BALL / KEY ITEM and Gen 3 ITEMS / KEY ITEMS /
  POKé BALLS / BERRY POUCH hold 999 different items. `BIGGER POCKETS` option
  (on by default) turns it off without a restart.
- START sorts the open pocket by name, then by count, then by name again.
- Gen 3 (FRLG / Emerald) bag cursor wraps between the first item and CANCEL.

### Changed

- Replaced the experimental multi-gen scaffold (`multigen/`, preview overlay,
  Crystal SORT probe and their test notes) with `gen2.lua` and `gen3.lua`.
  `main.lua` picks the half for the running game; the Gen 1 bag is unchanged
  and runs again in the headless Gen 1 test.

## [2.6.4] - 2026-09-10

### Fixed

- Closing the bag now removes the fullscreen panel on the same frame. The
  presenter follows the live screen stack instead of a value cached when the
  screen was built, so a close that happens under a child (an item flow), a
  stack clear on a save load, or any other path that unwinds the state drops
  the overlay with it instead of leaving a blank white panel over the game.
- The presenter clears the scissor before drawing, so a scissor left set by
  the engine's letterbox or display cutout can no longer clip the panel or
  its canvas clear on Android.
- PC WITHDRAW / DEPOSIT / TOSS lists are matched by their stable `kind` id
  as well as the legacy title, restoring the fullscreen presenter and the
  SELECT swap on engine builds that hand those lists a `nil` title.
- A child screen (USE/TOSS, quantity, confirmation) that throws while being
  redrawn no longer skips the presenter's state restore and leaks its
  transform into later frames.

## [2.6.3] - 2026-08-23

### Fixed

- Mart purchases now stop at x999, including on older Gen 1 engine builds.
- Adding items to an existing stack uses the same x999 limit. A total of
  x1000 is rejected.
- Marts no longer crash when an older engine build does not provide its stack
  capacity setting.

## [2.6.0] - 2026-08-23

### Added

- Item stacks can hold up to x999 in the bag and PC during normal gameplay.
- The Poké Flute is in BATTLE ITEMS during battle and KEY ITEMS everywhere
  else.
- The battle bag remembers its last usable pocket for the current play session.
- Touchscreen SELECT opens the bag's sort menu. Keyboard and controller SELECT
  keep their normal item-swap behavior.

### Compatibility

- Native runtime saves support x999 stacks.
- Legacy Gen 1 raw saves still have their original limits: 20 bag entries and
  quantities up to x99.

## [2.5.0–2.5.11] - 2026-08-22

### Added

- Added the FULLSCREEN BAG MENUS option. It is on by default and can be
  disabled to use a smaller classic-style pop-out menu.

### Improved

- Bag and PC menus keep four item rows visible when the window allows it.
- Text and spacing adapt to desktop, mobile, portrait, landscape, and small
  windows while staying on the pixel grid.
- The footer now shows the current position, such as `1 / 3`, and places
  controls beneath their buttons.
- PC action messages fit on one line and do not overlap the footer.
- The compact menu keeps the same Useful Bag design instead of using the
  unrelated vanilla list style.
- Header spacing, divider spacing, row spacing, and the right-facing cursor
  were cleaned up for a more consistent layout.

## [2.4.2–2.4.8] - 2026-08-21 to 2026-08-22

### Added

- Added fullscreen bag and PC menus with pocket names, item counts, money,
  controls, and TM/HM scrolling.
- PC withdraw and deposit lists use the same menu presentation as the bag while
  keeping their existing order and SELECT-swap behavior.

### Improved

- Useful Bag now includes its own menu presenter and no longer needs a separate
  UI mod.
- Menu text is clearer on Android, iOS, tall portrait windows, and smaller
  desktop windows.
- Large pocket titles, footer messages, and divider spacing no longer crowd or
  overlap the item list.

## [2.4.0–2.4.1] - 2026-08-06

### Added

- TM and HM items show their full move names, such as `TM14 BLIZZARD`.
- Long move names scroll so they do not cover the item quantity.

### Fixed

- Fixed the TM ticker showing the TM number twice.

## [2.3.0] - 2026-08-06

### Added

- PC WITHDRAW, DEPOSIT, and TOSS lists support the original SELECT item swap.
- Reordered PC and bag lists keep their order after closing and reopening.

## [2.2.0] - 2026-08-05

### Added

- PC storage now supports up to 999 separate item stacks instead of 50.

## [2.1.0] - 2026-08-05

### Added

- In battle, the bag opens on BATTLE ITEMS or the first usable pocket.
- LEFT/RIGHT skips TMs/HMs and KEY ITEMS, which cannot be used in battle.

## [2.0.0] - 2026-08-05

### Changed

- Renamed the mod from 999 Bag Slots to Useful Bag.

### Added

- Added six pockets: ITEMS, MEDICINE, POKé BALLS, TMs/HMs, BATTLE ITEMS,
  and KEY ITEMS.
- LEFT/RIGHT cycles through the pockets and wraps at both ends.
- The pockets are views of the same underlying bag, so using or depositing an
  item updates every relevant pocket automatically.

## [1.2.0] - 2026-08-03

### Added

- The bag cursor wraps from the first item to the last and back again.

## [1.1.0] - 2026-08-02

### Added

- TAB on keyboard or R3/right-stick click on controller opens the sort menu.
- Items can be sorted by name or quantity, and the selected order is saved.
- Shift keys continue to perform the normal SELECT item swap.

## [1.0.0] - 2026-08-01

### Added

- Increased the bag from 20 to 999 separate item slots.
- At this stage, individual stacks still had the original x99 limit.

## Multi-Gen scaffold v0.5.0
- Added engine-aware integration gate and test assertions.
- No changes to gameplay hooks, save files, or original Gen 1 menu.


## Multi-Gen scaffold v0.6.0
- Exposed `multigenDiagnostics()` through mod exports.
- Diagnostics report game, generation, engine and adapter mode.
- Added reasons to integration decisions.
- No native Gen 2/3 menu integration; original Gen 1 hooks unchanged.

## Multi-Gen scaffold v0.7.0
- Prevent Gen 1-only imports and hooks from running on non-Gen 1 engines.
- Export diagnostic status on unsupported/unknown engines.
- Fail closed if generation/engine detection is unavailable.
- Gen 2/3 menus are not yet implemented.


## Multi-Gen development scaffold v0.8.0
- Added `readOnlyModel(info, save)` to normalize Gen 1 and Gen 3 diagnostic inventory snapshots.
- Preserves Gen 3 native pocket order without mutating saves.
- Gen 2 remains explicitly unsupported until its native inventory layout is verified.
- Added tests for Gen 3 model shape and engine mismatch.
- No gameplay UI hooks added.


## Multi-Gen scaffold v0.9.0
- Verified Gen 2 `Game2.lua` uses `self.save.inventory[itemId]` for item consumption.
- Added read-only flat inventory model for Gen 2 (Gold/Silver/Crystal).
- Added Gen 2 model test and updated diagnostic documentation.
- No menu hooks, write operations or gameplay UI integration.


## Multi-Gen scaffold v0.10.0
- Added pure `menuView(model, pocketIndex, sortBy)` to prepare a selected pocket for a future UI.
- Supports deterministic name/ID and descending-count ordering, with stable ID tie-break.
- Added input validation and copy-on-read to avoid mutating saves.
- Added menu-view unit tests (not executed in-game).
- No menu rendering or engine hooks; Gen 2/3 remain diagnostic only.

## Multi-Gen scaffold v0.11.0
- Added optional generation-aware item-name resolver callback to read-only menuView.
- Name sorting uses resolved display names (case-insensitive) with ID tie-break.
- Safely falls back to item IDs if a resolver fails or returns no name.
- Added resolver tests; no game-native item database or UI wiring yet.

## Multi-Gen scaffold v0.12.0
- Added opt-in, read-only flat-inventory category projection with injected classifier.
- Rejects unclassified items instead of silently hiding them.
- Preserves source inventory and checks duplicate category keys.
- Added isolated tests; no native Gen 2 item database or UI hooks yet.


## Multi-Gen development scaffold v0.13.0
- Added explicit conceptual Gen 2 pocket labels (Items, Balls, Key Items, TM/HM).
- Added `categoryClassifier(mapping)` with defensive copy and validation.
- Added tests for Gen 2 category routing and unknown items.
- No guessed item-ID mapping or native Gen 2 menu hooks.


## Multi-Gen development scaffold v0.14.0
- Added `multigen/menu_controller.lua`, a generation-neutral read-only menu navigation controller.
- Pocket cycling with wraparound, cursor up/down with wraparound, page slicing and empty-pocket handling.
- Added `tests/menu_controller_test.lua` for navigation and non-mutation.
- No actual game UI registration or native menu hooks; Gen 2/3 not playable yet.


## Multi-Gen scaffold v0.15.0
- Audited Gen 1 registration and Gen 3 native Bag menu from dev-5.
- Added `multigen/ui_capabilities.lua` with fail-closed UI hook eligibility.
- Added `tests/ui_capabilities_test.lua` and `MULTIGEN_UI_RESEARCH.md`.
- No Gen 2/3 UI hooks yet: native action handling must be preserved.


## Multi-Gen scaffold v0.16.0
- Traced native Gen 3 BagMenu show/close/handleInput and Stack lifecycle.
- Added read-only `multigen/game3_lifecycle.lua` and mocked unit tests.
- Documented native battle callbacks and overlay requirements.
- No Gen 2/3 gameplay UI hooks; no save modifications.


## Multi-Gen scaffold v0.17.0
- Inspected Gen 2 `PackMenu.lua` and `StartMenu.lua` in the supplied dev-5 archive.
- Corrected Gen 2 pocket IDs/order to ITEM, BALL, KEY_ITEM, TM_HM.
- Added `gen2Classifier(items)` using the engine's own item pocket metadata.
- Added unit tests for real pocket keys, missing item fallback, and invalid pockets.
- Documented Gen 2 cursor handling, native item actions and StartMenu callback.
- No gameplay hook or save modification.


## Multi-Gen scaffold v0.18.0
- Added read-only `gen2_pack_bridge` for native PackMenu state.
- Preserves engine-produced row order, TM/HM labels, counts and modes.
- Added mock tests for snapshots, copy isolation and invalid pockets.
- No native menu replacement, action interception or gameplay UI hook yet.


## Multi-Gen scaffold v0.19.0
- Added `multigen/gen3_bag_bridge.lua` reading native Gen 3 BagMenu.
- Uses verified isOpen/currentPocket/list API; preserves native row order.
- Added mock tests for snapshot, closed menu and invalid pocket.
- No Gen 2/3 gameplay hooks or save writes.


## Multi-Gen scaffold v0.20.0
- Added render-independent text preview from Gen 2/3 native bag snapshots.
- Exposed `multigenPreview(snapshot, maxRows)` on non-Gen1 `mod.exports`.
- Added tests for pagination truncation, cursor marker, and empty pockets.
- No in-game drawing or input interception: visual integration still pending.


## Multi-Gen scaffold v0.21.0
- Added `multigen/live_preview.lua` to connect Gen 2/3 native menu bridges to the text preview.
- Exported `multigenLivePreview(nativeMenu, maxRows)` on non-Gen1 engines.
- Added mock tests for both generations and invalid inputs.
- Still diagnostic-only: no in-game drawing or hooks. Engine menu instances must be supplied by caller.


## Multi-Gen scaffold v0.22.0
- Added opt-in Love2D overlay renderer `multigen/overlay.lua`.
- Exported `multigenDrawPreview(lines, graphics, x, y)` for external callers.
- Added mocked draw-call tests and graphics state isolation.
- No automatic render hook: Gen 2/3 UI remains unchanged until a supported integration is identified.

## Multi-Gen scaffold v0.23.0
- Added opt-in reversible draw-method wrapper in `multigen/draw_integration.lua`.
- Native draw is always called first; preview exceptions are isolated.
- Rejects duplicate installation and refuses unsafe uninstall if another mod replaced the method.
- Added mocked wrapper lifecycle tests.
- Deliberately not auto-installed into Gen 2/3 until UI object lifecycle is verified.


## Multi-Gen scaffold v0.24.0
- Added experimental opt-in Gen 2 PackMenu.draw overlay hook.
- Can be installed and uninstalled via exported functions with explicit prototype and graphics.
- Renders live Gen 2 pocket preview after native draw; no item-action interception.
- Added mocked install/draw/uninstall tests.
- Not installed automatically; game compatibility and visual placement remain untested.


## Multi-Gen scaffold v0.25.0
- Fixed missing Gen 2 overlay install/uninstall exports in main.lua (v0.24.0 shipped the helper but did not expose it).
- Kept installation explicitly opt-in to avoid unverified automatic UI monkey-patching.
- No game UI changes until a supported hook or verified in-game test is available.


## Multi-Gen scaffold v0.26.0
- Added optional Gen 2 overlay auto-install from the non-Gen1 mod entrypoint.
- Default OFF in `multigen/preview_config.lua`; set enabled=true for an experimental in-game test.
- Loads `src.ui.gen2.PackMenu` and attaches the reversible draw wrapper.
- Exposes overlay status and stop functions; installation errors fail closed.
- Added mocked startup tests. Not tested in the running game.

## Multi-Gen scaffold v0.27.0
- Fixed mod discovery: manifest now explicitly targets gen1, gen2, gen3 using the engine's supported `games` field.
- Set `gen2compat: true` for compatibility with the Gen 2 gate.
- Manifest version updated from upstream 2.6.4 to fork development 0.27.0.
- Gen 2/3 functionality remains experimental; overlay is disabled by default.


## Multi-Gen development v0.28.0
- Adopted native Pokémon Crystal PackMenu style for Gen 2.
- Default config now explicitly sets style="crystal"; experimental overlay
  requires both enabled=true and style="overlay-experimental".
- Added read-only `gen2_crystal.inspect()` with item counts and native UI policy.
- Added mocked tests for the native-style diagnostic.
- Native sort and item actions intentionally remain unchanged until safe
  integration with SELECT/reordering is verified.

## Multi-Gen development v0.29.0
- Added read-only Gen 2 alphabetical and quantity sort previews for ITEM/BALL pockets.
- Key Items and TM/HM retain native order; no SELECT/save changes.
- Exported multigenGen2SortPreview(nativePack, mode) for diagnostics.
- No on-screen sort controls or live sorting yet.


## Multi-Gen development v0.30.0
- Added read-only Gen 2 sort plan returning ordered item IDs for ITEM/BALL.
- Detects duplicates, CANCEL rows, and no-op sorting.
- Keeps Key Items and TM/HM in native order.
- Added mock tests and explicit pre-integration test checklist.
- No gameplay sorting UI or save writes yet.

## Multi-Gen development v0.31.0
- Confirmed native `Bag.order`/`Bag.move` and `PackMenu:rebuild` against supplied dev-5 source.
- Added explicit opt-in `gen2_sort_apply.apply(pack, Bag, mode)` using native Bag.move.
- Includes busy-menu guard, rollback on errors, cursor preservation, and mocked tests.
- Not wired into gameplay UI: no new visible sort command or automatic sorting.
- Native item-stack edge cases require game testing before activation.

## Multi-Gen v0.32.0
- Added opt-in Gen 2 Crystal-native SORT submenu (ITEM/BALL only).
- SORT offers name/count and back; native menu drawing retained.
- No overlay; USE/GIVE/TOSS/SELECT delegated to original menu.
- Disabled by default pending live game testing.

## v0.32.1 (Gen 2 SORT startup repair)
- Deferred SORT menu installation until `game.ready` instead of only mod init.
- Added diagnostic status strings and explicit retry export.
- Reports missing dependencies or installation errors instead of generic failure.
- Keeps Crystal rendering and native item actions.
- Not yet verified in a live Gen 2 build.

## v0.32.2
- Attempt Gen 2 SORT installation immediately, not only after game.ready.
- Retry on game.ready if initial dependencies are not ready.
- Guard optional inBattle method in submenu wrapper.
- Add debug export and log message for installation failures.
- Not verified in-game; SORT remains opt-in.

## v0.32.3
- Added detailed Gen 2 SORT initialization and native submenu logs.
- Added attempt counter to exported diagnostics.
- No changes to native Crystal graphics or sorting algorithms.
