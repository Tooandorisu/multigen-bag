-- Headless tests for gen3.lua.  Run from the mod folder:
--   lua tests/gen3_test.lua
-- Engine modules are stand-ins shaped like src/core/game3/items_data.lua,
-- src/core/game3/bag.lua and src/ui/game3/bag_menu.lua.

package.path = "./?.lua;" .. package.path

local failures, passes = 0, 0
local function check(cond, msg)
  if cond then passes = passes + 1 else
    failures = failures + 1
    print("FAIL: " .. msg)
  end
end

local NAMES = { [13] = "POTION", [14] = "ANTIDOTE", [139] = "BERRY", [4] = "POKé BALL",
  [2] = "ULTRA BALL", [259] = "BICYCLE" }

-- items_data stand-in ------------------------------------------------------
local profileBag = { capacity = { ITEMS = 42, KEY_ITEMS = 30, POKE_BALLS = 13,
  TM_CASE = 58, BERRY_POUCH = 43 } }
local ItemsData = { CAPACITY = {}, BAG_MODEL = { sortHmsFirst = { TM_CASE = true },
  sortById = { BERRY_POUCH = true } } }
function ItemsData.applyProfile()
  for k in pairs(ItemsData.CAPACITY) do ItemsData.CAPACITY[k] = nil end
  for k, v in pairs(profileBag.capacity) do ItemsData.CAPACITY[k] = v end
  ItemsData._bagModel = profileBag
  return profileBag
end
function ItemsData.displayName(id) return NAMES[id] or tostring(id) end
ItemsData.applyProfile()

function ItemsData.toNumericId(id) return tonumber(id) end
local GameBag = { canAddCalls = 0 }
function GameBag.canAdd() GameBag.canAddCalls = GameBag.canAddCalls + 1
  return #GameBag.items < ItemsData.CAPACITY.ITEMS end

local BagMenu = { open = false, mode = "list", cursor = 1, scroll = 0, pocketIdx = 1 }
local POCKETS = { "ITEMS", "KEY_ITEMS", "POKE_BALLS", "TM_CASE", "BERRY_POUCH" }
function BagMenu.currentPocket() return POCKETS[BagMenu.pocketIdx] end
function BagMenu.list()
  local rows = {}
  for i, slot in ipairs(BagMenu._bag.pockets[BagMenu.currentPocket()]) do
    rows[i] = { id = slot.id, qty = slot.qty }
  end
  return rows
end
function BagMenu.showMessage(text) BagMenu.mode = "message" BagMenu.messageText = text end
function BagMenu.handleInput() BagMenu.nativeCalls = (BagMenu.nativeCalls or 0) + 1 end

package.loaded["src.core.game3.items_data"] = ItemsData
package.loaded["src.core.game3.bag"] = GameBag
package.loaded["src.ui.game3.bag_menu"] = BagMenu
package.loaded["src.core.game3.se_ids"] = { SE_SELECT = 5 }
package.loaded["src.core.game3.audio"] = { playSe = function() end }
package.loaded["src.ui.game3.screens"] = { skin = function() return nil end }
local Storage = { pcItemsCount = function() return 30 end }
package.loaded["src.core.game3.storage"] = Storage
package.loaded["src.ui.game3.stack"] = { top = function() return { mod = BagMenu } end }

local G3 = dofile("gen3.lua")

-- pure ---------------------------------------------------------------------
do
  local slots = { { id = 13, qty = 5 }, { id = 14, qty = 1 }, { id = 139, qty = 12 } }
  G3.sortSlots(slots, "name", ItemsData.displayName)
  check(slots[1].id == 14 and slots[2].id == 139 and slots[3].id == 13, "name sort")
  G3.sortSlots(slots, "count", ItemsData.displayName)
  check(slots[1].id == 139 and slots[2].id == 13 and slots[3].id == 14, "count sort")
  local c, s = G3.wrapTarget(1, 10, 6, false)
  check(c == 10 and s == 4, "up on first row -> CANCEL, scrolled to the end")
  c, s = G3.wrapTarget(10, 10, 6, true)
  check(c == 1 and s == 0, "down on CANCEL -> first row")
  check(G3.wrapTarget(4, 10, 6, true) == nil, "mid-list press is native")
  check(G3.wrapTarget(1, 1, 1, true) == nil, "empty pocket does not wrap")
end

-- capacity -------------------------------------------------------------------
local optionValue = true
local mod = { options = { get = function(_, key)
  if key == "bigger_pockets" then return optionValue end
end } }

local status = G3.install(mod)
check(status.capacity and status.sort and status.pc, "install reports capacity, sort and pc")
check(Storage.pcItemsCount({}) == 999, "PC holds 999")
optionValue = false
check(Storage.pcItemsCount({}) == 30, "option off: deposits use the cart limit")
check(Storage.pcItemsCount() == 999, "save rebuild never trims the PC")
optionValue = true
check(ItemsData.CAPACITY.ITEMS == 999 and ItemsData.CAPACITY.KEY_ITEMS == 999
  and ItemsData.CAPACITY.POKE_BALLS == 999 and ItemsData.CAPACITY.BERRY_POUCH == 999,
  "pockets raised to 999")
check(ItemsData.CAPACITY.TM_CASE == 58, "TM CASE untouched")
ItemsData.applyProfile()
check(ItemsData.CAPACITY.ITEMS == 999, "raise survives a profile refill")
optionValue = false
GameBag.items = {}
GameBag.canAdd()
check(ItemsData.CAPACITY.ITEMS == 42 and ItemsData.CAPACITY.POKE_BALLS == 13,
  "option off restores the profile capacity before canAdd")
optionValue = true
GameBag.canAdd()
check(ItemsData.CAPACITY.ITEMS == 999, "option back on raises again")
G3.install(mod)
check(BagMenu.__usefulBagGen3Menu ~= nil, "menu wrapped once")

-- sort through handleInput ----------------------------------------------------
local function pressing(button)
  return { wasPressed = function(_, b) return b == button end }
end

BagMenu.open = true
BagMenu._bag = { pockets = {
  ITEMS = { { id = 13, qty = 5 }, { id = 14, qty = 1 }, { id = 139, qty = 12 } },
  KEY_ITEMS = { { id = 259, qty = 1 } },
  POKE_BALLS = { { id = 4, qty = 3 }, { id = 2, qty = 9 } },
  TM_CASE = { { id = 289, qty = 1 } },
  BERRY_POUCH = {},
} }
BagMenu.cursor = 3

local function ids(pocket)
  local out = {}
  for i, slot in ipairs(BagMenu._bag.pockets[pocket]) do out[i] = slot.id end
  return table.concat(out, ",")
end

BagMenu.handleInput(pressing("start"))
check(ids("ITEMS") == "14,139,13", "START sorts ITEMS by name")
check(BagMenu.messageText == "Sorted by name." and BagMenu.mode == "message", "message")
check(BagMenu.cursor == 1 and BagMenu.scroll == 0, "cursor reset")
check(not BagMenu.nativeCalls, "START frame swallowed")

BagMenu.handleInput(pressing("start"))
check(BagMenu.nativeCalls == 1 and ids("ITEMS") == "14,139,13",
  "START while the message is up goes native (closes the message)")

BagMenu.mode = "list"
BagMenu.handleInput(pressing("start"))
check(ids("ITEMS") == "139,13,14", "second START sorts by count")
check(ids("POKE_BALLS") == "4,2", "other pockets untouched")
BagMenu.mode = "list"
BagMenu.handleInput(pressing("start"))
check(ids("ITEMS") == "13,14,139" and BagMenu.messageText == "Sorted by number.",
  "third START sorts by item number")

BagMenu.mode = "list"
BagMenu.pocketIdx = 4
BagMenu.handleInput(pressing("start"))
check(BagMenu.nativeCalls == 2, "TM CASE is not sorted")

BagMenu.pocketIdx = 1
BagMenu._location = "shop"
BagMenu.handleInput(pressing("start"))
check(BagMenu.nativeCalls == 3 and BagMenu.mode == "list", "no sort in a chooser")
BagMenu._location = nil

BagMenu._battle = true
BagMenu.handleInput(pressing("start"))
check(BagMenu.nativeCalls == 4, "no sort in battle")
BagMenu._battle = nil

-- cursor wrap -----------------------------------------------------------------
BagMenu.cursor, BagMenu.scroll = 1, 0
BagMenu.handleInput(pressing("up"))
check(BagMenu.cursor == 4 and BagMenu.scroll == 0, "UP on first row wraps to CANCEL")
check(BagMenu._shake and BagMenu._shake.phase == "shake", "wrap shakes the bag like a native move")
BagMenu.handleInput(pressing("down"))
check(BagMenu.cursor == 1, "DOWN on CANCEL wraps to first row")
BagMenu.handleInput(pressing("down"))
check(BagMenu.nativeCalls == 5, "mid-list DOWN is native")

BagMenu.moveFrom = 1
BagMenu.cursor = 1
BagMenu.handleInput(pressing("up"))
check(BagMenu.nativeCalls == 6 and BagMenu.cursor == 1, "no wrap while moving an item")
BagMenu.moveFrom = nil

print(("gen3: %d passed, %d failed"):format(passes, failures))
if failures > 0 then os.exit(1) end
