# Useful Bag

A 999-capacity bag auto-sorted into six pockets — ITEMS, MEDICINE, POKé
BALLS, TMs / HMs, BATTLE ITEMS and KEY ITEMS — that you cycle with
LEFT/RIGHT.

## What you get

- **Capacity.** `constants.bagSize` is patched from 20 to 999 distinct item
  slots, `constants.itemStackCap` raises every bag and PC stack to x999, and
  `field.pcItemCap` raises the PC storage from 50 to 999 stacks. Shop purchase
  quantities are clamped to the remaining room in the selected stack.
- **Six pockets.** Items are auto-sorted into ITEMS, MEDICINE, POKé BALLS,
  TMs / HMs, BATTLE ITEMS and KEY ITEMS. Cycle pockets with LEFT/RIGHT,
  wrapping around at both ends.
- **Battle-aware bag.** In battle the bag opens on BATTLE ITEMS (or the
  first non-empty usable pocket) and LEFT/RIGHT skips TMs / HMs and KEY
  ITEMS, which can't be used mid-battle — no more scrolling through TMs
  when you need a Hyper Potion. The Poké Flute appears in BATTLE ITEMS in
  battle and in KEY ITEMS outside battle. The last battle pocket is remembered
  for the current runtime session.
- **A hidden bag.** The pockets are filtered projections of the flat
  inventory (`save.inventory` + `bagOrder`); nothing is moved out of it. So
  key items keep working no matter which pocket the bag was closed on — PC
  deposit a key item and it leaves the hidden bag and the KEY ITEMS pocket
  together, and using a potion decrements the same count the MEDICINE
  pocket shows.
- **Sort.** TAB (keyboard), R3 / right stick click (controller), or the
  touchscreen SELECT overlay opens a SORT BY NAME / SORT BY COUNT prompt
  while the bag is open. Shift keys and controller SELECT still perform the
  vanilla item swap.
- **PC SELECT-swap.** In the PC's WITHDRAW / DEPOSIT / TOSS item lists,
  press SELECT to mark an item, then SELECT (or A) again on another row to
  swap them — the vanilla reorder that was missing. Withdraw/Toss reorder
  the PC storage and Deposit reorders the bag, and the lists open in your
  stored order.
- **Full TM/HM names.** Machine items read "TM14 BLIZZARD" (not just
  "TM14") in the bag and the PC. "TM14" stays put and the move name
  scrolls as a horizontal ticker — hold at the start, scroll across, hold,
  scroll back — so long ones like "TM15 HYPER BEAM" stay readable instead
  of bleeding over the count.
- **Cursor wrap.** The bag cursor wraps at the first/last item: Up on the
  first goes to the last and vice versa.
- **Presentation toggle.** `FULLSCREEN BAG MENUS` is on by default in the mod
  options. Turn it off for a smaller native-resolution pop-out that keeps the
  same Useful Bag panel, selection, divider, ticker, footer, and money design;
  pocket behavior, storage ordering, and SELECT-swap remain unchanged.

## How it works

The engine reads distinct bag capacity from `Data.constants.bagSize`, stack
capacity from `Data.constants.itemStackCap` (`src/inventory/Bag.lua`), and the
PC cap from `Data.field.pcItemCap` (`src/ui/PlayerPC.lua`); this mod patches
all three to 999 and projects the flat inventory into the six pockets at the
bag screen.

## Install

Copy the `useful_bag` folder into your install's `mods/` directory (one
level deep, alongside the other discovered mods), or use `modkit.py`:

```sh
python3 tools/modkit.py pack mods/useful_bag
```

## Compatibility

- Item stacks support x999 in the native runtime save format.
- Legacy Gen 1 raw save imports/exports retain their format limits: at most 20
  bag entries and a quantity byte capped at 99.
- Useful Bag includes its own fullscreen presenter and does not require a
  companion UI mod.
