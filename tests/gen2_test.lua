-- Headless tests for gen2.lua.  Run from the mod folder:
--   lua tests/gen2_test.lua [path/to/gen1recomp]
-- With an engine path the real src/inventory/Bag.lua is used; without one a
-- minimal stand-in is.

local engine = arg and arg[1]
package.path = "./?.lua;" .. (engine and (engine .. "/?.lua;") or "") .. package.path

local failures, passes = 0, 0
local function check(cond, msg)
  if cond then passes = passes + 1 else
    failures = failures + 1
    print("FAIL: " .. msg)
  end
end

local ITEMS = {
  POTION = { name = "POTION", pocket = "ITEM", index = 18 },
  ANTIDOTE = { name = "ANTIDOTE", pocket = "ITEM", index = 9 },
  BERRY = { name = "BERRY", pocket = "ITEM", index = 173 },
  ULTRA_BALL = { name = "ULTRA BALL", pocket = "BALL", index = 2 },
  POKE_BALL = { name = "POKé BALL", pocket = "BALL", index = 5 },
  BICYCLE = { name = "BICYCLE", pocket = "KEY_ITEM", index = 7 },
  TM_01 = { name = "TM01", pocket = "TM_HM", tmNumber = 1, index = 191 },
}
local DATA = { items = ITEMS, constants = { bagSize = 20 } }

-- GameVersion stand-in: Bag.lua asks it whether stacks split (Gen 1 only).
package.loaded["src.core.GameVersion"] = { generation = function() return 2 end }
package.loaded["src.core.Data"] = DATA

local Bag
if engine then
  Bag = require("src.inventory.Bag")
else
  Bag = {}
  function Bag.capacity(_, pocket)
    return ({ ITEM = 20, BALL = 12, KEY_ITEM = 25, TM_HM = 57 })[pocket or "ITEM"]
  end
  function Bag.order(save) save.bagOrder = save.bagOrder or {} return save.bagOrder end
end
package.loaded["src.inventory.Bag"] = Bag

local G2 = dofile("gen2.lua")

-- pure ------------------------------------------------------------------
do
  local names = { a = "Zinc", b = "antidote", c = "Max Potion" }
  local counts = { a = 3, b = 3, c = 40 }
  local byName = G2.sortedIds({ "a", "b", "c" }, "name",
    function(id) return names[id] end, function(id) return counts[id] end)
  check(table.concat(byName, ",") == "b,c,a", "name sort is case-insensitive")
  local byCount = G2.sortedIds({ "a", "b", "c" }, "count",
    function(id) return names[id] end, function(id) return counts[id] end)
  check(table.concat(byCount, ",") == "c,b,a", "count sort high first, ties by name")
  check(G2.nextMode(nil) == "name" and G2.nextMode("name") == "count"
    and G2.nextMode("count") == "number" and G2.nextMode("number") == "name",
    "mode cycles name -> count -> number -> name")
  local byNumber = G2.sortedIds({ "a", "b", "c" }, "number",
    function(id) return names[id] end, function(id) return counts[id] end,
    function(id) return ({ a = 2, b = 30, c = 1 })[id] end)
  check(table.concat(byNumber, ",") == "c,a,b", "number sort uses the item index")
  local r = G2.withSortRow({ "use", "give", "toss", "quit" })
  check(table.concat(r, ",") == "use,give,toss,ub_sort,quit", "SORT goes before QUIT")
  local full = { "use", "give", "toss", "sel", "quit" }
  check(G2.withSortRow(full) == full, "a full submenu gets no SORT row")
  local usable = function(i) return i ~= 2 and i ~= 4 end
  check(G2.stepPocket(1, 1, 4, usable) == 3, "RIGHT skips an unusable pocket")
  check(G2.stepPocket(1, -1, 4, usable) == 3, "LEFT wraps and skips")
  check(G2.stepPocket(1, 1, 4, function() return false end) == 2,
    "nothing usable: plain neighbour")
end

do -- only the pocket's slots move
  local pocketOf = function(id) return ITEMS[id].pocket end
  local order = { "POTION", "POKE_BALL", "BICYCLE", "ANTIDOTE", "ULTRA_BALL", "BERRY" }
  G2.sortPocketOrder(order, "ITEM", pocketOf, "name",
    function(id) return ITEMS[id].name end, function() return 1 end)
  check(table.concat(order, ",") ==
    "ANTIDOTE,POKE_BALL,BICYCLE,BERRY,ULTRA_BALL,POTION",
    "ITEM sort keeps BALL and KEY_ITEM positions")
end

-- capacity --------------------------------------------------------------
local optionValue = true
local mod = { options = { get = function(_, key)
  if key == "bigger_pockets" then return optionValue end
end } }

-- stub PackMenu
local Pack = {}
Pack.__index = Pack
function Pack:pocket() return { id = self.pocketId } end
function Pack:pocketOf(id) return (ITEMS[id] and ITEMS[id].pocket) or "ITEM" end
function Pack:rebuild() self.rebuilt = (self.rebuilt or 0) + 1 end
function Pack:storeCursor() end
function Pack:playSfx() end
function Pack:showMessage(text) self.message = text end
function Pack:update() self.nativeUpdates = (self.nativeUpdates or 0) + 1 end
function Pack:inBattle() return self.battle == true end
Pack.POCKETS = { { id = "ITEM" }, { id = "BALL" }, { id = "KEY_ITEM" }, { id = "TM_HM" } }
function Pack:switchPocket(delta)
  self.pocketIndex = (self.pocketIndex - 1 + delta) % 4 + 1
  self.pocketId = Pack.POCKETS[self.pocketIndex].id
end
function Pack:restoreCursor() end
function Pack:submenuRows() return { "use", "give", "toss", "quit" } end
function Pack:submenuLabel(id) return id:upper() end
function Pack:closeSubmenu() self.submenu = nil end
function Pack:chooseSubmenu() self.nativeChoose = true end
local ItemPc = {}
function ItemPc:pcAdd() return "native" end
package.loaded["src.ui.gen2.ItemPcMenu"] = ItemPc
package.loaded["src.ui.gen2.PackMenu"] = Pack

local status = G2.install(mod)
check(status.capacity and status.sort and status.pc, "install reports capacity, sort and pc")
check(G2.install(mod).capacity, "install is idempotent")

check(Bag.capacity(DATA, "ITEM") == 999, "ITEM pocket 999")
check(Bag.capacity(DATA) == 999, "default (ITEM) pocket 999")
check(Bag.capacity(DATA, "BALL") == 999, "BALL pocket 999")
check(Bag.capacity(DATA, "KEY_ITEM") == 999, "KEY_ITEM pocket 999")
check(Bag.capacity(DATA, "TM_HM") == 57, "TM_HM pocket untouched")
optionValue = false
check(Bag.capacity(DATA, "BALL") == 12, "option off restores BALL 12")
optionValue = true

if engine then
  -- real Bag.add honours the wrapped capacity: 30 distinct ITEM ids
  local save = { inventory = {} }
  for i = 1, 30 do ITEMS["JUNK_" .. i] = { name = "JUNK " .. i, pocket = "ITEM", index = 300 + i } end
  local ok = true
  for i = 1, 30 do ok = ok and Bag.add(save, "JUNK_" .. i, 1, DATA) end
  check(ok, "real Bag.add takes 30 distinct ITEM ids (cart limit 20)")
  check(not Bag.add(save, "JUNK_1", 99, DATA), "stack cap stays x99")
  optionValue = false
  ITEMS.EXTRA = { name = "EXTRA", pocket = "ITEM", index = 400 }
  check(not Bag.add(save, "EXTRA", 1, DATA), "option off: full pocket refuses a new id")
  optionValue = true
end

-- sort through the update wrapper -----------------------------------------
local function pressing(button)
  return { wasPressed = function(_, b) return b == button end }
end

local save = { inventory = { POTION = 5, ANTIDOTE = 1, BERRY = 12, POKE_BALL = 3,
  ULTRA_BALL = 9, BICYCLE = 1, TM_01 = 1 },
  bagOrder = { "POTION", "POKE_BALL", "BERRY", "BICYCLE", "ANTIDOTE", "ULTRA_BALL", "TM_01" } }
local pack = setmetatable({ save = save, items = ITEMS, bagData = { items = ITEMS },
  pocketId = "ITEM", pocketIndex = 1, index = 3, scroll = 0, game = { input = pressing("start") } }, Pack)

Pack.update(pack, 0)
local function itemOrder()
  local out = {}
  for _, id in ipairs(save.bagOrder) do
    if ITEMS[id].pocket == "ITEM" then out[#out + 1] = id end
  end
  return table.concat(out, ",")
end
check(itemOrder() == "ANTIDOTE,BERRY,POTION", "START sorts ITEM by name")
check(pack.message == "Sorted by name.", "name message shown")
check(pack.index == 1 and pack.scroll == 0, "cursor back to top")
check(not pack.nativeUpdates, "START frame not passed to native update")

pack.message = nil
Pack.update(pack, 0)
check(itemOrder() == "BERRY,POTION,ANTIDOTE", "second START sorts by count")
check(pack.message == "Sorted by count.", "count message shown")
pack.message = nil
ITEMS.POTION.index, ITEMS.ANTIDOTE.index, ITEMS.BERRY.index = 18, 9, 173
Pack.update(pack, 0)
check(itemOrder() == "ANTIDOTE,POTION,BERRY", "third START sorts by item number")
check(pack.message == "Sorted by number.", "number message shown")

-- a message up: START goes to the native update, nothing sorts
local before = table.concat(save.bagOrder, ",")
Pack.update(pack, 0)
check(table.concat(save.bagOrder, ",") == before and pack.nativeUpdates == 1,
  "START with a message up is native")

pack.message = nil
pack.pocketId = "TM_HM"
Pack.update(pack, 0)
check(table.concat(save.bagOrder, ",") == before and pack.nativeUpdates == 2,
  "TM_HM pocket is not sorted")

pack.pocketId = "BALL"
pack.game.input = pressing("a")
Pack.update(pack, 0)
check(pack.nativeUpdates == 3, "other buttons reach native update")

-- SORT row in the submenu ------------------------------------------------------
pack.pocketId, pack.pocketIndex, pack.battle = "ITEM", 1, nil
local rows = Pack.submenuRows(pack, "POTION")
check(rows[4] == "ub_sort" and Pack.submenuLabel(pack, "ub_sort") == "SORT",
  "field submenu has a SORT row")
check(Pack.submenuLabel(pack, "use") == "USE", "other labels are native")
pack.submenu = { row = { id = "POTION" }, rows = rows, index = 4 }
Pack.chooseSubmenu(pack)
check(pack.submenu and pack.submenu.rows[1] == "ub_sort_name"
  and Pack.submenuLabel(pack, "ub_sort_number") == "NO.", "SORT opens NAME / QTY / NO.")
for id, label in pairs(G2.SORT_LABEL) do
  check(#label <= 4, "submenu label fits the 4-tile box: " .. id .. " = " .. label)
end
pack.submenu.index = 2
pack.message = nil
Pack.chooseSubmenu(pack)
check(itemOrder() == "BERRY,POTION,ANTIDOTE" and not pack.submenu
  and pack.message == "Sorted by count.", "picking QTY sorts by count")
pack.submenu = { row = {}, rows = { "use", "quit" }, index = 1 }
Pack.chooseSubmenu(pack)
check(pack.nativeChoose, "USE still reaches the native chooser")
pack.message = nil
pack.pocketId = "TM_HM"
check(#Pack.submenuRows(pack, "TM_01") == 4 and Pack.submenuRows(pack, "TM_01")[4] == "quit",
  "no SORT row in TM/HM")

-- battle-aware pockets -----------------------------------------------------
-- BALL has an ULTRA BALL; make KEY_ITEM unusable in battle.
ITEMS.BICYCLE.battleMenu = "ITEMMENU_NOUSE"
pack.battle = true
pack.pocketId, pack.pocketIndex = "BALL", 2
pack:switchPocket(1)
check(pack.pocketId == "ITEM", "battle RIGHT from BALL skips KEY_ITEM and TM_HM")
pack:switchPocket(-1)
check(pack.pocketId == "BALL", "battle LEFT from ITEM wraps to BALL")
check(#Pack.submenuRows(pack, "POTION") == 4 and Pack.submenuRows(pack, "POTION")[4] == "quit",
  "no SORT row in battle")
local battleBefore = table.concat(save.bagOrder, ",")
pack.pocketId, pack.pocketIndex = "ITEM", 1
pack.game.input = pressing("start")
local nativeBefore = pack.nativeUpdates
Pack.update(pack, 0)
check(table.concat(save.bagOrder, ",") == battleBefore and pack.nativeUpdates == nativeBefore + 1,
  "START does not sort in battle")
pack.game.input = pressing("a")
pack.pocketId, pack.pocketIndex = "BALL", 2
local tmPack = setmetatable({ save = save, items = ITEMS, bagData = { items = ITEMS },
  pocketId = "TM_HM", pocketIndex = 4, index = 1, scroll = 0, battle = true,
  game = { input = pressing("a") } }, Pack)
Pack.update(tmPack, 0)
check(tmPack.pocketIndex == 1, "battle PACK opening on TM/HM moves to ITEM")
pack.battle = false
pack.pocketId, pack.pocketIndex = "BALL", 2
pack:switchPocket(1)
check(pack.pocketId == "KEY_ITEM", "field LEFT/RIGHT is native")

-- item PC --------------------------------------------------------------------
local pcSelf = { save = { pcItems = {} } }
for i = 1, 60 do pcSelf.save.pcItems["P" .. i] = 1 end
check(ItemPc.pcAdd(pcSelf, "NEW", 5) == true and pcSelf.save.pcItems.NEW == 5,
  "PC takes a 61st stack")
optionValue = false
check(ItemPc.pcAdd(pcSelf, "NEW2", 1) == "native", "option off: native PC")
optionValue = true

print(("gen2: %d passed, %d failed"):format(passes, failures))
if failures > 0 then os.exit(1) end
