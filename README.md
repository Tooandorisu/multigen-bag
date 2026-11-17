# MultiGen Bag

A fork and expansion of [Useful Bag](https://github.com/ShaneMcGovernIE/useful-bag)
by Paperboi (ShaneMcGovernIE), which is Gen 1 only. MultiGen Bag keeps his
Gen 1 bag and brings the same ideas to Gen 2 and Gen 3. All credit for the
original mod goes to him.

Use MultiGen Bag **or** Useful Bag, not both: they change the same Gen 1 bag,
so the mod manager treats them as conflicting.


A 999-capacity bag auto-sorted into six pockets — ITEMS, MEDICINE, POKé
BALLS, TMs / HMs, BATTLE ITEMS and KEY ITEMS — that you cycle with
LEFT/RIGHT.

Works on Gen 1 (Red / Blue / Yellow), Gen 2 (Gold / Silver / Crystal) and
Gen 3 (FireRed / LeafGreen / Ruby / Sapphire / Emerald). Gen 2 and Gen 3
already have pockets, so there the mod keeps the game's own PACK / BAG and
adds bigger pockets and sorting (see below).

## Gen 2 and Gen 3

- **Bigger pockets.** Gen 2's ITEM, BALL and KEY ITEM pockets and Gen 3's
  ITEMS, KEY ITEMS, POKé BALLS and BERRY POUCH hold 999 different items
  instead of the cart's 12–46. The TM/HM pocket and TM CASE already hold every
  TM and HM, so they keep their size. Turn this off with the `BIGGER POCKETS`
  mod option; it applies straight away, and items already in a pocket are
  never removed.
- **Sort.** Press START in a pocket to sort it by name. Press START again
  for count (highest first), again for item number (the game's own order),
  and again to go back to name. Works in Gen 2's ITEM, BALL and KEY ITEM
  pockets and Gen 3's ITEMS, KEY ITEMS and POKé BALLS. In Gen 2 you can also
  pick SORT from an item's menu (USE / GIVE / TOSS / SORT / QUIT) and choose
  NAME, QTY or NO.; items whose menu is already full (five rows) leave SORT
  off so the box still fits. The TM/HM pockets, TM CASE and BERRY POUCH are
  kept in number order by the game itself. Sorting is off in battle, and in
  Gen 3 also in the shop / PC / give choosers.
- **Bigger item PC.** Gen 2's item PC holds 999 stacks instead of 50, and Gen
  3's holds 999 different items instead of 30 (FRLG) / 50 (RSE). Follows the
  `BIGGER POCKETS` option. Gen 3 never trims the PC when a save loads, even
  with the option off.
- **Battle-aware PACK (Gen 2).** In battle, LEFT/RIGHT skips pockets with
  nothing you can use in battle (always TM/HM, and any pocket where every item
  is unusable), and a PACK that would open on one of those opens on the first
  usable pocket instead.
- **Cursor wrap (Gen 3).** UP on the first item goes to CANCEL and DOWN on
  CANCEL goes back to the top, in FireRed, LeafGreen and Emerald. Gen 2's PACK
  already wraps. Ruby / Sapphire's bag moves its own cursor and keeps the
  cart's behavior.
- **Stacks stay native.** Gen 2 and Ruby / Sapphire / Emerald keep x99 per
  item (their PACK, marts and item PC only draw two digits); FireRed /
  LeafGreen already allow x999.

The Gen 1 features below (six pockets, battle-aware bag, PC SELECT-swap,
fullscreen menus) are Gen 1 only.

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
  same MultiGen Bag panel, selection, divider, ticker, footer, and money design;
  pocket behavior, storage ordering, and SELECT-swap remain unchanged.

## How it works

The engine reads distinct bag capacity from `Data.constants.bagSize`, stack
capacity from `Data.constants.itemStackCap` (`src/inventory/Bag.lua`), and the
PC cap from `Data.field.pcItemCap` (`src/ui/PlayerPC.lua`); this mod patches
all three to 999 and projects the flat inventory into the six pockets at the
bag screen.

## Install

Copy the `multigen_bag` folder into your install's `mods/` directory (one
level deep, alongside the other discovered mods), or use `modkit.py`:

```sh
python3 tools/modkit.py pack mods/multigen_bag
```

## Compatibility

- Gen 2 / Gen 3: the bigger pockets and PC live in the native runtime save.
  Exporting to a real cartridge save keeps the cart's limits.
- Gen 3: if you remove the mod while the item PC holds more than 30 (FRLG) /
  50 (RSE) different items, the game trims the extras on the next load. Take
  them out first. The bag pockets are never trimmed.
- Gen 1 on engine builds that split items into x99 stacks: an item still tops
  out at x999 in total, shown as several x99 rows.

- Item stacks support x999 in the native runtime save format.
- Legacy Gen 1 raw save imports/exports retain their format limits: at most 20
  bag entries and a quantity byte capped at 99.
- MultiGen Bag includes its own fullscreen presenter and does not require a
  companion UI mod.
