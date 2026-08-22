# Changelog

## [2.5.11] - 2026-08-22
### Added
- `FULLSCREEN BAG MENUS` can be disabled in mod options to use a smaller,
  classic-style pop-out bag and PC menu while retaining Useful Bag pockets,
  sorting, selection, money, and item counts.

### Fixed
- Restored the fullscreen bag's existing responsive row layout.
- The smaller pop-out bag and PC list now reserve four item slots.

## [2.5.10] - 2026-08-22
### Fixed
- Fullscreen bag lists now always reserve four item rows; row positions use
  the available space directly instead of depending on the selected font size.

## [2.5.9] - 2026-08-22

### Fixed

- Fullscreen text now steps down to the largest integer scale that keeps at
  least four readable item rows inside the header and footer dividers.

## [2.5.8] - 2026-08-22

### Changed

- Replaced the persistent footer control legend with a current-item indicator
  such as `1 / 3`, showing the selected item and total items in the active
  bag, PC, or storage list.
- PC feedback messages continue to use the same footer when a list reports an
  action result.

## [2.5.7] - 2026-08-22

### Fixed

- Reworked the two-line footer layout so fullscreen controls stay underneath
  their buttons without consuming enough space to break the item list.
- Pop-out menus now use the compact one-line legend, while narrow fullscreen
  viewports automatically fall back before text can overlap or become smaller
  than the pixel font.
- Kept the list rows at a readable integer height and preserved symmetric
  spacing between the header and footer dividers.

## [2.5.6] - 2026-08-22

### Fixed

- Footer control labels now place the action beneath each button group (for
  example `A` over `use` and `B` over `back`).
- Rebalanced the footer height and list geometry so the top and bottom divider
  spacing remains even after the two-line control footer is added.
- Corrected odd-height arrow rows so the right-facing cursor remains symmetric
  on the native pixel grid.

## [2.5.5] - 2026-08-22

### Fixed

- Balanced the list region so the first-row and last-row spacing match at the
  top and bottom dividers.
- Corrected the cursor geometry to form a clean right-facing stepped arrow.

## [2.5.4] - 2026-08-22

### Fixed

- Added breathing room between the header divider and the first item.
- Restored explicit A/B and Left/Right control instructions in the footer.
- Replaced the selected-row square cursor with a pixel-built right arrow.

## [2.5.3] - 2026-08-22

### Fixed

- Small fullscreen viewports now reduce row spacing only when necessary so
  four items remain visible by default instead of falling back to three.

## [2.5.2] - 2026-08-22

### Fixed

- Compact bag and PC menus now reserve enough native vertical space to show
  four items by default while keeping the header and footer inside their
  boundaries.

## [2.5.1] - 2026-08-22

### Fixed

- Fixed the compact bag presenter using an oversized black border and
  palette-shaded output. Compact menus now draw over the finished playfield
  with a 2px native inset, integer scaling, and a footer that cannot collide
  with the money amount.

## [2.5.0] - 2026-08-22

### Added

- Added the `FULLSCREEN BAG MENUS` mod toggle. It defaults on; turning it off
  renders the same Useful Bag design language in the game's smaller native
  resolution instead of falling back to the unrelated vanilla list styling.
  Pocket, storage-order, and SELECT-swap behavior are unchanged.

## [2.4.8] - 2026-08-22

### Fixed

- Increased standalone menu readability on Android, iOS, and tall portrait
  windows. Portrait text now uses an integer width-based scale, including a
  4x ceiling for high-resolution displays, while desktop and landscape sizing
  retain their fitting behavior.

## [2.4.7] - 2026-08-21

### Fixed

- Flattened PC deposit/withdraw feedback messages into one line in the
  fullscreen footer so they do not cross the footer boundary.

## [2.4.6] - 2026-08-21

### Changed

- PC WITHDRAW ITEM and DEPOSIT ITEM now use the same standalone fullscreen
  list presenter as the bag, while retaining their PC ordering and SELECT-swap
  behavior.

## [2.4.5] - 2026-08-21

### Fixed

- Reduced the header font size and compacted the gap before its divider so
  large pocket titles no longer dominate or crowd the first row.

## [2.4.4] - 2026-08-21

### Fixed

- Increased text sizing in smaller windows and snapped the standalone Plain
  Pixel font to its native 15 px design grid to keep strokes readable and
  crisp. Header spacing now follows the font's actual line height so the
  divider cannot overlap the title.

## [2.4.3] - 2026-08-21

### Fixed

- Replaced the optional Gen1 Modern UI integration with Useful Bag's own
  fullscreen presenter. The mod now renders its headers, pocket rows, money,
  and TM/HM ticker without requiring another mod.

## [2.4.2] - 2026-08-21

### Fixed

- Registered the bag with Gen1 Modern UI so supported installs replace the
  classic 160x144 list with the fullscreen presenter, including its title,
  footer, and money display.
- Kept machine move metadata in the public presentation model so TM/HM names
  remain readable when the modern presenter is active.

## [2.4.1] - 2026-08-06

### Fixed

- TM ticker duplicated the pinned prefix: the scrolled text re-ran "TM01 "
  ("TM01 TM01 MEGA PUNCH"). Only the move name scrolls now — the pinned
  "TM01 " part is drawn once.

## [2.4.0] - 2026-08-06

### Added

- Full TM/HM names in the bag and the PC: machine items label as
  "TM14 BLIZZARD" instead of just "TM14". The TM/number part stays pinned;
  when the move name is too wide for the row it scrolls as a horizontal
  ticker (the MoveRelearn pacing) instead of bleeding over the count.

## [2.3.0] - 2026-08-06

### Added

- PC SELECT-swap: the WITHDRAW / DEPOSIT / TOSS item lists in the player's
  PC now support the vanilla item-swap (press SELECT to mark an item, a
  second SELECT — or A — swaps it with the cursor row). Withdraw and Toss
  reorder the PC storage (`save.pcOrder`); Deposit reorders the bag
  (`save.bagOrder`), matching the original game. The lists also open in
  the stored order instead of alphabetical, so a reorder persists across
  reopening.

## [2.2.0] - 2026-08-05

### Added

- PC item storage now holds 999 distinct stacks instead of 50:
  `field.pcItemCap` is patched alongside `constants.bagSize`, so "No room
  left to store items." stops appearing.

## [2.1.0] - 2026-08-05

### Added

- Battle-aware pockets: the in-battle bag now opens on the BATTLE ITEMS
  pocket (or the first non-empty usable pocket) and its LEFT / RIGHT
  cycling skips TMs / HMs and KEY ITEMS, which can't be used mid-battle.

## [2.0.0] - 2026-08-05

### Changed

- Renamed the mod from "999 Bag Slots" to "Useful Bag" (mod id `bag_999` -> `useful_bag`).

### Added

- The bag auto-sorts into six pockets: ITEMS, MEDICINE, POKé BALLS, TMs / HMs, BATTLE ITEMS and KEY ITEMS, cycled with LEFT/RIGHT (wrapping at both ends).
- A hidden bag (the flat inventory) stays the active bag underneath the pockets, so key items keep working no matter which pocket the bag was closed on; PC deposits and item uses are mirrored into every pocket automatically.

## [1.2.0] - 2026-08-03

### Added

- The bag cursor wraps around: Up on the first item lands on the last,
  Down on the last lands on the first, in and out of battle. No more
  scrolling back through hundreds of slots to reach the other end.

## [1.1.0] - 2026-08-02

### Added

- Bag sort shortcut: TAB (keyboard) or R3 / right stick click
  (controller) opens a SORT BY NAME / SORT BY COUNT prompt while the bag
  is open. Count sort puts the biggest stacks first. The order persists
  in the save. Shift keys still perform the vanilla SELECT item swap;
  TAB is repurposed from SELECT while the bag is open.

## [1.0.0] - 2026-08-01

### Added

- `constants.bagSize` patched 20 -> 999, raising the bag's distinct-item
  capacity. Quantity cap per slot (99) unchanged.
