DialogCreate:dFamilyCommon(playerid)
{
    format(
        totalstring,
        sizeof totalstring,
        "{"#DC_MAIN"}1. {"#DC_WHITE"}���������� � ������\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}�������� �����\n"\
        "{"#DC_MAIN"}3. {"#DC_WHITE"}����� �����\n"\
        "{"#DC_MAIN"}4. {"#DC_WHITE"}������ �����\n"
    );

    if (IsFamilyMember(playerid)) {
        strcat(
            totalstring,
            "{"#DC_MAIN"}5. {"#DC_WHITE"}���������� ������\n"
        );

        if (GetPlayerFamilyRankIndex(playerid) == FAMILY_OWNER_RANK_INDEX) {
            strcat(
                totalstring,
                "{"#DC_MAIN"}6. {"#DC_WHITE"}����� �������� � ������� �����\n"\
                "{"#DC_MAIN"}7. {"#DC_WHITE"}�������� ����� ������ �����\n"\
                "{"#DC_RED"}���������� �����\n"
            );
        }
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyCommon,
        DIALOG_STYLE_LIST,
        "{"#DC_MAIN"} �����",
        totalstring,
        "�����",
        "�������"
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
                return Hud:ShowNotification(playerid, ERROR, "�� �� ������ ������� ����� �����, ������ ������ �����");
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
        Hud:ShowNotification(playerid, ERROR, "�� ������ ����� �������� � ������� ����� �� ����� 1 ���� � 5 �����");
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyCash,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"} ������ ������� � ������� �����",
       "{"#DC_WHITE"}�� ������ ����� �������� � ������� �����. �� ��� ����� ����� �� {"#DC_GREEN"}$"#FAMILY_MIN_WITHDRAW"{"#DC_WHITE"} �� {"#DC_GREEN"}$"#FAMILY_MAX_WITHDRAW"{"#DC_WHITE"}\n\n"\
       "������� ����� ������:",

        "�����",
        "�������"
    );

    return true;
}

DialogResponse:dFamilyCash(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ ����� ��� ������");
        return Dialog_Show(playerid, Dialog:dFamilyCash);
    }

    if (!IsNumeric(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ �������������� �����!");
        return Dialog_Show(playerid, Dialog:dFamilyCash);
    }

    new sum = strval(inputtext);

    if (sum < FAMILY_MIN_WITHDRAW || sum > FAMILY_MAX_WITHDRAW) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ ����� � ��������� �� {"#DC_GREEN"}$"#FAMILY_MIN_WITHDRAW"{"#DC_GREY"} �� {"#DC_GREEN"}$"#FAMILY_MAX_WITHDRAW"{"#DC_GRAY"}!");
        return Dialog_Show(playerid, Dialog:dFamilyCash);
    } 

    if (sum > families[GetPlayerFamilyIndex(playerid)][F_BALANCE]) {
        Hud:ShowNotification(playerid, ERROR, "�� ������� ����� ������������ ������� ��� ������ ����� �����");
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
        FAMILY_ACTIONS_PREFIX"%s[%d] ���� {"#DC_GREEN"}$%d{familyColor} � ������� �����",
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
        "{"#DC_MAIN"}������� �����",
        "{"#DC_WHITE"}�� ������������� ������ ���������� �����?\n\n"\
        "{"#DC_LRED"}��� �������� ����������!",
        "�����������",
        "�����"
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
        Hud:ShowNotification(playerid, ERROR, "�� �� ������ ���������� ���� �����, ���� � ��� ���� ���������");
        return Dialog_Show(playerid, Dialog:dFamilyDissolve);
    }

    if (Family:GetFamilyVehiclesCount(familyIndex) > 0) {
        Hud:ShowNotification(playerid, ERROR, "�� �� ������ ���������� ���� �����, ���� �� ������ �������� ���������");
        return Dialog_Show(playerid, Dialog:dFamilyDissolve);
    }

    format(
        totalstring, 144,
        "[A] ����� {"#DC_WHITE"}%s[%d] {92c13f}��������� ����� %s {92c13f}[ID: %d]",
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

    Hud:ShowNotification(playerid, ET_INFO,  "�� ������� ���������� ���� �����");

    return true;
}

DialogCreate:dFamilyAssignLeader(playerid)
{
    Dialog_Open(
        playerid,
        Dialog:dFamilyAssignLeader,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"}��������� ���������",
        "{"#DC_WHITE"}������� ��� ������ ��������� �����. ����� �������� ������ �������� ����� ������������ � ���������� ����� � ����.\n\n"\
        "{"#DC_LRED"}��������! �� ��������� ���� ����� ��������� �����������, ������� �� ����� ����������.\n"\
        "������ ��������� � ���, ��� �������!",
        "�����������",
        "�����"
    );
    return true;
}

DialogResponse:dFamilyAssignLeader(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ ��� ������ ���������!");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    new target_id = GetPlayerIdByName(inputtext);

    if (target_id == INVALID_PLAYER_ID) {
        Hud:ShowNotification(playerid, ERROR, "��������� ����� �� ������");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    if (!IsPlayerInRangeOfPlayer(5.0, playerid, target_id)) {
        Hud:ShowNotification(playerid, ERROR, "���� ����� �� ����� � ����");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    if (GetPlayerFamilyIndex(playerid) != GetPlayerFamilyIndex(target_id)) {
        Hud:ShowNotification(playerid, ERROR, "���� ����� �� �������� ������ ����� �����");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    if (GetPlayerFamilyRankIndex(target_id) != FAMILY_DEPUTY_RANK_INDEX) {
        Hud:ShowNotification(playerid, ERROR, "����� �� �������� ����� ������������");
        return Dialog_Show(playerid, Dialog:dFamilyAssignLeader);
    }

    PlayerInfo[target_id][p_family_rank_index] = FAMILY_OWNER_RANK_INDEX;
    PlayerInfo[playerid][p_family_rank_index] = FAMILY_DEPUTY_RANK_INDEX;

    Family:SavePlayerRank(playerid);
    Family:SavePlayerRank(target_id);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s[%d] �������� ����� ���������� �����",
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

    strcat(bigstring, "{"#DC_MAIN"}����������\t{"#DC_MAIN"}������\t{"#DC_MAIN"}���������\n");
    
    new veh_state[20];

    ClearPlayerListitemData(playerid);

    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_MODEL] == INVALID_FAMILY_ID)
            continue;

        SetPlayerListitemData(playerid, totalVehicles, i);

        switch (family_cars[familyIndex][i][FV_STATE]) {
            case ALIVE: format(veh_state, sizeof veh_state, "{"#DC_GREEN"}�������");
            case DEAD: format(veh_state, sizeof veh_state, "{"#DC_RED"}���������");
            case NOT_SPAWNED: format(veh_state, sizeof veh_state, "{"#DC_GRAY"}�� ����������");
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
            "{"#DC_MAIN"}�������� ���������",
            "{"#DC_WHITE"}�������� ��������� �� ������",
            "�����",
            "" 
        );
    }


    Dialog_Open(
        playerid,
        Dialog:dFamilyVehicles,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}������ ���������� �����",
        bigstring,
        "�������",
        "�����"
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
        Hud:ShowNotification(playerid, ERROR, "�� �������� ������ ���������� ����������");
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_WHITE"}�� ������������� ������ ���������� ���������� {"#DC_MAIN"}%s{"#DC_WHITE"}?\n"\
        "���� ����� ����� ������� ��� {"#DC_MAIN"}%d{"#DC_WHITE"} �����������.",
        GetVehicleConfig(family_cars[familyIndex][vehicleIndex][FV_MODEL], VC_NAME),
        Family:GetAvailableCarsToSpawn(familyIndex)
    );

    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyConfirmVehicleSpawn,
        "{"#DC_MAIN"}������������� ������ ����������",
        bigstring,
        "�����������",
        "������"
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
        Hud:ShowNotification(playerid, ERROR, "���������� ���������� ���� ���������");
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    if (!Family:SpawnVehicle(playerid, vehicleIndex)) {
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    if (GetPlayerVehicleID(playerid) == family_cars[familyIndex][vehicleIndex][FV_VEHICLE_ID]) {
        Hud:ShowNotification(playerid, ERROR, "�� ��� ���������� � ���� ����������");
        return Dialog_Show(playerid, Dialog:dFamilyVehicles);
    }

    new Float:x, Float:y, Float:z;

    GetVehiclePos(family_cars[familyIndex][vehicleIndex][FV_VEHICLE_ID], x, y, z);
    SetPlayerGPS(playerid, x, y, z, "���������� �����");

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
        "{"#DC_MAIN"} ���������� �����������",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}��������� ��������� - {"#DC_GREEN"}$"#FAMILY_VEHICLE_UNLOAD_COST"\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}�������� ���� �������\n",
        "�����",
        "�������"
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
                Hud:ShowNotification(playerid, ERROR, "�� ������� ����� ����� ������������ ������� ��� �������� ����������");
                return Dialog_Show(playerid, Dialog:dFamilyVehAction);
            }

            if (IsVehicleOccupied(vehicleid)) {
                Hud:ShowNotification(playerid, ERROR, "���������� ��������� ���������, ������� ���-�� ������������");
                return Dialog_Show(playerid, Dialog:dFamilyVehAction);
            }

            new Float:vhealth;

            GetVehicleHealth(vehicleid, vhealth);

            if (vhealth < 950.0) {
                Hud:ShowNotification(playerid, ERROR, "�� �� ������ ��������� ������������ ���������");
                return Dialog_Show(playerid, Dialog:dFamilyVehAction);
            }

            families[familyIndex][F_BALANCE] -= FAMILY_VEHICLE_UNLOAD_COST;
            Family:SaveFamilyInt(familyIndex, "balance",  families[familyIndex][F_BALANCE]);

            Family:UnloadVehicle(familyIndex, vehicleIndex);

            format(
                totalstring,
                sizeof totalstring,
                FAMILY_ACTIONS_PREFIX"%s %s[%d] �������� �������� ��������� \"%s\"",
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

            SetPlayerGPS(playerid, x, y, z, "���������� �����");
            return true;
        }
        case DEAD: {
            Hud:ShowNotification(playerid, ERROR, "���������� ��� ���������. ����� ��� ����������� ����� ������������ ������������ ���������� � ����������� ����");
            return true;
        }

        case NOT_SPAWNED: {
            if (GetPlayerFamilyRankIndex(playerid) < family_cars[familyIndex][selectedItem][FV_RANK] - 1) {
                Hud:ShowNotification(playerid, ERROR, "� ��� ��� ������� � ����� ����������");
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
        "{"#DC_MAIN"} ����� ����� - ����������",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}�� ������ � �����\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}�� ����� � ������\n"\
        "{"#DC_MAIN"}3. {"#DC_WHITE"}���������� ���������� ����������\n"\
        "{"#DC_MAIN"}4. {"#DC_WHITE"}���������� ���������� ����������\n",
        "�����",
        "�������"
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
        "{"#DC_WHITE"}����� ����� �� ������ ������: {"#DC_MAIN"}%d{"#DC_WHITE"}\n\n"\
        "������� �������� �����, ������� ������ �����, � ���� ����:",
        Family:GetFamiliesCount()
    );

    Dialog_Open(
        playerid,
        Dialog:dFamilySearch,
        DIALOG_STYLE_INPUT,
        "{"#DC_MAIN"} ����� �����",
        bigstring,

        "�����",
        "�����"
    );

    bigstring[0] = EOS;
}

DialogCreate:dFamilyManage(playerid)
{
    format(
        totalstring,
        sizeof totalstring,
        "{"#DC_MAIN"}1. {"#DC_WHITE"}���������� � �����\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}������ ����� {"#DC_WHITE"}[{"#DC_GREEN"}ONLINE{"#DC_WHITE"}]\n"\
        "{"#DC_MAIN"}3. {"#DC_WHITE"}����� ������ �����\n"\
        "{"#DC_MAIN"}4. {"#DC_WHITE"}������ {"#DC_GREEN"}���������{"#DC_WHITE"} �����\n"\
        "{"#DC_MAIN"}5. {"#DC_WHITE"}������ {"#DC_LRED"}����������{"#DC_WHITE"} �����\n"\
        "{"#DC_MAIN"}6. {"#DC_WHITE"}������ ��������� ����������\n"\
        "{"#DC_MAIN"}7. {"#DC_WHITE"}������������ �������� �� �������� ����\n"\
        "{"#DC_MAIN"}8. {"#DC_WHITE"}����������� �����\n"\
        "{"#DC_MAIN"}9. {FFCD00}���������� ������\n"
    );

    if (GetPlayerFamilyRankIndex(playerid) < FAMILY_OWNER_RANK_INDEX) {
        strcat(totalstring, "{"#DC_LRED"}�������� �����");
    }

    Dialog_Open(
        playerid,
        Dialog:dFamilyManage,
        DIALOG_STYLE_LIST,
        "{"#DC_MAIN"} �����",
        totalstring,
        "�����",
        "�������"
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
                Hud:ShowNotification(playerid, ERROR, "�� �� ������ ������������ ���");
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
        "{"#DC_MAIN"}������������� ������ ���������",
        "{"#DC_WHITE"}�� ������������� ������ ������ ��������� � ���� ������?",
        "�����������",
        "������"
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
            "�� ��� %s � ���� ������",
            relationDbType == HOSTILE ? "���������" : "�������"
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
        FAMILY_ACTIONS_PREFIX"%s %s[%d] ������� %s ����� %s",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        RelationType:relationType == HOSTILE ? "����������" : "�������������",
        family_name
    );
    Family:SendFamilyMessageByIndex(familyIndex, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s[%d] �� ����� %s ������� ���� ����� %s",
        GetName(playerid),
        playerid,
        families[familyIndex][F_NAME],
        RelationType:relationType == HOSTILE ? "����������" : "�������������"
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
        "{"#DC_MAIN"}������������� ������� ���������",
        "{"#DC_WHITE"}�� ������������� ������ ��������� ��������� � ���� ������?",
        "�����������",
        "������"
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
        "%s %s[%d] �������� %s ��������� � ������ %s",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        (relationType == HOSTILE ? "����������" : "���������"),
        family_name
    );
    Family:SendFamilyMessageByIndex(familyIndex, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        "%s[%d] �� ����� %s{familyColor} �������� %s ��������� � ����� ������",
        GetName(playerid),
        playerid,
        families[familyIndex][F_NAME],
        (relationType == HOSTILE ? "����������" : "���������")
    );

    Family:SendFamilyMessageById(relatedFamilyId, bigstring);
    bigstring[0] = EOS;

    return true;
}

DialogCreate:dFamilyOnlineMembers(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    totalstring[0] = EOS;

    strcat(totalstring, "{"#DC_MAIN"}���\t{"#DC_MAIN"}����\t{"#DC_MAIN"}����� ��������\n");
    
    new totalPlayers = 0, phone[25];

    foreach(new i: Player) {
        if (GetPlayerFamilyIndex(i) != familyIndex) {
            continue;
        }

        //SCMF(playerid, -1, "%d, %d, %s", familyIndex, GetPlayerFamilyRankIndex(playerid), family_ranks[familyIndex][GetPlayerFamilyRankIndex(i)][FR_NAME]);

        if (!PlayerInfo[i][pPhoneNumber]) {
            strcat(phone, "{"#DC_GRAY"}�����������");
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
        "{"#DC_MAIN"} ����� ����� ������",
        totalstring,
        "�����",
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
                "\n {"#DC_MAIN"}� {"#DC_WHITE"}%s",
                deputy_name
            );
            strcat(deputies, bigstring);
        }
    } else {
        deputies = "{"#DC_WHITE"}���";
    }

    cache_delete(request_deputies);

    if (GetPlayerFamilyIndex(playerid) != INVALID_FAMILY_ID
        && families[GetPlayerFamilyIndex(playerid)][F_ID] == familyId) {
        format(
            totalstring,
            sizeof totalstring,
            "\n{"#DC_MAIN"}�� ������� �����: {"#DC_GREEN"}$%d\n"\
            "{"#DC_MAIN"}���� ���������: {"#DC_BLUE"}%d\n",
            balance,
            points
        );
    } else {
        totalstring[0] = EOS;
    }

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_MAIN"}�����: {"#DC_WHITE"}%s {"#DC_WHITE"}[ID: %d]\n\n"\
        "{"#DC_MAIN"}���� �����������: {"#DC_WHITE"}%s\n"\
        "{"#DC_MAIN"}������ �����: {"#DC_WHITE"}%d ���.\n"\
        "{"#DC_MAIN"}������ ����� �����: {"#DC_WHITE"}%d ���.\n\n"\
        "{"#DC_MAIN"}��������� �����: {"#DC_WHITE"}%s\n"\
        "{"#DC_MAIN"}�����������: %s\n%s",
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
        "{"#DC_MAIN"}���������� � �����",
        bigstring,
        "�����",
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
        "{"#DC_MAIN"}����� �����",
        "{"#DC_WHITE"}���������� �� ������� �� �������",
        "�����",
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
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ �������� ��� ������");
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
        "{"#DC_MAIN"} ������������� �� ������ �����",
       "{"#DC_WHITE"}�� ������ ������������ �� ������ ����� �� {"#DC_GREEN"}$"#FAMILY_MIN_DONATE"{"#DC_WHITE"} �� {"#DC_GREEN"}$"#FAMILY_MAX_DONATE"{"#DC_WHITE"}\n\n"\
       "������� ����� �������������:",

        "�����",
        "�������"
    );
}

DialogResponse:dFamilyDonate(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyManage);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ ����� ��� �������������");
        return Dialog_Show(playerid, Dialog:dFamilyDonate);
    }

    if (!IsNumeric(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ �������������� �����!");
        return Dialog_Show(playerid, Dialog:dFamilyDonate);
    }

    new sum = strval(inputtext);

    if (sum < FAMILY_MIN_DONATE || sum > FAMILY_MAX_DONATE) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ ����� � ��������� �� {"#DC_GREEN"}$"#FAMILY_MIN_DONATE"{"#DC_GREY"} �� {"#DC_GREEN"}$"#FAMILY_MAX_DONATE"{"#DC_GRAY"}!");
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
        FAMILY_ACTIONS_PREFIX"%s %s[%d] ����������� {"#DC_GREEN"}$%d{familyColor} �� ������ �����",
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
        Hud:ShowNotification(playerid, ERROR, "��� �������� ����������");
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
        "{"#DC_MAIN"}����������� �����",
        bigstring,
        "�����",
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
        "{"#DC_MAIN"}�������� �����",
        "{"#DC_WHITE"}��������� �������� �����: {"#DC_MAIN"}"#FAMILY_PRICE"{"#DC_WHITE"} ������\n\n"\
        "{"#DC_MAIN"}����������� ����������:\n"\
        " {"#DC_MAIN"}� {"#DC_WHITE"}������� ��� ������� "#FAMILY_CREATION_MIN_LEVEL" ������\n"\
        " {"#DC_MAIN"}� {"#DC_WHITE"}�� �������� ������ �����\n"\
        " {"#DC_MAIN"}� {"#DC_WHITE"}�� ����� ����������� �����\n\n"\
        "�������� ����� ����� �������� �� {"#DC_MAIN"}24 ��������{"#DC_WHITE"}, �� ������\n"\
        "RGB ���� (�� 62 � ������ RGB �����). ������ RGB ����: {HEX},\n"\
        "��� HEX - ��������������� ��� �����",

        "�����",
        "�������"
    );
}

DialogResponse:dFamilyCreate(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyCommon);
    }

    if (GetPlayerLevel(playerid) < FAMILY_CREATION_MIN_LEVEL) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ����� ��� ������� "#FAMILY_CREATION_MIN_LEVEL" ������� ��� �������� �����");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ �������� ��� ����� �����!");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    new totalLength = strlen(inputtext);

    if (totalLength > FAMILY_MAX_COLORED_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "�������� ����� ����� �� ����� ��������� ����� "#FAMILY_MAX_COLORED_SYMBOLS" �������� � ������ ����� ������");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    if (totalLength < FAMILY_MIN_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "�������� ����� ����� �� ����� ��������� ����� "#FAMILY_MIN_SYMBOLS" ��������");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    new family_name[FAMILY_MAX_COLORED_SYMBOLS];

    regex_replace(inputtext, "\\{.*?\\}", "\1", family_name, FAMILY_MAX_COLORED_SYMBOLS);

    totalLength = strlen(family_name);

    if (totalLength > FAMILY_MAX_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "�������� ����� ����� �� ����� ��������� ����� "#FAMILY_MAX_SYMBOLS" �������� ��� ����� ����� ������");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    if (totalLength < FAMILY_MIN_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "�������� ����� ����� �� ����� ��������� ����� "#FAMILY_MIN_SYMBOLS" ��������");
        return Dialog_Show(playerid, Dialog:dFamilyCreate);
    }

    if (PlayerInfo[playerid][pDonateMoney] < FAMILY_PRICE) {
        Hud:ShowNotification(playerid, ERROR, "�� ����� ������� ������ ���� ��� ������� "#FAMILY_PRICE" ������ ��� �������� �����");
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
        "{"#DC_MAIN"} ���������� � ������",
        "{"#DC_MAIN"}�����{"#DC_WHITE"} � ����������� ����� �������� ��������. �������������, ������������\n\
        � ���������� ����� ����� ��������� � ����, ��� ��� �����!\n\n"\
        "{"#DC_MAIN"}�������� �����, �� ��������� ��������� �����������:\n"\
        " {"#DC_MAIN"}� {"#DC_WHITE"}����� ���������, �������� ������� � �����\n"\
        " {"#DC_MAIN"}� {"#DC_WHITE"}���������� ������� � ���������� ������������\n"\
        " {"#DC_MAIN"}� {"#DC_WHITE"}��������� �������������� ������� �� ���� � ������� �����\n"\
        " {"#DC_MAIN"}� {"#DC_WHITE"}������ � �����, ������� ����� ������������ ��� ����� �����\n"\
        " {"#DC_MAIN"}� {"#DC_WHITE"}��������� � ������� ���������� ������������ �������� � ����������\n\n"\
        "{"#DC_MAIN"}� �����: {"#DC_GREEN"}��� ������ ������� �����!",
        "�����",
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
            "����������: {"#DC_GREY"}����� %s[%d] ��������� �� ������ ����������� � �����",
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
        "{"#DC_MAIN"} ���������� ������",
        "{"#DC_MAIN"}1. {"#DC_WHITE"}�������� ���� ����������� �����\n"\
        "{"#DC_MAIN"}2. {"#DC_WHITE"}�������� �������� �����\n"\
        "{"#DC_MAIN"}3. {"#DC_WHITE"}�������� �������� ������\n"\
        "{"#DC_MAIN"}4. {"#DC_WHITE"}�������� ����������� �����\n\n"\
        "{"#DC_MAIN"}5. {"#DC_WHITE"}���������� �������� �����������\n"\
        "{"#DC_MAIN"}6. {"#DC_WHITE"}��������������� �������� ���������\n"\
        "{"#DC_MAIN"}7. {"#DC_WHITE"}�������� ��������� ����������\n"\
        "{"#DC_MAIN"}8. {"#DC_WHITE"}���������� �������� ���������\n"\
        "{"#DC_MAIN"}9. {"#DC_WHITE"}������� �������� ���������\n\n"\
        "{"#DC_MAIN"}10. {"#DC_WHITE"}���������� {"#DC_GREEN"}����������{"#DC_WHITE"} �������\n"\
        "{"#DC_MAIN"}11. {"#DC_WHITE"}���������� {"#DC_LRED"}�����������{"#DC_WHITE"} �������\n",
        "�����",
        "�������"
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
        Hud:ShowNotification(playerid, ERROR, "�� �� ������ ��������� ����");
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
    {"#DC_WHITE"}����� �� ������ �������� ��������� ��� ���� ������ ����� �����.\n\
    (������ ��������� ������ ����� ������ ������ ���, ��� ����� � ����)\n\n\
    {"#DC_BEIGE"}������� ���������: {"#DC_WHITE"}%s\n\n\
    {"#DC_GRAY"}������� ����� ���������: (�� 5 �� "#FAMILY_MAX_NOTIFICATION_SYMBOLS" ��������). ����� ��������� ��������� �������� ���� ������\
    ", families[familyIndex][F_NOTIFICATION]);
    Dialog_Open(playerid, Dialog:dFamilyNotification, DSI, "{"#DC_MAIN"}��������� ������ �����", bigstring, "�������", "�����");
}

DialogResponse:dFamilyNotification(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid);

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ET_INFO,  "�� ������� ��������� ����������� ����� ��� �����");
        families[familyIndex][F_NOTIFICATION][0] = EOS;
        Family:SaveFamilyString(familyIndex, "notification", families[familyIndex][F_NOTIFICATION]);
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage); 
    }

    if (strlen(inputtext) < 5 || strlen(inputtext) > FAMILY_MAX_NOTIFICATION_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "��������� ������ ���� ������ �� 5 �� "#FAMILY_MAX_NOTIFICATION_SYMBOLS" ��������");
        return Dialog_Show(playerid, Dialog:dFamilyNotification);
    }

    families[familyIndex][F_NOTIFICATION][0] = EOS;
    strcat(families[familyIndex][F_NOTIFICATION], inputtext);
    Family:SaveFamilyString(familyIndex, "notification", inputtext, FAMILY_MAX_NOTIFICATION_SYMBOLS);    

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] ������� ����������� �����",
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
        "{"#DC_MAIN"}����� �����",
        totalstring,
        "�������",
        "�����"
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
        FAMILY_ACTIONS_PREFIX"%s %s[%d] ������� ���� ����������� ����� �� \"%s\"",
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
        "{"#DC_MAIN"}��������� �������� �����",
        "{"#DC_WHITE"}��������� ��������� �������� �����: {"#DC_GREEN"}"#FAMILY_RENAME_PRICE" RUB\n\n"\
        "{"#DC_WHITE"}�������� ����� ����� �������� �� {"#DC_MAIN"}24 ��������{"#DC_WHITE"}, �� ������\n"\
        "RGB ���� (�� 62 � ������ RGB �����). ������ RGB ����: {HEX},\n"\
        "��� HEX - ��������������� ��� �����",

        "�����",
        "�������"
    );
}

DialogResponse:dFamilyRename(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ ����� �������� ��� �����!");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    // test
    new totalLength = strlen(inputtext);

    if (totalLength > FAMILY_MAX_COLORED_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "�������� ����� �� ����� ��������� ����� "#FAMILY_MAX_COLORED_SYMBOLS" �������� � ������ ����� ������");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    if (totalLength < FAMILY_MIN_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "�������� ����� �� ����� ��������� ����� "#FAMILY_MIN_SYMBOLS" ��������");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    new family_name[FAMILY_MAX_COLORED_SYMBOLS];

    regex_replace(inputtext, "\\{.*?\\}", "\1", family_name, FAMILY_MAX_COLORED_SYMBOLS);

    totalLength = strlen(family_name);

    if (totalLength > FAMILY_MAX_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "�������� ����� �� ����� ��������� ����� "#FAMILY_MAX_SYMBOLS" �������� ��� ����� ����� ������");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    if (totalLength < FAMILY_MIN_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "�������� ����� �� ����� ��������� ����� "#FAMILY_MIN_SYMBOLS" ��������");
        return Dialog_Show(playerid, Dialog:dFamilyRename);
    }

    if (PlayerInfo[playerid][pDonateMoney] < FAMILY_RENAME_PRICE) {
        Hud:ShowNotification(playerid, ERROR, "�� ����� ������� ������ ���� ��� ������� "#FAMILY_RENAME_PRICE" ������ ��� ��������� �������� �����");
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
        FAMILY_ACTIONS_PREFIX"%s %s[%d] ������� �������� ����� �� {FFFFFF}\"%s\"",
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
        "{"#DC_MAIN"}������ ������",
        totalstring,
        GetPVarInt(playerid, PVAR_FAMILIES_EDIT_VEH_RANK) ? "�������" : "��������",
        "������"
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
        "{"#DC_MAIN"}��������� �������� �����",
        "{"#DC_WHITE"}������� ����� �������� ����� � ���� ���� ������ �� "#FAMILY_MAX_RANK_SYMBOLS":",
        "�����",
        "�������"
    );
}

DialogResponse:dFamilyRankNameInput(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyManageListRangs);
    }

    if (isnull(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ ����� �������� �����");
        return Dialog_Show(playerid, Dialog:dFamilyRankNameInput);
    }

    new totalLength = strlen(inputtext);

    if (totalLength > FAMILY_MAX_RANK_SYMBOLS || totalLength < FAMILY_MIN_RANK_SYMBOLS) {
        Hud:ShowNotification(playerid, ERROR, "���� �� ����� ��������� ����� "#FAMILY_MAX_RANK_SYMBOLS" � ����� "#FAMILY_MIN_RANK_SYMBOLS"� ��������");
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
        Hud:ShowNotification(playerid, ERROR, "�� ������� ����������� ��� �������");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_WHITE"}�� ������������� ������ ��������������� {"#DC_MAIN"}%d{"#DC_WHITE"} ����� �� {"#DC_GREEN"}$%d{"#DC_WHITE"}?",
        totalRepairableCars,
        totalRepairableCars * FAMILY_VEHICLE_REPAIR_PRICE
    );

    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyRepairActive,
        "{"#DC_MAIN"}������� ����������",
        bigstring,
        "�����������",
        "�����"
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
        Hud:ShowNotification(playerid, ERROR, "�� ������� ����� ������������ ������� ��� ������� ���� �����������");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    Family:RepairVehicles(familyIndex);

    families[familyIndex][F_BALANCE] -= price;

    Family:SaveFamilyInt(familyIndex, "balance",  families[familyIndex][F_BALANCE]);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] ������� ���� �������� ��������� �����",
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
        Hud:ShowNotification(playerid, ERROR, "�� ������� ����������� ��� ��������");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_WHITE"}�� ������������� ������ ��������� �� ������� {"#DC_MAIN"}%d{"#DC_WHITE"} ����� �� {"#DC_GREEN"}$%d{"#DC_WHITE"}?",
        totalRepairableCars,
        totalRepairableCars * FAMILY_VEHICLE_RESPAWN_PRICE
    );

    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyRespawnEmpty,
        "{"#DC_MAIN"}������� ����������",
        bigstring,
        "�����������",
        "�����"
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
        Hud:ShowNotification(playerid, ERROR, "�� ������� ����� ������������ ������� ��� �������� ���� ��������� �����������");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    Family:RespawnEmptyVehicles(familyIndex);

    families[familyIndex][F_BALANCE] -= price;

    Family:SaveFamilyInt(familyIndex, "balance",  families[familyIndex][F_BALANCE]);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] ����������� ���� ��������� ��������� �����",
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
        Hud:ShowNotification(playerid, ERROR, "�� �������� ������ ���������� ����������.");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    if (GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0) {
        Hud:ShowNotification(playerid, ERROR, "�� �� ������ ���������� ���������, �������� � ���� �����");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    totalstring[0] = EOS;

    new price[20];

    strcat(totalstring, "{"#DC_MAIN"}����������\t{"#DC_MAIN"}����\n");

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
        "{"#DC_MAIN"}������� ����������",
        totalstring,
        "�������",
        "�����"
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
        "{"#DC_WHITE"}�� ������������� ������ ���������� ���������� {"#DC_MAIN"}%s{"#DC_WHITE"} �� %s{"#DC_WHITE"}?",
        GetVehicleConfig(available_family_cars[vehicleIndex][FAC_MODEL], VC_NAME),
        price
    );

    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyBuyVehicleConfirm,
        "{"#DC_MAIN"}������������� ������� ����������",
        bigstring,
        "�����������",
        "�����"
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
        Hud:ShowNotification(playerid, ERROR, "�� �������� ������ ���������� ��������� ����������.");
        return Dialog_Show(playerid, Dialog:dFamilyLeaderManage);
    }

    new price = available_family_cars[vehicleIndex][FAC_PRICE];

    switch (available_family_cars[vehicleIndex][FAC_PRICE_TYPE]) {
        case FAMILY_CASH: {
            if (families[familyIndex][F_BALANCE] < price) {
                Hud:ShowNotification(playerid, ERROR, "�� ������� ����� ������������ ������� ��� ������� ����� ����������");
                return Dialog_Show(playerid, Dialog:dFamilyBuyVehicle);
            }

            families[familyIndex][F_BALANCE] -= price;
            Family:SaveFamilyInt(familyIndex, "balance", families[familyIndex][F_BALANCE]);
            Family:BuyNewVehicle(playerid, familyIndex, freeSlot, vehicleIndex);
            return true;
        }

        case DONATE: {
            if (PlayerInfo[playerid][pDonateMoney] < price) {
                Hud:ShowNotification(playerid, ERROR, "�� ����� ������� ������������ ������� ��� ������� ����� ����������");
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
        "{"#DC_MAIN"} ��������� ����� ����������",
        "{"#DC_WHITE"}����� {"#DC_MAIN"}����� 1{"#DC_WHITE"}\n\n"\
        "������� ID ����� ���������� ������ �� 0 �� 255 � ����:",

        "�����",
        "�����"
    );

    bigstring[0] = EOS;
}

DialogResponse:dFamilyVehColor(playerid, response, listitem, inputtext[])
{
    if (!response) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ���������� ���� ��� ���������� ����������");
        return Dialog_Show(playerid, Dialog:dFamilyVehColor);
    }

    if (isnull(inputtext) || !IsNumeric(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ �������������� ���� ������");
        return Dialog_Show(playerid, Dialog:dFamilyVehColor);
    }

    new number = strval(inputtext);

    if (number < 0 || number > 255) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ ���� ������ � ��������� �� 0 �� 255");
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
        "{"#DC_MAIN"} ��������� ����� ����������",
        "{"#DC_WHITE"}����� {"#DC_MAIN"}����� 2{"#DC_WHITE"}\n\n"\
        "������� ID ����� ���������� ������ �� 0 �� 255 � ����:",

        "�����",
        "�����"
    );

    bigstring[0] = EOS;
}

DialogResponse:dFamilyVehColor2(playerid, response, listitem, inputtext[])
{
    if (!response) {
        return Dialog_Show(playerid, Dialog:dFamilyVehColor);
    }

    if (isnull(inputtext) || !IsNumeric(inputtext)) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ �������������� ���� ������");
        return Dialog_Show(playerid, Dialog:dFamilyVehColor2);
    }

    new number = strval(inputtext);

    if (number < 0 || number > 255) {
        Hud:ShowNotification(playerid, ERROR, "�� ������ ������ ���� ������ � ��������� �� 0 �� 255");
        return Dialog_Show(playerid, Dialog:dFamilyVehColor2);
    }

    new familyIndex = GetPlayerFamilyIndex(playerid),
        vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE);

    family_cars[familyIndex][vehicleIndex][FV_COLOR_2] = number;
    Family:SaveFamilyVehInt(familyIndex, vehicleIndex, "color_2", number);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] �������� ���������� %s ��� �����",
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
        "�� ������������� ������ ������� %s �� %s",
        GetVehicleConfig(model, VC_NAME),
        Family:GetSellPriceStringForModel(model)
    );
    
    Dialog_MessageEx(
        playerid,
        Dialog:dFamilyConfirmVehicleSell,
        "{"#DC_MAIN"}������� ���������� �����",
        bigstring,
        "�����������",
        "������"
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
        FAMILY_ACTIONS_PREFIX"%s %s[%d] ������ ���������� ����� %s",
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