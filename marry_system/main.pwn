// -- Инициализация системы
stock MarrySystem:Init()
{
    for(new idx; idx != MAX_MARRY_ACTORS; idx++)
    {
        g_marry_actors[idx][M_ACTOR_ID] = Actors:Create(
            g_marry_actors[idx][M_ACTOR_SKIN], 
            g_marry_actors[idx][M_ACTOR_X],
            g_marry_actors[idx][M_ACTOR_Y],
            g_marry_actors[idx][M_ACTOR_Z],
            g_marry_actors[idx][M_ACTOR_ANGLE],
            MARRY_WORLD_ID, MARRY_INTERIOR_ID,
            g_marry_actors[idx][M_ACTOR_ACTION_TYPE],
            g_marry_actors[idx][M_ACTOR_TYPE]
        );

        SetAreaData(\
            GetActorData(\
                g_marry_actors[idx][M_ACTOR_ID],\
                A_ACTOR_AREA_ID\
            ),\
            A_AREA_NOTIFY_KEY,\
            AREA_NOTIFY_KEY_ALT\
        );

        CreateDynamic3DTextLabel(
            g_marry_actors[idx][M_ACTOR_NAME], COLOR_WHITE, 
            g_marry_actors[idx][M_ACTOR_X],
            g_marry_actors[idx][M_ACTOR_Y],
            g_marry_actors[idx][M_ACTOR_Z],
            10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 
            MARRY_WORLD_ID, MARRY_INTERIOR_ID
        );
    }

    new pickupid;

    for(new idx; idx != MAX_MARRY_PICKUPS; idx++)
    {
        pickupid = Pickups:Create(
            g_marry_pickups[idx][M_PICKUP_MODELID],
            g_marry_pickups[idx][M_PICKUP_X],
            g_marry_pickups[idx][M_PICKUP_Y],
            g_marry_pickups[idx][M_PICKUP_Z],
            g_marry_pickups[idx][M_PICKUP_WORLD],
            g_marry_pickups[idx][M_PICKUP_INTERIOR],
            g_marry_pickups[idx][M_PICKUP_ACTION_TYPE],
            PICKUP_NOTIFY_KEY_ALT
        );

        if(idx == 0)
        {
            CreateDynamic3DTextLabel(
                "« Церковь »", COLOR_YELLOW, 
                g_marry_pickups[idx][M_PICKUP_X],
                g_marry_pickups[idx][M_PICKUP_Y],
                g_marry_pickups[idx][M_PICKUP_Z], 
                10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 
                g_marry_pickups[idx][M_PICKUP_WORLD],
                g_marry_pickups[idx][M_PICKUP_INTERIOR]
            );
        }

        SetPickupData(pickupid, P_TYPE, g_marry_pickups[idx][M_PICKUP_TYPE]);
    }

    CreateDynamicMapIcon(MARRY_MAP_ICON_POS, MARRY_MAP_ICON_ID, COLOR_WHITE, 0, 0);

    return true;
}

// -- Игрок активировал пикап
stock MarrySystem:OnPlayerEnterPickup(playerid, pickup_id)
{
    new type = GetPickupData(pickup_id, P_TYPE);

    switch(type)
    {
        // -- Вход в церковь
        case PICKUP_TYPE_MARRY_ENTER:
        {
            SetPlayerPosEx(playerid, MARRY_POS_ENTER_INTERIOR);
            SetPlayerVirtualWorld(playerid, MARRY_WORLD_ID);
            SetPlayerInterior(playerid, MARRY_INTERIOR_ID);
        }

        // -- Выход из церкви
        case PICKUP_TYPE_MARRY_LEAVE:
        {
            SetPlayerPosEx(playerid, MARRY_POS_LEAVE_INTERIOR);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerInterior(playerid, 0);
        }
    }

    SetPlayerData(playerid, P_FREEZE_TIME, 3);
    TogglePlayerControllable(playerid, false);

    return true;
}

// -- Игрок активировал актёра
stock MarrySystem:OnPlayerActorActive(playerid, area_id)
{
    new type = GetAreaData(area_id, A_AREA_TYPE);

    switch(type)
    {
        case ACTOR_TYPE_MARRY_PRIEST:
            return Dialog_Show(playerid, Dialog:D_MARRY_PRIEST);

        case ACTOR_TYPE_MARRY_FLOWER:
            return Dialog_Show(playerid, Dialog:D_MARRY_FLOWER);

        case ACTOR_TYPE_MARRY_VEHICLE:
            return Dialog_Show(playerid,Dialog:D_MARRY_VEHICLE);
    }

    return true;
}

// -- Обновление аренды свадебного транспорта
stock MarrySystem:UpdatePlayerRentVehicle(playerid)
{
    if(!g_marry_rent_veh_player[playerid][R_TIME_END])
        return true;

    g_marry_rent_veh_player[playerid][R_TIME_END]--;

    if(g_marry_rent_veh_player[playerid][R_TIME_END] / 60 == 10)
        SendClientMessage(playerid, COLOR_MAIN, "[Информация] {"#DC_WHITE"}До конца аренды свадебного транспорта осталось {"#DC_BEIGE"}10 минут");

    if(g_marry_rent_veh_player[playerid][R_TIME_END] / 60 == 5)
        SendClientMessage(playerid, COLOR_MAIN, "[Информация] {"#DC_WHITE"}До конца аренды свадебного транспорта осталось {"#DC_BEIGE"}5 минут");

    if(!g_marry_rent_veh_player[playerid][R_TIME_END])
    {
        Vehicles:Destroy(g_marry_rent_veh_player[playerid][R_VEHICLEID]);

        g_marry_rent_veh_player[playerid] = g_marry_rent_veh_player_null;

        SendClientMessage(playerid, COLOR_MAIN, "[Информация] {"#DC_WHITE"}Время аренды свадебного транспорта истекло");

        g_total_marry_vehicles++;

        return true;
    }

    return true;
}

// -- Игрок сел в транспорт
stock MarrySystem:OnPlayerEnterVehicle(playerid, vehicleid)
{
    new ownable_type = GetVehicleData(vehicleid, V_OWNABLE_TYPE),
        action_type = GetVehicleData(vehicleid, V_ACTION_TYPE);

    if(ownable_type == VEH_OWNABLE_MARRY && playerid != action_type)
    {
        ClearAnimations(playerid);
        return Hud:ShowNotification(playerid, ERROR, "у Вас нет ключей от данного транспорта");
    }

    return true;
}

// -- Игрок вышел из игры
stock MarrySystem:OnPlayerDisconnect(playerid)
{
    if(g_marry_rent_veh_player[playerid][R_VEHICLEID] == INVALID_VEHICLE_ID)
        return true;

    Vehicles:Destroy(g_marry_rent_veh_player[playerid][R_VEHICLEID]);

    g_marry_rent_veh_player[playerid] = g_marry_rent_veh_player_null;

    g_total_marry_vehicles++;

    return true;
}

stock MarrySystem:ClearPlayerData(playerid)
{
    g_marry_rent_veh_player[playerid] = g_marry_rent_veh_player_null;
    return true;
}

stock MarrySystem:OnPlayersMarry(girl_id, boy_id)
{
    format(
        totalstring, sizeof totalstring, 
        "{"#DC_WHITE"}%s "#CLR_MARRY"и {"#DC_WHITE"}%s "#CLR_MARRY"заключили брак. Поздравляем молодожёнов!", 
        GetName(boy_id), GetName(girl_id)
    );
    SendClientMessageToAll(COLOR_MARRY, totalstring);

    SetPlayerData(girl_id, P_MARRY, GetPlayerAccountID(boy_id));
    SetPlayerData(boy_id, P_MARRY, GetPlayerAccountID(girl_id));

    SetPlayerPosEx(girl_id, 283.2690, -241.7698, 1004.4092, 178.4946);
    SetPlayerPosEx(boy_id, 283.3111, -242.8571, 1004.4092, 358.3495);

    UseAnim(boy_id, "BD_FIRE", "GRLFRD_KISS_03", 4.1, 0, 0, 0, 0, 0);

    format(
        totalstring, sizeof totalstring, 
        "UPDATE `accounts` SET `marry` = '%d' WHERE `id` = '%d'",
        GetPlayerData(boy_id, P_MARRY), GetPlayerAccountID(boy_id)
    );
    mysql_tquery(mysql, totalstring);

    format(
        totalstring, sizeof totalstring, 
        "UPDATE `accounts` SET `marry` = '%d' WHERE `id` = '%d'",
        GetPlayerData(girl_id, P_MARRY), GetPlayerAccountID(girl_id)
    );
    mysql_tquery(mysql, totalstring);

    totalstring[0] = EOS;

    foreach(new i:Player)
    {
        if(!IsPlayerInRangeOfPlayer(100.0, boy_id, i))
            continue;

        if(GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(boy_id))
            continue;

        MarrySystem:PlayerPlayMusic(i, true, true);   
    }

    return true;
}

stock MarrySystem:PlayerPlayMusic(playerid, bool:enable = true, bool:is_marry = false)
{
    StopAudioStreamForPlayer(playerid);
    g_marry_time[playerid] = EOS;

    if(enable)
    {
        if(is_marry)
        {
            PlayAudioStreamForPlayer(playerid, g_marry_music[2][M_MUSIC_URL]);
            g_marry_last_player_music[playerid] = 2;
            g_marry_time[playerid] = g_marry_music[2][M_MUSIC_TIME] + gettime();
            return true;
        }

        new index = random_ex(0, 1, 1);

        if(g_marry_last_player_music[playerid] == index)
            return MarrySystem:PlayerPlayMusic(playerid, enable, is_marry);

        PlayAudioStreamForPlayer(playerid, g_marry_music[index][M_MUSIC_URL]);
        g_marry_last_player_music[playerid] = index;

        g_marry_time[playerid] = g_marry_music[index][M_MUSIC_TIME] + gettime();

        return true;
    }

    return true;
}

stock MarrySystem:UpdatePlayerMusic(playerid)
{
    if(!g_marry_time[playerid])
        return true;

    if(g_marry_time[playerid] < gettime())
        MarrySystem:PlayerPlayMusic(playerid, true);

    return true;
}

DialogCreate:D_MARRY_FLOWER(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_MARRY_FLOWER, DIALOG_STYLE_MSGBOX,
        "{"#DC_MAIN"}Покупка букета цветов",
        "{"#DC_WHITE"}Вы действительно хотите купить букет цветов?\n\
        Стоимость: {"#DC_GREEN"}"#MARRY_PRICE_FLOWER"$",
        "Купить", "Закрыть"
    );

    return true;
}

DialogCreate:D_MARRY_PRIEST(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_MARRY_PRIEST, DIALOG_STYLE_LIST,
        "{"#DC_MAIN"}Священнослужитель",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}Информация\n\
        {"#DC_MAIN"}2. {"#DC_WHITE"}Заключить брак\n\
        {"#DC_MAIN"}3. {"#DC_WHITE"}Развестись",
        "Далее", "Закрыть"
    );

    return true;
}

DialogCreate:D_MARRY_INFO(playerid)
{
    Dialog_Open(
        playerid, Dialog:D_MARRY_INFO, DIALOG_STYLE_MSGBOX,
        "{"#DC_MAIN"}Информация",
        "{"#DC_WHITE"}Тут информация о системе (MARRY_SYSTEM)",
        "Назад", "Закрыть"
    );

    return true;
}

DialogCreate:D_MARRY_VEHICLE(playerid)
{
    if(GetPlayerLevel(playerid) < 5)
        return Hud:ShowNotification(playerid, ERROR, "доступно с 5 уровня");

    if(!GetPlayerLicense(playerid, LICENSE_TYPE_AUTO))
        return Hud:ShowNotification(playerid, ERROR, "у Вас нет водительского удостоверения");

    if(g_marry_rent_veh_player[playerid][R_VEHICLEID] != INVALID_VEHICLE_ID)
        return Hud:ShowNotification(playerid, ERROR, "Вы уже арендуете свадебный транспорт");

    format(bigstring, sizeof bigstring, "{"#DC_WHITE"}№ Название\t{"#DC_WHITE"}Стоимость\n");

    for(new idx; idx != MAX_MARRY_VEHICLE_TYPES; idx++)
    {
        format(
            totalstring, sizeof totalstring, 
            "{"#DC_MAIN"}%d. {"#DC_WHITE"}%s\t{"#DC_GREEN"}%d$\n", 
            idx + 1,
            g_marry_vehicle[idx][M_VEH_NAME],
            g_marry_vehicle[idx][M_VEH_PRICE]
        );
        strcat(bigstring, totalstring);
    }
    
    Dialog_Open(
        playerid, Dialog:D_MARRY_VEHICLE, DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}Аренда свадебного транспорта",
        bigstring,
        "Далее", "Закрыть"
    );

    bigstring[0] = EOS;
    totalstring[0] = EOS;

    return true;
}

DialogCreate:D_MARRY_VEHICLE_COLOR(playerid)
{
    bigstring[0] = EOS;
    
    for(new idx; idx != MAX_MARRY_VEHICLE_COLORS; idx++)
    {
        format(
            totalstring, sizeof totalstring, 
            "{"#DC_MAIN"}%d. {%s}%s\n", 
            idx + 1,
            g_marry_vehicle_color[idx][M_COLOR_HEX],
            g_marry_vehicle_color[idx][M_COLOR_NAME]
        );
        strcat(bigstring, totalstring);
    }

    Dialog_Open(
        playerid, Dialog:D_MARRY_VEHICLE_COLOR, DIALOG_STYLE_LIST,
        "{"#DC_MAIN"}Выбор цвета транспорта",
        bigstring,
        "Далее", "Назад"
    );

    totalstring[0] = EOS;
    bigstring[0] = EOS;

    return true;
}

DialogCreate:D_MARRY_VEHICLE_SUCCESS(playerid)
{
    new idx_model = GetPlayerListitemData(playerid, 0),
        idx_color = GetPlayerListitemData(playerid, 1);

    format(
        totalstring, sizeof totalstring, 
        "{"#DC_WHITE"}Вы действительно собираетесь арендовать свадебный транспорт?\n\n\
        {"#DC_WHITE"}Модель - {"#DC_MAIN"}%s\n\
        {"#DC_WHITE"}Цвет - {%s}%s\n\n\
        {"#DC_WHITE"}Стоимость - {"#DC_GREEN"}%d$",
        g_marry_vehicle[idx_model][M_VEH_NAME],
        g_marry_vehicle_color[idx_color][M_COLOR_HEX],
        g_marry_vehicle_color[idx_color][M_COLOR_NAME],
        g_marry_vehicle[idx_model][M_VEH_PRICE] 
    );
    Dialog_Open(
        playerid, Dialog:D_MARRY_VEHICLE_SUCCESS, DIALOG_STYLE_MSGBOX,
        "{"#DC_MAIN"}Подтверждение",
        totalstring,
        "Далее", "Назад"
    );

    totalstring[0]  = EOS;

    return true;
}

DialogCreate:D_MARRY_INPUT(playerid)
{
    if(GetPlayerSex(playerid) != SEX_BOY)
        return Hud:ShowNotification(playerid, ERROR, "сделать предложение может только мужчина");

    Dialog_Open(
        playerid, Dialog:D_MARRY_INPUT, DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"}Жениться",
        "{"#DC_WHITE"}Введите ID своей будущей жены:",
        "Далее", "Назад"
    );

    return true;
}

DialogResponse:D_MARRY_INFO(playerid, response, listitem, inputtext[])
{
    if(!response)
        return true;
        
    Dialog_Show(playerid, Dialog:D_MARRY_PRIEST);

    return true;
}

DialogResponse:D_MARRY_FLOWER(playerid, response, listitem, inputtext[])
{
    if(!response)
        return true;

    if(GetPlayerCash(playerid) < MARRY_PRICE_FLOWER)
        return Hud:ShowNotification(playerid, ERROR, "У Вас недостаточно средств");

    if(IsPlayerWeaponID(playerid, WEAPON_FLOWER))
        return Hud:ShowNotification(playerid, ERROR, "У Вас уже есть букет с цветами");

    SetPlayerCash(playerid, GetPlayerCash(playerid) - MARRY_PRICE_FLOWER);

    GivePlayerWeapon(playerid, WEAPON_FLOWER, 1);

    Hud:ShowNotification(playerid, SUCCESS, "Вы успешно купили букет с цветами");

    return true;
}

DialogResponse:D_MARRY_PRIEST(playerid, response, listitem, inputtext[])
{
    if(!response)
        return true;

    switch(listitem)
    {
        case 0: Dialog_Show(playerid, Dialog:D_MARRY_INFO);
        case 1: Dialog_Show(playerid, Dialog:D_MARRY_INPUT);
        case 2:
        {
            if(!GetPlayerData(playerid, P_MARRY))
                return Hud:ShowNotification(playerid, ERROR, "Вы не состоите в браке");

            format(
                totalstring, sizeof totalstring, 
                "UODATE `accounts` SET `marry` = '0' WHERE `id` = '%d'", 
                GetPlayerAccountID(playerid)
            );
            mysql_tquery(mysql, totalstring);

            format(
                totalstring, sizeof totalstring, 
                "UODATE `accounts` SET `marry` = '0' WHERE `id` = '%d'", 
                GetPlayerData(playerid, P_MARRY)
            );
            mysql_tquery(mysql, totalstring);

            Hud:ShowNotification(playerid, SUCCESS, "Вы успешно развелись");

            SetPlayerData(playerid, P_MARRY, 0);

            new bool:result = false;

            foreach(new i:Player)
            {
                if(GetPlayerAccountID(i) != GetPlayerData(playerid, P_MARRY))
                    continue;

                SendClientMessage(i, COLOR_MAIN, "[Информация] {"#DC_WHITE"}По желанию вашей второй половинки Вы развелись");
                SetPlayerData(i, P_MARRY, 0);
                
                result = true;

                break;
            }

            if(result)
                return true;

            SendOfflineMessage(
                GetPlayerData(playerid, P_MARRY),
                COLOR_MAIN,
                "[Информация] {"#DC_WHITE"}По желанию вашей второй половинки Вы развелись"
            );
        }
    }

    return true;
}

DialogResponse:D_MARRY_VEHICLE(playerid, response, listitem, inputtext[])
{
    if(!response)
        return ClearPlayerListitemData(playerid);

    SetPlayerListitemData(playerid, 0, listitem);
    Dialog_Show(playerid, Dialog:D_MARRY_VEHICLE_COLOR);

    return true;
}

DialogResponse:D_MARRY_VEHICLE_COLOR(playerid, response, listitem, inputtext[])
{
    if(!response)
    {
        ClearPlayerListitemData(playerid);
        return Dialog_Show(playerid, Dialog:D_MARRY_VEHICLE);
    }

    SetPlayerListitemData(playerid, 1, listitem);

    Dialog_Show(playerid, Dialog:D_MARRY_VEHICLE_SUCCESS);

    return true;
}

DialogResponse:D_MARRY_VEHICLE_SUCCESS(playerid, response, listitem, inputtext[])
{
    if(!response)
        return Dialog_Show(playerid, Dialog:D_MARRY_VEHICLE_COLOR);

    new idx_model = GetPlayerListitemData(playerid, 0),
        idx_color = GetPlayerListitemData(playerid, 1);

    ClearPlayerListitemData(playerid);

    if(!g_total_marry_vehicles)
        return Hud:ShowNotification(playerid, ERROR, "в данный момент не свободного транспорта");

    if(GetPlayerCash(playerid) < g_marry_vehicle[idx_model][M_VEH_PRICE])
        return Hud:ShowNotification(playerid, ERROR, "у Вас недостаточно средств"); 

    SetPlayerCash(playerid, GetPlayerCash(playerid) - g_marry_vehicle[idx_model][M_VEH_PRICE]);

    new index  = random_ex(0, MAX_MARRY_VEHICLE_POS - 2, 1);

    if(g_marry_vehicle[idx_model][M_VEH_MODELID] == 409)
        index = MAX_MARRY_VEHICLE_POS - 1;

    new vehicleid = Vehicles:Create(
        g_marry_vehicle[idx_model][M_VEH_MODELID],
        g_marry_vehicle_pos[index][0],
        g_marry_vehicle_pos[index][1],
        g_marry_vehicle_pos[index][2],
        g_marry_vehicle_pos[index][3],
        g_marry_vehicle_color[idx_color][M_COLOR_ID],
        g_marry_vehicle_color[idx_color][M_COLOR_ID],
        0, 0, -1, 0, 0, VEH_OWNABLE_MARRY, playerid
    );

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    PutPlayerInVehicle(playerid, vehicleid, 0);

    Hud:ShowNotification(playerid, SUCCESS, "Вы успешно арендовали свадебный транспорт");

    g_marry_rent_veh_player[playerid][R_TIME_END] = MARRY_MINUTE_VEH_RENT * 60;
    g_marry_rent_veh_player[playerid][R_VEHICLEID] = vehicleid;

    g_total_marry_vehicles--;

    return true;
}

DialogResponse:D_MARRY_INPUT(playerid, response, listitem, inputtext[])
{
    if(!response)
        return Dialog_Show(playerid, Dialog:D_MARRY_PRIEST);

    new from_playerid = strval(inputtext);

    if(from_playerid < 0 || from_playerid > MAX_PLAYERS - 1)
    {
        Dialog_Show(playerid, Dialog:D_MARRY_INPUT);
        return Hud:ShowNotification(playerid, ERROR, "игрока с таким ID не существует");
    }

    if(!IsPlayerConnected(from_playerid) || !IsPlayerLogged(from_playerid))
    {
        Dialog_Show(playerid, Dialog:D_MARRY_INPUT);
        return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
    }

    if(!IsPlayerInRangeOfPlayer(3.0, from_playerid, playerid))
        return Hud:ShowNotification(playerid, ERROR, P_RANGE);

    if(GetPlayerSex(from_playerid) != SEX_GIRL)
        return Hud:ShowNotification(playerid, ERROR, "Вы не можете жениться на мужчине");

    if(GetPlayerData(from_playerid, P_MARRY))
        return Hud:ShowNotification(playerid, ERROR, "данный игрок уже состоит в браке");

    if(GetPlayerData(playerid, P_MARRY))
        return Hud:ShowNotification(playerid, ERROR, "Вы уже состоите в браке");

    if(GetPlayerLevel(playerid) < 5)
        return Hud:ShowNotification(playerid, ERROR, "доступно с 5 уровня");

    if(GetPlayerLevel(from_playerid) < 5)
        return Hud:ShowNotification(playerid, ERROR, "игрок не достиг 5 уровня");

    if(!Player_CreateProposalToPlayer(playerid, from_playerid, PROPOSAL_MARRY))
        return true;

    format(
        totalstring, sizeof totalstring, 
        "Игрок {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}предложил Вам выйти за него замуж",
        GetName(playerid), playerid
    );
    SendClientMessage(from_playerid, COLOR_WHITE, totalstring);
    SendClientMessage(from_playerid, COLOR_WHITE, PROPOSAL_TEXT);

    format(
        totalstring, sizeof totalstring, 
        "Вы предложили {"#DC_MAIN"}%s [%d] {"#DC_WHITE"}выйти за Вас замуж", 
        GetName(from_playerid), from_playerid
    );
    SendClientMessage(playerid, COLOR_WHITE, totalstring);

    totalstring[0] = EOS;

    return true;
}