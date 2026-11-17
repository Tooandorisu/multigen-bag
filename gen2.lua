-- MultiGen Bag for Gen 2 (Gold / Silver / Crystal).
--
-- Gold already has pockets, so this half of the mod does not rebuild the
-- PACK.  It keeps the engine's own PackMenu (every USE / GIVE / TOSS / SEL
-- flow stays engine-owned) and adds what MultiGen Bag is for:
--
--   * BIGGER POCKETS: the ITEM, BALL and KEY ITEM pockets hold 999 distinct
--     items instead of 20 / 12 / 25.  The TM/HM pocket already holds one of
--     every TM and HM, so it keeps its size.  Stacks keep the cart's x99:
--     the PACK, the MART and the item PC all draw two digits.
--   * SORT: START in the ITEM, BALL or KEY ITEM pocket sorts it by name;
--     press START again for count (highest first), again for item number
--     (the game's own order), then name again.  Items whose menu has room
--     also get a SORT row (NAME / QTY / NO.) so the feature is findable.
--     The TM/HM pocket is already sorted by number.
--   * BATTLE-AWARE PACK: in battle LEFT/RIGHT skips pockets with nothing
--     usable in battle (always TM/HM, and any pocket of NOUSE items), and a
--     PACK that would open on one of those opens on a usable pocket instead.
--   * BIGGER ITEM PC: the PC holds 999 stacks instead of 50.
--
-- How: Gen 2 keeps the flat id -> count inventory plus save.bagOrder
-- (src/inventory/Bag.lua) and PackMenu buckets it by each item's pocket at
-- draw time.  Sorting rewrites only the bagOrder slots that belong to the
-- current pocket, so the other pockets keep their order untouched.  The
-- capacity is Bag.capacity(data, pocket), which Bag.add consults.
--
-- Returns install(mod, options) -> status table.

local M = {}

M.CAPACITY = 999
-- Pockets the player can sort.  TM_HM is ordered by tm number on every draw
-- (PackMenu:rebuild), so a sort there would be thrown away.
M.SORTABLE = { ITEM = true, BALL = true, KEY_ITEM = true }
M.BIGGER = { ITEM = true, BALL = true, KEY_ITEM = true }

M.MESSAGE = {
  name = "Sorted by name.",
  count = "Sorted by count.",
  number = "Sorted by number.",
}
M.MODES = { "name", "count", "number" }
M.PC_CAPACITY = 999
-- engine/items/pack.asm submenu box: 7 tiles wide (border, cursor, then four
-- letters -- USE / GIVE / TOSS / SEL / QUIT all fit), and Crystal's column
-- only fits five rows above the text box, so SORT is added only where it fits.
-- Every label here must stay at four characters or fewer.
M.SUBMENU_MAX = 5
M.SORT_ROWS = { "ub_sort_name", "ub_sort_count", "ub_sort_number", "quit" }
M.SORT_LABEL = { ub_sort = "SORT", ub_sort_name = "NAME",
  ub_sort_count = "QTY", ub_sort_number = "NO." }
local SORT_ROW_MODE = { ub_sort_name = "name", ub_sort_count = "count",
  ub_sort_number = "number" }

local function lower(s) return tostring(s or ""):lower() end

-- Pure: the pocket's ids in the new order.  `nameOf(id)` and `countOf(id)`
-- are injected so this is testable without the engine.
function M.sortedIds(ids, mode, nameOf, countOf, numberOf)
  local out = {}
  for i = 1, #ids do out[i] = ids[i] end
  local function byName(a, b)
    local na, nb = lower(nameOf(a)), lower(nameOf(b))
    if na ~= nb then return na < nb end
    return tostring(a) < tostring(b)
  end
  if mode == "count" then
    table.sort(out, function(a, b)
      local ca, cb = tonumber(countOf(a)) or 0, tonumber(countOf(b)) or 0
      if ca ~= cb then return ca > cb end
      return byName(a, b)
    end)
  elseif mode == "number" and numberOf then
    table.sort(out, function(a, b)
      local na = tonumber(numberOf(a)) or math.huge
      local nb = tonumber(numberOf(b)) or math.huge
      if na ~= nb then return na < nb end
      return byName(a, b)
    end)
  else
    table.sort(out, byName)
  end
  return out
end

-- Rewrite, in place, only the positions of `order` whose id is in `pocket`.
-- Returns true when the order changed.
function M.sortPocketOrder(order, pocket, pocketOf, mode, nameOf, countOf, numberOf)
  local slots, ids = {}, {}
  for i = 1, #order do
    if pocketOf(order[i]) == pocket then
      slots[#slots + 1] = i
      ids[#ids + 1] = order[i]
    end
  end
  if #ids < 2 then return false end
  local sorted = M.sortedIds(ids, mode, nameOf, countOf, numberOf)
  local changed = false
  for k = 1, #slots do
    if order[slots[k]] ~= sorted[k] then changed = true end
    order[slots[k]] = sorted[k]
  end
  return changed
end

-- The next sort mode for a pocket: name, count, number, then name again.
function M.nextMode(last)
  for i, mode in ipairs(M.MODES) do
    if mode == last then return M.MODES[i % #M.MODES + 1] end
  end
  return M.MODES[1]
end

-- Pure: with an item submenu's rows, where SORT goes (before QUIT), or nil
-- when the box is full.
function M.withSortRow(rows)
  if type(rows) ~= "table" or #rows >= M.SUBMENU_MAX then return rows end
  local out, added = {}, false
  for _, id in ipairs(rows) do
    if id == "quit" and not added then
      out[#out + 1] = "ub_sort"
      added = true
    end
    out[#out + 1] = id
  end
  if not added then return rows end
  return out
end

-- Pure: the pocket LEFT/RIGHT lands on, stepping over pockets `usable`
-- rejects.  Returns the plain neighbour when no other pocket is usable.
function M.stepPocket(index, delta, count, usable)
  local i = index
  for _ = 1, count do
    i = (i - 1 + delta) % count + 1
    if i == index then break end
    if usable(i) then return i end
  end
  return (index - 1 + delta) % count + 1
end

local function biggerPockets(mod)
  local ok, value = pcall(function() return mod.options:get("bigger_pockets") end)
  return not ok or value ~= false
end

local function installCapacity(mod, Bag)
  if rawget(Bag, "__usefulBagGen2Capacity") then return true end
  local native = Bag.capacity
  if type(native) ~= "function" then return false end
  rawset(Bag, "__usefulBagGen2Capacity", native)
  Bag.capacity = function(data, pocket)
    local nativeCap = native(data, pocket)
    if biggerPockets(mod) and M.BIGGER[pocket or "ITEM"] then
      return math.max(M.CAPACITY, tonumber(nativeCap) or 0)
    end
    return nativeCap
  end
  return true
end

-- PackMenu:update with no modal state up: the list itself has the input.
local function listHasInput(pack)
  return not (pack.qtyState or pack.switching or pack.message or pack.confirm
    or pack.submenu or pack.staleRows)
end

local function sortPack(pack, Bag, memory, mode)
  local pocket = pack:pocket() and pack:pocket().id
  if not M.SORTABLE[pocket] or pack.tutorial then return false end
  local save = pack.save
  if not (save and save.inventory) then return false end
  local order = Bag.order(save, pack.bagData)
  local key = pocket
  mode = mode or M.nextMode(memory[key])
  local items = pack.items or {}
  M.sortPocketOrder(order, pocket,
    function(id) return pack:pocketOf(id) end, mode,
    function(id)
      local def = items[id]
      return (def and def.name) or tostring(id):gsub("_", " ")
    end,
    function(id) return save.inventory[id] end,
    function(id)
      local def = items[id]
      return def and (def.index or def.itemId)
    end)
  memory[key] = mode
  pack.index, pack.scroll = 1, 0
  pack:rebuild()
  if pack.storeCursor then pack:storeCursor() end
  if pack.playSfx then pcall(pack.playSfx, pack, "Sfx_SwitchPokemon") end
  pack:showMessage(M.MESSAGE[mode])
  return true
end

-- Whether a pocket holds anything the battle jumptable would use
-- (PackMenu:submenuRows' in-battle arm: TM_HM never, NOUSE items never).
local function battleUsable(pack, Bag, pocketId)
  if pocketId == "TM_HM" then return false end
  local save = pack.save
  local inventory = save and save.inventory
  if not inventory then return true end
  local items = pack.items or {}
  for _, id in ipairs(Bag.order(save, pack.bagData)) do
    local count = tonumber(inventory[id]) or 0
    if count > 0 and pack:pocketOf(id) == pocketId then
      local def = items[id]
      if not (def and def.battleMenu == "ITEMMENU_NOUSE") then return true end
    end
  end
  return false
end

local function pocketUsable(pack, Bag, POCKETS)
  return function(i)
    return battleUsable(pack, Bag, POCKETS[i] and POCKETS[i].id)
  end
end

-- A battle PACK that opened on an unusable pocket (wLastPocket was TM/HM)
-- moves to the first usable one, once.
local function settleBattlePocket(pack, Bag, POCKETS)
  if pack.__usefulBagSettled then return end
  pack.__usefulBagSettled = true
  if not (pack.inBattle and pack:inBattle()) or not POCKETS then return end
  local usable = pocketUsable(pack, Bag, POCKETS)
  if usable(pack.pocketIndex) then return end
  for i = 1, #POCKETS do
    if usable(i) then
      pack.pocketIndex = i
      if pack.restoreCursor then pack:restoreCursor() end
      pack:rebuild()
      return
    end
  end
end

local function memoryFor(memories, pack)
  local save = pack.save or pack
  local memory = memories[save]
  if not memory then
    memory = {}
    memories[save] = memory
  end
  return memory
end

local function installMenu(Pack, Bag)
  if rawget(Pack, "__usefulBagGen2Sort") then return true end
  local native = Pack.update
  if type(native) ~= "function" then return false end
  rawset(Pack, "__usefulBagGen2Sort", native)
  local POCKETS = rawget(Pack, "POCKETS")
  -- Last mode per pocket, per save; weak so a new game starts fresh.
  local memories = setmetatable({}, { __mode = "k" })

  Pack.update = function(self, dt, ...)
    pcall(settleBattlePocket, self, Bag, POCKETS)
    local input = self.game and self.game.input
    if input and listHasInput(self) and input:wasPressed("start") then
      local ok, sorted = pcall(sortPack, self, Bag, memoryFor(memories, self))
      if ok and sorted then return end
    end
    return native(self, dt, ...)
  end

  local nativeSwitch = Pack.switchPocket
  if type(nativeSwitch) == "function" and POCKETS then
    Pack.switchPocket = function(self, delta, ...)
      if self.inBattle and self:inBattle() and (delta == 1 or delta == -1) then
        local ok, target = pcall(M.stepPocket, self.pocketIndex, delta, #POCKETS,
          pocketUsable(self, Bag, POCKETS))
        if ok and target then
          local steps = (target - self.pocketIndex) % #POCKETS
          if delta < 0 then steps = steps - #POCKETS end
          if steps ~= 0 then return nativeSwitch(self, steps, ...) end
        end
      end
      return nativeSwitch(self, delta, ...)
    end
  end

  -- SORT row in the item submenu, outside battle and only in sortable
  -- pockets.  The rows are ids; the label and the pick are answered here.
  local nativeRows = Pack.submenuRows
  if type(nativeRows) == "function" then
    Pack.submenuRows = function(self, itemId, ...)
      local rows = nativeRows(self, itemId, ...)
      local pocket = self.pocket and self:pocket()
      if self.inBattle and self:inBattle() then return rows end
      if not (pocket and M.SORTABLE[pocket.id]) then return rows end
      return M.withSortRow(rows)
    end
  end
  local nativeLabel = Pack.submenuLabel
  if type(nativeLabel) == "function" then
    Pack.submenuLabel = function(self, id, ...)
      if M.SORT_LABEL[id] then return M.SORT_LABEL[id] end
      return nativeLabel(self, id, ...)
    end
  end
  local nativeChoose = Pack.chooseSubmenu
  if type(nativeChoose) == "function" then
    Pack.chooseSubmenu = function(self, ...)
      local menu = self.submenu
      local id = menu and menu.rows and menu.rows[menu.index]
      if id == "ub_sort" then
        -- the same box, now asking how
        self.submenu = { row = menu.row, rows = M.SORT_ROWS, index = 1,
          usefulBagSort = true }
        return
      elseif SORT_ROW_MODE[id] then
        self:closeSubmenu()
        pcall(sortPack, self, Bag, memoryFor(memories, self), SORT_ROW_MODE[id])
        return
      end
      return nativeChoose(self, ...)
    end
  end
  return true
end

-- ItemPcMenu:pcAdd (engine/items/items.asm PutItemInPocket over wPCItems):
-- the same top-up-then-spill rule with a bigger stack budget.
local function installPc(mod, ItemPc)
  if rawget(ItemPc, "__usefulBagGen2Pc") then return true end
  local native = ItemPc.pcAdd
  if type(native) ~= "function" then return false end
  rawset(ItemPc, "__usefulBagGen2Pc", native)
  local STACK = 99
  local function stacksFor(n) return math.ceil((tonumber(n) or 0) / STACK) end
  ItemPc.pcAdd = function(self, id, qty, ...)
    if not biggerPockets(mod) then return native(self, id, qty, ...) end
    local pc = self.save and self.save.pcItems
    if type(pc) ~= "table" then return native(self, id, qty, ...) end
    local held = tonumber(pc[id]) or 0
    local used = 0
    for _, count in pairs(pc) do used = used + stacksFor(count) end
    local need = stacksFor(held + qty) - stacksFor(held)
    if used + need > M.PC_CAPACITY then return false end
    pc[id] = held + qty
    return true
  end
  return true
end

function M.install(mod, req)
  req = req or require
  local status = { generation = 2, capacity = false, sort = false }
  local okB, Bag = pcall(req, "src.inventory.Bag")
  if okB and type(Bag) == "table" then
    status.capacity = installCapacity(mod, Bag)
  else
    status.error = "src.inventory.Bag unavailable"
    return status
  end
  local okP, Pack = pcall(req, "src.ui.gen2.PackMenu")
  if okP and type(Pack) == "table" then
    status.sort = installMenu(Pack, Bag)
  else
    status.error = "src.ui.gen2.PackMenu unavailable"
  end
  local okC, ItemPc = pcall(req, "src.ui.gen2.ItemPcMenu")
  if okC and type(ItemPc) == "table" then
    status.pc = installPc(mod, ItemPc)
  end
  return status
end

return M
