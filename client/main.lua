local ESX = nil

_menuPool = NativeUI.CreatePool()

local raketeringMenu = NativeUI.CreateMenu("Raketering", "~b~Raktering Bestellung")
local sheetFoodMenu = nil

_menuPool:Add(raketeringMenu)

local dish = ''
local quantity = 1

local raketeringMenuOpen = false
local orderSheetOpen = false

local orderSheetTypes = {
  'Allgemein',
  'Polizei',
  'Bundeswehr',
}

orderSheet = {
  type = 'Allgemein',
  orders = {}
}

-- Menu to select the type of the raketering order sheet
function AddMenuOrderSheetType(menu)
  local newitem = NativeUI.CreateListItem("Bestellung für", orderSheetTypes, 1)

  menu:AddItem(newitem)
  menu.OnListChange = function(sender, item, index)
    if item == newitem then
      orderSheet.type = item:IndexToItem(index)
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

  for i = 1, 21 do amount[i] = i - 1 end

  for k,v in pairs(Config.FoodItems) do
    local newitem = NativeUI.CreateListItem(k, amount, 0)

    menu:AddItem(newitem)
  end

  menu.OnListChange = function(sender, item, index)
    if Config.FoodItems[item.Base.Text._Text] ~= nil then
      
      local quantity = item:IndexToItem(index)

      Config.FoodItems[item.Base.Text._Text] = quantity
    end
  end
end

-- Button to add it to the current order
function AddMenuAddToSheet(menu)
  local newitem = NativeUI.CreateItem("Bestellzettel ausfüllen", "Auf den Bestellzettel damit")
  newitem:SetRightBadge(BadgeStyle.Tick)

  menu:AddItem(newitem)

  menu.OnItemSelect = function(sender, item, index)
      if item == newitem then
       
        orderSheet.orders = Config.FoodItems


        menu:GoBack()
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
  local giveSheet = NativeUI.CreateItem("Bestellzettel abgeben", 'Bestellzettel an Person übergeben')
  local resetSheet = NativeUI.CreateItem("Bestellzettel löschen", 'Neuen Bestellzettel anfangen')
  
  giveSheet:SetRightBadge(BadgeStyle.Tick)

  menu:AddItem(giveSheet)
  menu:AddItem(resetSheet)

  menu.OnItemSelect = function(sender, item, index)
      if item == giveSheet then
        GiveSheetToClosestPlayer()
      elseif item == resetSheet then
        for k,v in pairs(Config.FoodItems) do
          Config.FoodItems[k] = 0
        end
        
        orderSheet = {
          type = 'Allgemein',
          orders = {}
        }

        BuildMenu()
      end
  end
  menu.OnIndexChange = function(sender, index)
      if sender.Items[index] == newitem then
          newitem:SetLeftBadge(BadgeStyle.None)
      end
  end
end

-- Build menu structure
function BuildMenu() 
  raketeringMenu:Clear()

  AddMenuOrderSheetType(raketeringMenu)

  sheetFoodMenu = _menuPool:AddSubMenu(raketeringMenu, "Bestellzettel ausfüllen")

  --AddMenuFoodsOrdered(sheetFoodMenu)
  AddMenuFoodsCount(sheetFoodMenu)
  AddMenuAddToSheet(sheetFoodMenu)
  AddMenuBasic(raketeringMenu)
  _menuPool:RefreshIndex()
end

BuildMenu()

-- Handout order sheet to closest player

function GiveSheetToClosestPlayer()
  local player, distance = ESX.Game.GetClosestPlayer()

  orderSheetOpen = true
	SendNUIMessage({
		action = "open",
		sheet = orderSheet
	})

  if distance ~= -1 and distance <= 3.0 then
    TriggerServerEvent('raketering:handout_sheet', orderSheet, GetPlayerServerId(player))
  else
    ESX.ShowNotification('Niemand in der Nähe')
  end
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    _menuPool:ProcessMenus()

    -- Open the raketering menu by key or by event
    if (Config.UseKeyToOpen and IsControlJustPressed(1, Config.Key)) or raketeringMenuOpen then
      raketeringMenu:Visible(not raketeringMenu:Visible())
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
  raketeringMenuOpen = true
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