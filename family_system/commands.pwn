CMD:familychat(playerid, params[])
{
    if (!IsFamilyMember(playerid)) return Hud:ShowNotification(playerid, ERROR, N_ACCSES);
    if(sscanf(params, "s[256]", params[0])) return SCM(playerid, COLOR_MAIN, "�����������:{"#DC_WHITE"} /fc [�����]");

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_CHAT_PREFIX"%s %s[%d]: %s",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        params[0]
    );

    Family:SendFamilyMessage(playerid, bigstring);

    bigstring[0] = EOS;
    return CMD_RESULT_SUCCESS;
}
alias:familychat("fc")

CMD:finvite(playerid, params[])
{
	if(GetPlayerFamilyRankIndex(playerid) < FAMILY_MIN_INVITE_RANK) return SCM(playerid, COLOR_GREY, N_ACCSES);
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_MAIN, "�����������:{"#DC_WHITE"} /finvite [id ������]");
	if(!IsPlayerConnected(params[0])) return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
	if(PlayerInfo[params[0]][pLogged] == false) return Hud:ShowNotification(playerid, ERROR, P_NO_LOGGED);
	if(!IsPlayerInRangeOfPlayer(10.0, playerid, params[0])) return SCM(playerid, COLOR_GREY, P_RANGE);
    if(PlayerInfo[params[0]][pLevel] < 2) return Hud:ShowNotification(playerid, ERROR, "� ������ ������������� ������� ��� ���������� � ����������� (����� 2)");
	if(IsFamilyMember(params[0])) return SCM(playerid, COLOR_GREY, "���� ����� �������� ������ ������ �����");
	if(IsPlayerInAnyVehicle(params[0])) return SCM(playerid, COLOR_GREY, "����� �� ������ ���������� � ����������");
    if (GetPVarType(params[0], PVAR_FAMILIES_INVITED_BY) != 0) return SCM(playerid, COLOR_GREY, "����� ��� ������������� ����������� � ���������� � �����");

    format(
        totalstring,
        sizeof totalstring,
        "{"#DC_WHITE"}%s %s[%d] ���������� ��� �������� � ����� %s",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        families[GetPlayerFamilyIndex(playerid)][F_NAME]
    );
	Dialog_MessageEx(params[0], Dialog:dFamilyInvite, "{"#DC_MAIN"}����������� � �����", totalstring, "��", "���");
	totalstring[0] = EOS;

    SetPVarInt(params[0], PVAR_FAMILIES_INVITED_BY, playerid);
    Family:SendPrivateMessage(playerid, "�� ������� ��������� ����������� � �����");

	return CMD_RESULT_SUCCESS;
}

CMD:frang(playerid, params[])
{
    if(GetPlayerFamilyRankIndex(playerid) < FAMILY_MIN_INVITE_RANK) return SCM(playerid, COLOR_GREY, N_ACCSES);
	if(sscanf(params, "dc", params[0], params[1])) return SCM(playerid, COLOR_MAIN, "�����������:{"#DC_WHITE"} /frang [id ������] [+/-]");
	if(!IsPlayerConnected(params[0])) return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
	if(PlayerInfo[params[0]][pLogged] == false) return Hud:ShowNotification(playerid, ERROR, P_NO_LOGGED);
    if (params[0] == playerid) return Hud:ShowNotification(playerid, ERROR, "�� �� ������ �������� ���� ����");
	if(GetPlayerFamilyIndex(params[0]) != GetPlayerFamilyIndex(playerid)) return Hud:ShowNotification(playerid, ERROR, "���� ����� �� �������� ������ ����� �����");
    if (GetPlayerFamilyRankIndex(params[0]) >= GetPlayerFamilyRankIndex(playerid)) return Hud:ShowNotification(playerid, ERROR, "�� �� ������ ��������� ������ ����� ������");

	if(params[1] != '+' && params[1] != '-')
		return SCM(playerid, COLOR_MAIN, "�����������:{"#DC_WHITE"} /frang [id ������] [+/-]");

    if (params[1] == '-' && GetPlayerFamilyRankIndex(params[0]) == 0)
		return Hud:ShowNotification(playerid, ERROR, "����� ��� ����� ����������� ����");

    new next_player_rank = GetPlayerFamilyRankIndex(params[0]) + (params[1] == '-' ? -1 : 1);

    if (next_player_rank == GetPlayerFamilyRankIndex(playerid))
    	return Hud:ShowNotification(playerid, ERROR, "�� �� ������ �������� ����� ������");

    PlayerInfo[params[0]][p_family_rank_index] = next_player_rank;
    Family:SavePlayerRank(params[0]);

    new bool:is_bigger = params[1] != '-';

    format(
        bigstring,
        sizeof bigstring,
        "%s %s[%d] %s ��� �� %s ����� � �����",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        (is_bigger ? "�������" : "�������"), 
        GetPlayerFamilyRankName(params[0])
    );

    Family:SendPrivateMessage(params[0], bigstring);

    format(
        bigstring,
        sizeof bigstring,
        "�� %s %s[%d] �� %s ����� � �����",
        (is_bigger ? "��������" : "��������"), 
        GetName(params[0]),
        params[0],
        GetPlayerFamilyRankName(params[0])
    );

    Family:SendPrivateMessage(playerid, bigstring);

    return CMD_RESULT_SUCCESS; 
}

CMD:fampark(playerid)
{
    if(GetPlayerFamilyRankIndex(playerid) < FAMILY_DEPUTY_RANK_INDEX) return SCM(playerid, COLOR_GREY, N_ACCSES);
    if (!IsPlayerInAnyVehicle(playerid)) return Hud:ShowNotification(playerid, ERROR, "�� ������ ���������� � ����������, ����� ������������ ���");
    
    new vehicleid = GetPlayerVehicleID(playerid),
        familyIndex = GetPlayerFamilyIndex(playerid);

    if (VehInfo[vehicleid][v_family_index] - 1 != familyIndex) return Hud:ShowNotification(playerid, ERROR, "���� ��������� �� ����������� ����� �����");

    new Float:x, Float:y, Float:z, Float:rot, vehicleIndex;

    GetPlayerPos(playerid, x, y, z);
    GetVehicleZAngle(vehicleid, rot);

    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_VEHICLE_ID] != vehicleid)
            continue;
        
        vehicleIndex = i;
        break;
    }

    family_cars[familyIndex][vehicleIndex][FV_X] = x;
    family_cars[familyIndex][vehicleIndex][FV_Y] = y;
    family_cars[familyIndex][vehicleIndex][FV_Z] = z;
    family_cars[familyIndex][vehicleIndex][FV_ROT] = rot;

    Family:SaveFamilyVehPosition(familyIndex, vehicleIndex);
    Family:SendPrivateMessage(playerid, "�� ������� �������� ����� �������� ������");

    return CMD_RESULT_SUCCESS;
}

CMD:foffuninvite(playerid, params[])
{
    if(GetPlayerFamilyRankIndex(playerid) < FAMILY_MIN_INVITE_RANK) return SCM(playerid, COLOR_GREY, N_ACCSES);
	if(sscanf(params, "s[32]", params[0])) return SCM(playerid, COLOR_MAIN, "�����������:{"#DC_WHITE"} /foffuninvite [������� ������]");

    mysql_escape_string(params[0], params[0]);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT id FROM accounts WHERE name = '%s'",
        params[0]
    );

    new Cache:request_account_id = mysql_query(mysql, bigstring);
    bigstring[0] = EOS;

    if (cache_num_rows() == 0) {
        cache_delete(request_account_id);
        return Hud:ShowNotification(playerid, ERROR, "�� ������� ����� ������� � ����� ������");
    }

    new accountId;

    cache_get_value_name_int(0, "id", accountId);

    cache_delete(request_account_id);

    new familyIndex = GetPlayerFamilyIndex(playerid);

    if (!Family:IsAccountRelatedWithFamily(familyIndex, accountId)) {
        return Hud:ShowNotification(playerid, ERROR, "��������� ������� �� ������ � ����� ������");
    }

    if (Family:GetRankByAccountId(familyIndex, accountId) - 1 >= GetPlayerFamilyRankIndex(playerid)) {
        return Hud:ShowNotification(playerid, ERROR, "�� �� ������ ������� ����� ����� �����");
    }

    Family:RemovePlayerFromFamily(playerid, familyIndex, accountId);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] �������� � �������� %s �� ������� �����",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        params[0]
    );
    Family:SendFamilyMessage(playerid, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        "{%s}"FAMILY_ACTIONS_PREFIX"%s %s[%d] �������� ��� � �������� �� ������� �����",
        families[familyIndex][F_COLOR],
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid
    );
    SendOfflineMessageByAccountId(accountId, COLOR_WHITE, bigstring);

    bigstring[0] = EOS;

    return CMD_RESULT_SUCCESS;
}

CMD:funinvite(playerid, params[])
{
    if(GetPlayerFamilyRankIndex(playerid) < FAMILY_MIN_INVITE_RANK) return SCM(playerid, COLOR_GREY, N_ACCSES);
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_MAIN, "�����������:{"#DC_WHITE"} /funinvite [id ������]");
	if(!IsPlayerConnected(params[0])) return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
	if(PlayerInfo[params[0]][pLogged] == false) return Hud:ShowNotification(playerid, ERROR, P_NO_LOGGED);
	if(GetPlayerFamilyIndex(params[0]) != GetPlayerFamilyIndex(playerid)) return SCM(playerid, COLOR_GREY, "���� ����� �� �������� ������ ����� �����");
    if (GetPlayerFamilyRankIndex(params[0]) >= GetPlayerFamilyRankIndex(playerid)) return SCM(playerid, COLOR_GREY, "�� �� ������ ������� �� ����� ����� ������");

    Family:RemovePlayerFromFamily(playerid, GetPlayerFamilyIndex(playerid), GetPlayerAccountID(params[0]));

    return CMD_RESULT_SUCCESS; 
}

CMD:afuninvite(playerid, params[])
{
    if(!GetAdminLogged(playerid, 4)) return SCM(playerid, COLOR_GREY, N_ACCSES);
	if(sscanf(params, "ds[32]", params[0], params[1])) return SCM(playerid, COLOR_MAIN, "�����������:{"#DC_WHITE"} /afuninvite [id ������] [�������]");
	if(!IsPlayerConnected(params[0])) return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
	if(PlayerInfo[params[0]][pLogged] == false) return Hud:ShowNotification(playerid, ERROR, P_NO_LOGGED);
	if(!IsFamilyMember(params[0])) return SCM(playerid, COLOR_GREY, "���� ����� �� �������� ������ �����");
    if (GetPlayerFamilyRankIndex(params[0]) == FAMILY_OWNER_RANK_INDEX) return SCM(playerid, COLOR_GREY, "�� �� ������ ������� ��������� �����");

    Family:RemovePlayerFromFamily(playerid, GetPlayerFamilyIndex(playerid), GetPlayerAccountID(params[0]), params[1]);

    return CMD_RESULT_SUCCESS; 
}

CMD:family(playerid)
{
    if (!IsFamilyMember(playerid)) return Hud:ShowNotification(playerid, ERROR, N_ACCSES);

    Dialog_Show(playerid, Dialog:dFamilyManage);
    return CMD_RESULT_SUCCESS;
}
alias:family("fam")


cmd:fleaders(playerid)
{
    new phone_number[16];
    new bool:result = false;

    format(bigstring, sizeof bigstring, "{"#DC_WHITE"}�������� �����\t{"#DC_WHITE"}��������\t{"#DC_WHITE"}����� ��������\n");

    foreach(new i:Player)
    {
        if(!IsPlayerLogged(i))
            continue;

        if(GetPlayerFamilyRankIndex(i) != FAMILY_OWNER_RANK_INDEX)
            continue;
    
        if(!GetPlayerPhoneNumber(i)) phone_number = "���";
        else format(phone_number, sizeof phone_number, "%d", GetPlayerPhoneNumber(i));

        format(
            totalstring, sizeof totalstring, 
            "%s\t{"#DC_WHITE"}%s [%d]\t%s\n",
            families[GetPlayerFamilyIndex(i)][F_NAME],
            GetName(i), i,
            phone_number
        );
        strcat(bigstring, totalstring);

        result = true;
    }

    if(!result)
    {
        totalstring[0] = EOS;
        bigstring[0] = EOS;

        Hud:ShowNotification(playerid, ERROR, "� ������ ������ ������� ����� ��� � ����");

        return true;
    }

    Dialog_Open(
        playerid, Dialog:D_NULL, DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}������ ����� ������",
        bigstring,
        "�������", ""
    );

    bigstring[0] = EOS;
    totalstring[0] = EOS;

    return CMD_RESULT_SUCCESS;
}