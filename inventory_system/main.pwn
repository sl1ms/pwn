// -- Очищение структуры инвентаря у игрока
stock Inventory:ClearPlayerData(playerid)
{
    for(new idx; idx != MAX_INVENTORY_SLOTS; idx++)
    {
        SetPlayerInventoryData(playerid, I_ID, idx, INVALID_INVENTORY_SLOT);
        SetPlayerInventoryData(playerid, I_ITEM, idx, INVALID_INVENTORY_ITEM);
        SetPlayerInventoryData(playerid, I_COUNT, idx, 0);
    }

    return true;
}

// -- Загружаем инвентарь игрока
stock Inventory:LoadPlayerData(playerid)
{
    format(
        totalstring, sizeof totalstring, 
        "SELECT `item_id`, `count`, `id`, `slot_id` FROM "#DB_ACCOUNT_INVENTORY" WHERE `account_id` = '%d'",
        GetPlayerAccountID(playerid) 
    );

    new Cache:request_load_inventory_data = mysql_query(mysql, totalstring);
    new rows = cache_num_rows();

    new temp_slot_id;

    for(new idx; idx != rows; idx++)
    {
        cache_get_value_name_int(idx, "slot_id", temp_slot_id);

        cache_get_value_name_int(idx, "id", GetPlayerInventoryData(playerid, I_ID, temp_slot_id));
        cache_get_value_name_int(idx, "item_id", GetPlayerInventoryData(playerid, I_ITEM, temp_slot_id));
        cache_get_value_name_int(idx, "count", GetPlayerInventoryData(playerid, I_COUNT, temp_slot_id));
    }

    cache_delete(request_load_inventory_data);

    totalstring[0] = EOS;

    return true;
}

// -- Сохранение слота инвентаря
stock Inventory:SavePlayerSlotData(playerid, slot_id)
{
    if(GetPlayerInventoryData(playerid, I_ID, slot_id) == INVALID_INVENTORY_SLOT)
    {
        format(
            totalstring, sizeof totalstring, 
            "INSERT INTO "#DB_ACCOUNT_INVENTORY" (`account_id`, `item_id`, `count`, `slot_id`) VALUES ('%d', '%d', '%d', '%d')", 
            GetPlayerAccountID(playerid),
            GetPlayerInventoryData(playerid, I_ITEM, slot_id),
            GetPlayerInventoryData(playerid, I_COUNT, slot_id),
            slot_id
        );
        new Cache:request_insert_slot_data = mysql_query(mysql, totalstring);

        SetPlayerInventoryData(playerid, I_ID, slot_id, cache_insert_id());

        cache_delete(request_insert_slot_data);

        totalstring[0] = EOS;

        return true;
    }

    format(
        totalstring, sizeof totalstring, 
        "UPDATE "#DB_ACCOUNT_INVENTORY" SET `item_id` = '%d', `count` = '%d', `slot_id` = '%d' WHERE `id` = '%d'", 
        GetPlayerInventoryData(playerid, I_ITEM, slot_id),
        GetPlayerInventoryData(playerid, I_COUNT, slot_id),
        slot_id,
        GetPlayerInventoryData(playerid, I_ID, slot_id)
    );
    mysql_tquery(mysql, totalstring);

    return true;
}

// -- Узнаем слот инвентаря в котором лежит предмет
stock Inventory:GetItemSlotPlayerData(playerid, item_id)
{
    for(new idx; idx != MAX_INVENTORY_SLOTS; idx++)
        if(GetPlayerInventoryData(playerid, I_ITEM, idx) == item_id)
            return idx;

    return INVALID_INVENTORY_SLOT;
}

// -- Меняем количество предмета в инвентаре
stock Inventory:SetCountItemPlayerData(playerid, slot_id, count)
{
    if(slot_id <= INVALID_INVENTORY_SLOT)
    {
        format(
            totalstring, sizeof totalstring, 
            "[INVENTORY_SYSTEM] Произошла ошибка. Сообщите администрации {"#DC_WHITE"}(Inventory:SetCountItemPlayerData(%d, %d, %d))", 
            playerid, slot_id, count
        );
        SendClientMessage(playerid, COLOR_LRED, totalstring);

        totalstring[0] = EOS;
        return true;
    }

    new slot_count = GetPlayerInventoryData(playerid, I_COUNT, slot_id);

    SetPlayerInventoryData(playerid, I_COUNT, slot_id, slot_count + count);

    if(GetPlayerInventoryData(playerid, I_COUNT, slot_id) <= 0)
    {
        SetPlayerInventoryData(playerid, I_ITEM, slot_id, INVALID_INVENTORY_ITEM);
        SetPlayerInventoryData(playerid, I_COUNT, slot_id, 0);
    }

    Inventory:SavePlayerSlotData(playerid, slot_id);

    return true;
}

// -- Узнаем количество предмета в слоте
stock Inventory:GetCountItemPlayerData(playerid, slot_id)
{
    return (slot_id <= INVALID_INVENTORY_SLOT) ? 0 : GetPlayerInventoryData(playerid, I_COUNT, slot_id);
}

// -- Выдаем предмет в инвентарь
stock Inventory:GiveItemPlayerData(playerid, item_id, count)
{
    new slot_id = INVALID_INVENTORY_SLOT;

    if(!Inventory:GetItemSplit(item_id))
    {
        for(new idx; idx != MAX_INVENTORY_SLOTS; idx++)
        {
            if(GetPlayerInventoryData(playerid, I_ITEM, idx) != item_id) 
                continue;

            slot_id = idx;
            break;
        }   
    }

    if(slot_id == INVALID_INVENTORY_SLOT)
        slot_id = Inventory:GetFreeSlotPlayerData(playerid);

    if(slot_id == INVALID_INVENTORY_SLOT)
    {
        Hud:ShowNotification(playerid, ERROR, "инвентарь переполнен");
        return false;
    }
    
    new inventory_limit = GetItemInventoryLimit(item_id, playerid);

    if(inventory_limit - (GetPlayerInventoryData(playerid, I_COUNT, slot_id) + count) < 0)
    {   
        new item_reduction[8];

        strunpack(item_reduction, inventory_items[item_id][ITEM_REDUCTION], sizeof item_reduction);

        format(
            totalstring, sizeof totalstring, "Вы не можете поместить в инвентарь более %d %s данного предмета", 
            inventory_limit, 
            item_reduction
        );
        Hud:ShowNotification(playerid, ERROR, totalstring);

        totalstring[0] = EOS;

        return false;
    }

    new slot_count = GetPlayerInventoryData(playerid, I_COUNT, slot_id);

    SetPlayerInventoryData(playerid, I_ITEM, slot_id, item_id);
    SetPlayerInventoryData(playerid, I_COUNT, slot_id, slot_count + count);

    switch(item_id)
    {
        case ITEM_PHONE, 173:
        {
            new item_quest_count = 0;

            if(Inventory:GetItemSlotPlayerData(playerid, 173) != INVALID_INVENTORY_SLOT) 
                item_quest_count += 1;

            if(Inventory:GetItemSlotPlayerData(playerid, ITEM_PHONE) != INVALID_INVENTORY_SLOT) 
                item_quest_count += 1;

            if(item_quest_count == 2) 
                CompletedQuests(playerid, 3);
        }
    }
    if(Inv_IsSkinItem(item_id))
        CompletedQuests(playerid, 6);
        
    if(Inv_IsEatItem(item_id))
        CompletedQuests(playerid, 7);

    Inventory:SavePlayerSlotData(playerid, slot_id);
        
    return true;
}

// -- Ищем свободный слот в инвентаре
stock Inventory:GetFreeSlotPlayerData(playerid)
{
    new slot_id = INVALID_INVENTORY_SLOT,
        inventory_max = 25;

    if(GetPlayerData(playerid, P_BACKPACK)) 
        inventory_max = 45; 

    if(GetPlayerData(playerid, P_IMPROVEDBACKPACK)) 
        inventory_max = MAX_INVENTORY_SLOTS;
    
    for(new idx; idx != inventory_max; idx++)
    {
        if(!GetPlayerInventoryData(playerid, I_ITEM, idx))
        {
            slot_id = idx; 
            break;
        }
    }

    return slot_id;
}

stock Inventory:GetItemSplit(item_id)
{
    if(51 <= item_id <= 172 || 278 <= item_id <= 287 || item_id == ITEM_CANISTER || Inv_IsSkinItem(item_id)) 
        return true; 

    return false; 
}