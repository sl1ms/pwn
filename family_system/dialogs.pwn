DialogCreate:dFamilyCommon(playerid)
{
    format(
        totalstring,
        sizeof totalstring,
        "{"#DC_MAIN"}1. {"#DC_WHITE"}Информация о семьях\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}Создание семьи\n"\
        "{"#DC_MAIN"}3. {"#DC_WHITE"}Поиск семьи\n"\
        "{"#DC_MAIN"}4. {"#DC_WHITE"}Список семей\n"
    );

    if (IsFamilyMember(playerid)) {
        strcat(
            totalstring,
            "{"#DC_MAIN"}5. {"#DC_WHITE"}Управление семьей\n"
        );

        if (GetPlayerFamilyRankIndex(playerid) == FAMILY_OWNER_RANK_INDEX) {
            strcat(
                totalstring,
                "{"#DC_MAIN"}6. {"#DC_WHITE"}Снять средства с баланса семьи\n"\
                "{"#DC_MAIN"}7. {"#DC_WHITE"}Передать право лидера семьи\n"\
                "{"#DC_RED"}Распустить семью\n"
            );
        }
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyCommon,
        DIALOG_STYLE_LIST,
        "{"#DC_MAIN"} Семьи",
        totalstring,
        "Далее",
        "Закрыть"
    );
    
    totalstring[0] = EOS;

    return true;
}

DialogResponse:dFamilyCommon(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return true;
    }

    switch (listitem) {
        case 0: return Dialog_Show(playerid, Dialog:dFamilyCommonInfo);
        case 1: {
            if (IsFamilyMember(playerid)) {
                return Hud:ShowNotification(playerid, ERROR, "Вы не можете создать новую семью, будучи членом семьи");
            }

            return Dialog_Show(playerid, Dialog:dFamilyCreate);
        }
        case 2: return Dialog_Show(playerid, Dialog:dFamilyOrderType);
        case 3: return Family:SearchForFamily(playerid, "");
        case 4: return Dialog_Show(playerid, Dialog:dFamilyManage);
        case 5: return Dialog_Show(playerid, Dialog:dFamilyCash);
        case 6: return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
        case 7: return Dialog_Show(playerid, Dialog:dFamilyDissolve);
    }

    return true;
}

DialogCreate:dFamilyCash(playerid)
{
    if (families[GetPlayerFamilyIndex(playerid)][F_WITHDRAW_TIMEOUT] > gettime()) {
        Hud:ShowNotification(playerid, ERROR, "Вы можете снять средства с баланса семьи не более 1 раза в 5 минут");
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyCash,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"} Снятие средств с баланса семьи",
       "{"#DC_WHITE"}Вы можете снять средства с баланса семьи. За раз можно снять от {"#DC_GREEN"}$"#FAMILY_MIN_WITHDRAW"{"#DC_WHITE"} до {"#DC_GREEN"}$"#FAMILY_MAX_WITHDRAW"{"#DC_WHITE"}\n\n"\
       "Введите сумму снятия:",

        "Далее",
        "Закрыть"
    );

    return true;
}

DialogResponse:dFamilyCash(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести сумму для снятия");
        return Dialog_Show(playerid, Dialog:dFamilyCash);
    }

    if (!IsNumeric(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести действительное число!");
        return Dialog_Show(playerid, Dialog:dFamilyCash);
    }

    new sum = strval(inputtext);

    if (sum < FAMILY_MIN_WITHDRAW || sum > FAMILY_MAX_WITHDRAW) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести число в диапазоне от {"#DC_GREEN"}$"#FAMILY_MIN_WITHDRAW"{"#DC_GREY"} до {"#DC_GREEN"}$"#FAMILY_MAX_WITHDRAW"{"#DC_GRAY"}!");
        return Dialog_Show(playerid, Dialog:dFamilyCash);
    } 

    if (sum > families[GetPlayerFamilyIndex(playerid)][F_BALANCE]) {
        Hud:ShowNotification(playerid, ERROR, "На балансе семьи недостаточно средств для снятия такой суммы");
        return Dialog_Show(playerid, Dialog:dFamilyCash);
    }

    GiveMoney(playerid, sum, 0);

    new familyIndex = GetPlayerFamilyIndex(playerid);

    families[familyIndex][F_BALANCE] -= sum;
    families[familyIndex][F_WITHDRAW_TIMEOUT] = gettime() + FAMILY_WITHDRAW_TIMEOUT;

    Family:SaveFamilyInt(familyIndex, "balance", families[familyIndex][F_BALANCE]); 

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s[%d] снял {"#DC_GREEN"}$%d{familyColor} с баланса семьи",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        sum
    );

    Family:SendFamilyMessage(playerid, bigstring);

    return Dialog_Show(playerid, Dialog:dFamilyCommon);
}

DialogCreate:dFamilyDissolve(playerid)
{
    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyDissolve,
        "{"#DC_MAIN"}Роспуск семьи",
        "{"#DC_WHITE"}Вы действительно хотите распустить семью?\n\n"\
        "{"#DC_LRED"}Это действие необратимо!",
        "Подтвердить",
        "Назад"
    );

    return true;
}

DialogResponse:dFamilyDissolve(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT 1 FROM "#DB_FAMILY_MEMBERS" WHERE family_id = %d AND deleted_at IS NULL",
        families[familyIndex][F_ID]
    );

    new Cache:total_members_request = mysql_query(mysql, bigstring);
    bigstring[0] = EOS;

    new total_members = cache_num_rows();

    cache_delete(total_members_request);

    if (total_members > 1) {
        Hud:ShowNotification(playerid, ERROR, "Вы не можете распустить свою семью, пока в ней есть участники");
        return Dialog_Show(playerid, Dialog:dFamilyDissolve);
    }

    if (Family:GetFamilyVehiclesCount(familyIndex) > 0) {
        Hud:ShowNotification(playerid, ERROR, "Вы не можете распустить свою семью, пока не продан семейный транспорт");
        return Dialog_Show(playerid, Dialog:dFamilyDissolve);
    }

    format(
        totalstring, 144,
        "[A] Игрок {"#DC_WHITE"}%s[%d] {92c13f}распустил семью %s {92c13f}[ID: %d]",
        GetName(playerid), playerid, families[familyIndex][F_NAME],
        families[familyIndex][F_NAME],
        families[familyIndex][F_ID]
    );
    SendAdminMessage(0x92c13fFF, totalstring, 1, CONNECT_PLAYER);
    totalstring[0] = EOS;

    format(
        bigstring,
        sizeof bigstring,
        "UPDATE "#DB_FAMILIES" SET deleted_at = now() WHERE id = %d",
        families[familyIndex][F_ID]
    );
    mysql_tquery(mysql, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        "UPDATE "#DB_FAMILY_MEMBERS" SET deleted_at = now() WHERE family_id = %d",
        families[familyIndex][F_ID]
    );
    mysql_tquery(mysql, bigstring);

    Family:UnloadFamily(familyIndex);
    Family:Destroy3DTextOfPlayer(playerid);

    PlayerInfo[playerid][p_family_index] = INVALID_FAMILY_ID;
    PlayerInfo[playerid][p_family_rank_index] = INVALID_FAMILY_ID;

    Hud:ShowNotification(playerid, ET_INFO,  "Вы успешно распустили свою семью");

    return true;
}

DialogCreate:dFamilyAssignLeader(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyAssignLeader,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"}Изменение владельца",
        "{"#DC_WHITE"}Введите ник нового владельца семьи. Новый владелец должен являться Вашим заместителем и находиться рядом с Вами.\n\n"\
        "{"#DC_LRED"}Внимание! Вы потеряете свои права владельца моментально, вернуть их будет невозможно.\n"\
        "Будьте осторожны с тем, что делаете!",
        "Подтвердить",
        "Назад"
    );
    return true;
}

DialogResponse:dFamilyAssignLeader(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести ник нового владельца!");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    new target_id = GetPlayerIdByName(inputtext);

    if (target_id == INVALID_PLAYER_ID) {
        Hud:ShowNotification(playerid, ERROR, "Указанный игрок не найден");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    if (!IsPlayerInRangeOfPlayer(5.0, playerid, target_id)) {
        Hud:ShowNotification(playerid, ERROR, "Этот игрок не рядом с Вами");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    if (GetPlayerFamilyIndex(playerid) != GetPlayerFamilyIndex(target_id)) {
        Hud:ShowNotification(playerid, ERROR, "Этот игрок не является членом Вашей семьи");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    if (GetPlayerFamilyRankIndex(target_id) != FAMILY_DEPUTY_RANK_INDEX) {
        Hud:ShowNotification(playerid, ERROR, "Игрок не является Вашим заместителем");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    PlayerInfo[target_id][p_family_rank_index] = FAMILY_OWNER_RANK_INDEX;
    PlayerInfo[playerid][p_family_rank_index] = FAMILY_DEPUTY_RANK_INDEX;

    Family:SavePlayerRank(playerid);
    Family:SavePlayerRank(target_id);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s[%d] назначен новым владельцем семьи",
        GetName(target_id),
        target_id
    );
    Family:SendFamilyMessage(target_id, bigstring);

    return true;
}

DialogCreate:dFamilyVehicles(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    new totalVehicles = 0;

    bigstring[0] = EOS;

    strcat(bigstring, "{"#DC_MAIN"}Автомобиль\t{"#DC_MAIN"}Доступ\t{"#DC_MAIN"}Состояние\n");
    
    new veh_state[20];

    ClearPlayerListitemData(playerid);

    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_MODEL] == INVALID_FAMILY_ID)
            continue;

        SetPlayerListitemData(playerid, totalVehicles, i);

        switch (family_cars[familyIndex][i][FV_STATE]) {
            case ALIVE: format(veh_state, sizeof veh_state, "{"#DC_GREEN"}Активен");
            case DEAD: format(veh_state, sizeof veh_state, "{"#DC_RED"}Уничтожен");
            case NOT_SPAWNED: format(veh_state, sizeof veh_state, "{"#DC_GRAY"}Не заспавнена");
        }

        format(
            totalstring,
            sizeof totalstring,
            "{"#DC_MAIN"}%d. {"#DC_WHITE"}%s\t{"#DC_WHITE"}%s\t%s\n",
            totalVehicles + 1,
            GetVehicleConfig(family_cars[familyIndex][i][FV_MODEL], VC_NAME),
            GetFamilyRankName(familyIndex, family_cars[familyIndex][i][FV_RANK] - 1),
            veh_state
        );
        strcat(bigstring, totalstring);
        totalVehicles++;
    }

    if (totalVehicles == 0) {
        return Dialog_MessageEx(
            playerid,
            Dialog:dFamilyNotificationView,
            "{"#DC_MAIN"}Семейный транспорт",
            "{"#DC_WHITE"}Семейный транспорт не найден",
            "Назад",
            "" 
        );
    }


    Dialog_Open(
        playerid,
        Dialog:dFamilyVehicles,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}Список транспорта семьи",
        bigstring,
        "Выбрать",
        "Назад"
    );

    totalstring[0] = EOS;
    bigstring[0] = EOS;

    return true;
}

DialogCreate:dFamilyConfirmVehicleSpawn(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid),
        vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);

    if (!Family:GetAvailableCarsToSpawn(familyIndex)) {
        Hud:ShowNotification(playerid, ERROR, "Вы достигли лимита созданного транспорта");
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_WHITE"}Вы действительно хотите заспавнить автомобиль {"#DC_MAIN"}%s{"#DC_WHITE"}?\n"\
        "Ваша семья может создать еще {"#DC_MAIN"}%d{"#DC_WHITE"} автомобилей.",
        GetVehicleConfig(family_cars[familyIndex][vehicleIndex][FV_MODEL], VC_NAME),
        Family:GetAvailableCarsToSpawn(familyIndex)
    );

    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyConfirmVehicleSpawn,
        "{"#DC_MAIN"}Подтверждение спавна автомобиля",
        bigstring,
        "Подтвердить",
        "Отмена"
    );

    bigstring[0] = EOS;

    return true;
}

DialogResponse:dFamilyConfirmVehicleSpawn(playerid, response, listitem, inputtext[])
{
    if (!response) {
        DeletePVar(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid),
        vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);

    if (family_cars[familyIndex][vehicleIndex][FV_STATE] != NOT_SPAWNED) {
        Hud:ShowNotification(playerid, ERROR, "Невозможно заспавнить этот транспорт");
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    if (!Family:SpawnVehicle(playerid, vehicleIndex)) {
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    if (GetPlayerVehicleID(playerid) == family_cars[familyIndex][vehicleIndex][FV_VEHICLE_ID]) {
        Hud:ShowNotification(playerid, ERROR, "Вы уже находитесь в этом транспорте");
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    new Float:x, Float:y, Float:z;

    GetVehiclePos(family_cars[familyIndex][vehicleIndex][FV_VEHICLE_ID], x, y, z);
    SetPlayerGPS(playerid, x, y, z, "Автомобиль семьи");

    return true;
}

DialogCreate:dFamilyVehAction(playerid)
{
    new vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE),
        familyIndex = GetPlayerFamilyIndex(playerid);

    if (family_cars[familyIndex][vehicleIndex][FV_STATE] != ALIVE) {
        return Dialog_Show(playerid, Dialog:dFamilyManageListRangs);
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyVehAction,
        DIALOG_STYLE_LIST,
        "{"#DC_MAIN"} Управление транспортом",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}Выгрузить транспорт - {"#DC_GREEN"}$"#FAMILY_VEHICLE_UNLOAD_COST"\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}Изменить ранг доступа\n",
        "Далее",
        "Закрыть"
    );

    return true;
}

DialogResponse:dFamilyVehAction(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    new vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE),
        familyIndex = GetPlayerFamilyIndex(playerid),
        vehicleid = family_cars[familyIndex][vehicleIndex][FV_VEHICLE_ID];

    switch (listitem) {
        case 0: {
            if (families[familyIndex][F_BALANCE] < FAMILY_VEHICLE_UNLOAD_COST) {
                Hud:ShowNotification(playerid, ERROR, "На балансе Вашей семьи недостаточно средств для выгрузки транспорта");
                return Dialog_Show(playerid, Dialog:dFamilyVehAction);
            }

            if (IsVehicleOccupied(vehicleid)) {
                Hud:ShowNotification(playerid, ERROR, "Невозможно выгрузить транспорт, который кем-то используется");
                return Dialog_Show(playerid, Dialog:dFamilyVehAction);
            }

            new Float:vhealth;

            GetVehicleHealth(vehicleid, vhealth);

            if (vhealth < 950.0) {
                Hud:ShowNotification(playerid, ERROR, "Вы не можете выгрузить поврежденный транспорт");
                return Dialog_Show(playerid, Dialog:dFamilyVehAction);
            }

            families[familyIndex][F_BALANCE] -= FAMILY_VEHICLE_UNLOAD_COST;
            Family:SaveFamilyInt(familyIndex, "balance",  families[familyIndex][F_BALANCE]);

            Family:UnloadVehicle(familyIndex, vehicleIndex);

            format(
                totalstring,
                sizeof totalstring,
                FAMILY_ACTIONS_PREFIX"%s %s[%d] выгрузил семейный транспорт \"%s\"",
                GetPlayerFamilyRankName(playerid),
                GetName(playerid),
                playerid,
                GetVehicleConfig(family_cars[familyIndex][vehicleIndex][FV_MODEL], VC_NAME)
            );
            Family:SendFamilyMessage(playerid, totalstring);
            totalstring[0] = EOS;
            return Dialog_Show(playerid, Dialog:dFamilyVehicles);
        }

        case 1: return Dialog_Show(playerid, Dialog:dFamilyManageListRangs);

    }

    return Dialog_Show(playerid, Dialog:dFamilyVehicles);
}

DialogResponse:dFamilyVehicles(playerid, response, listitem, inputtext[])
{
    if (!response) {
        DeletePVar(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);
        DeletePVar(playerid, PVAR_FAMILIES_EDIT_VEH_RANK);
        DeletePVar(playerid, PVAR_FAMILIES_SELL_VEH);
        return Dialog_Show(playerid, Dialog:dFamilyManage);
    }

    new selectedItem = GetPlayerListitemData(playerid, listitem),
        familyIndex = GetPlayerFamilyIndex(playerid);
    
    ClearPlayerListitemData(playerid);

    if (GetPVarInt(playerid, PVAR_FAMILIES_EDIT_VEH_RANK)) {
        SetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE, selectedItem);
        return Dialog_Show(playerid, Dialog:dFamilyVehAction);
    }

    if (GetPVarInt(playerid, PVAR_FAMILIES_SELL_VEH)) {
        SetPVarInt(playerid, PVAR_FAMILIES_SELL_VEH, selectedItem);
        return Dialog_Show(playerid, Dialog:dFamilyConfirmVehicleSell);
    }

    switch (family_cars[familyIndex][selectedItem][FV_STATE]) {
        case ALIVE: {
            new Float:x, Float:y, Float:z;

            GetVehiclePos(family_cars[familyIndex][selectedItem][FV_VEHICLE_ID], x, y, z);

            SetPlayerGPS(playerid, x, y, z, "Автомобиль семьи");
            return true;
        }
        case DEAD: {
            Hud:ShowNotification(playerid, ERROR, "Автомобиль был уничтожен. Лидер или заместитель могут восстановить уничтоженные автомобили в специальном меню");
            return true;
        }

        case NOT_SPAWNED: {
            if (GetPlayerFamilyRankIndex(playerid) < family_cars[familyIndex][selectedItem][FV_RANK] - 1) {
                Hud:ShowNotification(playerid, ERROR, "У Вас нет доступа к этому транспорту");
                return Dialog_Show(playerid, Dialog:dFamilyVehicles);
            }

            SetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE, selectedItem);
            return Dialog_Show(playerid, Dialog:dFamilyConfirmVehicleSpawn);
        }
    }

    return Dialog_Show(playerid, Dialog:dFamilyVehicles);
}

DialogCreate:dFamilyOrderType(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyOrderType,
        DIALOG_STYLE_LIST,
        "{"#DC_MAIN"} Поиск семей - сортировка",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}От старых к новым\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}От новых к старым\n"\
        "{"#DC_MAIN"}3. {"#DC_WHITE"}Наименьшее количество участников\n"\
        "{"#DC_MAIN"}4. {"#DC_WHITE"}Наибольшее количество участников\n",
        "Далее",
        "Закрыть"
    );
}

DialogResponse:dFamilyOrderType(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    SetPVarInt(playerid, PVAR_FAMILIES_SEARCH_ORDER, listitem);
    return Dialog_Show(playerid, Dialog:dFamilySearch);
}

DialogCreate:dFamilySearch(playerid)
{
    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_WHITE"}Всего семей на данный момент: {"#DC_MAIN"}%d{"#DC_WHITE"}\n\n"\
        "Введите название семьи, которую хотите найти, в поле ниже:",
        Family:GetFamiliesCount()
    );

    Dialog_Open(
        playerid,
        Dialog:dFamilySearch,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"} Поиск семьи",
        bigstring,

        "Далее",
        "Назад"
    );

    bigstring[0] = EOS;
}

DialogCreate:dFamilyManage(playerid)
{
    format(
        totalstring,
        sizeof totalstring,
        "{"#DC_MAIN"}1. {"#DC_WHITE"}Информация о семье\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}Состав семьи {"#DC_WHITE"}[{"#DC_GREEN"}ONLINE{"#DC_WHITE"}]\n"\
        "{"#DC_MAIN"}3. {"#DC_WHITE"}Общий состав семьи\n"\
        "{"#DC_MAIN"}4. {"#DC_WHITE"}Список {"#DC_GREEN"}дружеских{"#DC_WHITE"} семей\n"\
        "{"#DC_MAIN"}5. {"#DC_WHITE"}Список {"#DC_LRED"}враждебных{"#DC_WHITE"} семей\n"\
        "{"#DC_MAIN"}6. {"#DC_WHITE"}Список семейного транспорта\n"\
        "{"#DC_MAIN"}7. {"#DC_WHITE"}Пожертвовать средства на семейный счёт\n"\
        "{"#DC_MAIN"}8. {"#DC_WHITE"}Уведомление семьи\n"\
        "{"#DC_MAIN"}9. {FFCD00}Управление семьей\n"
    );

    if (GetPlayerFamilyRankIndex(playerid) < FAMILY_OWNER_RANK_INDEX) {
        strcat(totalstring, "{"#DC_LRED"}Покинуть семью");
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyManage,
        DIALOG_STYLE_LIST,
        "{"#DC_MAIN"} Семья",
        totalstring,
        "Далее",
        "Закрыть"
    );

    totalstring[0] = EOS;
}

DialogResponse:dFamilyManage(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return true;
    }

    switch (listitem) {
        case 0: return Dialog_Show(playerid, Dialog:dFamilyInfo);
        case 1: return Dialog_Show(playerid, Dialog:dFamilyOnlineMembers);
        case 2: return Family:ShowMembers(playerid, GetPlayerFamilyIndex(playerid));
        case 3: return Family:GetRelations(playerid, GetPlayerFamilyIndex(playerid), FRIENDLY);
        case 4: return Family:GetRelations(playerid, GetPlayerFamilyIndex(playerid), HOSTILE);
        case 5: return Dialog_Show(playerid, Dialog:dFamilyVehicles);
        case 6: return Dialog_Show(playerid, Dialog:dFamilyDonate);
        case 7: return Dialog_Show(playerid, Dialog:dFamilyNotificationView);
        case 8: {
            if (GetPlayerFamilyRankIndex(playerid) < FAMILY_DEPUTY_RANK_INDEX) {
                Hud:ShowNotification(playerid, ERROR, "Вы не можете использовать это");
                return Dialog_Show(playerid, Dialog:dFamilyManage);
            }

            return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
        }
        case 9: return Family:RemovePlayerFromFamily(playerid, GetPlayerFamilyIndex(playerid), GetPlayerAccountID(playerid));
    }

    return true;
}

DialogResponse:dFamilyRelations(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyManage);
    }

    new selectedItem = GetPlayerListitemData(playerid, listitem);
    ClearPlayerListitemData(playerid);

    if (selectedItem == FAMILIES_SEARCH_ID_NEXT) {
        return Family:GetRelations(playerid, GetPlayerFamilyIndex(playerid), RelationType:GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_RELATION), GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET) + FAMILIES_PER_PAGE);
    }

    if (selectedItem == FAMILIES_SEARCH_ID_BACK) {
        return Family:GetRelations(playerid, GetPlayerFamilyIndex(playerid), RelationType:GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_RELATION), GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET) - FAMILIES_PER_PAGE);
    }

    if (selectedItem == FAMILIES_ADD_RELATION) {
        SetPVarInt(playerid, PVAR_FAMILIES_FROM_RL_MANAGE, 1);
        return Dialog_Show(playerid, Dialog:dFamilyOrderType);
    }

    if (GetPVarInt(playerid, PVAR_FAMILIES_FROM_RL_MANAGE)) {
        SetPVarInt(playerid, PVAR_FAMILIES_RELATION_ID, selectedItem);
        return Dialog_Show(playerid, Dialog:dFamilyReleaseRLConfirm);
    }

    DeletePVar(playerid, PVAR_FAMILIES_SEARCH_OFFSET);
    return Dialog_Show(playerid, Dialog:dFamilyManage);
}

DialogCreate:dFamilyConfirmRelation(playerid)
{
    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyConfirmRelation,
        "{"#DC_MAIN"}Подтверждение начала отношений",
        "{"#DC_WHITE"}Вы действительно хотите начать отношения с этой семьей?",
        "Подтвердить",
        "Отмена"
    );    
}

DialogResponse:dFamilyConfirmRelation(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Family:SearchForFamily(playerid, family_search_requests[playerid], GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET));
    }

    new familyIndex = GetPlayerFamilyIndex(playerid),
        relationType = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_RELATION),
        targetFamilyId = GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_CURRENT);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT relation_type FROM "#DB_FAMILY_RELATIONSHIPS" WHERE family_id = %d AND related_family_id = %d",
        families[familyIndex][F_ID],
        targetFamilyId
    );

    new Cache:request_relation_exists = mysql_query(mysql, bigstring);
    bigstring[0] = EOS;

    if (cache_num_rows() > 0) {
        new RelationType:relationDbType;

        cache_get_value_name_int(0, "relation_type", _:relationDbType);
        cache_delete(request_relation_exists);

        format(
            bigstring,
            sizeof bigstring,
            "Вы уже %s с этой семьей",
            relationDbType == HOSTILE ? "враждуете" : "дружите"
        );
        Hud:ShowNotification(playerid, ERROR, bigstring);
        bigstring[0] = EOS;

        return Family:SearchForFamily(playerid, family_search_requests[playerid], GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET));
    }
    
    cache_delete(request_relation_exists);

    format(
        bigstring,
        sizeof bigstring,
        "INSERT "#DB_FAMILY_RELATIONSHIPS" (family_id, related_family_id, relation_type) VALUES (%d, %d, %d)",
        families[familyIndex][F_ID],
        targetFamilyId,
        relationType
    );
    mysql_tquery(mysql, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT name FROM "#DB_FAMILIES" WHERE id = %d",
        targetFamilyId
    );

    new Cache:request_family_name = mysql_query(mysql, bigstring);

    new family_name[FAMILY_MAX_COLORED_SYMBOLS];

    cache_get_value_name(0, "name", family_name);
    cache_delete(request_family_name);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] объявил %s семью %s",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        RelationType:relationType == HOSTILE ? "враждебной" : "дружественной",
        family_name
    );
    Family:SendFamilyMessageByIndex(familyIndex, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s[%d] из семьи %s объявил Вашу семью %s",
        GetName(playerid),
        playerid,
        families[familyIndex][F_NAME],
        RelationType:relationType == HOSTILE ? "враждебной" : "дружественной"
    );

    Family:SendFamilyMessageById(targetFamilyId, bigstring);
    bigstring[0] = EOS;

    DeletePVar(playerid, PVAR_FAMILIES_SEARCH_CURRENT);
    DeletePVar(playerid, PVAR_FAMILIES_FROM_RL_MANAGE);
    return true;
}

DialogCreate:dFamilyReleaseRLConfirm(playerid)
{
    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyReleaseRLConfirm,
        "{"#DC_MAIN"}Подтверждение разрыва отношений",
        "{"#DC_WHITE"}Вы действительно хотите разорвать отношения с этой семьей?",
        "Подтвердить",
        "Отмена"
    );
}

DialogResponse:dFamilyReleaseRLConfirm(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Family:GetRelations(playerid, GetPlayerFamilyIndex(playerid), RelationType:GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_RELATION));
    }

    new familyIndex = GetPlayerFamilyIndex(playerid),
        relatedFamilyId = GetPVarInt(playerid, PVAR_FAMILIES_RELATION_ID);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT name FROM "#DB_FAMILIES" WHERE id = %d",
        relatedFamilyId,
        families[familyIndex][F_ID],
        relatedFamilyId
    );

    new Cache:requestTragetData = mysql_query(mysql, bigstring);

    new family_name[FAMILY_MAX_COLORED_SYMBOLS], RelationType:relationType = RelationType:GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_RELATION);

    cache_get_value_name(0, "name", family_name);

    cache_delete(requestTragetData);

    format(
        bigstring,
        sizeof bigstring,
        "DELETE FROM "#DB_FAMILY_RELATIONSHIPS" WHERE family_id = %d AND related_family_id = %d",
        families[familyIndex][F_ID],
        relatedFamilyId
    );

    mysql_tquery(mysql, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        "%s %s[%d] разорвал %s отношения с семьей %s",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        (relationType == HOSTILE ? "враждебные" : "дружеские"),
        family_name
    );
    Family:SendFamilyMessageByIndex(familyIndex, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        "%s[%d] из семьи %s{familyColor} разорвал %s отношения с вашей семьей",
        GetName(playerid),
        playerid,
        families[familyIndex][F_NAME],
        (relationType == HOSTILE ? "враждебные" : "дружеские")
    );

    Family:SendFamilyMessageById(relatedFamilyId, bigstring);
    bigstring[0] = EOS;

    return true;
}

DialogCreate:dFamilyOnlineMembers(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    totalstring[0] = EOS;

    strcat(totalstring, "{"#DC_MAIN"}Имя\t{"#DC_MAIN"}Ранг\t{"#DC_MAIN"}Номер телефона\n");
    
    new totalPlayers = 0, phone[25];

    foreach(new i: Player) {
        if (GetPlayerFamilyIndex(i) != familyIndex) {
            continue;
        }

        //SCMF(playerid, -1, "%d, %d, %s", familyIndex, GetPlayerFamilyRankIndex(playerid), family_ranks[familyIndex][GetPlayerFamilyRankIndex(i)][FR_NAME]);

        if (!PlayerInfo[i][pPhoneNumber]) {
            strcat(phone, "{"#DC_GRAY"}Отсутствует");
        } else {
            format(phone, sizeof phone, "%d", PlayerInfo[i][pPhoneNumber]);
        }

        format(
            bigstring,
            sizeof bigstring,
            "{"#DC_MAIN"}%d. {"#DC_WHITE"}%s\t{"#DC_WHITE"}%s\t{"#DC_MAIN"}%s\n",
            totalPlayers + 1,
            GetName(i),
            family_ranks[familyIndex][GetPlayerFamilyRankIndex(i)][FR_NAME],
            phone
        );
        strcat(totalstring, bigstring);
        totalPlayers++;
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyOnlineMembers,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"} Члены семьи онлайн",
        totalstring,
        "Назад",
        ""
    );

    totalstring[0] = EOS;
    bigstring[0] = EOS;
}

DialogResponse:dFamilyOnlineMembers(playerid, response, listitem, inputtext[])
{
    Dialog_Show(playerid, Dialog:dFamilyManage);
}

DialogCreate:dFamilyInfo(playerid)
{
    new familyId = GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_CURRENT);

    if (familyId == 0) {
        familyId = families[GetPlayerFamilyIndex(playerid)][F_ID];
    }

    format(
        totalstring,
        sizeof totalstring,
        "SELECT "\
        "f.name, f.points, fd.name as leader_name, balance, DATE(created_at) as created_at, "\
        "(SELECT COUNT(id) FROM family_members WHERE family_id = %d AND deleted_at IS NULL) as members_count "\
        "FROM families f "\
        "LEFT JOIN (SELECT fm.family_id, (SELECT name FROM accounts WHERE id = fm.member_id) as name FROM family_members fm WHERE rank_id = "#FAMILY_OWNER_RANK") fd ON fd.family_id = f.id "\
        "WHERE id = %d",
        familyId,
        familyId
    );

    new family_name[FAMILY_MAX_COLORED_SYMBOLS], name[MAX_PLAYER_NAME],
        balance, members_count, points, created_at[20];

    new Cache:request_basic_info = mysql_query(mysql, totalstring);

    cache_get_value_name(0, "name", family_name);
    cache_get_value_name(0, "leader_name", name);
    cache_get_value_name(0, "created_at", created_at);
    cache_get_value_name_int(0, "balance", balance);
    cache_get_value_name_int(0, "points", points);
    cache_get_value_name_int(0, "members_count", members_count);

    cache_delete(request_basic_info);

    new deputies[100];

    format(
        totalstring,
        sizeof totalstring,
        "SELECT a.name FROM family_members fm "\
        "LEFT JOIN accounts a ON fm.member_id = a.id "\
        "WHERE fm.deleted_at IS NULL AND family_id = %d AND rank_id = "#FAMILY_DEPUTY_RANK,
        familyId
    );

    new Cache:request_deputies = mysql_query(mysql, totalstring);

    if (cache_num_rows() > 0) {
        new deputy_name[MAX_PLAYER_NAME];

        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_name(i, "name", deputy_name);

            format(
                bigstring,
                sizeof bigstring,
                "\n {"#DC_MAIN"}• {"#DC_WHITE"}%s",
                deputy_name
            );
            strcat(deputies, bigstring);
        }
    } else {
        deputies = "{"#DC_WHITE"}Нет";
    }

    cache_delete(request_deputies);

    if (GetPlayerFamilyIndex(playerid) != INVALID_FAMILY_ID
        && families[GetPlayerFamilyIndex(playerid)][F_ID] == familyId) {
        format(
            totalstring,
            sizeof totalstring,
            "\n{"#DC_MAIN"}На балансе семьи: {"#DC_GREEN"}$%d\n"\
            "{"#DC_MAIN"}Очки репутации: {"#DC_BLUE"}%d\n",
            balance,
            points
        );
    } else {
        totalstring[0] = EOS;
    }

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_MAIN"}Семья: {"#DC_WHITE"}%s {"#DC_WHITE"}[ID: %d]\n\n"\
        "{"#DC_MAIN"}Дата образования: {"#DC_WHITE"}%s\n"\
        "{"#DC_MAIN"}Состав семьи: {"#DC_WHITE"}%d чел.\n"\
        "{"#DC_MAIN"}Онлайн члены семьи: {"#DC_WHITE"}%d чел.\n\n"\
        "{"#DC_MAIN"}Создатель семьи: {"#DC_WHITE"}%s\n"\
        "{"#DC_MAIN"}Заместители: %s\n%s",
        family_name,
        familyId,
        created_at,
        members_count,
        Family:GetFamilyOnlineById(familyId),
        name,
        deputies,
        totalstring
    );

    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyInfo,
        "{"#DC_MAIN"}Информация о семье",
        bigstring,
        "Назад",
        ""
    );

    totalstring[0] = EOS;
    bigstring[0] = EOS;
}

DialogResponse:dFamilyInfo(playerid, response, listitem, inputtext)
{
    if (!GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_CURRENT)) {
        return Dialog_Show(playerid, Dialog:dFamilyManage);
    }

    DeletePVar(playerid, PVAR_FAMILIES_SEARCH_CURRENT);

    Family:SearchForFamily(
        playerid,
        family_search_requests[playerid],
        GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET)
    );

    return true;
}

DialogResponse:dFamilyMembers(playerid, response, listitem, inputtext[])
{
    if (!response) {
        DeletePVar(playerid, PVAR_FAMILIES_SEARCH_OFFSET);

        return Dialog_Show(playerid, Dialog:dFamilyManage);
    }

    new selectedItem = GetPlayerListitemData(playerid, listitem);

    if (selectedItem == FAMILIES_SEARCH_ID_NEXT) {
        return Family:ShowMembers(playerid, GetPlayerFamilyIndex(playerid), GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET) + FAMILIES_PER_PAGE);
    }

    if (selectedItem == FAMILIES_SEARCH_ID_BACK) {
        return Family:ShowMembers(playerid, GetPlayerFamilyIndex(playerid), GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET) - FAMILIES_PER_PAGE);
    }

    DeletePVar(playerid, PVAR_FAMILIES_SEARCH_OFFSET);
    return Dialog_Show(playerid, Dialog:dFamilyManage);
}

DialogResponse:dFamilySearchList(playerid, response, listitem, inputtext[])
{
    if (!response) {
        new bool:is_empty_query = family_search_requests[playerid][0] == EOS;

        DeletePVar(playerid, PVAR_FAMILIES_SEARCH_CURRENT);
        DeletePVar(playerid, PVAR_FAMILIES_SEARCH_OFFSET);
        DeletePVar(playerid, PVAR_FAMILIES_SEARCH_TOTAL);
        family_search_requests[playerid][0] = EOS;

        if (GetPVarInt(playerid, PVAR_FAMILIES_FROM_RL_MANAGE)) {
            DeletePVar(playerid, PVAR_FAMILIES_FROM_RL_MANAGE);
            return Family:GetRelations(playerid, GetPlayerFamilyIndex(playerid), RelationType:GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_RELATION));
        }

        return Dialog_Show(playerid, is_empty_query ? (Dialog:dFamilyCommon) : (Dialog:dFamilyOrderType));
    }

    new selectedItem = GetPlayerListitemData(playerid, listitem);

    if (selectedItem == FAMILIES_SEARCH_ID_NEXT) {
        return Family:SearchForFamily(playerid, family_search_requests[playerid], GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET) + FAMILIES_PER_PAGE);
    }

    if (selectedItem == FAMILIES_SEARCH_ID_BACK) {
        return Family:SearchForFamily(playerid, family_search_requests[playerid], GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET) - FAMILIES_PER_PAGE);
    }

    SetPVarInt(playerid, PVAR_FAMILIES_SEARCH_CURRENT, selectedItem);
    Dialog_Show(playerid, GetPVarInt(playerid, PVAR_FAMILIES_FROM_RL_MANAGE) ? (Dialog:dFamilyConfirmRelation) : (Dialog:dFamilyInfo));
    return true;
}

DialogCreate:dFamilyNothingFound(playerid)
{
    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyNothingFound,
        "{"#DC_MAIN"}Поиск семей",
        "{"#DC_WHITE"}Результаты по запросу не найдены",
        "Назад",
        ""
    );
}

DialogResponse:dFamilyNothingFound(playerid, response, listitem, inputtext[])
{
    Dialog_Show(playerid, Dialog:dFamilyCommon);
}

DialogResponse:dFamilySearch(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyOrderType);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести значение для поиска");
        return Dialog_Show(playerid, Dialog:dFamilySearch);
    }

    new family_search_request[FAMILY_MAX_COLORED_SYMBOLS];

    strcat(family_search_request, inputtext);

    Family:SearchForFamily(playerid, family_search_request, 0);
    return true;
}

DialogCreate:dFamilyDonate(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyDonate,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"} Пожертвование на баланс семьи",
       "{"#DC_WHITE"}Вы можете пожертвовать на баланс семьи от {"#DC_GREEN"}$"#FAMILY_MIN_DONATE"{"#DC_WHITE"} до {"#DC_GREEN"}$"#FAMILY_MAX_DONATE"{"#DC_WHITE"}\n\n"\
       "Введите сумму пожертвования:",

        "Далее",
        "Закрыть"
    );
}

DialogResponse:dFamilyDonate(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyManage);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести сумму для пожертвования");
        return Dialog_Show(playerid, Dialog:dFamilyDonate);
    }

    if (!IsNumeric(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести действительное число!");
        return Dialog_Show(playerid, Dialog:dFamilyDonate);
    }

    new sum = strval(inputtext);

    if (sum < FAMILY_MIN_DONATE || sum > FAMILY_MAX_DONATE) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести число в диапазоне от {"#DC_GREEN"}$"#FAMILY_MIN_DONATE"{"#DC_GREY"} до {"#DC_GREEN"}$"#FAMILY_MAX_DONATE"{"#DC_GRAY"}!");
        return Dialog_Show(playerid, Dialog:dFamilyDonate);
    } 

    if (sum > GetMoney(playerid)) {
        SCM(playerid, COLOR_GREY, N_MONEY);
        return Dialog_Show(playerid, Dialog:dFamilyDonate);
    }

    GiveMoney(playerid, -sum, 0);

    new familyIndex = GetPlayerFamilyIndex(playerid);

    families[familyIndex][F_BALANCE] += sum;

    Family:SaveFamilyInt(familyIndex, "balance", families[familyIndex][F_BALANCE]); 

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] пожертвовал {"#DC_GREEN"}$%d{familyColor} на баланс семьи",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        sum
    );
    Family:SendFamilyMessage(playerid, bigstring);

    bigstring[0] = EOS;

    return Dialog_Show(playerid, Dialog:dFamilyManage);
}

DialogCreate:dFamilyNotificationView(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    if (strlen(families[familyIndex][F_NOTIFICATION]) < 1) {
        Hud:ShowNotification(playerid, ERROR, "Нет активных оповещений");
        return Dialog_Show(playerid, Dialog:dFamilyManage);
    }

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_WHITE"}%s",
        families[familyIndex][F_NOTIFICATION]
    );

    Dialog_MessageEx(playerid,
        Dialog:dFamilyNotificationView,
        "{"#DC_MAIN"}Уведомление семьи",
        bigstring,
        "Назад",
        ""
    );
    return true;
}

DialogResponse:dFamilyNotificationView(playerid)
{
    DeletePVar(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);
    DeletePVar(playerid, PVAR_FAMILIES_EDIT_VEH_RANK);
    DeletePVar(playerid, PVAR_FAMILIES_SELL_VEH);

    return Dialog_Show(playerid, Dialog:dFamilyManage);
}

DialogCreate:dFamilyCreate(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyCreate,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"}Создание семьи",
        "{"#DC_WHITE"}Стоимость создания семьи: {"#DC_MAIN"}"#FAMILY_PRICE"{"#DC_WHITE"} рублей\n\n"\
        "{"#DC_MAIN"}Необходимые требования:\n"\
        " {"#DC_MAIN"}• {"#DC_WHITE"}наличие как минимум "#FAMILY_CREATION_MIN_LEVEL" уровня\n"\
        " {"#DC_MAIN"}• {"#DC_WHITE"}не являться членом семьи\n"\
        " {"#DC_MAIN"}• {"#DC_WHITE"}не иметь собственной семьи\n\n"\
        "Название семьи может состоять из {"#DC_MAIN"}24 символов{"#DC_WHITE"}, не считая\n"\
        "RGB коды (до 62 с учетом RGB кодов). Формат RGB кода: {HEX},\n"\
        "где HEX - шестисимвольный код цвета",

        "Далее",
        "Закрыть"
    );
}

DialogResponse:dFamilyCreate(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    if (GetPlayerLevel(playerid) < FAMILY_CREATION_MIN_LEVEL) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны иметь как минимум "#FAMILY_CREATION_MIN_LEVEL" уровень для создания семьи");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести название для новой семьи!");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    new totalLength = strlen(inputtext);

    if (totalLength > FAMILY_MAX_COLORED_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Название новой семьи не может содержать более "#FAMILY_MAX_COLORED_SYMBOLS" символов с учетом кодов цветов");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    if (totalLength < FAMILY_MIN_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Название новой семьи не может содержать менее "#FAMILY_MIN_SYMBOLS" символов");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    new family_name[FAMILY_MAX_COLORED_SYMBOLS];

    regex_replace(inputtext, "\\{.*?\\}", "\1", family_name, FAMILY_MAX_COLORED_SYMBOLS);

    totalLength = strlen(family_name);

    if (totalLength > FAMILY_MAX_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Название новой семьи не может содержать более "#FAMILY_MAX_SYMBOLS" символов без учета кодов цветов");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    if (totalLength < FAMILY_MIN_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Название новой семьи не может содержать менее "#FAMILY_MIN_SYMBOLS" символов");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    if (PlayerInfo[playerid][pDonateMoney] < FAMILY_PRICE) {
        Hud:ShowNotification(playerid, ERROR, "На вашем балансе должно быть как минимум "#FAMILY_PRICE" рублей для создания семьи");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    PlayerInfo[playerid][pDonateMoney] -= FAMILY_PRICE;

    update_int_mysql(playerid, "donate", PlayerInfo[playerid][pDonateMoney]);

    Family:Create(inputtext, family_name, playerid, FAMILY_MAX_COLORED_SYMBOLS);

    return true;
}

DialogCreate:dFamilyCommonInfo(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyCommonInfo,
        DIALOG_STYLE_MSGBOX,
        "{"#DC_MAIN"} Информация о семьях",
        "{"#DC_MAIN"}Семьи{"#DC_WHITE"} — неотъмлемая часть игрового процесса. Объединяйтесь, развивайтесь\n\
        и достигайте новых высот совместно с теми, кто Вам дорог!\n\n"\
        "{"#DC_MAIN"}Создавая семью, Вы получаете следующие возможности:\n"\
        " {"#DC_MAIN"}• {"#DC_WHITE"}общий транспорт, семейный особняк и склад\n"\
        " {"#DC_MAIN"}• {"#DC_WHITE"}управление рангами и назначение заместителей\n"\
        " {"#DC_MAIN"}• {"#DC_WHITE"}получение дополнительных бонусов за игру в составе семьи\n"\
        " {"#DC_MAIN"}• {"#DC_WHITE"}доступ к рации, которой могут пользоваться все члены семьи\n"\
        " {"#DC_MAIN"}• {"#DC_WHITE"}доступные к покупке уникальные транспортные средства и аксессуары\n\n"\
        "{"#DC_MAIN"}И помни: {"#DC_GREEN"}нет ничего сильнее семьи!",
        "Назад",
        ""
    );
}

DialogResponse:dFamilyCommonInfo(playerid, response, listitem, inputtext[])
{
    return Dialog_Show(playerid, Dialog:dFamilyCommon);
}

DialogResponse:dFamilyInvite(playerid, response, listitem, inputtext[])
{
    if (!response) {
        format(
            bigstring,
            sizeof bigstring,
            "Информация: {"#DC_GREY"}Игрок %s[%d] отказался от Вашего приглашения в семью",
            GetName(playerid),
            playerid
        );

        SCM(GetPVarInt(playerid, PVAR_FAMILIES_INVITED_BY), COLOR_MAIN, bigstring);
        bigstring[0] = EOS;

        DeletePVar(playerid, PVAR_FAMILIES_INVITED_BY);

        return true;
    }

    Family:InvitePlayerToFamily(
        GetPlayerFamilyIndex(GetPVarInt(playerid, PVAR_FAMILIES_INVITED_BY)),
        GetPlayerAccountID(playerid)
    );
    DeletePVar(playerid, PVAR_FAMILIES_INVITED_BY);
    return true;
}

// Owner & deputy manage
DialogCreate:dFamilyLeaderManage(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyLeaderManage,
        DIALOG_STYLE_LIST,
        "{"#DC_MAIN"} Управление семьей",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}Изменить цвет уведомлений семьи\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}Изменить название семьи\n"\
        "{"#DC_MAIN"}3. {"#DC_WHITE"}Изменить название рангов\n"\
        "{"#DC_MAIN"}4. {"#DC_WHITE"}Изменить уведомление семьи\n\n"\
        "{"#DC_MAIN"}5. {"#DC_WHITE"}Управление семейным транспортом\n"\
        "{"#DC_MAIN"}6. {"#DC_WHITE"}Отремонтировать семейный транспорт\n"\
        "{"#DC_MAIN"}7. {"#DC_WHITE"}Доставка семейного транспорта\n"\
        "{"#DC_MAIN"}8. {"#DC_WHITE"}Приобрести семейный транспорт\n"\
        "{"#DC_MAIN"}9. {"#DC_WHITE"}Продать семейный транспорт\n\n"\
        "{"#DC_MAIN"}10. {"#DC_WHITE"}Управление {"#DC_GREEN"}дружескими{"#DC_WHITE"} семьями\n"\
        "{"#DC_MAIN"}11. {"#DC_WHITE"}Управление {"#DC_LRED"}враждебными{"#DC_WHITE"} семьями\n",
        "Далее",
        "Закрыть"
    );
}

DialogResponse:dFamilyLeaderManage(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyManage);
    }

    if (((listitem != 0
        && listitem < 3) || listitem == 8)
        && GetPlayerFamilyRankIndex(playerid) != FAMILY_OWNER_RANK_INDEX) {
        Hud:ShowNotification(playerid, ERROR, "Вы не можете управлять этим");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    switch (listitem) {
        case 0: return Dialog_Show(playerid, Dialog:dFamilySelectColor);
        case 1: return Dialog_Show(playerid, Dialog:dFamilyRename);
        case 2: return Dialog_Show(playerid, Dialog:dFamilyManageListRangs);
        case 3: return Dialog_Show(playerid, Dialog:dFamilyNotification);
        case 4: {
            SetPVarInt(playerid, PVAR_FAMILIES_EDIT_VEH_RANK, 1);
            return Dialog_Show(playerid, Dialog:dFamilyVehicles);
        }
        case 5: return Dialog_Show(playerid, Dialog:dFamilyRepairActive);
        case 6: return Dialog_Show(playerid, Dialog:dFamilyRespawnEmpty);
        case 7: return Dialog_Show(playerid, Dialog:dFamilyBuyVehicle);
        case 8: {
            SetPVarInt(playerid, PVAR_FAMILIES_SELL_VEH, 1);
            return Dialog_Show(playerid, Dialog:dFamilyVehicles);
        }
        case 9: return Family:GetRelations(playerid, GetPlayerFamilyIndex(playerid), FRIENDLY, .fromManage = true);
        case 10: return Family:GetRelations(playerid, GetPlayerFamilyIndex(playerid), HOSTILE, .fromManage = true);
    }

    return Dialog_Show(playerid, Dialog:dFamilyManage);
}

DialogCreate:dFamilyNotification(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    format(bigstring, 500, "\
    {"#DC_WHITE"}Здесь Вы можете написать сообщение для всех членов Вашей семьи.\n\
    (Данное сообщение игроки будут видеть каждый раз, при входе в игру)\n\n\
    {"#DC_BEIGE"}Текущее сообщение: {"#DC_WHITE"}%s\n\n\
    {"#DC_GRAY"}Введите новое сообщение: (от 5 до "#FAMILY_MAX_NOTIFICATION_SYMBOLS" символов). Чтобы отключить сообщение оставьте поле пустым\
    ", families[familyIndex][F_NOTIFICATION]);
    Dialog_Open(playerid, Dialog:dFamilyNotification, DSI, "{"#DC_MAIN"}Сообщение членам семьи", bigstring, "Принять", "Назад");
}

DialogResponse:dFamilyNotification(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid);

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ET_INFO,  "Вы успешно отключили уведомление семьи при входе");
        families[familyIndex][F_NOTIFICATION][0] = EOS;
        Family:SaveFamilyString(familyIndex, "notification", families[familyIndex][F_NOTIFICATION]);
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage); 
    }

    if (strlen(inputtext) < 5 || strlen(inputtext) > FAMILY_MAX_NOTIFICATION_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Сообщение должно быть длиной от 5 до "#FAMILY_MAX_NOTIFICATION_SYMBOLS" символов");
        return Dialog_Show(playerid, Dialog:dFamilyNotification);
    }

    families[familyIndex][F_NOTIFICATION][0] = EOS;
    strcat(families[familyIndex][F_NOTIFICATION], inputtext);
    Family:SaveFamilyString(familyIndex, "notification", inputtext, FAMILY_MAX_NOTIFICATION_SYMBOLS);    

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] изменил уведомление семьи",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid
    );

    Family:SendFamilyMessageByIndex(familyIndex, bigstring);
    bigstring[0] = EOS;

    return true;
}

DialogCreate:dFamilySelectColor(playerid)
{
    totalstring[0] = EOS;

    for (new i = 0; i < sizeof family_available_colors; i++) {
        format(
            bigstring,
            sizeof bigstring,
            "{"#DC_MAIN"}%d. {%s} %s\n",
            i + 1,
            family_available_colors[i][FC_COLOR],
            family_available_colors[i][FC_COLOR_NAME]
        );
        strcat(totalstring, bigstring);
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilySelectColor,
        DIALOG_STYLE_LIST,
        "{"#DC_MAIN"}Выбор цвета",
        totalstring,
        "Выбрать",
        "Назад"
    );

    totalstring[0] = EOS;
}

DialogResponse:dFamilySelectColor(playerid, response, listitem, inputtext[]) {
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid);

    families[familyIndex][F_COLOR][0] = EOS;
    strcat(families[familyIndex][F_COLOR], family_available_colors[listitem][FC_COLOR]);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] изменил цвет уведомлений семьи на \"%s\"",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        family_available_colors[listitem][FC_COLOR_NAME]
    );
    Family:SendFamilyMessage(playerid, bigstring);
    bigstring[0] = EOS;

    Family:SaveFamilyString(familyIndex, "color", families[familyIndex][F_COLOR], 10);

    return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
}

DialogCreate:dFamilyRename(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyRename,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"}Изменение названия семьи",
        "{"#DC_WHITE"}Стоимость изменения названия семьи: {"#DC_GREEN"}"#FAMILY_RENAME_PRICE" RUB\n\n"\
        "{"#DC_WHITE"}Название семьи может состоять из {"#DC_MAIN"}24 символов{"#DC_WHITE"}, не считая\n"\
        "RGB коды (до 62 с учетом RGB кодов). Формат RGB кода: {HEX},\n"\
        "где HEX - шестисимвольный код цвета",

        "Далее",
        "Закрыть"
    );
}

DialogResponse:dFamilyRename(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести новое название для семьи!");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    // test
    new totalLength = strlen(inputtext);

    if (totalLength > FAMILY_MAX_COLORED_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Название семьи не может содержать более "#FAMILY_MAX_COLORED_SYMBOLS" символов с учетом кодов цветов");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    if (totalLength < FAMILY_MIN_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Название семьи не может содержать менее "#FAMILY_MIN_SYMBOLS" символов");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    new family_name[FAMILY_MAX_COLORED_SYMBOLS];

    regex_replace(inputtext, "\\{.*?\\}", "\1", family_name, FAMILY_MAX_COLORED_SYMBOLS);

    totalLength = strlen(family_name);

    if (totalLength > FAMILY_MAX_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Название семьи не может содержать более "#FAMILY_MAX_SYMBOLS" символов без учета кодов цветов");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    if (totalLength < FAMILY_MIN_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Название семьи не может содержать менее "#FAMILY_MIN_SYMBOLS" символов");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    if (PlayerInfo[playerid][pDonateMoney] < FAMILY_RENAME_PRICE) {
        Hud:ShowNotification(playerid, ERROR, "На вашем балансе должно быть как минимум "#FAMILY_RENAME_PRICE" рублей для изменения названия семьи");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid);

    PlayerInfo[playerid][pDonateMoney] -= FAMILY_RENAME_PRICE;

    update_int_mysql(playerid, "donate", PlayerInfo[playerid][pDonateMoney]);
    
    families[familyIndex][F_NAME][0] = EOS;
    strcat(families[familyIndex][F_NAME], inputtext);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] изменил название семьи на {FFFFFF}\"%s\"",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        inputtext
    );
    Family:SendFamilyMessage(playerid, bigstring);
    bigstring[0] = EOS;

    Family:SaveFamilyString(familyIndex, "name", inputtext, FAMILY_MAX_COLORED_SYMBOLS);
    Family:SaveFamilyString(familyIndex, "clean_name", family_name, FAMILY_MAX_SYMBOLS);

    Family:RecreateFamily3DTextLabels(familyIndex);

    return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
}

DialogCreate:dFamilyManageListRangs(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    totalstring[0] = EOS;

    for (new i = 0; i < FAMILY_OWNER_RANK; i++) {
        format(
            bigstring,
            sizeof bigstring,
            "%d. %s\n",
            i + 1,
            family_ranks[familyIndex][i][FR_NAME]
        );

        strcat(totalstring, bigstring);
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyManageListRangs,
        DIALOG_STYLE_LIST,
        "{"#DC_MAIN"}Список рангов",
        totalstring,
        GetPVarInt(playerid, PVAR_FAMILIES_EDIT_VEH_RANK) ? "Выбрать" : "Изменить",
        "Отмена"
    );
    totalstring[0] = EOS;
    bigstring[0] = EOS;
}

DialogResponse:dFamilyManageListRangs(playerid, response, listitem, inputtext[])
{
    if (!response) {
        if (GetPVarInt(playerid, PVAR_FAMILIES_EDIT_VEH_RANK)) {
            return Dialog_Show(playerid, Dialog:dFamilyVehicles);
        }
        
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    if (GetPVarInt(playerid, PVAR_FAMILIES_EDIT_VEH_RANK)) {
        new familyIndex = GetPlayerFamilyIndex(playerid),
            carIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);

        family_cars[familyIndex][carIndex][FV_RANK] = listitem + 1;

        Family:SaveFamilyVehInt(familyIndex, carIndex, "minimum_rank", listitem + 1);
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    SetPVarInt(playerid, PVAR_FAMILIES_CURRENT_RANK, listitem);
    return Dialog_Show(playerid, Dialog:dFamilyRankNameInput);
}

DialogCreate:dFamilyRankNameInput(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyRankNameInput,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"}Изменение названия ранга",
        "{"#DC_WHITE"}Введите новое название ранга в поле ниже длиной до "#FAMILY_MAX_RANK_SYMBOLS":",
        "Далее",
        "Закрыть"
    );
}

DialogResponse:dFamilyRankNameInput(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyManageListRangs);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести новое название ранга");
        return Dialog_Show(playerid, Dialog:dFamilyRankNameInput);
    }

    new totalLength = strlen(inputtext);

    if (totalLength > FAMILY_MAX_RANK_SYMBOLS || totalLength < FAMILY_MIN_RANK_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "Ранг не может содержать более "#FAMILY_MAX_RANK_SYMBOLS" и менее "#FAMILY_MIN_RANK_SYMBOLS"х символов");
        return Dialog_Show(playerid, Dialog:dFamilyRankNameInput);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid),
        currentRank = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_RANK);

    family_ranks[familyIndex][currentRank][FR_NAME][0] = EOS;
    strcat(family_ranks[familyIndex][currentRank][FR_NAME], inputtext);

    Family:SaveFamilyRankString(familyIndex, currentRank, "title", family_ranks[familyIndex][currentRank][FR_NAME], FAMILY_MAX_RANK_SYMBOLS);

    return Dialog_Show(playerid, Dialog:dFamilyManageListRangs);
}

DialogCreate:dFamilyRepairActive(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    new totalRepairableCars = Family:GetDamagedCarsCount(familyIndex);

    if (totalRepairableCars == 0) {
        Hud:ShowNotification(playerid, ERROR, "Не найдено автомобилей для починки");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_WHITE"}Вы действительно хотите отремонтировать {"#DC_MAIN"}%d{"#DC_WHITE"} машин за {"#DC_GREEN"}$%d{"#DC_WHITE"}?",
        totalRepairableCars,
        totalRepairableCars * FAMILY_VEHICLE_REPAIR_PRICE
    );

    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyRepairActive,
        "{"#DC_MAIN"}Починка транспорта",
        bigstring,
        "Подтвердить",
        "Назад"
    );

    bigstring[0] = EOS;
    return true;
}

DialogResponse:dFamilyRepairActive(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid);

    new price = Family:GetDamagedCarsCount(familyIndex) * FAMILY_VEHICLE_REPAIR_PRICE;

    if (families[familyIndex][F_BALANCE] < price) {
        Hud:ShowNotification(playerid, ERROR, "На балансе семьи недостаточно средств для починки всех автомобилей");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    Family:RepairVehicles(familyIndex);

    families[familyIndex][F_BALANCE] -= price;

    Family:SaveFamilyInt(familyIndex, "balance",  families[familyIndex][F_BALANCE]);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] починил весь активный транспорт семьи",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid
    );
    Family:SendFamilyMessage(playerid, bigstring);
    bigstring[0] = EOS;

    return true;
}

DialogCreate:dFamilyRespawnEmpty(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    new totalRepairableCars = Family:GetEmptyVehiclesCount(familyIndex);

    if (totalRepairableCars == 0) {
        Hud:ShowNotification(playerid, ERROR, "Не найдено автомобилей для респавна");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_WHITE"}Вы действительно хотите отправить на респавн {"#DC_MAIN"}%d{"#DC_WHITE"} машин за {"#DC_GREEN"}$%d{"#DC_WHITE"}?",
        totalRepairableCars,
        totalRepairableCars * FAMILY_VEHICLE_RESPAWN_PRICE
    );

    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyRespawnEmpty,
        "{"#DC_MAIN"}Респавн транспорта",
        bigstring,
        "Подтвердить",
        "Назад"
    );

    bigstring[0] = EOS;
    return true;
}

DialogResponse:dFamilyRespawnEmpty(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid);

    new price = Family:GetEmptyVehiclesCount(familyIndex) * FAMILY_VEHICLE_RESPAWN_PRICE;

    if (families[familyIndex][F_BALANCE] < price) {
        Hud:ShowNotification(playerid, ERROR, "На балансе семьи недостаточно средств для респавна всех свободных автомобилей");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    Family:RespawnEmptyVehicles(familyIndex);

    families[familyIndex][F_BALANCE] -= price;

    Family:SaveFamilyInt(familyIndex, "balance",  families[familyIndex][F_BALANCE]);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] зареспавнил весь незанятый транспорт семьи",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        family_available_colors[listitem][FC_COLOR_NAME]
    );
    Family:SendFamilyMessage(playerid, bigstring);
    bigstring[0] = EOS;

    return true;
}

DialogCreate:dFamilyBuyVehicle(playerid)
{
    new freeSlot = Family:GetFreeFamilyVehicleSlot(GetPlayerFamilyIndex(playerid));

    if (freeSlot == INVALID_FAMILY_ID) {
        Hud:ShowNotification(playerid, ERROR, "Вы достигли лимита купленного транспорта.");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    if (GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0) {
        Hud:ShowNotification(playerid, ERROR, "Вы не можете приобрести транспорт, находясь в этом месте");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    totalstring[0] = EOS;

    new price[20];

    strcat(totalstring, "{"#DC_MAIN"}Автомобиль\t{"#DC_MAIN"}Цена\n");

    for (new i = 0; i < sizeof available_family_cars; i++) {
        if (available_family_cars[i][FAC_PRICE_TYPE] == DONATE) {
            format(price, sizeof price, "{"#DC_GOLD"}%d RUB", available_family_cars[i][FAC_PRICE]);
        } else {
            format(price, sizeof price, "{"#DC_GREEN"}$%d", available_family_cars[i][FAC_PRICE]);
        }

        format(
            bigstring,
            sizeof bigstring,
            "{"#DC_MAIN"}%d. {"#DC_WHITE"}%s\t%s\n",
            i + 1,
            GetVehicleConfig(available_family_cars[i][FAC_MODEL], VC_NAME),
            price
        );
        strcat(totalstring, bigstring);
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyBuyVehicle,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}Покупка транспорта",
        totalstring,
        "Выбрать",
        "Назад"
    );

    totalstring[0] = EOS;
    bigstring[0] = EOS;
    return true;
}

DialogResponse:dFamilyBuyVehicle(playerid, response, listitem, inputtext[])
{
    if (!response) {
        DeletePVar(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManager);
    }

    SetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE, listitem);
    return Dialog_Show(playerid, Dialog:dFamilyBuyVehicleConfirm);
}

DialogCreate:dFamilyBuyVehicleConfirm(playerid)
{
    new vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);

    new price[20];

    if (available_family_cars[vehicleIndex][FAC_PRICE_TYPE] == DONATE) {
        format(price, sizeof price, "{"#DC_GOLD"}%d RUB", available_family_cars[vehicleIndex][FAC_PRICE]);
    } else {
        format(price, sizeof price, "{"#DC_GREEN"}$%d", available_family_cars[vehicleIndex][FAC_PRICE]);
    }

    format(
        bigstring, sizeof bigstring,
        "{"#DC_WHITE"}Вы действительно хотите приобрести автомобиль {"#DC_MAIN"}%s{"#DC_WHITE"} за %s{"#DC_WHITE"}?",
        GetVehicleConfig(available_family_cars[vehicleIndex][FAC_MODEL], VC_NAME),
        price
    );

    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyBuyVehicleConfirm,
        "{"#DC_MAIN"}Подтверждение покупки транспорта",
        bigstring,
        "Подтвердить",
        "Назад"
    );

    bigstring[0] = EOS;
    return true;
}

DialogResponse:dFamilyBuyVehicleConfirm(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyBuyVehicle);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid),
        vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE),
        freeSlot = Family:GetFreeFamilyVehicleSlot(familyIndex);

    if (freeSlot == INVALID_FAMILY_ID) {
        Hud:ShowNotification(playerid, ERROR, "Вы достигли лимита купленного семейного транспорта.");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    new price = available_family_cars[vehicleIndex][FAC_PRICE];

    switch (available_family_cars[vehicleIndex][FAC_PRICE_TYPE]) {
        case FAMILY_CASH: {
            if (families[familyIndex][F_BALANCE] < price) {
                Hud:ShowNotification(playerid, ERROR, "На балансе семьи недостаточно средств для покупки этого транспорта");
                return Dialog_Show(playerid, Dialog:dFamilyBuyVehicle);
            }

            families[familyIndex][F_BALANCE] -= price;
            Family:SaveFamilyInt(familyIndex, "balance", families[familyIndex][F_BALANCE]);
            Family:BuyNewVehicle(playerid, familyIndex, freeSlot, vehicleIndex);
            return true;
        }

        case DONATE: {
            if (PlayerInfo[playerid][pDonateMoney] < price) {
                Hud:ShowNotification(playerid, ERROR, "На вашем балансе недостаточно средств для покупки этого транспорта");
                return Dialog_Show(playerid, Dialog:dFamilyBuyVehicle);
            }

            PlayerInfo[playerid][pDonateMoney] -= price;

            update_int_mysql(playerid, "donate", PlayerInfo[playerid][pDonateMoney]);
            Family:BuyNewVehicle(playerid, familyIndex, freeSlot, vehicleIndex);
            return true;
        }
    }

    return true;
}

DialogCreate:dFamilyVehColor(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyVehColor,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"} Установка цвета транспорта",
        "{"#DC_WHITE"}Выбор {"#DC_MAIN"}цвета 1{"#DC_WHITE"}\n\n"\
        "Введите ID цвета автомобиля числом от 0 до 255 в поле:",

        "Далее",
        "Назад"
    );

    bigstring[0] = EOS;
}

DialogResponse:dFamilyVehColor(playerid, response, listitem, inputtext[])
{
    if (!response) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны установить цвет для купленного автомобиля");
        return Dialog_Show(playerid, Dialog:dFamilyVehColor);
    }

    if (isnull(inputtext) || !IsNumeric(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести действительный цвет числом");
        return Dialog_Show(playerid, Dialog:dFamilyVehColor);
    }

    new number = strval(inputtext);

    if (number < 0 || number > 255) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести цвет числом в диапазоне от 0 до 255");
        return Dialog_Show(playerid, Dialog:dFamilyVehColor);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid),
        vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);

    family_cars[familyIndex][vehicleIndex][FV_COLOR_1] = number;
    Family:SaveFamilyVehInt(familyIndex, vehicleIndex, "color_1", number); 

    return Dialog_Show(playerid, Dialog:dFamilyVehColor2);    
}


DialogCreate:dFamilyVehColor2(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyVehColor2,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"} Установка цвета транспорта",
        "{"#DC_WHITE"}Выбор {"#DC_MAIN"}цвета 2{"#DC_WHITE"}\n\n"\
        "Введите ID цвета автомобиля числом от 0 до 255 в поле:",

        "Далее",
        "Назад"
    );

    bigstring[0] = EOS;
}

DialogResponse:dFamilyVehColor2(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyVehColor);
    }

    if (isnull(inputtext) || !IsNumeric(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести действительный цвет числом");
        return Dialog_Show(playerid, Dialog:dFamilyVehColor2);
    }

    new number = strval(inputtext);

    if (number < 0 || number > 255) {
        Hud:ShowNotification(playerid, ERROR, "Вы должны ввести цвет числом в диапазоне от 0 до 255");
        return Dialog_Show(playerid, Dialog:dFamilyVehColor2);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid),
        vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);

    family_cars[familyIndex][vehicleIndex][FV_COLOR_2] = number;
    Family:SaveFamilyVehInt(familyIndex, vehicleIndex, "color_2", number);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] приобрел автомобиль %s для семьи",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        GetVehicleConfig(family_cars[familyIndex][vehicleIndex][FV_MODEL], VC_NAME)
    );
    Family:SendFamilyMessage(playerid, bigstring);
    bigstring[0] = EOS;

    return true;
}

DialogCreate:dFamilyConfirmVehicleSell(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid),
        vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);

    new model = family_cars[familyIndex][vehicleIndex][FV_MODEL];

    format(
        bigstring,
        sizeof bigstring,
        "Вы действительно хотите продать %s за %s",
        GetVehicleConfig(model, VC_NAME),
        Family:GetSellPriceStringForModel(model)
    );
    
    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyConfirmVehicleSell,
        "{"#DC_MAIN"}Продажа транспорта семьи",
        bigstring,
        "Подтвердить",
        "Отмена"
    );

    bigstring[0] = EOS;
}

DialogResponse:dFamilyConfirmVehicleSell(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid),
        vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);

    new model = family_cars[familyIndex][vehicleIndex][FV_MODEL];

    if (family_cars[familyIndex][vehicleIndex][FV_STATE] == ALIVE) {
        Family:UnloadVehicle(familyIndex, vehicleIndex);
    }

    new price = Family:GetSellPriceForModel(model);

    /*
    switch (Family:GetSellPriceTypeForModel(model)) {
        case FAMILY_CASH: {
            families[familyIndex][F_BALANCE] += price;
            Family:SaveFamilyInt(familyIndex, "balance", families[familyIndex][F_BALANCE]);
        }

        case DONATE: {
            PlayerInfo[playerid][pDonateMoney] += price;
            update_int_mysql(playerid, "donate", PlayerInfo[playerid][pDonateMoney]);
        }
    }
    */
    
    families[familyIndex][F_BALANCE] += price;
    Family:SaveFamilyInt(familyIndex, "balance", families[familyIndex][F_BALANCE]);

    format(
        bigstring,
        sizeof bigstring,
        "DELETE FROM "#DB_FAMILY_VEHICLES" WHERE id = %d",
        family_cars[familyIndex][vehicleIndex][FV_ID]
    );
    mysql_tquery(mysql, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] продал автомобиль семьи %s",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        GetVehicleConfig(family_cars[familyIndex][vehicleIndex][FV_MODEL], VC_NAME)
    );
    Family:SendFamilyMessage(playerid, bigstring);

    family_cars[familyIndex][vehicleIndex] = default_family_vehicle;

    bigstring[0] = EOS;
    return true;
}