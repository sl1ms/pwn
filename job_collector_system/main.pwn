// -- Активация сейфа
forward JobCollector:OnPlayerSafeActive();
public JobCollector:OnPlayerSafeActive()
{
    if(IsDynamicObjectMoving(SafeDoorBank))
    {
        StopDynamicObject(SafeDoorBank);
        KillTimer(g_bank_safe_timer);
    }

    // -- Если сейф закрыт, то открываем его
    if(!g_bank_safe_state) 
    {
        MoveDynamicObject(SafeDoorBank, 1397.3215, -1684.3142, 40.7843, 1.5, 0.0000, -0.0001, 90.0000);
        g_bank_safe_timer = SetTimer(JobCollectorText(JobCollector:OnPlayerSafeActive), 5000, false);
    }
    else 
    {
        MoveDynamicObject(SafeDoorBank, 1398.1815, -1683.1666, 40.7843, 1.5, 0.0000, -0.0001, 179.9935); // Закрытая
        KillTimer(g_bank_safe_timer);
    }

    g_bank_safe_state = !g_bank_safe_state;

    return true;
}

// -- Инициализация системы
stock JobCollector:Init()
{
    for(new idx; idx != MAX_GANG_FRACTION; idx++)
        g_jc_attack_group[idx] = g_jc_attack_group_default;

    for(new idx; idx != MAX_JOB_COLLECTOR_PICKUPS; idx++)
    {
        g_job_collector_pickup[idx][JC_PICKUP_ID] = Pickups:Create(
            g_job_collector_pickup[idx][JC_PICKUP_MODEL], 
            g_job_collector_pickup[idx][JC_PICKUP_X],
            g_job_collector_pickup[idx][JC_PICKUP_Y],
            g_job_collector_pickup[idx][JC_PICKUP_Z],
            BANK_VIRTUAL_WORLD, BANK_INTERIOR, 
            PICKUP_ACTION_JOB_COLLECTOR,
            PICKUP_NOTIFY_KEY_ALT
        );

        CreateDynamic3DTextLabel(
            g_job_collector_pickup[idx][JC_PICKUP_TEXT],
            COLOR_MAIN,
            g_job_collector_pickup[idx][JC_PICKUP_X],
            g_job_collector_pickup[idx][JC_PICKUP_Y],
            g_job_collector_pickup[idx][JC_PICKUP_Z] + 0.35,
            MAX_JC_DRAWDISTANCE_TEXT_3D,
            INVALID_PLAYER_ID, INVALID_VEHICLE_ID,
            1, BANK_VIRTUAL_WORLD, BANK_INTERIOR
        );
    }

    for(new idx; idx != MAX_JOB_COLLECTOR_ACTORS; idx++)
    {
        g_job_collector_actor[idx][JC_ACTOR_ID] = Actors:Create(
            g_job_collector_actor[idx][JC_ACTOR_SKIN],
            g_job_collector_actor[idx][JC_ACTOR_X],
            g_job_collector_actor[idx][JC_ACTOR_Y],
            g_job_collector_actor[idx][JC_ACTOR_Z],
            g_job_collector_actor[idx][JC_ACTOR_ANGLE],
            g_job_collector_actor[idx][JC_ACTOR_WORLD],
            g_job_collector_actor[idx][JC_ACTOR_INTERIOR],
            g_job_collector_actor[idx][JC_ACTOR_ACTION_TYPE],
            g_job_collector_actor[idx][JC_ACTOR_TYPE]
        );

        ApplyDynamicActorAnimation(
            g_job_collector_actor[idx][JC_ACTOR_ID], 
            g_job_collector_actor[idx][JC_ACTOR_ANIM_LIB],
            g_job_collector_actor[idx][JC_ACTOR_ANIM_NAME],
            4.1, 0, 0, 0, 1, 0
        );

        if(!strcmp(g_job_collector_actor[idx][JC_ACTOR_NAME], "none"))
            continue;
            
        CreateDynamic3DTextLabel(
            g_job_collector_actor[idx][JC_ACTOR_NAME],
            COLOR_WHITE,
            g_job_collector_actor[idx][JC_ACTOR_X],
            g_job_collector_actor[idx][JC_ACTOR_Y],
            g_job_collector_actor[idx][JC_ACTOR_Z] + 1.0,
            MAX_JC_DRAWDISTANCE_TEXT_3D,
            INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1,
            g_job_collector_actor[idx][JC_ACTOR_WORLD],
            g_job_collector_actor[idx][JC_ACTOR_INTERIOR]
        );
    }

    // -- Показ у определенного актера уведомление на кнопку "ALT"
    new actor_id = g_job_collector_actor[0][JC_ACTOR_ID];
    new area_id = GetActorData(actor_id, A_ACTOR_AREA_ID);

    SetAreaData(area_id, A_AREA_NOTIFY_KEY, AREA_NOTIFY_KEY_ALT);

    // -- Дверь входа в сейф
    Area:Create(
        1398.2864, -1683.6924, 40.2980, 2.0, BANK_VIRTUAL_WORLD, BANK_INTERIOR, INVALID_ACTOR_ID,
        AREA_ACTION_TYPE_BANK_SAFE, DEFAULT_AREA_TYPE, AREA_NOTIFY_KEY_ALT
    );

    for(new idx; idx != MAX_JC_LOBBY; idx++)
        g_jc_lobby_data[idx] = g_jc_lobby_data_null;

    return true;
}

// -- Если игрок вступил на пикап
stock JobCollector:OnPlayerEnterPickup(playerid, pickup_id)
{
    new index_pickup;

    for(new idx; idx != MAX_JOB_COLLECTOR_PICKUPS; idx++)
    {
        if(g_job_collector_pickup[idx][JC_PICKUP_ID] != pickup_id)
            continue;

        index_pickup = idx;
        break;
    }
    
    switch(index_pickup)
    {
        case JC_PICKUP_DRESSING_ROOM:
            return Dialog_Show(playerid, Dialog:D_JC_DRESSING_ROOM);

        case JC_PICKUP_SAFE:
        {
            if(!IsPlayerAttachedObjectSlotUsed(playerid, ATTACH_IDX_BONE_ARM_RIGHT))
                return true;

            new modelid;

            if(GetPlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT, modelid))
                if(modelid != MODELID_JC_MONEY_BAG)
                    return true;

            new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);
            new money = JC_MONEY_BAD_SALARY * JobCollector:GetPlayersInLobby(lobby_id);

            if(lobby_id == INVALID_JC_LOBBY_ID)
                return RemovePlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT);

            format(
                totalstring, sizeof totalstring, 
                "[G] Каждый получил по %d$ за выгруженную сумку с деньгами", 
                money
            );
            JobCollector:SendLobbyMessage(lobby_id, totalstring);

            RemovePlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT);

            new from_playerid;

            for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
            {
                from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);
             
                if(from_playerid != INVALID_PLAYER_ID)
                    SetPlayerCash(from_playerid, GetPlayerCash(from_playerid) + money);
            }

            return true;
        }
    }

    return true;
}

// -- Если игрок подошел к Актёру
stock JobCollector:OnPlayerActiveActor(playerid)
{
    Dialog_Show(playerid, Dialog:D_JC_EPLOYMENT);
    return true;
}

// -- Трудоустройство игрока
stock JobCollector:OnPlayerEployment(playerid)
{
    if(GetPlayerJob(playerid) == JOB_ID_COLLECTOR)
    {
        if(JobCollector:IsPlayerAtWorkDay(playerid))
            JobCollector:OnPlayerWorkDay(playerid);

        Hud:ShowNotification(playerid, SUCCESS, "Вы успешно уволились с работы инкассатора");
        SetPlayerJob(playerid, JOB_ID_NONE);

        return true;
    }

    if(GetPlayerLevel(playerid) < 7)
        return Hud:ShowNotification(playerid, ERROR, "чтобы устроиться на данную работу, необходим 7 уровень");

    if(!GetPlayerLicense(playerid, LICENSE_TYPE_GUN))
        return Hud:ShowNotification(playerid, ERROR, "чтобы устроиться на данную работу, необходимо иметь лицензию на оружие");

    if(!GetPlayerLicense(playerid, LICENSE_TYPE_AUTO))
        return Hud:ShowNotification(playerid, ERROR, "чтобы устроиться на данную работу, необходимо иметь лицензию на вождение транспорта");

    if(GetPlayerMember(playerid) != F_NONE)
        return Hud:ShowNotification(playerid, ERROR, "Вы не можете устроиться на работу, состояв в организации");

    SetPlayerJob(playerid, JOB_ID_COLLECTOR);

    Hud:ShowNotification(playerid, SUCCESS, "Вы успешно устроились на работу инкассатора");

    JobCollector:ClearPlayerData(playerid);

    return true;
}

// -- Проверяем, на рабочем ли дне игрок
stock JobCollector:IsPlayerAtWorkDay(playerid)
{
    if(GetPlayerJobCollector(playerid, JC_WORK_DAY))
        return true;

    return false;
}

// -- Очищаем структуру игрока
stock JobCollector:ClearPlayerData(playerid)
{
    g_player_job_collector[playerid] = g_player_job_collector_default;
    return true;
}

// -- Начать/Завершить рабочий день
stock JobCollector:OnPlayerWorkDay(playerid)
{
    if(JobCollector:IsPlayerAtWorkDay(playerid))
    {
        JobCollector:OnPlayerLeaveInLobby(playerid, "Окончен рабочий день");

        SetPlayerSkin(playerid, GetPlayerJobCollector(playerid, JC_SKIN));

        JobCollector:ClearPlayerData(playerid);

        Hud:ShowNotification(playerid, SUCCESS, "Рабочий день успешно завершен");

        ResetPlayerWeapons(playerid);
        DisablePlayerCheckpoint(playerid);
        SetPlayerArmour(playerid, 0.0);
        RemovePlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT);
        
        return true;
    }

    SetPlayerJobCollector(playerid, JC_SKIN, GetPlayerSkin(playerid));
    SetPlayerJobCollector(playerid, JC_WORK_DAY, true);

    if(GetPlayerSex(playerid) == SEX_BOY) SetPlayerSkin(playerid, JC_SKIN_BOY);
    else SetPlayerSkin(playerid, JC_SKIN_GIRL);

    Hud:ShowNotification(playerid, SUCCESS, "Вы успешно начали рабочий день!");
    Hud:ShowNotification(playerid, ET_INFO,
        "Чтобы начать работу, необходимо найти напарника (используйте команду {"#DC_BEIGE"}/jinvite{"#DC_WHITE"})",
        10000
    );

    return true;
}

// -- Арендовать рабочий транспорт
stock JobCollector:OnPlayerRentVehicle(playerid)
{
    if(GetPlayerJob(playerid) != JOB_ID_COLLECTOR)
        return Hud:ShowNotification(playerid, ERROR, "Вы не работаете инкассатором");

    if(!JobCollector:IsPlayerAtWorkDay(playerid))
        return Hud:ShowNotification(playerid, ERROR, "необходимо начать рабочий день");

    if(!GetPlayerLicense(playerid, LICENSE_TYPE_AUTO))
        return Hud:ShowNotification(playerid, ERROR, "у Вас нет водительского удостоверения");

    if(!g_job_collector_veh_count)
        return Hud:ShowNotification(playerid, ERROR, "в гараже нет свободного трансопорта");

    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return Hud:ShowNotification(playerid, ERROR, "чтобы арендовать рабочий транспорт, необходимо найти напарника");

    if(GetJobCollectorLobbyData(lobby_id, JC_LOBBY_CREATED_ID) != playerid)
        return Hud:ShowNotification(playerid, ERROR, "арендовать транспорт может только владелец рабочей группы");

    if(GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID) != INVALID_VEHICLE_ID)
        return Hud:ShowNotification(playerid, ERROR, "у Вашей рабочий группы уже есть арендованный рабочий транспорт");

    Dialog_Show(playerid, Dialog:D_JC_RENT_VEHICLE);

    return true;
}

// -- Если игрок сел в рабочий транспорт
stock JobCollector:OnPlayerEnterVehicle(playerid, vehicle_id)
{
    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);
    new bool:result = false;

    if(lobby_id == INVALID_JC_LOBBY_ID)
        result = true;

    else if(vehicle_id != GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID))
        result = true;
    
    else if(!(GetPlayerJob(playerid) == JOB_ID_COLLECTOR && JobCollector:IsPlayerAtWorkDay(playerid)))
        result = true;

    if(result)
    {
        ClearAnimations(playerid, 1);
        return Hud:ShowNotification(playerid, ERROR, "у Вас нет ключей от данного транспорта");
    }
        
    return true;
}

// -- Игрок прибыл к банкомату
stock JobCollector:OnPlayerEnterCheckpoint(playerid)
{
    DisablePlayerCheckpoint(playerid);

    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return true;

    new atm_id = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_ID);

    if(atm_id == INVALID_ATM_ID)
        return true;

    new Float:x = GetAtmData(atm_id, ATM_X), 
        Float:y = GetAtmData(atm_id, ATM_Y),
        Float:z = GetAtmData(atm_id, ATM_Z);

    if(!IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z))
        SetPlayerCheckpoint(playerid, x, y, z, 5.0);

    new from_playerid = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_ACTIVE_PLAYERID);

    format(
        totalstring, sizeof totalstring, 
        "Вы успешно прибыли к банкомату. Обслуживает данный банкомат: {"#DC_BEIGE"}%s [%d]",
        GetName(from_playerid), from_playerid 
    );
    Hud:ShowNotification(playerid, SUCCESS, totalstring);

    if(from_playerid == playerid)
    {
        for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
        {
            from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);

            if(from_playerid != INVALID_PLAYER_ID)
                DisablePlayerCheckpoint(from_playerid);
        }
    }

    return true;
}

// -- Показываем игроку банкомат, к которму он поедет
stock JobCollector:SetPlayerCheckpoint(playerid)
{
    new atm_id = random_ex(0, MAX_ATM - 1, 1);
    
    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return true;

    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_ID, atm_id);
    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_KEY, INVALID_ATM_KEY);
    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_ID, atm_id);

    new Float:x = GetAtmData(atm_id, ATM_X),
        Float:y = GetAtmData(atm_id, ATM_Y),
        Float:z = GetAtmData(atm_id, ATM_Z);

    new player_count_in_lobby = JobCollector:GetPlayersInLobby(lobby_id);
    new chance = 100 / player_count_in_lobby;
    new rand_chance;
    new result_playerid = INVALID_PLAYER_ID;
    new from_playerid;

    for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
    {
        from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);

        if(from_playerid == INVALID_PLAYER_ID)
            continue;

        SetPlayerCheckpoint(from_playerid, x, y, z, 3.0);
        SendClientMessage(from_playerid, COLOR_MAIN, "[Инкассация] {"#DC_WHITE"}Банкомат отмечен {"#DC_LRED"}красной {"#DC_WHITE"}меткой на карте");

        if(result_playerid != INVALID_PLAYER_ID)
            continue;

        rand_chance = random_ex(0, 100, 1);

        if(rand_chance < chance)
            continue;

        result_playerid = from_playerid;
    }

    if(result_playerid == INVALID_PLAYER_ID)
        result_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, 0);

    format(
        totalstring, sizeof totalstring,
        "[G] Код от банкомата получил %s [%d], он должен обслужить банкомат",
        GetName(result_playerid), result_playerid
    );
    JobCollector:SendLobbyMessage(lobby_id, totalstring);

    new random_atm_key = random_ex(100000, 999999, 1);
    
    SetPlayerJobCollector(result_playerid, JC_ATM_KEY, random_atm_key);
    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_KEY, random_atm_key);
    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ACTIVE_PLAYERID, result_playerid);

    format(
        totalstring, sizeof totalstring, 
        "[Инкассация] {"#DC_WHITE"}Пин-код от банкомата - {"#DC_BANK"}%d", 
        random_atm_key
    );
    SendClientMessage(result_playerid, COLOR_MAIN, totalstring);
    SendClientMessage(result_playerid, COLOR_MAIN, "[Инкассация] {"#DC_WHITE"}Введите его в меню банкомата, чтобы забрать деньги");


    return true;
}

// -- Кладем/берем сумку с деньгами
stock JobCollector:OnPlayerUseTrunk(playerid)
{
    new vehicleid = Vehicles:GetNearestVehicle(playerid);

    if(vehicleid == INVALID_VEHICLE_ID)
        return true;

    new ownable_type = GetVehicleData(vehicleid, V_OWNABLE_TYPE),
        action_type = GetVehicleData(vehicleid, V_ACTION_TYPE);

    switch(ownable_type)
    {
        case VEH_OWNABLE_JOB:
        {
            switch(action_type)
            {
                case VEH_TYPE_COLLECTOR:
                {
                    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

                    if(lobby_id == INVALID_JC_LOBBY_ID)
                    {
                        if(!IsAGang(playerid))
                            return true;

                        new fraction_id = GetPlayerMember(playerid);

                        if(vehicleid != GetJobCollectorAttackGroup(fraction_id - 7, AG_VEHICLEID_ATTACK))
                            return true;

                        SetPVarInt(playerid, PVAR_COLLECTOR_VEH_PUT_ID, vehicleid);
                    }
                }
            }
        }

        default:
        {
            if(!IsAGang(playerid))
                return true;

            new fraction_id = GetPlayerMember(playerid);

            if(VehInfo[vehicleid][vFraction] != fraction_id)
                return true;

            if(GetVehicleModel(vehicleid) != 482)
                return true;

            SetPVarInt(playerid, PVAR_ATTACK_VEH_PUT_ID, vehicleid);

            Dialog_Show(playerid, Dialog:D_JC_USE_TRUNK);
        }
    }

    new Float:trunk_pos[3];
    Vehicles:GetTrunkVehiclePos(vehicleid, trunk_pos[0], trunk_pos[1], trunk_pos[2]);

    if(!IsPlayerInRangeOfPoint(playerid, 2.0, trunk_pos[0], trunk_pos[1], trunk_pos[2]))
        return true;

    Dialog_Show(playerid, Dialog:D_JC_USE_TRUNK);

    return true;
}

// -- Если машина инассаторов повреждена
stock JobCollector:VehicleDamage(vehicleid, playerid)
{
    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return true;

    new vehicle_id = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID);

    if(vehicle_id == INVALID_VEHICLE_ID)
        return true;

    if(vehicleid != vehicle_id)
        return true;

    new Float:vehicle_health;
    GetVehicleHealth(vehicleid, vehicle_health);

    if(vehicle_health < 300.0)
        SetVehicleHealth(vehicleid, 300.0);

    return true;
}

// -- Игрок закончил мини-игру и взял сумку
stock JobCollector:PlayerSuccessMoneyTake(playerid)
{
    Hud:ShowNotification(playerid, SUCCESS, "Вы успешно забрали деньги из банкомата, положите их в машину");

    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return true;

    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_ID, INVALID_ATM_ID);
    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_KEY, INVALID_ATM_KEY);
    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ACTIVE_PLAYERID, INVALID_PLAYER_ID);

    SetPlayerJobCollector(playerid, JC_ATM_KEY, INVALID_ATM_KEY);

    SetPlayerAttachedObject(
        playerid, ATTACH_IDX_BONE_ARM_RIGHT, MODELID_JC_MONEY_BAG, BONE_ARM_RIGHT, 
        0.190999, 0.019000, 0.000000,
        0.000000, -92.599990, 91.599983,
        0.263000, 0.766000, 1.011000
    );

    return true;
}

// -- Игрок вызывает тревогу
stock JobCollector:OnPlayerAlarm(playerid)
{   
    if(!(GetPlayerJob(playerid) == JOB_ID_COLLECTOR && JobCollector:IsPlayerAtWorkDay(playerid)))
        return true;

    if(GetPlayerNeedHelpData(playerid, NH_STATE))
        return Hud:ShowNotification(playerid, ERROR, "Вы уже вызвали подкрепление, ожидайте приянтие вызова");

    Dialog_Show(playerid, Dialog:D_NEED_HELP);

    return true;
}

// -- Проверяем состоит ли игрок в лобби и не явлется его создателем
stock JobCollector:IsPlayerInivtedLobby(playerid)
{
    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return false;

    if(GetJobCollectorLobbyData(lobby_id, JC_LOBBY_CREATED_ID) == playerid)
        return false;

    return true;
}

// -- Ищем свободное лобби
stock JobCollector:GetFreeLobbyID()
{
    new lobby_id = INVALID_JC_LOBBY_ID;

    for(new idx; idx != MAX_JC_LOBBY; idx++)
    {
        if(GetJobCollectorLobbyData(idx, JC_LOBBY_CREATED_ID) != INVALID_PLAYER_ID)
            continue;

        lobby_id = idx;
        break;
    }

    return lobby_id;
}

// -- Получаем количество участников в лобби
stock JobCollector:GetPlayersInLobby(lobby_id)
{
    new players_count = 0;

    for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
        if(GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx) != INVALID_PLAYER_ID)
            players_count++;

    return players_count;
}

// -- Получаем свободную ячейку для записи игрока в структуру
stock JobCollector:GetFreePlayerIndexLobby(lobby_id)
{
    new index;

    for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
    {
        if(GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx) != INVALID_PLAYER_ID)
            continue;

        index = idx;
        break;
    }

    return index;
}

// -- Узнаем слот в который записан игрок
stock JobCollector:GetPlayerIndexLobby(playerid, lobby_id)
{
    new index = INVALID_PLAYER_ID;

    for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
    {
        if(GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx) != playerid)
            continue;

        index = idx;
        break;
    }

    return index;
}

// -- Очищаем структуру лобби
stock JobCollector:ClearLobbyData(lobby_id)
{
    new vehicle_id = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID);
    new from_playerid;

    for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
    {
        from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);

        if(from_playerid == INVALID_PLAYER_ID)
            continue;

        SetPlayerJobCollector(from_playerid, JC_LOBBY_ID, INVALID_JC_LOBBY_ID);
        SetPlayerJobCollector(from_playerid, JC_ATM_KEY, INVALID_ATM_KEY);

        DisablePlayerCheckpoint(from_playerid);
    }

    if(vehicle_id != INVALID_VEHICLE_ID && !GetVehicleData(vehicle_id, V_ATTACK))
    {
        Vehicles:Destroy(vehicle_id);
        g_job_collector_veh_count++;
    }

    g_jc_lobby_data[lobby_id] = g_jc_lobby_data_null;

    return true;
}

// -- Если игрок покидает лобби
stock JobCollector:OnPlayerLeaveInLobby(playerid, const reason[])
{
    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return true;

    new index = JobCollector:GetPlayerIndexLobby(playerid, lobby_id);
    new key_atm = GetPlayerJobCollector(playerid, JC_ATM_KEY);

    SetPlayerJobCollector(playerid, JC_LOBBY_ID, INVALID_JC_LOBBY_ID);
    SetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, index, INVALID_PLAYER_ID);

    new vehicle_id = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID);

    if(GetPlayerVehicleID(playerid) == vehicle_id)
        RemovePlayerFromVehicle(playerid);

    DisablePlayerCheckpoint(playerid);

    format(
        totalstring, sizeof totalstring, 
        "[G] Игрок %s покидает рабочую группу. Причина: %s",
        GetName(playerid), reason 
    );
    JobCollector:SendLobbyMessage(lobby_id, totalstring);

    if(JobCollector:IsPlayerAtWorkDay(playerid))
    {
        ResetPlayerWeapons(playerid);
        DisablePlayerCheckpoint(playerid);
        SetPlayerArmour(playerid, 0.0);
        RemovePlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT);

        SetPlayerSkin(playerid, GetPlayerJobCollector(lobby_id, JC_SKIN));

        JobCollector:ClearPlayerData(playerid);    

        SendClientMessage(playerid, COLOR_MAIN, "[Инкассация] {"#DC_WHITE"}Рабочий день окончен");    
    }

    if(JobCollector:GetPlayersInLobby(lobby_id) <= 1)
    {
        new from_playerid;

        JobCollector:SendLobbyMessage(lobby_id, "[G] Рабочая группа была расформирована");

        for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
        {
            from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);

            if(from_playerid == INVALID_PLAYER_ID || from_playerid == playerid)
                continue;

            if(!JobCollector:IsPlayerAtWorkDay(from_playerid))
                continue;

            SetPlayerSkin(from_playerid, GetPlayerJobCollector(from_playerid, JC_SKIN));

            ResetPlayerWeapons(from_playerid);
            DisablePlayerCheckpoint(from_playerid);
            SetPlayerArmour(from_playerid, 0.0);
            RemovePlayerAttachedObject(from_playerid, ATTACH_IDX_BONE_ARM_RIGHT);

            SetPlayerSkin(playerid, GetPlayerJobCollector(lobby_id, JC_SKIN));

            JobCollector:ClearPlayerData(from_playerid); 

            SendClientMessage(from_playerid, COLOR_MAIN, "[Инкассация] {"#DC_WHITE"}Рабочий день окончен");
        }
    
        JobCollector:ClearLobbyData(lobby_id);

        return true;
    }

    if(key_atm != INVALID_ATM_KEY)
    {
        new from_playerid;

        for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
        {
            from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);

            if(from_playerid == INVALID_PLAYER_ID || from_playerid == playerid)
                continue;

            SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ACTIVE_PLAYERID, from_playerid);

            new atm_key = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_KEY);
            SetPlayerJobCollector(from_playerid, JC_ATM_KEY, atm_key);

            format(
                totalstring, sizeof totalstring, 
                "[G] Код от банкомата был передан %s [%d]", 
                GetName(from_playerid), from_playerid
            );
            JobCollector:SendLobbyMessage(lobby_id, totalstring);

            format(
                totalstring, sizeof totalstring, 
                "[Инкассация] {"#DC_WHITE"}Пин-код от банкомата - {"#DC_BANK"}%d", 
                atm_key
            );
            SendClientMessage(from_playerid, COLOR_MAIN, totalstring);
            SendClientMessage(from_playerid, COLOR_MAIN, "[Инкассация] {"#DC_WHITE"}Введите его в меню банкомата, чтобы забрать деньги");

            totalstring[0] = EOS;

            break;
        }
    }

    if(GetJobCollectorLobbyData(lobby_id, JC_LOBBY_CREATED_ID) == playerid)
    {
        new created_at_playerid = INVALID_PLAYER_ID;

        for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
        {
            created_at_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);

            if(created_at_playerid == INVALID_PLAYER_ID || created_at_playerid == playerid)
                continue;

            SetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx, INVALID_PLAYER_ID);

            break;
        }

        SetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, 0, created_at_playerid);
        SetJobCollectorLobbyData(lobby_id, JC_LOBBY_CREATED_ID, created_at_playerid);

        format(
            totalstring, sizeof totalstring, 
            "[G] Новый владелец рабочей группы %s [%d]", 
            GetName(created_at_playerid), created_at_playerid
        );
        JobCollector:SendLobbyMessage(lobby_id, totalstring);
    }
    else
    {
        if(index != INVALID_PLAYER_ID)
            SetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, index, INVALID_PLAYER_ID);
    }

    totalstring[0] = EOS;

    return true;
}

// -- Если игрок выходит из игры
stock JobCollector:OnPlayerDisconnect(playerid)
{
    JobCollector:OnPlayerLeaveAttackGroup(playerid, "Выход из игры");

    if(GetPlayerJob(playerid) != JOB_ID_COLLECTOR)
        return true;

    if(JobCollector:IsPlayerAtWorkDay(playerid))
    {
        ResetPlayerWeapons(playerid);
        DisablePlayerCheckpoint(playerid);
        SetPlayerArmour(playerid, 0.0);
        RemovePlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT);        
    }

    new lobby_id = GetPlayerJobCollector(playerid,  JC_LOBBY_ID);

    if(lobby_id != INVALID_JC_LOBBY_ID) 
        return JobCollector:OnPlayerLeaveInLobby(playerid, "Выход из игры");
    
    JobCollector:ClearPlayerData(playerid);

    return true;
}

// -- Сообщение в лобби
stock JobCollector:SendLobbyMessage(lobby_id, const message[])
{
    for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
        if(GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx) != INVALID_PLAYER_ID)
            SendClientMessage(GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx), COLOR_LOBBY_CHAT, message);

    return true;
}

DialogCreate:D_NEED_HELP(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_NEED_HELP, DIALOG_STYLE_MSGBOX,
        "{"#DC_MAIN"}Подкрепление",
        "{"#DC_WHITE"}Вы действительно хотите вызвать подкрепление?\n\
        За ложный вызов, Вы можете получить наказание",
        "Далее", "Закрыть"
    );
    return true;
}

DialogCreate:D_JC_USE_TRUNK(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_USE_TRUNK, DIALOG_STYLE_LIST,
        "{"#DC_MAIN"}Багажник",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}Положить сумку с деньгами\n\
        {"#DC_MAIN"}2. {"#DC_WHITE"}Взять сумку с деньгами",
        "Далее", "Закрыть"
    );

    return true;
}

DialogResponse:D_NEED_HELP(playerid, response, listitem, inputtext[])
{
    if(!response)
        return true;

    if(GetPlayerNeedHelpData(playerid, NH_ACTIVE) != INVALID_PLAYER_ID)
    {
        new from_playerid = GetPlayerNeedHelpData(playerid, NH_ACTIVE);
        new fraction_id = GetPlayerMember(from_playerid);
        new fraction_rank = GetPlayerRank(from_playerid);

        format(
            totalstring, sizeof totalstring, 
            "%s %s [%d] уже выехал к Вам на помощь, ожидайте", 
            GetFractionRankName(fraction_id, fraction_rank),
            GetName(from_playerid), from_playerid
        );
        SendClientMessage(playerid, COLOR_RED, totalstring);

        return true;
    }

    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return true;

    new vehicleid = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID);

    if(GetPlayerVehicleID(playerid) != vehicleid)
        return true;

    new Float:distance;

    new Float:x,
        Float:y,
        Float:z;

    GetPlayerPos(playerid, x, y, z);

    SetPlayerNeedHelpData(playerid, NH_STATE, true);
    SetPlayerNeedHelpData(playerid, NH_TYPE, NH_TYPE_POLICE);

    foreach(new i:Player)
    {
        if(!(GetPlayerMember(i) == F_POLICE || GetPlayerJob(i) == JOB_ID_COLLECTOR))
            continue;

        distance = GetPlayerDistanceFromPoint(i, x, y, z);

        format(
            totalstring, sizeof totalstring, 
            "Инкассатор %s [%d] вызывает подкрепление. Расстояние: %.1f",
            GetName(playerid), playerid, distance 
        );

        SendClientMessage(i, COLOR_RED, totalstring);

        if(GetPlayerJob(i) != JOB_ID_COLLECTOR)
            SendClientMessage(i, COLOR_RED, "Используйте команду /nhelp для принятия вызова");
    }

    totalstring[0] = EOS;

    return true;
}

DialogCreate:D_JC_EPLOYMENT(playerid)
{
    format(
        totalstring, sizeof totalstring,
        "{"#DC_MAIN"}1. {"#DC_WHITE"}%s\n\
        {"#DC_MAIN"}2. {"#DC_WHITE"}Арендовать рабочий транспорт\n\t\n\
        {"#DC_MAIN"}Информация о работе",
        GetPlayerJob(playerid) == JOB_ID_COLLECTOR ? "Уволиться с работы" : "Устроиться на работу"
    );
    Dialog_Open(
        playerid, Dialog:D_JC_EPLOYMENT, DIALOG_STYLE_TABLIST,
        "{"#DC_MAIN"}Инкассация",
        totalstring,
        "Далее", "Закрыть"
    );

    totalstring[0] = EOS;

    return true;
}

DialogCreate:D_JC_DRESSING_ROOM(playerid)
{
    if(GetPlayerJob(playerid) != JOB_ID_COLLECTOR)
        return Hud:ShowNotification(playerid, ERROR, "Вы не работаете инкассатором");

    format(
        totalstring, sizeof totalstring, 
        "{"#DC_MAIN"}1. {"#DC_WHITE"}%s рабочий день\n\t\n\
        {"#DC_MAIN"}2. {"#DC_WHITE"}Надеть бронежилет\n\
        {"#DC_MAIN"}3. {"#DC_WHITE"}Взять Desert Eagle\t{"#DC_BEIGE"}"#MAX_JC_WEAPON_AMMO_DEAGLE" пт.\n\
        {"#DC_MAIN"}4. {"#DC_WHITE"}Взять MP-5\t{"#DC_BEIGE"}"#MAX_JC_WEAPON_AMMO_MP5" пт.",
        JobCollector:IsPlayerAtWorkDay(playerid) ? "Завершить" : "Начать"
    );

    Dialog_Open(
        playerid, Dialog:D_JC_DRESSING_ROOM, DIALOG_STYLE_TABLIST,
        "{"#DC_MAIN"}Раздевалка",
        totalstring,
        "Далее", "Закрыть"
    );

    totalstring[0] = EOS;

    return true;
}

DialogCreate:D_JC_INFO(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_INFO, DIALOG_STYLE_MSGBOX,
        "{"#DC_MAIN"}Информация о работе",
        "{"#DC_WHITE"}Тут информация о работе инкассатора.",
        "Назад", "Закрыть"
    );

    return true;
}

DialogCreate:D_JC_RENT_VEHICLE(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_RENT_VEHICLE, DIALOG_STYLE_MSGBOX,
        "{"#DC_MAIN"}Аренда рабочего транспорта",
        "{"#DC_WHITE"}Стоимость аренды рабочего транспорта составляет - {"#DC_GREEN"}"#PRICE_JC_RENT_VEHICLE"$\n\
        {"#DC_WHITE"}Вы действительно собираетесь арендовать рабочий транспорт?",
        "Да", "Нет"
    );

    return true;
}

DialogCreate:D_JC_ATM_KEY_INPUT(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_ATM_KEY_INPUT, DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"}Банкомат",
        "{"#DC_WHITE"}Введите код доступа к банкомату, чтобы забрать деньги\n\n\
        {"#DC_GRAY"}Код состоит из 6-ти цифр",
        "Ввод", "Назад"
    );

    return true;
}

DialogResponse:D_JC_EPLOYMENT(playerid, response, listitem, inputtext[])
{
    if(!response)
        return true;

    switch(listitem)
    {
        case 0: JobCollector:OnPlayerEployment(playerid);
        case 1: JobCollector:OnPlayerRentVehicle(playerid);
        case 2: Dialog_Show(playerid, Dialog:D_JC_EPLOYMENT);
        case 3: Dialog_Show(playerid, Dialog:D_JC_INFO);
    }

    return true;
}

DialogResponse:D_JC_DRESSING_ROOM(playerid, response, listitem, inputtext[])
{
    if(!response)
        return true;

    switch(listitem)
    {
        case 0: // Начать/закончить рабочий день 
            JobCollector:OnPlayerWorkDay(playerid);
        
        case 1: // Раздевалка
            Dialog_Show(playerid, Dialog:D_JC_DRESSING_ROOM);
        
        case 2: // Бронежилет
        {
            if(!JobCollector:IsPlayerAtWorkDay(playerid))
                return Hud:ShowNotification(playerid, ERROR, "необходимо начать рабочий день");

            new Float:armour;
            GetPlayerArmour(playerid, armour);

            if(armour >= 100)
                return Hud:ShowNotification(playerid, ERROR, "у Вас уже есть бронежилет");

            if(GetPlayerJobCollectorArray(playerid, JC_ANTIFLOOD, JC_ITEM_ARMOUR) > gettime())
                return Hud:ShowNotification(playerid, ERROR, "брать бронежилет можно раз в "#MAX_JC_LIMIT_TIME_TAKE_ITEM" минут");

            SetPlayerArmour(playerid, 100.0);
            SetPlayerJobCollectorArray(playerid, JC_ANTIFLOOD, JC_ITEM_ARMOUR, gettime() + (MAX_JC_LIMIT_TIME_TAKE_ITEM * 60));

            Hud:ShowNotification(playerid, SUCCESS,
                "Вы успешно взяли {"#DC_BEIGE"}бронежилет"
            );

            Dialog_Show(playerid, Dialog:D_JC_DRESSING_ROOM);
        }

        case 3: // Desert Eagle
        {
            if(!JobCollector:IsPlayerAtWorkDay(playerid))
                return Hud:ShowNotification(playerid, ERROR, "необходимо начать рабочий день");

            if(!GetPlayerLicense(playerid, LICENSE_TYPE_GUN))
                return Hud:ShowNotification(playerid, ERROR, "у Вас нет лицензии на оружие");

            if(IsPlayerWeaponID(playerid, WEAPON_DEAGLE))
                return Hud:ShowNotification(playerid, ERROR, "у Вас есть данное оружие");

            if(GetPlayerJobCollectorArray(playerid, JC_ANTIFLOOD, JC_ITEM_DEAGLE) > gettime())
                return Hud:ShowNotification(playerid, ERROR, "брать оружие можно раз в "#MAX_JC_LIMIT_TIME_TAKE_ITEM" минут");

            GivePlayerWeapon(playerid, WEAPON_DEAGLE, MAX_JC_WEAPON_AMMO_DEAGLE);
            SetPlayerJobCollectorArray(playerid, JC_ANTIFLOOD, JC_ITEM_DEAGLE, gettime() + (MAX_JC_LIMIT_TIME_TAKE_ITEM * 60));

            Hud:ShowNotification(playerid, SUCCESS,
                "Вы успешно взяли {"#DC_BEIGE"}Desert Eagle {"#DC_WHITE"}с {"#DC_GRAY"}"#MAX_JC_WEAPON_AMMO_DEAGLE" пт."
            );

            Dialog_Show(playerid, Dialog:D_JC_DRESSING_ROOM);
        }

        case 4: // MP-5
        {
            if(!JobCollector:IsPlayerAtWorkDay(playerid))
                return Hud:ShowNotification(playerid, ERROR, "необходимо начать рабочий день");

            if(!GetPlayerLicense(playerid, LICENSE_TYPE_GUN))
                return Hud:ShowNotification(playerid, ERROR, "у Вас нет лицензии на оружие");

            if(IsPlayerWeaponID(playerid, WEAPON_MP5))
                return Hud:ShowNotification(playerid, ERROR, "у Вас есть данное оружие");

            if(GetPlayerJobCollectorArray(playerid, JC_ANTIFLOOD, JC_ITEM_MP5) > gettime())
                return Hud:ShowNotification(playerid, ERROR, "брать оружие можно раз в "#MAX_JC_LIMIT_TIME_TAKE_ITEM" минут");

            GivePlayerWeapon(playerid, WEAPON_MP5, MAX_JC_WEAPON_AMMO_MP5);
            SetPlayerJobCollectorArray(playerid, JC_ANTIFLOOD, JC_ITEM_MP5, gettime() + (MAX_JC_LIMIT_TIME_TAKE_ITEM * 60));
            
            Hud:ShowNotification(playerid, SUCCESS,
                "Вы успешно взяли {"#DC_BEIGE"}MP-5 {"#DC_WHITE"}с {"#DC_GRAY"}"#MAX_JC_WEAPON_AMMO_MP5" пт."
            );

            Dialog_Show(playerid, Dialog:D_JC_DRESSING_ROOM);
        }
    }

    return true;
}

DialogResponse:D_JC_INFO(playerid, response, listitem, inputtext[])
{
    if(!response)   
        return true;

    Dialog_Show(playerid, Dialog:D_JC_EPLOYMENT);

    return true;
}

DialogResponse:D_JC_RENT_VEHICLE(playerid, response, listitem, inputtext[])
{
    if(!response)
        return Dialog_Show(playerid, Dialog:D_JC_EPLOYMENT);

    if(GetPlayerCash(playerid) < PRICE_JC_RENT_VEHICLE)
        return Hud:ShowNotification(playerid, ERROR, "у Вас недостаточно средств");

    SetPlayerCash(playerid, GetPlayerCash(playerid) - PRICE_JC_RENT_VEHICLE);

    g_job_collector_veh_count--;

    new index = random_ex(0, MAX_JOB_COLLECTOR_VEHICLES_POS - 1, 1);

    new Float:x = g_job_collector_veicle_pos[index][0],
        Float:y = g_job_collector_veicle_pos[index][1],
        Float:z = g_job_collector_veicle_pos[index][2],
        Float:angle = g_job_collector_veicle_pos[index][3];

    new vehicleid = Vehicles:Create(
        MODEL_JC_VEHICLE, x, y, z, angle, 128, 128,
        .ownable_type = VEH_OWNABLE_JOB, 
        .action_type = VEH_TYPE_COLLECTOR
    );

    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return true;

    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID, vehicleid);

    new from_playerid;

    for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
    {
        from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);

        if(from_playerid == INVALID_PLAYER_ID)
            continue;

        SetPlayerInterior(from_playerid, 0);
        SetPlayerVirtualWorld(from_playerid, 0);
        PutPlayerInVehicle(from_playerid, vehicleid, idx);
    }

    format(
        totalstring, sizeof totalstring, 
        "Сумок с деньгами загружено\n\
        {"#DC_MAIN"}%d из "#MAX_JC_MONEY_BAG"",
        GetVehicleData(vehicleid, V_EXTRA)
    );

    new Text3D:text_id = CreateDynamic3DTextLabel(totalstring, COLOR_YELLOW, 0.0, 0.0, 2.0, 10.0, INVALID_PLAYER_ID, vehicleid, 1);
    
    SetVehicleData(vehicleid, V_TEXT_3D, text_id);

    SendClientMessage(playerid, COLOR_MAIN, "[Инкассация] {"#DC_WHITE"}Ваша работа заключается в обслуживании банкоматов");
    SendClientMessage(playerid, COLOR_MAIN, "[Инкассация] {"#DC_WHITE"}Чтобы найти банкомат, который необходимо обслужить, используйте {"#DC_YELLOW"}/atm");

    totalstring[0] = EOS;

    return true;
}

DialogResponse:D_JC_ATM_KEY_INPUT(playerid, response, listitem, inputtext[])
{
    if(!response)
        return Dialog_Show(playerid, Dialog:D_ATM_MENU);

    new input_password = strval(inputtext);

    if(input_password < 100000 || input_password > 999999)
    {
        Dialog_Show(playerid, Dialog:D_JC_ATM_KEY_INPUT);
        return Hud:ShowNotification(playerid, ERROR, "код должен состояить из 6-ти цифр");
    }

    if(input_password != GetPlayerJobCollector(playerid, JC_ATM_KEY))
    {
        Dialog_Show(playerid, Dialog:D_JC_ATM_KEY_INPUT);
        return Hud:ShowNotification(playerid, ERROR, "вы указали неверный код. Повторите попытку");
    }

    if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACH_IDX_BONE_ARM_RIGHT))
        return Hud:ShowNotification(playerid, ERROR, "у Вас заняты руки, Вы не можете унести сумку с деньгами");

    JobCollector:PlayerTextDrawShow(playerid);

    return true;
}

DialogResponse:D_JC_USE_TRUNK(playerid, response, listitem, inputtext[])
{
    if(!response)
        return true;

    if(GetPVarInt(playerid, PVAR_ATTACK_VEH_PUT_ID))
    {
        new vehicleid = GetPVarInt(playerid, PVAR_ATTACK_VEH_PUT_ID);
        
        switch(listitem)
        {
            case 0:
            {
                SetVehicleData(vehicleid, V_EXTRA, GetVehicleData(vehicleid, V_EXTRA) + 1);

                Hud:ShowNotification(playerid, SUCCESS, "Вы успешно положили сумку с деньгами");
                RemovePlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT);

                format(
                    totalstring, sizeof totalstring, 
                    "Сумок с деньгами загружено - {"#DC_WHITE"}%d",
                    GetVehicleData(vehicleid, V_EXTRA)
                );

                if(GetVehicleData(vehicleid, V_EXTRA) == 1)
                {
                    GetVehicleData(vehicleid, V_TEXT_3D) = CreateDynamic3DTextLabel(
                        totalstring, COLOR_MAIN, 0.0, 0.0, 0.0, 10.0, INVALID_PLAYER_ID, vehicleid, 1
                    );
                }
                else UpdateDynamic3DTextLabelText(GetVehicleData(vehicleid, V_TEXT_3D), COLOR_MAIN, totalstring);
            }
            case 1:
            {
                if(!GetVehicleData(vehicleid, V_EXTRA))
                    return Hud:ShowNotification(playerid, ERROR, "в машинет нет сумок с деньгами");

                if(IsPlayerAttachedObjectSlotUsed(playerid, 9))
                    return Hud:ShowNotification(playerid, ERROR, "Вы не сможете унести с собой больше сумок");
                    
                SetPlayerAttachedObject(
                    playerid, ATTACH_IDX_BONE_ARM_RIGHT, MODELID_JC_MONEY_BAG, BONE_ARM_RIGHT, 
                    0.190999, 0.019000, 0.000000,
                    0.000000, -92.599990, 91.599983,
                    0.263000, 0.766000, 1.011000
                );

                SetVehicleData(vehicleid, V_EXTRA, GetVehicleData(vehicleid, V_EXTRA) - 1);

                format(
                    totalstring, sizeof totalstring, 
                    "Сумок с деньгами загружено - {"#DC_WHITE"}%d",
                    GetVehicleData(vehicleid, V_EXTRA)
                );

                UpdateDynamic3DTextLabelText(GetVehicleData(vehicleid, V_TEXT_3D), COLOR_MAIN, totalstring);
            }
        }

        DeletePVar(playerid, PVAR_ATTACK_VEH_PUT_ID);

        totalstring[0] = EOS;

        return true;
    }

    if(GetPVarInt(playerid, PVAR_COLLECTOR_VEH_PUT_ID))
    {
        new vehicleid = GetPVarInt(playerid, PVAR_COLLECTOR_VEH_PUT_ID);
        new fraction_id = GetPlayerMember(playerid);
        new lobby_id;

        switch(listitem)
        {
            case 0:
            {
                if(GetVehicleData(vehicleid, V_EXTRA) == MAX_JC_MONEY_BAG && !IsAGang(playerid))
                    return SendClientMessage(playerid, COLOR_MAIN, "[Инкассация] {"#DC_WHITE"}Отвезите все собранные деньги в сейф банка");

                if(!IsPlayerAttachedObjectSlotUsed(playerid, ATTACH_IDX_BONE_ARM_RIGHT))
                    return Hud:ShowNotification(playerid, ERROR, "у Вас нет в руках сумки с деньгами");

                new modelid;
                GetPlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT, modelid);

                if(modelid != MODELID_JC_MONEY_BAG)
                    return Hud:ShowNotification(playerid, ERROR, "у Вас нет в руках сумки с деньгами");

                SetVehicleData(vehicleid, V_EXTRA, GetVehicleData(vehicleid, V_EXTRA) + 1);

                Hud:ShowNotification(playerid, SUCCESS, "Вы успешно положили сумку с деньгами");
                RemovePlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT);

                if(IsAGang(playerid))
                    return true;

                if(GetVehicleData(vehicleid, V_EXTRA) == MAX_JC_MONEY_BAG)
                {
                    JobCollector:SendLobbyMessage(lobby_id, "[G] Отвезите сумки с деньгами в банк");

                    for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
                        if(GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx) != INVALID_PLAYER_ID)
                            SetPlayerGPS(GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx), 1415.5, -1702.8, 13.5, "Банк");

                    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ACTIVE_PLAYERID, INVALID_PLAYER_ID);
                    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_ID, INVALID_ATM_ID);
                    SetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_KEY, INVALID_ATM_KEY);

                    SetPlayerJobCollector(playerid, JC_ATM_KEY, INVALID_ATM_KEY);
                }
                else 
                {
                    new from_playerid = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_CREATED_ID);
                    SendClientMessage(from_playerid, COLOR_MAIN, "[Инкассация] {"#DC_WHITE"}Чтобы найти банкомат, который необходимо обслужить, используйте {"#DC_YELLOW"}/atm");
                }
            }

            case 1:
            {
                if(!GetVehicleData(vehicleid, V_EXTRA))
                    return Hud:ShowNotification(playerid, ERROR, "в машинет нет сумок с деньгами");

                if(IsPlayerAttachedObjectSlotUsed(playerid, 9))
                    return Hud:ShowNotification(playerid, ERROR, "Вы не сможете унести с собой больше сумок");
                    
                SetPlayerAttachedObject(
                    playerid, ATTACH_IDX_BONE_ARM_RIGHT, MODELID_JC_MONEY_BAG, BONE_ARM_RIGHT, 
                    0.190999, 0.019000, 0.000000,
                    0.000000, -92.599990, 91.599983,
                    0.263000, 0.766000, 1.011000
                );

                SetVehicleData(vehicleid, V_EXTRA, GetVehicleData(vehicleid, V_EXTRA) - 1);

                if(GetVehicleData(vehicleid, V_EXTRA) == 0 && GetVehicleData(vehicleid, V_ATTACK) && IsAGang(playerid))
                {
                    lobby_id = GetJobCollectorAttackGroup(fraction_id - 7, AG_LOBBY_ID);
                    new from_playerid;

                    if(lobby_id != INVALID_JC_LOBBY_ID)
                    {
                        for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
                        {
                            from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);

                            if(from_playerid != INVALID_PLAYER_ID)
                                JobCollector:OnPlayerLeaveInLobby(from_playerid, "Ограбление");
                        }
                    }
                    Vehicles:Destroy(vehicleid);
                    g_job_collector_veh_count++;

                    SetJobCollectorAttackGroup(fraction_id - 7, AG_LIMIT, LIMIT_HOUR_ATTACK * 360);
                    SetJobCollectorAttackGroup(fraction_id - 7, AG_VEHICLEID_ATTACK, INVALID_VEHICLE_ID);
                    SetJobCollectorAttackGroup(fraction_id - 7, AG_ACTIVE_TIME, 0);
                }
            }
        }

        DeletePVar(playerid, PVAR_COLLECTOR_VEH_PUT_ID);

        format(
            totalstring, sizeof totalstring, 
            "Сумок с деньгами загружено\n\
            {"#DC_MAIN"}%d из "#MAX_JC_MONEY_BAG"",
            GetVehicleData(vehicleid, V_EXTRA)
        );

        new Text3D:text_id = GetVehicleData(vehicleid, V_TEXT_3D);
        UpdateDynamic3DTextLabelText(text_id, COLOR_YELLOW, totalstring);

        totalstring[0] = EOS;

        return true;
    }

    return true;
}

DialogCreate:D_JC_LOBBY(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_LOBBY, DIALOG_STYLE_LIST,
        "{"#DC_MAIN"}Управление рабочей группой",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}Список участников\n\
        {"#DC_MAIN"}2. {"#DC_WHITE"}Пригласить участника\n\
        {"#DC_MAIN"}3. {"#DC_WHITE"}Исключить участника",
        "Далее", "Закрыть"
    );

    return true;
}

DialogCreate:D_JC_LOBBY_LIST(playerid)
{
    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
    {
        ClearPlayerListitemData(playerid);
        return DeletePVar(playerid, PVAR_JC_LOBBY_TYPE_LIST);
    } 

    new count_players = 0;
    new name[64],
        phone_number[8];
    new from_playerid;

    format(bigstring, sizeof bigstring, "{"#DC_WHITE"}№\t{"#DC_WHITE"}Никнейм\t{"#DC_WHITE"}Навык\t{"#DC_WHITE"}Телефон\n");

    for(new idx; idx != MAX_JC_LOBBY_PLAYER; idx++)
    {
        from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, idx);
        if(from_playerid == INVALID_PLAYER_ID)
            continue;

        count_players++;

        if(from_playerid == playerid){
            format(name, sizeof name, "%s {"#DC_GREEN"}(Вы)", GetName(playerid));
        } else {
            format(name, sizeof name, "%s", GetName(from_playerid));
        }

        format(phone_number, 8, "%d", GetPlayerPhoneNumber(from_playerid));

        format(
            totalstring, sizeof totalstring,
            "{"#DC_MAIN"}%d.\t{"#DC_WHITE"}%s\t{"#DC_BEIGE"}%d\t{"#DC_GRAY"}%s\n",
            count_players,
            name,
            123,
            !GetPlayerPhoneNumber(from_playerid) ? "Отсутствует" : phone_number
        );
        strcat(bigstring, totalstring);

        if(GetPVarInt(playerid, PVAR_JC_LOBBY_TYPE_LIST) == JC_LOBBY_ROW_UNINVITE)
            SetPlayerListitemData(playerid, count_players - 1, idx);
    }

    if(GetPVarInt(playerid, PVAR_JC_LOBBY_TYPE_LIST) == JC_LOBBY_ROW_UNINVITE)
    {
        Dialog_Open(
            playerid, Dialog:D_JC_LOBBY_LIST, DIALOG_STYLE_TABLIST_HEADERS,
            "{"#DC_MAIN"}Исключение участника",
            bigstring,
            "Выбрать", "Назад"
        );
    }
    else
    {
        Dialog_Open(
            playerid, Dialog:D_JC_LOBBY_LIST, DIALOG_STYLE_TABLIST_HEADERS,
            "{"#DC_MAIN"}Список участников",
            bigstring,
            "Назад", "Закрыть"
        );
    }

    totalstring[0] = EOS;
    bigstring[0] = EOS;

    return true;
}

DialogCreate:D_JC_LOBBY_INVITE(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_LOBBY_INVITE, DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"}Пригласить участника",
        "{"#DC_WHITE"}Введите ID игрока, которого хотите пригласить",
        "Далее", "Назад"
    );

    return true;
}

DialogResponse:D_JC_LOBBY_LIST(playerid, response, listitem, inputtext[])
{
    if(!response)
    {
        if(GetPVarInt(playerid, PVAR_JC_LOBBY_TYPE_LIST) == JC_LOBBY_ROW_UNINVITE)
            return Dialog_Show(playerid, Dialog:D_JC_LOBBY);

        return true;
    }

    if(GetPVarInt(playerid, PVAR_JC_LOBBY_TYPE_LIST) != JC_LOBBY_ROW_UNINVITE)
        return Dialog_Show(playerid, Dialog:D_JC_LOBBY);

    new index = GetPlayerListitemData(playerid, listitem);

    ClearPlayerListitemData(playerid);
    DeletePVar(playerid, PVAR_JC_LOBBY_TYPE_LIST);

    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);
    new from_playerid = GetJobCollectorLobbyDataArray(lobby_id, JC_LOBBY_PLAYERID, index);

    if(from_playerid == playerid)
        return Hud:ShowNotification(playerid, ERROR, "Вы не можете исключить самого себя");

    if(from_playerid == INVALID_PLAYER_ID)
        return Hud:ShowNotification(playerid, ERROR, "данный игрок не состоит в лобби");

    format(
        totalstring, sizeof totalstring,
        "Вы успешно исключили игрока {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}из своей рабочей группы",
        GetName(from_playerid), from_playerid
    );
    SendClientMessage(playerid, COLOR_WHITE, totalstring);

    format(
        totalstring, sizeof totalstring,
        "Игрок {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}исключил Вас из своей рабочей группы",
        GetName(playerid), playerid
    );
    SendClientMessage(from_playerid, COLOR_WHITE, totalstring);

    JobCollector:OnPlayerLeaveInLobby(from_playerid, "Исключен");

    totalstring[0] = EOS;

    return true;
}

DialogResponse:D_JC_LOBBY(playerid, response, listitem, inputtext[])
{
    if(!response)
    {
        ClearPlayerListitemData(playerid);
        return DeletePVar(playerid, PVAR_JC_LOBBY_TYPE_LIST);
    } 

    if(GetPlayerJobCollector(playerid, JC_LOBBY_ID) == INVALID_JC_LOBBY_ID)
    {
        ClearPlayerListitemData(playerid);
        return DeletePVar(playerid, PVAR_JC_LOBBY_TYPE_LIST);
    } 

    if(listitem == JC_LOBBY_ROW_INVITE)
        return Dialog_Show(playerid, Dialog:D_JC_LOBBY_INVITE);

    SetPVarInt(playerid, PVAR_JC_LOBBY_TYPE_LIST, listitem);
    Dialog_Show(playerid, Dialog:D_JC_LOBBY_LIST);

    return true;
}

DialogResponse:D_JC_LOBBY_INVITE(playerid, response, listitem, inputtext[])
{
    if(!response)
        return Dialog_Show(playerid, Dialog:D_JC_LOBBY);

    if(strval(inputtext) < 0 || strval(inputtext) > MAX_PLAYERS)
    {
        Dialog_Show(playerid, Dialog:D_JC_LOBBY_INVITE);
        return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
    }

    callcmd::jinvite(playerid, inputtext);

    return true;
}

cmd:atm(playerid)
{
    if(GetPlayerJob(playerid) != JOB_ID_COLLECTOR)
        return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    if(!JobCollector:IsPlayerAtWorkDay(playerid))
        return Hud:ShowNotification(playerid, ERROR, "необходимо выйти на рабочий день");

    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return Hud:ShowNotification(playerid, ERROR, "необходимо найти напарника для работы");

    if(GetJobCollectorLobbyData(lobby_id, JC_LOBBY_CREATED_ID) != playerid)
        return Hud:ShowNotification(playerid, ERROR, "искать банкомат может только владелец рабочей группы");

    new vehicleid = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID);

    if(!(vehicleid != INVALID_VEHICLE_ID && GetPlayerVehicleID(playerid) == vehicleid))
        return Hud:ShowNotification(playerid, ERROR, "доступно только в рабочем транспорте");

    if(GetJobCollectorLobbyData(lobby_id, JC_LOBBY_ATM_ID) != INVALID_ATM_ID)
        return Hud:ShowNotification(playerid, ERROR, "за Вашей рабоче группой уже закреплен банкомат, который Вы должны обслужить");

    if(GetVehicleData(vehicleid, V_EXTRA) >= MAX_JC_MONEY_BAG)
        return Hud:ShowNotification(playerid, ERROR, "отвезите загруженные сумки с деньгами в Банк");

    JobCollector:SetPlayerCheckpoint(playerid);

    return CMD_RESULT_SUCCESS;
}

cmd:j(playerid, params[])
{
    if(GetPlayerJob(playerid) != JOB_ID_COLLECTOR)
        return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    if(sscanf(params, "s[128]", params[0]))
        return SendClientMessage(playerid, COLOR_MAIN, "Используйте: {"#DC_WHITE"}/j [Текст]");

    format(
        totalstring, sizeof totalstring, 
        "[J] Инкассатор %s [%d]: %s", 
        GetName(playerid), playerid, params[0]
    );

    foreach(new i:Player)
        if(GetPlayerJob(i) == JOB_ID_COLLECTOR)
            SendClientMessage(i, COLOR_JOB_CHAT, totalstring);

    totalstring[0] = EOS;

    return CMD_RESULT_SUCCESS;
}

cmd:jb(playerid, params[])
{
    if(GetPlayerJob(playerid) != JOB_ID_COLLECTOR)
        return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    if(sscanf(params, "s[128]", params[0]))
        return SendClientMessage(playerid, COLOR_MAIN, "Используйте: {"#DC_WHITE"}/jb [NonRP текст]");

    format(
        totalstring, sizeof totalstring, 
        "(( [JB] Инкассатор %s [%d]: %s ))", 
        GetName(playerid), playerid, params[0]
    );

    foreach(new i:Player)
        if(GetPlayerJob(i) == JOB_ID_COLLECTOR)
            SendClientMessage(i, COLOR_JOB_CHAT, totalstring);

    totalstring[0] = EOS;

    return CMD_RESULT_SUCCESS;
}

cmd:jinvite(playerid, params[])
{
    if(GetPlayerJob(playerid) != JOB_ID_COLLECTOR)
        return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    if(!JobCollector:IsPlayerAtWorkDay(playerid))
        return Hud:ShowNotification(playerid, ERROR, "необходимо начать рабочий день");

    if(sscanf(params, "d", params[0]))
        return SendClientMessage(playerid, COLOR_MAIN, "Используйте: {"#DC_WHITE"}/jinvite [ID игрока]");

    if(!IsPlayerConnected(params[0]) || !IsPlayerLogged(params[0]))
        return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);

    if(!IsPlayerInRangeOfPlayer(2.0, playerid, params[0]))
        return Hud:ShowNotification(playerid, ERROR, "данный игрок далеко от Вас");

    if(playerid == params[0])
        return Hud:ShowNotification(playerid, ERROR, "Вы не можете пригласить самого себя");

    if(GetPlayerJob(params[0]) != JOB_ID_COLLECTOR)
        return Hud:ShowNotification(playerid, ERROR, "данный игрок не работает инкассатором");

    if(!JobCollector:IsPlayerAtWorkDay(params[0]))
        return Hud:ShowNotification(playerid, ERROR, "данный игрок не находится на рабочем дне");

    if(JobCollector:IsPlayerInivtedLobby(playerid))
        return Hud:ShowNotification(playerid, ERROR, "Вы можете приглашать игроков, только в свою группу");

    if(GetPlayerJobCollector(params[0], JC_LOBBY_ID) != INVALID_JC_LOBBY_ID)
        return Hud:ShowNotification(playerid, ERROR, "игрок уже состоит в группе");

    new lobby_id;

    if(GetPlayerJobCollector(playerid, JC_LOBBY_ID) != INVALID_JC_LOBBY_ID) {
        lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);
    } else {
        lobby_id = JobCollector:GetFreeLobbyID();
    }

    if(g_job_collector_veh_count == 0)
        return Hud:ShowNotification(playerid, ERROR, "Вы не можете создать свою группу, т.к. нет свободного транспорта");

    new players_in_lobby = JobCollector:GetPlayersInLobby(lobby_id);

    if(players_in_lobby >= MAX_JC_LOBBY_PLAYER)
        return Hud:ShowNotification(playerid, ERROR, "в группе максимальное количество участников");

    if(!Player_CreateProposalToPlayer(playerid, params[0], PROPOSAL_JC_LOBBY_ID)) 
        return true;

    SetPVarInt(params[0], PVAR_JC_LOBBY_ID, lobby_id);

    format(
        totalstring, sizeof totalstring,
        "Игрок {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}предлагает Вам присоединиться к {"#DC_BEIGE"}группе для совместной работы",
        GetName(playerid), playerid
    );
    SendClientMessage(params[0], COLOR_WHITE, totalstring);
    SendClientMessage(params[0], COLOR_WHITE, PROPOSAL_TEXT);

    format(
        totalstring, sizeof totalstring,
        "Вы предложили {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}присоединиться к группе для совместной работы",
        GetName(params[0]), params[0]
    );
    SendClientMessage(playerid, COLOR_WHITE, totalstring);

    return CMD_RESULT_SUCCESS;
}

cmd:jgroup(playerid)
{
    if(GetPlayerJob(playerid) != JOB_ID_COLLECTOR)
        return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    if(!JobCollector:IsPlayerAtWorkDay(playerid))
        return Hud:ShowNotification(playerid, ERROR, "необходимо выйти на рабочий день");

    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID || GetJobCollectorLobbyData(lobby_id, JC_LOBBY_CREATED_ID) != playerid)
        return Hud:ShowNotification(playerid, ERROR, "Вы можете управлять только личной группой");

    Dialog_Show(playerid, Dialog:D_JC_LOBBY);

    return CMD_RESULT_SUCCESS;
}

cmd:g(playerid, params[])
{
    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    if(sscanf(params, "s[128]", params[0]))
        return SendClientMessage(playerid, COLOR_MAIN, "Используйте: {"#DC_WHITE"}/g [Текст]");

    format(
        totalstring, sizeof totalstring, 
        "[G] Инкассатор %s [%d]: %s", 
        GetName(playerid), playerid, params[0]
    );

    JobCollector:SendLobbyMessage(lobby_id, totalstring);

    totalstring[0] = EOS;

    return CMD_RESULT_SUCCESS;
}

cmd:gb(playerid, params[])
{
    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);

    if(lobby_id == INVALID_JC_LOBBY_ID)
        return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    if(sscanf(params, "s[128]", params[0]))
        return SendClientMessage(playerid, COLOR_MAIN, "Используйте: {"#DC_WHITE"}/gb [NonRP текст]");

    format(
        totalstring, sizeof totalstring, 
        "(( [GB] Инкассатор %s [%d]: %s ))", 
        GetName(playerid), playerid, params[0]
    );

    JobCollector:SendLobbyMessage(lobby_id, totalstring);

    totalstring[0] = EOS;

    return CMD_RESULT_SUCCESS;
}

/*
    -----       -----       -----       -----       -----       -----

    * Нападение на инкассаторов

    -----       -----       -----       -----       -----       -----
*/

// -- Обновляем метку инкассаторов
forward JobCollector:UpdatePosLobbyAttackGroup(fraction_id);
public JobCollector:UpdatePosLobbyAttackGroup(fraction_id)
{
    if(!GetJobCollectorAttackGroup(fraction_id - 7, AG_ACTIVE_TIME))
        return true;

    new lobby_id = GetJobCollectorAttackGroup(fraction_id - 7, AG_LOBBY_ID);
    new vehicleid = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID);
    new vehicle_gang = GetJobCollectorAttackGroup(fraction_id - 7, AG_VEHICLEID_ATTACK);

    if(vehicleid == INVALID_VEHICLE_ID && vehicle_gang == INVALID_VEHICLE_ID)
    {
        JobCollector:SendAttackGroupMessage(fraction_id, "К сожалению, больше невозможно определить местонахождение инкассаторов");
        JobCollector:DisbandAttackGroup(fraction_id, "Неудачная попытка ограбления");

        return true;
    }

    new Float:lobby_pos[3];
    new from_playerid;

    GetVehiclePos(vehicleid, lobby_pos[0], lobby_pos[1], lobby_pos[2]);

    for(new idx; idx != MAX_JC_ATTACK_PLAYERS; idx++)
    {
        from_playerid = GetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, idx);

        if(from_playerid == INVALID_PLAYER_ID)
            continue;

        SetPlayerCheckpoint(from_playerid, lobby_pos[0], lobby_pos[1], lobby_pos[2], 5.0);
        SendClientMessage(from_playerid, COLOR_MAIN, "[Информация] {"#DC_WHITE"}Местоположение инкассаторов обновилось");
    }       

    GetJobCollectorAttackGroup(fraction_id - 7, AG_TIMER) = SetTimerEx(
        JobCollectorText(JobCollector:UpdatePosLobbyAttackGroup), 1000 * 60, false, "d", fraction_id
    );

    return true;
}

// -- Узнаем стоит ли лимит на ограбление у организации
stock JobCollector:IsFractionLimitAttack(fraction_id)
    return (GetJobCollectorAttackGroup(fraction_id - 7, AG_LIMIT));

// -- Узанем сколько игроков находятся в группе для ограбления
stock JobCollector:GetMaxPlayersInAttackGroup(fraction_id)
{
    new count_players;

    for(new idx; idx != MAX_JC_ATTACK_PLAYERS; idx++)
        if(GetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, idx) != INVALID_PLAYER_ID)
            count_players++;

    return count_players;
}

// -- Узнаем состоит ли игрок в группе нападения
stock JobCollector:GetPlayerInvitedAttackGroup(playerid, fraction_id)
{
    if(!fraction_id)
        return INVALID_PLAYER_ID;

    for(new idx; idx != MAX_JC_ATTACK_PLAYERS; idx++)
        if(GetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, idx) == playerid)
            return idx;

    return INVALID_PLAYER_ID;
}

// -- Ищем свободный слот для принятия игрока
stock JobCollector:GetFreeIndexAttackGroup(fraction_id)
{
    for(new idx; idx != MAX_JC_ATTACK_PLAYERS; idx++)
        if(GetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, idx) == INVALID_PLAYER_ID)
            return idx;

    return INVALID_PLAYER_ID;
}

// -- Взаимодействие с бывшем работником банка
stock JobCollector:ActiveOldWorkerBank(playerid)
{
    if(!IsAGang(playerid))
        return true;

    Dialog_Show(playerid, Dialog:D_JC_ATTACK_ACTOR);

    return true;
}

// -- Выбираем рандомную группу инкассаторов
stock JobCollector:GetRandomLobby()
{
    new count_lobby = -1;
    new lobyy_id[MAX_JC_LOBBY];
    new index_lobby = INVALID_JC_LOBBY_ID;

    for(new idx; idx != MAX_JC_LOBBY; idx++)
    {
        if(GetJobCollectorLobbyData(idx, JC_LOBBY_VEHICLEID) == INVALID_VEHICLE_ID)
            continue;

        if(count_lobby == -1)
            count_lobby = 0;

        lobyy_id[count_lobby] = idx;

        count_lobby++;
    }

    if(count_lobby == -1)
        return INVALID_JC_LOBBY_ID;

    new index_random = random_ex(0, count_lobby, 1);

    index_lobby = lobyy_id[index_random];

    return index_lobby;
}

// -- Расформировать группу
stock JobCollector:DisbandAttackGroup(fraction_id, const reason[])
{
    format(
        totalstring, sizeof totalstring, 
        "Группа нападений была расформирована. Причина: %s", 
        reason
    );
    JobCollector:SendAttackGroupMessage(fraction_id, totalstring);

    totalstring[0] = EOS;

    new from_playerid;

    for(new idx; idx != MAX_JC_ATTACK_PLAYERS; idx++)
    {
        from_playerid = GetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, idx);

        if(from_playerid == INVALID_PLAYER_ID)
            continue;

        SetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, idx, INVALID_PLAYER_ID);
        DisablePlayerCheckpoint(from_playerid);
    }

    KillTimer(GetJobCollectorAttackGroup(fraction_id - 7, AG_TIMER));

    new vehicleid = GetJobCollectorAttackGroup(fraction_id - 7, AG_VEHICLEID);
    Vehicles:Destroy(vehicleid);

    SetJobCollectorAttackGroup(fraction_id - 7, AG_TIMER, INVALID_TIMER);
    SetJobCollectorAttackGroup(fraction_id - 7, AG_ACTIVE_TIME, 0);
    SetJobCollectorAttackGroup(fraction_id - 7, AG_VEHICLEID, INVALID_VEHICLE_ID);
    SetJobCollectorAttackGroup(fraction_id - 7, AG_VEHICLEID_ATTACK, INVALID_VEHICLE_ID);

    return true;
}

// -- Обновление времени группы для атаки
stock JobCollector:UpdateTimeGroup()
{
    new limit,
        active_time,
        from_playerid;

    for(new idx; idx != MAX_GANG_FRACTION; idx++)
    {
        limit = GetJobCollectorAttackGroup(idx, AG_LIMIT);
        active_time = GetJobCollectorAttackGroup(idx, AG_ACTIVE_TIME);

        if(limit != 0)
            SetJobCollectorAttackGroup(idx, AG_LIMIT, limit - 1);

        if(active_time != 0)
        {
            SetJobCollectorAttackGroup(idx, AG_ACTIVE_TIME, active_time - 1);

            for(new idx_f; idx_f != MAX_JC_ATTACK_PLAYERS; idx_f++)
            {
                from_playerid = GetJobCollectorAttackGroupArray(idx, AG_PLAYERS, idx_f);

                if(from_playerid == INVALID_PLAYER_ID)
                    continue;

                format(
                    totalstring, sizeof totalstring, 
                    "%d SEC", 
                    active_time - 1
                );
                GameTextForPlayer(from_playerid, totalstring, 990, 4);
            }

            if(active_time - 1 == 0)
                JobCollector:DisbandAttackGroup(idx + 7, "Время нападения вышло");
        }
    }

    totalstring[0] = EOS;
}

// -- Чат для группы нападений
stock JobCollector:SendAttackGroupMessage(fraction_id, const message[])
{
    new from_playerid;

    for(new idx; idx != MAX_JC_ATTACK_PLAYERS; idx++)
    {
        from_playerid = GetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, idx);

        if(from_playerid != INVALID_PLAYER_ID)
            SendClientMessage(from_playerid, 0x73DBD9FF, message);
    }

    return true;
}

// -- Игрок покидает группу нападений
stock JobCollector:OnPlayerLeaveAttackGroup(playerid, const reason[])
{
    new fraction_id = GetPlayerMember(playerid),
        fraction_rank = GetPlayerRank(playerid);

    new index = JobCollector:GetPlayerInvitedAttackGroup(playerid, fraction_id);

    if(index == INVALID_PLAYER_ID)
        return true;

    SetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, index, INVALID_PLAYER_ID);
    DisablePlayerCheckpoint(playerid);

    format(
        totalstring, sizeof totalstring, 
        "%s %s [%d] покинул группу нападений. Причина: %s", 
        GetFractionRankName(fraction_id, fraction_rank),
        GetName(playerid), playerid, 
        reason
    );
    JobCollector:SendAttackGroupMessage(fraction_id, totalstring);
    JobCollector:UpdateAttackGroup(fraction_id);

    return true;
}

// -- Обновление группы нападений
stock JobCollector:UpdateAttackGroup(fraction_id)
{
    if(JobCollector:GetMaxPlayersInAttackGroup(fraction_id) >= MIN_JC_ATTACK_PLAYERS)
        return true;

    JobCollector:DisbandAttackGroup(fraction_id, "Недостаточно участников");

    return true;
}

// -- Игрок умер
stock JobCollector:OnPlayerDeath(playerid, killerid)
{
    if(GetPlayerJobCollector(playerid, JC_LOBBY_ID) == INVALID_JC_LOBBY_ID)
        return true;

    if(!IsAGang(killerid))
        return true;

    new lobby_id = GetPlayerJobCollector(playerid, JC_LOBBY_ID);
    new fraction_id = GetPlayerMember(killerid);

    if(GetJobCollectorAttackGroup(fraction_id - 7, AG_ACTIVE_TIME) == 0)
        return true;

    if(GetJobCollectorAttackGroup(fraction_id - 7, AG_LOBBY_ID) != lobby_id)
        return true;

    if(JobCollector:GetPlayerInvitedAttackGroup(killerid, fraction_id) == INVALID_PLAYER_ID)
        return true;

    if(GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID) == INVALID_VEHICLE_ID)
        return true;

    new vehicleid = GetJobCollectorLobbyData(lobby_id, JC_LOBBY_VEHICLEID);

    if(vehicleid == INVALID_VEHICLE_ID)
        return true;
    
    SetVehicleData(vehicleid, V_ATTACK, fraction_id);
    SetJobCollectorAttackGroup(fraction_id - 7, AG_VEHICLEID_ATTACK, vehicleid);

    JobCollector:SendAttackGroupMessage(fraction_id, "Был убит сотрудник инкассации, теперь вы можете открыть кузов");
    
    return true;
}

cmd:ginvite(playerid, params[])
{
    if(!IsAGang(playerid))
        return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    if(!PrivilegeFrac(playerid, 2)) 
		return Hud:ShowNotification(playerid, ERROR, "доступно только лидеру/заместителю");

    new fraction_id = GetPlayerMember(playerid);

    if(JobCollector:IsFractionLimitAttack(fraction_id))
        return Hud:ShowNotification(playerid, ERROR, "с момента успешного нападения еще не прошло "#LIMIT_HOUR_ATTACK" часа");

    if(JobCollector:GetMaxPlayersInAttackGroup(fraction_id) >= MAX_JC_ATTACK_PLAYERS)
        return Hud:ShowNotification(playerid, ERROR, "уже набрано максимальное количество участников");

    if(sscanf(params, "d", params[0]))
        return SendClientMessage(playerid, COLOR_MAIN, "Используйте: {"#DC_WHITE"}/ginvite [ID игрока]");

    if(!IsPlayerConnected(params[0]) || !IsPlayerLogged(params[0]))
        return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);

    if(playerid == params[0])
        return Hud:ShowNotification(playerid, ERROR, "Вы не можете принять самого себя");

    if(!IsPlayerInRangeOfPlayer(2.0, playerid, params[0]))
        return Hud:ShowNotification(playerid, ERROR, "данный игрок далеко от Вас");

    if(GetPlayerMember(params[0]) != fraction_id)
        return Hud:ShowNotification(playerid, ERROR, "данный игрок не состоит в Вашей организации");

    if(JobCollector:GetPlayerInvitedAttackGroup(params[0], fraction_id) != INVALID_PLAYER_ID)
        return Hud:ShowNotification(playerid, ERROR, "игрок уже состит в Вашей группе нападения");
    if(!Player_CreateProposalToPlayer(playerid, params[0], PROPOSAL_JC_ATTACK_GROUP))
        return true;

    new fraction_rank = GetPlayerRank(playerid);

    format(
        totalstring, sizeof totalstring,
        "%s {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}предлагает Вам присоединиться к {"#DC_BEIGE"}группе нападения",
        GetFractionRankName(fraction_id, fraction_rank),
        GetName(playerid), playerid
    );
    SendClientMessage(params[0], COLOR_WHITE, totalstring);
    SendClientMessage(params[0], COLOR_WHITE, PROPOSAL_TEXT);

    format(
        totalstring, sizeof totalstring,
        "Вы предложили {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}присоединиться к группе нападения",
        GetName(params[0]), params[0]
    );
    SendClientMessage(playerid, COLOR_WHITE, totalstring);

    totalstring[0] = EOS;

    return CMD_RESULT_SUCCESS;
}

cmd:gmenu(playerid)
{
    if(!IsAGang(playerid))
        return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    if(!PrivilegeFrac(playerid, 2)) 
		return Hud:ShowNotification(playerid, ERROR, "доступно только лидеру/заместителю");

    Dialog_Show(playerid, Dialog:D_JC_ATTACK_MENU);

    return true;
}

DialogCreate:D_JC_ATTACK_MENU(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_ATTACK_MENU, DIALOG_STYLE_LIST,
        "{"#DC_MAIN"}Управление группой нападения",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}Список участников\n\
        {"#DC_MAIN"}2. {"#DC_WHITE"}Пригласить участника\n\
        {"#DC_MAIN"}3. {"#DC_WHITE"}Исключить участника\n\
        {"#DC_MAIN"}4. {"#DC_WHITE"}Расформировать группу",
        "Далее", "Закрыть"
    );

    return true;
}

DialogCreate:D_JC_ATTACK_LIST(playerid)
{
    new is_uninvite = GetPVarInt(playerid, PVAR_SELECT_ROW_UNINVITE);

    new fraction_id = GetPlayerMember(playerid),
        fraction_rank,
        from_playerid,
        count_players;

    new name[64],
        phone_number[8];

    format(bigstring, sizeof bigstring, "{"#DC_WHITE"}№ Никнейм\t{"#DC_WHITE"}Ранг\t{"#DC_WHITE"}Телефон\n");

    for(new idx; idx != MAX_JC_ATTACK_PLAYERS; idx++)
    {
        from_playerid = GetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, idx);

        if(from_playerid == INVALID_PLAYER_ID)
            continue;

        if(from_playerid == playerid) format(name, sizeof name, "%s {"#DC_GREEN"}(Вы)", GetName(from_playerid));
        else format(name, sizeof name, "%s", GetName(from_playerid));

        fraction_rank = GetPlayerRank(from_playerid);

        format(phone_number, 8, "%d", GetPlayerPhoneNumber(from_playerid));

        format(
            totalstring, sizeof totalstring, 
            "{"#DC_MAIN"}%d. {"#DC_WHITE"}%s\t{"#DC_BEIGE"}%s {"#DC_GREY"}(%d)\t{"#DC_GRAY"}%d\n",
            count_players + 1,
            name,
            GetFractionRankName(fraction_id, fraction_rank), fraction_rank,
            !GetPlayerPhoneNumber(from_playerid) ? "Отсутствует" : phone_number
        );
        strcat(bigstring, totalstring);

        if(is_uninvite)
            SetPlayerListitemData(playerid, count_players, idx);

        count_players++;
    }

    Dialog_Open(
        playerid, Dialog:D_JC_ATTACK_LIST, DIALOG_STYLE_TABLIST_HEADERS,
        is_uninvite ? "{"#DC_MAIN"}Исключить участника" : "{"#DC_MAIN"}Список участников",
        bigstring,
        is_uninvite ? "Далее" : "Назад", 
        is_uninvite ? "Назад" : "Закрыть"
    );

    totalstring[0] = EOS;
    bigstring[0] = EOS;

    return true;
}

DialogCreate:D_JC_ATTACK_INVITE(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_ATTACK_INVITE, DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"}Пригласить участника",
        "{"#DC_WHITE"}Введите ID игрока, которого хотите принять в группу нападений:",
        "Далее", "Назад"
    );

    return true;
}

DialogCreate:D_JC_ATTACK_BUY(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_ATTACK_BUY, DIALOG_STYLE_MSGBOX,
        "{"#DC_MAIN"}Покупка наводки",
        "{"#DC_WHITE"}Ватсап, давно не виделись! Меня уволили эти сволочи, просекли, видать,\n\
        мои финансовые схемы, хе-х. В общем, ближе к делу: у меня есть актуальный план работы\n\
        наших инкассаторов и, собравшись с пацанами, вы без проблем сможете поработать с ними,\n\
        если ты сечешь, о чем я\n\n\
        Когда закончите дело, все бабки можете слить мне, я знаю, что с ними делать и щедро отблагодарю вас\n\
        За помощь я попрошу не так много: каких-то пару купюр зелени. Уверен, для вас это не бабки!",
        "Далее", "Закрыть"
    );
    return true;
}


DialogCreate:D_JC_ATTACK_ACTOR(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_JC_ATTACK_ACTOR, DIALOG_STYLE_LIST,
        "{"#DC_MAIN"}Бывший работник банка",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}Покупка наводки\n\
        {"#DC_MAIN"}2. {"#DC_WHITE"}Сдать сумку с деньгами",
        "Выбрать", "Закрыть"
    );
    return true;
}

DialogResponse:D_JC_ATTACK_ACTOR(playerid, response, listitem, inputtext[])
{
    if(!response)
        return true;

    switch(listitem)
    {
        case 0:
        {
            if(!PrivilegeFrac(playerid, 2))
                return Hud:ShowNotification(playerid, ERROR, "доступно только лидеру/заместителю");

            Dialog_Show(playerid, Dialog:D_JC_ATTACK_BUY);
        }
        case 1:
        {
            if(!IsPlayerAttachedObjectSlotUsed(playerid, ATTACH_IDX_BONE_ARM_RIGHT))
                return Hud:ShowNotification(playerid, ERROR, "у Вас нет в руках сумки с деньгами");

            new modelid;
            GetPlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT, modelid);
        
            if(modelid != MODELID_JC_MONEY_BAG)
                return Hud:ShowNotification(playerid, ERROR, "у Вас нет в руках сумки с деньгами");

            new from_playerid,
                fraction_id = GetPlayerMember(playerid),
                count_players = JobCollector:GetMaxPlayersInAttackGroup(fraction_id),
                money = MONEY_JC_ATTACK / count_players;

            format(
                totalstring, sizeof totalstring, 
                "Каждый получил по %d$ за разгрузку сумки", 
                money
            );

            for(new idx; idx != MAX_JC_ATTACK_PLAYERS; idx++)
            {
                from_playerid = GetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, idx);

                if(from_playerid == INVALID_PLAYER_ID)
                    continue;

                SetPlayerCash(from_playerid, GetPlayerCash(from_playerid) + money);

                SendClientMessage(from_playerid, COLOR_LOBBY_CHAT, totalstring);
            }

            RemovePlayerAttachedObject(playerid, ATTACH_IDX_BONE_ARM_RIGHT);
        }
    }

    totalstring[0] = EOS;

    return true;
}

DialogResponse:D_JC_ATTACK_MENU(playerid, response, listitem, inputtext[])
{
    if(!response)
    {
        DeletePVar(playerid, PVAR_SELECT_ROW_UNINVITE);
        return ClearPlayerListitemData(playerid);
    }

    switch(listitem)
    {
        case 0: Dialog_Show(playerid, Dialog:D_JC_ATTACK_LIST);
        case 1: Dialog_Show(playerid, Dialog:D_JC_ATTACK_INVITE);
        case 2:
        {
            SetPVarInt(playerid, PVAR_SELECT_ROW_UNINVITE, 1);
            Dialog_Show(playerid, Dialog:D_JC_ATTACK_LIST);
        }
        case 3: JobCollector:DisbandAttackGroup(GetPlayerMember(playerid), "Приказ лидера/заместителя");
    }
    
    return true;
}

DialogResponse:D_JC_ATTACK_LIST(playerid, response, listitem, inputtext[])
{
    new is_uninvite = GetPVarInt(playerid, PVAR_SELECT_ROW_UNINVITE);

    if(!response)
    {
        if(is_uninvite)
            Dialog_Show(playerid, Dialog:D_JC_ATTACK_MENU);

        return true;
    }
    
    if(!is_uninvite)
        return Dialog_Show(playerid, Dialog:D_JC_ATTACK_MENU);

    new index = GetPlayerListitemData(playerid, listitem);
    new fraction_id = GetPlayerMember(playerid),
        fraction_rank = GetPlayerRank(playerid);

    ClearPlayerListitemData(playerid);
    DeletePVar(playerid, PVAR_SELECT_ROW_UNINVITE);

    new from_playerid = GetJobCollectorAttackGroupArray(fraction_id - 7, AG_PLAYERS, index);

    if(from_playerid == playerid)
        return Hud:ShowNotification(playerid, ERROR, "Вы не можете исключить самого себя");

    JobCollector:OnPlayerLeaveAttackGroup(from_playerid, "Исключен");

    format(
        totalstring, sizeof totalstring, 
        "%s {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}исключил Вас из {"#DC_BEIGE"}группы нападения", 
        GetFractionRankName(fraction_id, fraction_rank),
        GetName(playerid), playerid
    );
    SendClientMessage(from_playerid, COLOR_WHITE, totalstring);

    format(
        totalstring, sizeof totalstring, 
        "Вы успешно исключили {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}из {"#DC_BEIGE"}группы нападения", 
        GetName(from_playerid), from_playerid
    );
    SendClientMessage(playerid, COLOR_WHITE, totalstring);

    totalstring[0] = EOS;

    return true;
}

DialogResponse:D_JC_ATTACK_BUY(playerid, response, listitem, inputtext[])
{
    if(!response)
        return Dialog_Show(playerid, Dialog:D_JC_ATTACK_ACTOR);

    new fraction_id = GetPlayerMember(playerid);

    if(JobCollector:GetMaxPlayersInAttackGroup(fraction_id) < MIN_JC_ATTACK_PLAYERS)
        return Hud:ShowNotification(playerid, ERROR, "в Вашей группе нападения слишком мало участников (Минимум - "#MIN_JC_ATTACK_PLAYERS")");

    if(GetJobCollectorAttackGroup(fraction_id - 7, AG_LIMIT_BUY))
        return Hud:ShowNotification(playerid, ERROR, "покупать наводку можно раз в "#TIME_BUY_SPECTATE" минут");

    if(GetPlayerCash(playerid) < PRICE_ATTACK_BUY)
        return Hud:ShowNotification(playerid, ERROR, "у Вас недостаточно средств");

    new index_jc_lobby = JobCollector:GetRandomLobby();

    if(index_jc_lobby == INVALID_JC_LOBBY_ID)
        return Hud:ShowNotification(playerid, ERROR, "в данный момент нет информации");

    SetPlayerCash(playerid, GetPlayerCash(playerid) - PRICE_ATTACK_BUY);

    SetJobCollectorAttackGroup(fraction_id - 7, AG_LOBBY_ID, index_jc_lobby);
    SetJobCollectorAttackGroup(fraction_id - 7, AG_ACTIVE_TIME, TIME_SPECTATE * 60);
    SetJobCollectorAttackGroup(fraction_id - 7, AG_LIMIT_BUY, TIME_BUY_SPECTATE * 60);
    
    JobCollector:UpdatePosLobbyAttackGroup(fraction_id);

    return true;
}

DialogResponse:D_JC_ATTACK_INVITE(playerid, response, listitem, inputtext[])
{
    if(!response)
        return Dialog_Show(playerid, Dialog:D_JC_ATTACK_MENU);

    if(strval(inputtext) < 0 || strval(inputtext) > MAX_PLAYERS)
    {
        Dialog_Show(playerid, Dialog:D_JC_ATTACK_INVITE);
        return Hud:ShowNotification(playerid, ERROR, "игрока с таким ID не существует");
    }

    callcmd::ginvite(playerid, inputtext);

    return true;
}