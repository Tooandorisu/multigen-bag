# Changelog

Useful Bag changes, newest first.

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
