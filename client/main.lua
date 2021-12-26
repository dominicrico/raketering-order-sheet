_menuPool = NativeUI.CreatePool()

local rakteringMenu = NativeUI.CreateMenu("Raketering", "~b~Raktering Bestellzettel")

_menuPool:Add(rakteringMenu)

local dish = ''
local quantity = 1

local rakteringMenuOpen = false
local orderSheetOpen = false

local orderSheetTypes = {
  pol = {
    checked = false
    name = 'Polizei'
  },
  bw = {
    checked = false
    name = 'Bundeswehr'
  },
  general = {
    checked = false
    name = 'Allgemein'
  },
}

orderSheet = {
  type = 'Allgemein',
  orders = {}
}

local sheetTypeMenu = _menuPool:AddSubMenu(rakteringMenu, "Bestellzettel Typ wählen")
local sheetFoodMenu = _menuPool:AddSubMenu(rakteringMenu, "Bestellzettel ausfüllen")

-- Menu to select the type of the raketering order sheet
function AddMenuOrderSheetType(menu)
  for k,v in orderSheetTypes do
    local item = NativeUI.CreateCheckboxItem("Bestellzettel " .. v.name , v.checked)
    menu:AddItem(item)

    menu.OnCheckboxChange = function(sender, _item, _checked)
      if _item == item then
        v.checked = _checked
        orderSheet.type = v.name
      end
    end
  end
end

-- Menu to add items to current order

-- Select food and quantity to add to current order
function AddMenuFoodsOrdered(menu)
  local newitem = NativeUI.CreateListItem("Bestellung", Config.FoodItems, 1)

  menu:AddItem(newitem)
  menu.OnListChange = function(sender, item, index)
    if item == newitem then
      dish = item:IndexToItem(index)
    end
  end
end

-- Select quantity of food to add to order
function AddMenuFoodsCount(menu)
  local amount = {}

  for i = 1, 20 do amount[i] = i end

  local newitem = NativeUI.CreateSliderItem("Anzahl", amount, 1, false)

  menu:AddItem(newitem)
  menu.OnSliderChange = function(sender, item, index)
    if item == newitem then
      quantity = item:IndexToItem(index)
    end
  end
end

-- Button to add it to the current order
function AddMenuAddToSheet(menu)
  local newitem = NativeUI.CreateItem("Zum Bestellzettel hinzufügen")
  newitem:SetRightBadge(BadgeStyle.Tick)

  menu:AddItem(newitem)

  menu.OnItemSelect = function(sender, item, index)
      if item == newitem then
        local order = {
          dish = dish,
          quantity = quantity
        }

        table.insert(orderSheet.orders, order)

        dish = ''
        quantity = 1
      end
  end
  menu.OnIndexChange = function(sender, index)
      if sender.Items[index] == newitem then
          newitem:SetLeftBadge(BadgeStyle.None)
      end
  end
end

-- Basic menu items like show, reset, etc ...

function AddMenuBasic(menu)
  local giveSheet = NativeUI.CreateItem("Raketering Bestellzettel abgeben")
  local resetSheet = NativeUI.CreateItem("Bestellzettel löschen")
  
  giveSheet:SetRightBadge(BadgeStyle.Tick)

  menu:AddItem(giveSheet)
  menu:AddItem(resetSheet)

  menu.OnItemSelect = function(sender, item, index)
      if item == giveSheet then
        GiveSheetToClosestPlayer()
      elseif item == resetSheet then
        dish = ''
        quantity = 1

        orderSheet = {
          type = 'Allgemein',
          orders = {}
        }
      end
  end
  menu.OnIndexChange = function(sender, index)
      if sender.Items[index] == newitem then
          newitem:SetLeftBadge(BadgeStyle.None)
      end
  end
end

-- Build menu structure

AddMenuOrderSheetType(sheetTypeMenu)
AddMenuFoodsOrdered(sheetFoodMenu)
AddMenuFoodsCount(sheetFoodMenu)
AddMenuAddToSheet(sheetFoodMenu)
AddMenuBasic(rakteringMenu)
_menuPool:RefreshIndex()

-- Handout order sheet to closest player

function GiveSheetToClosestPlayer()
  local player, distance = ESX.Game.GetClosestPlayer()

  if distance ~= -1 and distance <= 3.0 then
    TriggerServerEvent('raketering:handout_sheet', orderSheet, GetPlayerServerId(player))
  else
    ESX.ShowNotification('Niemand in der Nähe')
  end
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    _menuPool:ProcessMenus()

    -- Open the raketering menu by key or by event
    if (Config.UseKeyToOpen and IsControlJustPressed(1, Config.Key)) or rakteringMenuOpen then
      rakteringMenu:Visible(not rakteringMenu:Visible())
    end

    if (IsControlJustReleased(0, 322) or IsControlJustReleased(0, 177)) and orderSheetOpen then
			SendNUIMessage({
				action = "close"
			})
			orderSheetOpen = false
		end
  end
end)


-- Events

-- Open the Raketering Order Sheet Menu
RegisterNetEvent('raktering:open_menu')
AddEventHandler('raktering:open_menu', function() 
  rakteringMenuOpen = true
end)

-- Show the Raketering Order Sheet
RegisterNetEvent('raktering:show_sheet')
AddEventHandler('raktering:show_sheet', function(sheet)
	orderSheetOpen = true
	SendNUIMessage({
		action = "open",
		sheet = sheet
	})
end)