CMD:familychat(playerid, params[])
{
    if (!IsFamilyMember(playerid)) return Hud:ShowNotification(playerid, ERROR, N_ACCSES);
    if(sscanf(params, "s[256]", params[0])) return SCM(playerid, COLOR_MAIN, "Используйте:{"#DC_WHITE"} /fc [текст]");

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
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_MAIN, "Используйте:{"#DC_WHITE"} /finvite [id игрока]");
	if(!IsPlayerConnected(params[0])) return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
	if(PlayerInfo[params[0]][pLogged] == false) return Hud:ShowNotification(playerid, ERROR, P_NO_LOGGED);
	if(!IsPlayerInRangeOfPlayer(10.0, playerid, params[0])) return SCM(playerid, COLOR_GREY, P_RANGE);
    if(PlayerInfo[params[0]][pLevel] < 2) return Hud:ShowNotification(playerid, ERROR, "у игрока недостаточный уровень для вступления в организацию (нужен 2)");
	if(IsFamilyMember(params[0])) return SCM(playerid, COLOR_GREY, "Этот игрок является членом другой семьи");
	if(IsPlayerInAnyVehicle(params[0])) return SCM(playerid, COLOR_GREY, "Игрок не должен находиться в транспорте");
    if (GetPVarType(params[0], PVAR_FAMILIES_INVITED_BY) != 0) return SCM(playerid, COLOR_GREY, "Игрок уже рассматривает предложение о вступлении в семью");

    format(
        totalstring,
        sizeof totalstring,
        "{"#DC_WHITE"}%s %s[%d] приглашает Вас вступить в семью %s",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        families[GetPlayerFamilyIndex(playerid)][F_NAME]
    );
	Dialog_MessageEx(params[0], Dialog:dFamilyInvite, "{"#DC_MAIN"}Приглашение в семью", totalstring, "Да", "Нет");
	totalstring[0] = EOS;

    SetPVarInt(params[0], PVAR_FAMILIES_INVITED_BY, playerid);
    Family:SendPrivateMessage(playerid, "Вы успешно отправили приглашение в семью");

	return CMD_RESULT_SUCCESS;
}

CMD:frang(playerid, params[])
{
    if(GetPlayerFamilyRankIndex(playerid) < FAMILY_MIN_INVITE_RANK) return SCM(playerid, COLOR_GREY, N_ACCSES);
	if(sscanf(params, "dc", params[0], params[1])) return SCM(playerid, COLOR_MAIN, "Используйте:{"#DC_WHITE"} /frang [id игрока] [+/-]");
	if(!IsPlayerConnected(params[0])) return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
	if(PlayerInfo[params[0]][pLogged] == false) return Hud:ShowNotification(playerid, ERROR, P_NO_LOGGED);
    if (params[0] == playerid) return Hud:ShowNotification(playerid, ERROR, "Вы не можете изменять свой ранг");
	if(GetPlayerFamilyIndex(params[0]) != GetPlayerFamilyIndex(playerid)) return Hud:ShowNotification(playerid, ERROR, "Этот игрок не является членом вашей семьи");
    if (GetPlayerFamilyRankIndex(params[0]) >= GetPlayerFamilyRankIndex(playerid)) return Hud:ShowNotification(playerid, ERROR, "Вы не можете управлять рангом этого игрока");

	if(params[1] != '+' && params[1] != '-')
		return SCM(playerid, COLOR_MAIN, "Используйте:{"#DC_WHITE"} /frang [id игрока] [+/-]");

    if (params[1] == '-' && GetPlayerFamilyRankIndex(params[0]) == 0)
		return Hud:ShowNotification(playerid, ERROR, "Игрок уже имеет минимальный ранг");

    new next_player_rank = GetPlayerFamilyRankIndex(params[0]) + (params[1] == '-' ? -1 : 1);

    if (next_player_rank == GetPlayerFamilyRankIndex(playerid))
    	return Hud:ShowNotification(playerid, ERROR, "Вы не можете повысить этого игрока");

    PlayerInfo[params[0]][p_family_rank_index] = next_player_rank;
    Family:SavePlayerRank(params[0]);

    new bool:is_bigger = params[1] != '-';

    format(
        bigstring,
        sizeof bigstring,
        "%s %s[%d] %s Вас до %s ранга в семье",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        (is_bigger ? "повысил" : "понизил"), 
        GetPlayerFamilyRankName(params[0])
    );

    Family:SendPrivateMessage(params[0], bigstring);

    format(
        bigstring,
        sizeof bigstring,
        "Вы %s %s[%d] до %s ранга в семье",
        (is_bigger ? "повысили" : "понизили"), 
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
    if (!IsPlayerInAnyVehicle(playerid)) return Hud:ShowNotification(playerid, ERROR, "Вы должны находиться в автомобиле, чтобы припарковать его");
    
    new vehicleid = GetPlayerVehicleID(playerid),
        familyIndex = GetPlayerFamilyIndex(playerid);

    if (VehInfo[vehicleid][v_family_index] - 1 != familyIndex) return Hud:ShowNotification(playerid, ERROR, "Этот транспорт не принадлежит Вашей семье");

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
    Family:SendPrivateMessage(playerid, "Вы успешно изменили место парковки машины");

    return CMD_RESULT_SUCCESS;
}

CMD:foffuninvite(playerid, params[])
{
    if(GetPlayerFamilyRankIndex(playerid) < FAMILY_MIN_INVITE_RANK) return SCM(playerid, COLOR_GREY, N_ACCSES);
	if(sscanf(params, "s[32]", params[0])) return SCM(playerid, COLOR_MAIN, "Используйте:{"#DC_WHITE"} /foffuninvite [никнейм игрока]");

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
        return Hud:ShowNotification(playerid, ERROR, "Не удалось найти аккаунт с таким именем");
    }

    new accountId;

    cache_get_value_name_int(0, "id", accountId);

    cache_delete(request_account_id);

    new familyIndex = GetPlayerFamilyIndex(playerid);

    if (!Family:IsAccountRelatedWithFamily(familyIndex, accountId)) {
        return Hud:ShowNotification(playerid, ERROR, "Указанный аккаунт не связан с Вашей семьей");
    }

    if (Family:GetRankByAccountId(familyIndex, accountId) - 1 >= GetPlayerFamilyRankIndex(playerid)) {
        return Hud:ShowNotification(playerid, ERROR, "Вы не можете уволить этого члена семьи");
    }

    Family:RemovePlayerFromFamily(playerid, familyIndex, accountId);

    format(
        bigstring,
        sizeof bigstring,
        FAMILY_ACTIONS_PREFIX"%s %s[%d] исключил в оффлайне %s из состава семьи",
        GetPlayerFamilyRankName(playerid),
        GetName(playerid),
        playerid,
        params[0]
    );
    Family:SendFamilyMessage(playerid, bigstring);

    format(
        bigstring,
        sizeof bigstring,
        "{%s}"FAMILY_ACTIONS_PREFIX"%s %s[%d] исключил Вас в оффлайне из состава семьи",
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
	if(sscanf(params, "d", params[0])) return SCM(playerid, COLOR_MAIN, "Используйте:{"#DC_WHITE"} /funinvite [id игрока]");
	if(!IsPlayerConnected(params[0])) return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
	if(PlayerInfo[params[0]][pLogged] == false) return Hud:ShowNotification(playerid, ERROR, P_NO_LOGGED);
	if(GetPlayerFamilyIndex(params[0]) != GetPlayerFamilyIndex(playerid)) return SCM(playerid, COLOR_GREY, "Этот игрок не является членом вашей семьи");
    if (GetPlayerFamilyRankIndex(params[0]) >= GetPlayerFamilyRankIndex(playerid)) return SCM(playerid, COLOR_GREY, "Вы не можете кикнуть из семьи этого игрока");

    Family:RemovePlayerFromFamily(playerid, GetPlayerFamilyIndex(playerid), GetPlayerAccountID(params[0]));

    return CMD_RESULT_SUCCESS; 
}

CMD:afuninvite(playerid, params[])
{
    if(!GetAdminLogged(playerid, 4)) return SCM(playerid, COLOR_GREY, N_ACCSES);
	if(sscanf(params, "ds[32]", params[0], params[1])) return SCM(playerid, COLOR_MAIN, "Используйте:{"#DC_WHITE"} /afuninvite [id игрока] [причина]");
	if(!IsPlayerConnected(params[0])) return Hud:ShowNotification(playerid, ERROR, P_OFFLINE);
	if(PlayerInfo[params[0]][pLogged] == false) return Hud:ShowNotification(playerid, ERROR, P_NO_LOGGED);
	if(!IsFamilyMember(params[0])) return SCM(playerid, COLOR_GREY, "Этот игрок не является членом семьи");
    if (GetPlayerFamilyRankIndex(params[0]) == FAMILY_OWNER_RANK_INDEX) return SCM(playerid, COLOR_GREY, "Вы не можете кикнуть владельца семьи");

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

    format(bigstring, sizeof bigstring, "{"#DC_WHITE"}Название семьи\t{"#DC_WHITE"}Владелец\t{"#DC_WHITE"}Номер телефона\n");

    foreach(new i:Player)
    {
        if(!IsPlayerLogged(i))
            continue;

        if(GetPlayerFamilyRankIndex(i) != FAMILY_OWNER_RANK_INDEX)
            continue;
    
        if(!GetPlayerPhoneNumber(i)) phone_number = "Нет";
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

        Hud:ShowNotification(playerid, ERROR, "в данный момент лидеров семей нет в сети");

        return true;
    }

    Dialog_Open(
        playerid, Dialog:D_NULL, DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}Лидеры семей онлайн",
        bigstring,
        "Закрыть", ""
    );

    bigstring[0] = EOS;
    totalstring[0] = EOS;

    return CMD_RESULT_SUCCESS;
}