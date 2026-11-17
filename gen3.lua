-- MultiGen Bag for Gen 3 (FireRed / LeafGreen / Ruby / Sapphire / Emerald).
--
-- Gen 3 already has pockets, so this half of the mod keeps the engine's own
-- BAG screen (src/ui/game3/bag_menu.lua and its RSE / RS skins) and adds:
--
--   * BIGGER POCKETS: ITEMS, KEY ITEMS, POKé BALLS and the BERRY POUCH hold
--     999 distinct items instead of the cart's 20-46.  The TM CASE already
--     holds every TM and HM, so it keeps its size.  Stack sizes stay native
--     (x999 in FRLG, x99 in RSE outside the Berry Pouch): the RSE bag and
--     marts draw two digits.
--   * SORT: START in ITEMS, KEY ITEMS or POKé BALLS sorts the pocket by
--     name; START again sorts by count (highest first), again by item
--     number (the game's own order), then name again.
--     The TM CASE and BERRY POUCH are kept in number order by the game.
--   * BIGGER ITEM PC: the PC holds 999 different items instead of 30 (FRLG)
--     / 50 (RSE).  Loading a save never trims the PC, even with the option
--     off; only new deposits respect the cart limit then.
--   * CURSOR WRAP (FireRed / LeafGreen / Emerald): UP on the first row goes
--     to CANCEL, DOWN on CANCEL goes to the first row.  Ruby / Sapphire's bag
--     drives its own cursor and keeps the cart's clamp.
--
-- Capacity is ItemsData.CAPACITY (src/core/game3/items_data.lua), refilled
-- from the version's profile whenever the profile is applied, so the raise is
-- re-applied after applyProfile and checked again before each Bag.canAdd.
-- Sorting reorders bag.pockets[pocket] in place -- the same array the
-- SELECT-move rewrites -- so it is saved like any manual reorder.
--
-- Returns install(mod, options) -> status table.

local M = {}

M.CAPACITY = 999
M.BIGGER = { ITEMS = true, KEY_ITEMS = true, POKE_BALLS = true, BERRY_POUCH = true }
M.SORTABLE = { ITEMS = true, KEY_ITEMS = true, POKE_BALLS = true }
-- src/ui/game3/bag_menu.lua VISIBLE, when the skin does not say.
M.DEFAULT_SHOWN = 6

M.MESSAGE = {
  name = "Sorted by name.",
  count = "Sorted by count.",
  number = "Sorted by number.",
}
M.MODES = { "name", "count", "number" }
M.PC_CAPACITY = 999

local function lower(s) return tostring(s or ""):lower() end

-- Pure: sort an array of { id, qty } slots in place.
function M.sortSlots(slots, mode, nameOf, numberOf)
  local names = {}
  for i = 1, #slots do
    local slot = slots[i]
    names[slot] = lower(nameOf(slot.id))
  end
  local function byName(a, b)
    local na, nb = names[a], names[b]
    if na ~= nb then return na < nb end
    return tostring(a.id) < tostring(b.id)
  end
  if mode == "count" then
    table.sort(slots, function(a, b)
      local qa, qb = tonumber(a.qty) or 0, tonumber(b.qty) or 0
      if qa ~= qb then return qa > qb end
      return byName(a, b)
    end)
  elseif mode == "number" and numberOf then
    table.sort(slots, function(a, b)
      local na = tonumber(numberOf(a.id)) or math.huge
      local nb = tonumber(numberOf(b.id)) or math.huge
      if na ~= nb then return na < nb end
      return byName(a, b)
    end)
  else
    table.sort(slots, byName)
  end
  return slots
end

function M.nextMode(last)
  for i, mode in ipairs(M.MODES) do
    if mode == last then return M.MODES[i % #M.MODES + 1] end
  end
  return M.MODES[1]
end

-- Pure: where a wrapping cursor lands.  `cursor` and `total` count the
-- CANCEL row; returns nil when the press is not at an edge.
function M.wrapTarget(cursor, total, shown, down)
  if total < 2 then return nil end
  if down and cursor >= total then
    return 1, 0
  elseif not down and cursor <= 1 then
    return total, math.max(0, total - shown)
  end
  return nil
end

local function biggerPockets(mod)
  local ok, value = pcall(function() return mod.options:get("bigger_pockets") end)
  return not ok or value ~= false
end

-- Write the capacities the option asks for: 999 when on, the profile's own
-- numbers when off (so the toggle works without a restart).
local function syncCapacity(mod, ItemsData)
  local caps = ItemsData.CAPACITY
  if type(caps) ~= "table" then return end
  local model = ItemsData._bagModel
  local native = type(model) == "table" and type(model.capacity) == "table"
    and model.capacity or nil
  local on = biggerPockets(mod)
  for pocket in pairs(M.BIGGER) do
    local base = native and tonumber(native[pocket])
    if on then
      if caps[pocket] ~= nil or base then
        caps[pocket] = math.max(M.CAPACITY, base or 0)
      end
    elseif base then
      caps[pocket] = base
    end
  end
end

local function installCapacity(mod, ItemsData, Bag)
  if rawget(ItemsData, "__usefulBagGen3Capacity") then
    syncCapacity(mod, ItemsData)
    return true
  end
  rawset(ItemsData, "__usefulBagGen3Capacity", true)
  local nativeApply = ItemsData.applyProfile
  if type(nativeApply) == "function" then
    ItemsData.applyProfile = function(...)
      local bag = nativeApply(...)
      syncCapacity(mod, ItemsData)
      return bag
    end
  end
  local nativeCanAdd = Bag.canAdd
  if type(nativeCanAdd) == "function" then
    Bag.canAdd = function(...)
      syncCapacity(mod, ItemsData)
      return nativeCanAdd(...)
    end
  end
  syncCapacity(mod, ItemsData)
  return true
end

local function playSe(name)
  pcall(function()
    local SE = require("src.core.game3.se_ids")
    local id = SE[name] or SE.SE_SELECT
    if id then require("src.core.game3.audio").playSe(id) end
  end)
end

-- The bag is on its own list, not mid-animation, mid-message or mid-move.
local function listHasInput(BagMenu)
  if not (BagMenu.open and BagMenu.mode == "list") then return false end
  if BagMenu._exit or BagMenu._open or BagMenu._switch or BagMenu._pokedude
      or BagMenu._statBoost or BagMenu.moveFrom then
    return false
  end
  -- In battle BagMenu.handleInput forwards to whatever screen is on top
  -- (the party list for a potion); that screen owns the press.
  if BagMenu._battle then
    local ok, top = pcall(function() return require("src.ui.game3.stack").top() end)
    if ok and top and top.mod and top.mod ~= BagMenu then return false end
  end
  return true
end

-- Same gate the SELECT-move uses (bag_menu.lua can_move_items), minus
-- battle: the field bag only, not a chooser (shop, PC, berry tree, give).
local function canSort(BagMenu, ItemsData)
  if BagMenu._location ~= nil or BagMenu._onChoose or BagMenu._battle then
    return false
  end
  local bag = BagMenu._bag
  if not (bag and type(bag.pockets) == "table") then return false end
  local pocket = BagMenu.currentPocket()
  if not M.SORTABLE[pocket] then return false end
  local model = ItemsData.BAG_MODEL or {}
  if (model.sortHmsFirst and model.sortHmsFirst[pocket])
      or (model.sortById and model.sortById[pocket]) then
    return false
  end
  return type(bag.pockets[pocket]) == "table" and #bag.pockets[pocket] >= 1
end

local function sortBag(BagMenu, ItemsData, memories)
  if not canSort(BagMenu, ItemsData) then return false end
  local pocket = BagMenu.currentPocket()
  local slots = BagMenu._bag.pockets[pocket]
  local key = BagMenu._session or BagMenu._bag
  local memory = memories[key]
  if not memory then
    memory = {}
    memories[key] = memory
  end
  local mode = M.nextMode(memory[pocket])
  M.sortSlots(slots, mode, function(id)
    local ok, name = pcall(ItemsData.displayName, id)
    return ok and name or tostring(id)
  end, function(id)
    local ok, n = pcall(ItemsData.toNumericId, id)
    return ok and n or nil
  end)
  memory[pocket] = mode
  BagMenu.cursor, BagMenu.scroll = 1, 0
  playSe("SE_SELECT")
  if type(BagMenu.showMessage) == "function" then
    BagMenu.showMessage(M.MESSAGE[mode])
  end
  return true
end

local function shownRows(BagMenu, total)
  local shown = M.DEFAULT_SHOWN
  pcall(function()
    local skin = require("src.ui.game3.screens").skin("bag", BagMenu._session)
    if skin and tonumber(skin.MAX_SHOWN) then shown = tonumber(skin.MAX_SHOWN) end
  end)
  return math.min(shown, total)
end

-- RS draws and moves its own cursor (src/ui/game3/rs/bag_menu.lua); its
-- up/down never reach BagMenu.handleInput, so this only fires on FRLG/E.
local function wrapCursor(BagMenu, input)
  local down = input:wasPressed("down")
  if not (down or input:wasPressed("up")) then return false end
  local total = #BagMenu.list() + 1
  local cursor, scroll = M.wrapTarget(BagMenu.cursor, total,
    shownRows(BagMenu, total), down)
  if not cursor then return false end
  BagMenu.cursor, BagMenu.scroll = cursor, scroll
  playSe("SE_BAG_CURSOR")
  return true
end

local function installMenu(BagMenu, ItemsData)
  if rawget(BagMenu, "__usefulBagGen3Menu") then return true end
  local native = BagMenu.handleInput
  if type(native) ~= "function" then return false end
  rawset(BagMenu, "__usefulBagGen3Menu", native)
  local memories = setmetatable({}, { __mode = "k" })
  BagMenu.handleInput = function(input, ...)
    if input and type(input.wasPressed) == "function" and listHasInput(BagMenu) then
      -- Swallow the frame: the message box also closes on START, so passing
      -- the same press through would close it at once.
      if input:wasPressed("start") then
        local ok, sorted = pcall(sortBag, BagMenu, ItemsData, memories)
        if ok and sorted then return end
      end
      local ok, wrapped = pcall(wrapCursor, BagMenu, input)
      if ok and wrapped then return end
    end
    return native(input, ...)
  end
  return true
end

-- storage.lua asks Storage.pcItemsCount(session) before a deposit and
-- Storage.pcItemsCount() (no session) while rebuilding the PC from a save.
-- The rebuild always gets the big number, so turning the option off -- or a
-- reload -- never drops items already stored; deposits follow the option.
local function installPc(mod, Storage)
  if rawget(Storage, "__usefulBagGen3Pc") then return true end
  local native = Storage.pcItemsCount
  if type(native) ~= "function" then return false end
  rawset(Storage, "__usefulBagGen3Pc", native)
  Storage.pcItemsCount = function(session, ...)
    local base = native(session, ...)
    if session == nil or biggerPockets(mod) then
      return math.max(M.PC_CAPACITY, tonumber(base) or 0)
    end
    return base
  end
  return true
end

function M.install(mod, req)
  req = req or require
  local status = { generation = 3, capacity = false, sort = false }
  local okI, ItemsData = pcall(req, "src.core.game3.items_data")
  local okB, Bag = pcall(req, "src.core.game3.bag")
  if okI and okB and type(ItemsData) == "table" and type(Bag) == "table" then
    status.capacity = installCapacity(mod, ItemsData, Bag)
  else
    status.error = "game3 item modules unavailable"
    return status
  end
  local okM, BagMenu = pcall(req, "src.ui.game3.bag_menu")
  if okM and type(BagMenu) == "table" then
    status.sort = installMenu(BagMenu, ItemsData)
  else
    status.error = "src.ui.game3.bag_menu unavailable"
  end
  local okS, Storage = pcall(req, "src.core.game3.storage")
  if okS and type(Storage) == "table" then
    status.pc = installPc(mod, Storage)
  end
  return status
end

M.syncCapacity = syncCapacity

return M
