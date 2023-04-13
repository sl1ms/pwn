
stock Family:Init()
{
    for (new i = 0; i < MAX_LOADED_FAMILIES; i++) {
        families[i] = default_family;

        for (new j = 0; j < FAMILY_MAX_VEHICLES; j++) {
            family_cars[i][j] = default_family_vehicle;
        }

        for (new j = 0; j < FAMILY_MAX_RANKS; j++) {
            family_ranks[i][j] = default_family_rank;
        }
    }

    family_resources[F_PICKUP] = CreateDynamicPickup(
        FAMILY_PICKUP_MODEL,
        FAMILY_PICKUP_MODEL_TYPE,
        FAMILY_PICKUP_POS,
        FAMILY_PICKUP_WORLD,
        FAMILY_PICKUP_WORLD
    );

    family_resources[F_TEXT_ID] = CreateDynamic3DTextLabel(
            "Информация о семьях", COLOR_WHITE, 
            FAMILY_PICKUP_POS,
            15.0, 
            INVALID_PLAYER_ID,
            INVALID_VEHICLE_ID,
            1, FAMILY_PICKUP_WORLD, FAMILY_PICKUP_WORLD
    );

    family_resources[F_SPHERE_ID] = CreateDynamicSphere(
        FAMILY_PICKUP_POS,
        1.0,
        FAMILY_PICKUP_WORLD,
        FAMILY_PICKUP_WORLD
    );
}

stock Family:GetFreeFamilySlot()
{
    for (new i = 0; i < MAX_LOADED_FAMILIES; i++) {
        if (families[i][F_ID] == INVALID_FAMILY_ID) {
            return i;
        }
    }

    return INVALID_FAMILY_ID;
}

stock Family:GetFreeFamilyVehicleSlot(familyIndex)
{
    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_MODEL] == INVALID_FAMILY_ID) {
            return i;
        }
    }

    return INVALID_FAMILY_ID;
}

stock Family:GetFamilyOnline(familyIndex)
{
    new totalOnline = 0;

    foreach (new i: Player) {
        if (GetPlayerFamilyIndex(i) == familyIndex)
            totalOnline++;
    }

    return totalOnline;
}

stock Family:GetFamilyOnlineById(familyId)
{
    new familyIndex;

    for (new i = 0; i < MAX_LOADED_FAMILIES; i++) {
        if (families[i][F_ID] == familyId) {
            familyIndex = i;
            break;
        }
    }

    return Family:GetFamilyOnline(familyIndex);
}

stock Family:UnloadVehicle(familyIndex, vehicleIndex)
{
    W_DestroyVehicle(family_cars[familyIndex][vehicleIndex][FV_VEHICLE_ID]);
    Family:DestroyVehicle3DText(familyIndex, vehicleIndex);
    family_cars[familyIndex][vehicleIndex][FV_STATE] = NOT_SPAWNED;
    family_cars[familyIndex][vehicleIndex][FV_VEHICLE_ID] = INVALID_VEHICLE_ID;
}

stock Family:UnloadFamily(familyIndex)
{
    families[familyIndex] = default_family;

    for (new j = 0; j < FAMILY_MAX_VEHICLES; j++) { // todo: find and destroy vehicles
        if (family_cars[familyIndex][j][FV_STATE] == ALIVE) {
            W_DestroyVehicle(family_cars[familyIndex][j][FV_VEHICLE_ID]);
            Family:DestroyVehicle3DText(familyIndex, j);
        }

        family_cars[familyIndex][j] = default_family_vehicle;
    }

    for (new j = 0; j < FAMILY_MAX_RANKS; j++) {
        family_ranks[familyIndex][j] = default_family_rank;
    }
}

stock Family:OnPlayerLoggedIn(playerid)
{
    format(
        bigstring,
        sizeof bigstring,
        "SELECT family_id, rank_id FROM "DB_FAMILY_MEMBERS" WHERE member_id = %d AND deleted_at IS NULL",
        GetPlayerAccountID(playerid)
    );
    mysql_tquery(mysql, bigstring, FamilyText(Family:OnLoadMember), "d", playerid);
    bigstring[0] = EOS;
}

stock Family:OnPlayerDisconnect(playerid)
{
    if (GetPlayerFamilyIndex(playerid) == INVALID_FAMILY_ID) {
        return;
    }

    Family:Destroy3DTextOfPlayer(playerid);

    if (Family:GetFamilyOnline(GetPlayerFamilyIndex(playerid)) - 1 == 0) {
        Family:UnloadFamily(GetPlayerFamilyIndex(playerid));
    }
}

stock Family:SetPlayerRank(familyIndex, accountId, rankIndex)
{
    format(
        bigstring,
        sizeof bigstring,
        "UPDATE "DB_FAMILY_MEMBERS" SET rank_id = %d WHERE family_id = %d AND member_id = %d",
        families[familyIndex][F_ID],
        accountId,
        rankIndex + 1
    );

    mysql_tquery(mysql, bigstring);
    bigstring[0] = EOS;

    foreach (new i: Player) {
        if (GetPlayerAccountID(i) != accountId) {
            continue;
        }

        PlayerInfo[i][p_family_index] = familyIndex;
        PlayerInfo[i][p_family_rank_index] = rankIndex;
    }
}

stock Family:InvitePlayerToFamily(familyIndex, accountId)
{
    format(
        bigstring,
        sizeof bigstring,
        "INSERT INTO "DB_FAMILY_MEMBERS" (family_id, member_id) VALUES (%d, %d)",
        families[familyIndex][F_ID],
        accountId
    );

    mysql_tquery(mysql, bigstring);
    bigstring[0] = EOS;

    foreach (new i: Player) {
        if (GetPlayerAccountID(i) != accountId) {
            continue;
        }

        PlayerInfo[i][p_family_index] = familyIndex;
        PlayerInfo[i][p_family_rank_index] = FAMILY_INITIAL_RANK_INDEX;

        format(
            bigstring,
            sizeof bigstring,
            FAMILY_ACTIONS_PREFIX"Игрок %s[%d] вступил в семью",
            GetName(i),
            i
        );
        Family:SendFamilyMessage(i, bigstring);
        Family:Create3DTextForPlayer(i);
        bigstring[0] = EOS;
        break;
    }
}

stock Family:RemovePlayerFromFamily(playerid, familyIndex, accountId, const reason[] = "")
{
    format(
        bigstring,
        sizeof bigstring,
        "UPDATE "DB_FAMILY_MEMBERS" SET deleted_at = now() WHERE family_id = %d AND member_id = %d",
        families[familyIndex][F_ID],
        accountId
    );

    mysql_tquery(mysql, bigstring);
    bigstring[0] = EOS;

    foreach (new i: Player) {
        if (GetPlayerAccountID(i) != accountId) {
            continue;
        }

        if (playerid != i && PlayerInfo[playerid][p_family_index] == PlayerInfo[i][p_family_index]) {
            format(
                bigstring,
                sizeof bigstring,
                FAMILY_ACTIONS_PREFIX"%s %s[%d] исключил %s[%d] из состава семьи",
                GetPlayerFamilyRankName(playerid),
                GetName(playerid),
                playerid,
                GetName(i),
                i
            );

            format(
                totalstring,
                sizeof totalstring,
                FAMILY_ACTIONS_PREFIX"%s %s[%d] исключил Вас из семьи %s",
                GetPlayerFamilyRankName(playerid),
                GetName(playerid),
                playerid,
                families[familyIndex][F_NAME]
            );
            Family:SendPrivateMessage(i, totalstring);
            totalstring[0] = EOS;
        } else if (PlayerInfo[playerid][p_family_index] != PlayerInfo[i][p_family_index]) { 
            format(
                bigstring,
                sizeof bigstring,
                FAMILY_ACTIONS_PREFIX"Администратор %s[%d] исключил %s[%d] из состава семьи. Причина: %s",
                GetPlayerFamilyRankName(playerid),
                GetName(playerid),
                playerid,
                GetName(i),
                i,
                reason
            );

            format(
                totalstring,
                sizeof totalstring,
                FAMILY_ACTIONS_PREFIX"Администратор %s[%d] исключил Вас из семьи %s",
                GetName(playerid),
                playerid,
                families[familyIndex][F_NAME]
            );
            Family:SendPrivateMessage(i, totalstring);
            totalstring[0] = EOS;
        } else {
            format(
                bigstring,
                sizeof bigstring,
                FAMILY_ACTIONS_PREFIX"Игрок %s[%d] покинул семью",
                GetName(i),
                i
            );

            Family:SendPrivateMessage(i, "Вы успешно покинули семью");
        }

        PlayerInfo[i][p_family_index] = INVALID_FAMILY_ID;
        PlayerInfo[i][p_family_rank_index] = INVALID_FAMILY_ID;

        Family:SendFamilyMessageByIndex(familyIndex, bigstring);
        Family:Destroy3DTextOfPlayer(i);
        bigstring[0] = EOS;
    }

    if (!Family:GetFamilyOnline(familyIndex)) {
        Family:UnloadFamily(familyIndex);
    }

    return true;
}

stock Family:GetFamilyVehiclesCount(familyIndex)
{
    new totalAliveVehicles = 0;

    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_ID] != INVALID_FAMILY_ID)
            totalAliveVehicles++;
    }

    return totalAliveVehicles;
}

stock Family:GetFamilyAliveVehiclesCount(familyIndex)
{
    new totalAliveVehicles = 0;

    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_STATE] == ALIVE)
            totalAliveVehicles++;
    }

    return totalAliveVehicles;
}

stock Family:SaveFamilyString(familyIndex, const column[], value[], size = sizeof value)
{
    mysql_escape_string(value, value, size);

    format(
        totalstring,
        sizeof totalstring,
        "UPDATE "#DB_FAMILIES" SET %s = '%s' WHERE id = %d",
        column,
        value,
        families[familyIndex][F_ID]
    );
    mysql_tquery(mysql, totalstring);

    totalstring[0] = EOS;

    return true;
}

stock Family:SaveFamilyVehInt(familyIndex, vehicleIndex, const column[], value)
{
    format(
        totalstring,
        sizeof totalstring,
        "UPDATE "#DB_FAMILY_VEHICLES" SET %s = %d WHERE id = %d",
        column,
        value,
        family_cars[familyIndex][vehicleIndex][FV_ID]
    );
    mysql_tquery(mysql, totalstring);

    totalstring[0] = EOS;

    return true;
}

stock Family:SaveFamilyVehPosition(familyIndex, vehicleIndex)
{
    format(
        totalstring,
        sizeof totalstring,
        "UPDATE "#DB_FAMILY_VEHICLES" SET x = %.2f, y = %.2f, z = %.2f, rotation = %.2f WHERE id = %d",
         family_cars[familyIndex][vehicleIndex][FV_X],
         family_cars[familyIndex][vehicleIndex][FV_Y],
         family_cars[familyIndex][vehicleIndex][FV_Z],
         family_cars[familyIndex][vehicleIndex][FV_ROT],
        family_cars[familyIndex][vehicleIndex][FV_ID]
    );
    mysql_tquery(mysql, totalstring);

    totalstring[0] = EOS;
}

stock Family:SaveFamilyInt(familyIndex, const column[], value)
{
    format(
        totalstring,
        sizeof totalstring,
        "UPDATE "#DB_FAMILIES" SET %s = %d WHERE id = %d",
        column,
        value,
        families[familyIndex][F_ID]
    );
    mysql_tquery(mysql, totalstring);

    totalstring[0] = EOS;

    return true;
}

stock Family:CalculateVehicleBoughtRep(playerid, familyIndex)
{
    new vehicleIndex = GetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE),
        price = available_family_cars[vehicleIndex][FAC_PRICE];

    if (available_family_cars[vehicleIndex][FAC_PRICE_TYPE] == DONATE) {
        Family:IncrementFamilyInt(familyIndex, "points", F_REP_DONATE_VEHICLE_BUY);
        return; 
    }

    new repIndex = 0;

    for (new i = 0; i < sizeof family_vehicle_buy_rep; i++) {
        if (price >= family_vehicle_buy_rep[i][FVR_MIN_PRICE]
            && (price < family_vehicle_buy_rep[i][FVR_MAX_PRICE] || family_vehicle_buy_rep[i][FVR_MAX_PRICE] == INVALID_FAMILY_ID)
        ) {
            repIndex = i;
        }
    }

    Family:IncrementFamilyInt(familyIndex, "points", family_vehicle_buy_rep[repIndex][FVR_RATE]);
}

stock Family:IncrementFamilyInt(familyIndex, const column[], value = 1)
{
    format(
        totalstring,
        sizeof totalstring,
        "UPDATE "#DB_FAMILIES" SET %s = %s + %d WHERE id = %d",
        column,
        column,
        value,
        families[familyIndex][F_ID]
    );
    mysql_tquery(mysql, totalstring);

    totalstring[0] = EOS;

    return true;
}

stock Family:RepairVehicles(familyIndex)
{
    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_ID] == INVALID_FAMILY_ID
            || family_cars[familyIndex][i][FV_STATE] != ALIVE)
            continue;

        RepairVehicle(family_cars[familyIndex][i][FV_VEHICLE_ID]);
    }

    return true;
}

stock Family:GetDamagedCarsCount(familyIndex)
{
    new totalVehicles = 0, Float:vehicleHealth;

    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_MODEL] == INVALID_FAMILY_ID
            || family_cars[familyIndex][i][FV_STATE] != ALIVE)
            continue;

        GetVehicleHealth(
            family_cars[familyIndex][i][FV_VEHICLE_ID],
            vehicleHealth
        );

        if (vehicleHealth < 990) {
            totalVehicles++;
        }
    }

    return totalVehicles;
}

stock Family:RespawnVehicle(vehicleid)
{
    new vehicleIndex = INVALID_VEHICLE_ID,
        familyIndex = VehInfo[vehicleid][v_family_index] - 1;

    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_VEHICLE_ID] != vehicleid) continue;

        vehicleIndex = i;
        break;
    }

    if (vehicleIndex == INVALID_VEHICLE_ID) {
        return;
    }

    Family:UnloadVehicle(familyIndex, vehicleIndex);
    Family:SpawnVehicleByFamilyIndex(familyIndex, vehicleIndex);
}

stock Family:RespawnEmptyVehicles(familyIndex)
{
    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_MODEL] == INVALID_FAMILY_ID
            || family_cars[familyIndex][i][FV_STATE] == NOT_SPAWNED)
            continue;

        if (!IsVehicleOccupied(family_cars[familyIndex][i][FV_VEHICLE_ID])) {
            W_DestroyVehicle(family_cars[familyIndex][i][FV_VEHICLE_ID]);
            Family:DestroyVehicle3DText(familyIndex, i);
            Family:SpawnVehicleByFamilyIndex(familyIndex, i);
        }
    }

    return true;
}

stock Family:GetEmptyVehiclesCount(familyIndex)
{
    new totalVehicles = 0;

    for (new i = 0; i < FAMILY_MAX_VEHICLES; i++) {
        if (family_cars[familyIndex][i][FV_MODEL] == INVALID_FAMILY_ID
            || family_cars[familyIndex][i][FV_STATE] == NOT_SPAWNED)
            continue;

        if (!IsVehicleOccupied(family_cars[familyIndex][i][FV_VEHICLE_ID])) {
            totalVehicles++;
        }
    }

    return totalVehicles;
}

stock Family:SaveFamilyRankString(familyIndex, rankIndex, const column[], value[], size = sizeof value)
{
    mysql_escape_string(value, value, size);

    format(
        totalstring,
        sizeof totalstring,
        "UPDATE "#DB_FAMILY_RANKS" SET %s = '%s' WHERE id = %d",
        column,
        value,
        family_ranks[familyIndex][rankIndex][FR_ID]
    );
    mysql_tquery(mysql, totalstring);

    totalstring[0] = EOS;

    return true;
}

stock Family:GetAvailableCarsToSpawn(familyIndex)
{
    new onlinePlayers = Family:GetFamilyOnline(familyIndex),
        totalVehicles = Family:GetFamilyAliveVehiclesCount(familyIndex);
    
    new availableToSpawn = floatround(onlinePlayers / FAMILIES_VEHICLE_PER_PLAYERS, floatround_ceil);

    return (availableToSpawn == 0 ? 1 : availableToSpawn) - totalVehicles;
}

stock Family:CanSpawnNewVehiclesForFamily(familyIndex)
{
    new totalVehicles = Family:GetFamilyAliveVehiclesCount(familyIndex);

    return Family:GetAvailableCarsToSpawn(familyIndex) > totalVehicles;
}

stock Family:SpawnVehicleByFamilyIndex(familyId, vehicleIndex)
{
    family_cars[familyId][vehicleIndex][FV_VEHICLE_ID] = W_CreateVehicle(
        family_cars[familyId][vehicleIndex][FV_MODEL],
        family_cars[familyId][vehicleIndex][FV_X],
        family_cars[familyId][vehicleIndex][FV_Y],
        family_cars[familyId][vehicleIndex][FV_Z],
        family_cars[familyId][vehicleIndex][FV_ROT],
        family_cars[familyId][vehicleIndex][FV_COLOR_1],
        family_cars[familyId][vehicleIndex][FV_COLOR_2],
        0
    );
    family_cars[familyId][vehicleIndex][FV_STATE] = ALIVE;

    format(
        totalstring,
        sizeof totalstring,
        "{"#DC_MAIN"}Транспорт семьи\n{"#DC_WHITE"}%s",
        families[familyId][F_NAME]
    );

    family_cars[familyId][vehicleIndex][FV_3DTEXT] = CreateDynamic3DTextLabel(totalstring, 0xFFFFFFFF, 0.0, 0.0, 0.38, 10.0, .attachedvehicle = family_cars[familyId][vehicleIndex][FV_VEHICLE_ID]);

    VehInfo[family_cars[familyId][vehicleIndex][FV_VEHICLE_ID]][v_family_index] = familyId + 1;
    totalstring[0] = EOS;
}

stock Family:DestroyVehicle3DText(familyIndex, vehicleIndex)
{
    if (!IsValidDynamic3DTextLabel(family_cars[familyIndex][vehicleIndex][FV_3DTEXT])) {
        return;
    }

    DestroyDynamic3DTextLabel(family_cars[familyIndex][vehicleIndex][FV_3DTEXT]);
}

stock Family:SpawnVehicle(playerid, vehicleIndex, skipChecks = false)
{
    new familyId = GetPlayerFamilyIndex(playerid);

    if (!skipChecks && !Family:CanSpawnNewVehiclesForFamily(familyId)) {
        Hud:ShowNotification(playerid, ERROR, "Ваша семья достигла лимита активных машин");
        return false;
    }

    Family:SpawnVehicleByFamilyIndex(familyId, vehicleIndex);

    return true;
}

stock Family:SendFamilyMessageById(familyId, const message[])
{
    new familyIndex = INVALID_FAMILY_ID;

    for (new i = 0; i < MAX_LOADED_FAMILIES; i++) {
        if (families[i][F_ID] != familyId)
            continue;

        familyIndex = i;
        break;
    }

    if (familyIndex == INVALID_FAMILY_ID) {
        return false;
    }

    return Family:SendFamilyMessageByIndex(familyIndex, message); 
}

stock Family:SavePlayerRank(playerid)
{
    format(
        bigstring,
        sizeof bigstring,
        "UPDATE "#DB_FAMILY_MEMBERS" SET rank_id = %d WHERE family_id = %d AND member_id = %d",
        GetPlayerFamilyRankIndex(playerid) + 1,
        families[GetPlayerFamilyIndex(playerid)][F_ID],
        GetPlayerAccountID(playerid)
    );
    mysql_tquery(mysql, bigstring);

    bigstring[0] = EOS;
}

stock Family:SendFamilyMessageByIndex(familyIndex, const message[])
{
    totalstring[0] = EOS;

    format(
        totalstring,
        sizeof totalstring,
        "{%s}%s",
        families[familyIndex][F_COLOR],
        message
    );

    new color[20];

    format(color, sizeof color, "{%s}", families[familyIndex][F_COLOR]);

    regex_replace(totalstring, "\\{familyColor\\}", color, totalstring);

    foreach (new i: Player) {
        if (familyIndex != GetPlayerFamilyIndex(i))
            continue;

        SendClientMessage(i, COLOR_WHITE, totalstring);
    }

    totalstring[0] = EOS;
    return true;
}

stock Family:SendPrivateMessage(playerid, const message[])
{
    format(
        totalstring,
        sizeof totalstring,
        "{%s}"FAMILY_ACTIONS_PREFIX"%s",
        families[GetPlayerFamilyIndex(playerid)][F_COLOR],
        message
    );

    SendClientMessage(playerid, COLOR_WHITE, totalstring);

    totalstring[0] = EOS;
    return true;
}

stock Family:SendFamilyMessage(playerid, const message[])
{
    return Family:SendFamilyMessageByIndex(GetPlayerFamilyIndex(playerid), message);
}

stock Family:LoadFamilyForPlayer(playerid, familyId)
{
    new familyIndex = INVALID_FAMILY_ID;

    for (new i = 0; i < MAX_LOADED_FAMILIES; i++) {
        if (families[i][F_ID] == familyId) {
            familyIndex = i;
            break;
        }
    }

    if (familyIndex != INVALID_FAMILY_ID) {
        PlayerInfo[playerid][p_family_index] = familyIndex;
        Family:Create3DTextForPlayer(playerid);
        Family:NotifyPlayerOnJoin(playerid);
        return;
    }

    familyIndex = Family:GetFreeFamilySlot();

    if (familyIndex == INVALID_FAMILY_ID) { // unable to init family: all slots are in use.
        return;
    }

    format(
        bigstring,
        sizeof bigstring,
        "SELECT * FROM "DB_FAMILIES" WHERE id = %d AND deleted_at IS NULL",
        familyId
    );

    new Cache:family_request = mysql_query(mysql, bigstring);

    //SCMF(playerid, -1, "index = %d", familyIndex);

    if (cache_num_rows() == 0) {
        families[familyIndex] = default_family;
        PlayerInfo[playerid][p_family_index] = INVALID_FAMILY_ID;
        return;
    }

    families[familyIndex][F_ID] = familyId;
    cache_get_value_name(0, "name", families[familyIndex][F_NAME]);
    cache_get_value_name(0, "color", families[familyIndex][F_COLOR]);
    cache_get_value_name_int(0, "balance", families[familyIndex][F_BALANCE]);
    cache_get_value_name(0, "notification", families[familyIndex][F_NOTIFICATION]);

    cache_delete(family_request);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT * FROM "DB_FAMILY_RANKS" WHERE family_id = %d",
        familyId
    );

    new Cache:family_ranks_request = mysql_query(mysql, bigstring);

    new rankId, rankIndex;

    for (new i = 0; i < cache_num_rows(); i++) {
        cache_get_value_name_int(i, "rank_id", rankId); 

        rankIndex = rankId - 1;       

        cache_get_value_name(i, "title", family_ranks[familyIndex][rankIndex][FR_NAME]);
        cache_get_value_name_int(i, "id", family_ranks[familyIndex][rankIndex][FR_ID]);
    }

    cache_delete(family_ranks_request);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT * FROM "DB_FAMILY_VEHICLES" WHERE family_id = %d",
        familyId
    );

    new Cache:family_vehicles_request = mysql_query(mysql, bigstring);

    for (new i = 0; i < cache_num_rows(); i++) {
        cache_get_value_name_int(i, "id", family_cars[familyIndex][i][FV_ID]);
        cache_get_value_name_int(i, "vehicle_model", family_cars[familyIndex][i][FV_MODEL]);
        cache_get_value_name_int(i, "minimum_rank", family_cars[familyIndex][i][FV_RANK]);
        cache_get_value_name_int(i, "color_1", family_cars[familyIndex][i][FV_COLOR_1]);
        cache_get_value_name_int(i, "color_2", family_cars[familyIndex][i][FV_COLOR_2]);
        cache_get_value_name_int(i, "minimum_rank", family_cars[familyIndex][i][FV_RANK]);
        cache_get_value_name_float(i, "x", family_cars[familyIndex][i][FV_X]);
        cache_get_value_name_float(i, "y", family_cars[familyIndex][i][FV_Y]);
        cache_get_value_name_float(i, "z", family_cars[familyIndex][i][FV_Z]);
        cache_get_value_name_float(i, "rotation", family_cars[familyIndex][i][FV_ROT]);
    }

    cache_delete(family_vehicles_request);

    bigstring[0] = EOS;

    PlayerInfo[playerid][p_family_index] = familyIndex;
    Family:Create3DTextForPlayer(playerid);
    Family:NotifyPlayerOnJoin(playerid);
}

stock Family:SearchForFamily(playerid, const name[FAMILY_MAX_COLORED_SYMBOLS], offset = 0)
{
    new escaped_name[FAMILY_MAX_COLORED_SYMBOLS];

    mysql_escape_string(name, escaped_name);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT 1 FROM "DB_FAMILIES" WHERE clean_name LIKE '%s%s%s' AND deleted_at IS NULL", // yeah its pawn bro
        "%",
        escaped_name,
        "%"
    );

    new orderBy[20];

    switch(FamilyOrderBy:GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_ORDER)) {
        case CREATED_AT_ASC: strcat(orderBy, "f.created_at ASC");
        case CREATED_AT_DESC: strcat(orderBy, "f.created_at DESC");
        case MEMBERS_ASC: strcat(orderBy, "members_count ASC");
        case MEMBERS_DESC: strcat(orderBy, "members_count DESC");
    }

    new Cache:request_families_count = mysql_query(mysql, bigstring);

    SetPVarInt(playerid, PVAR_FAMILIES_SEARCH_TOTAL, cache_num_rows());
    cache_delete(request_families_count);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT f.id, f.name, DATE(f.created_at) as created_at, COUNT(fm.id) AS members_count FROM "DB_FAMILIES" f LEFT JOIN "DB_FAMILY_MEMBERS" fm ON fm.family_id = f.id AND fm.deleted_at IS NULL WHERE clean_name LIKE '%s%s%s' AND f.deleted_at IS NULL GROUP BY f.id ORDER BY %s LIMIT %d, "#FAMILIES_PER_PAGE,
        "%",
        escaped_name,
        "%",
        orderBy,
        offset
    );

    print(bigstring);

    mysql_tquery(mysql, bigstring, FamilyText(Family:OnSearchDone), "d", playerid);

    format(
        family_search_requests[playerid],
        FAMILY_MAX_COLORED_SYMBOLS,
        "%s",
        name
    );
    SetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET, offset);

    bigstring[0] = EOS;

    return true;
}

stock Family:ShowMembers(playerid, familyIndex, offset = 0)
{

    format(
        bigstring,
        sizeof bigstring,
        "SELECT 1 FROM "DB_FAMILY_MEMBERS" WHERE family_id = %d AND deleted_at IS NULL", // yeah its pawn bro
        families[familyIndex][F_ID]
    );

    new Cache:request_families_count = mysql_query(mysql, bigstring);

    SetPVarInt(playerid, PVAR_FAMILIES_SEARCH_TOTAL, cache_num_rows());
    cache_delete(request_families_count);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT a.name, a.phonenumber as number, DATE(a.releasedate) as last_played, rank_id FROM "DB_FAMILY_MEMBERS" f "\
        "LEFT JOIN accounts a ON a.id = f.member_id "\
        "WHERE f.family_id = %d AND f.deleted_at IS NULL ORDER BY rank_id DESC LIMIT %d, "#FAMILIES_PER_PAGE,
        families[familyIndex][F_ID],
        offset
    );

    mysql_tquery(mysql, bigstring, FamilyText(Family:OnMembersLoadDone), "dd", playerid, familyIndex);
    SetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET, offset);

    return true;
}

stock Family:GetRelations(playerid, familyIndex, RelationType:relationType, offset = 0, bool:fromManage = false)
{
    format(
        bigstring,
        sizeof bigstring,
        "SELECT 1 FROM "DB_FAMILY_RELATIONSHIPS" WHERE family_id = %d AND relation_type = %d", // yeah its pawn bro
        families[familyIndex][F_ID],
        _:relationType
    );

    new Cache:request_families_count = mysql_query(mysql, bigstring);

    SetPVarInt(playerid, PVAR_FAMILIES_SEARCH_TOTAL, cache_num_rows());
    cache_delete(request_families_count);

    format(
        bigstring,
        sizeof bigstring,
        "SELECT fr.related_family_id, DATE(fr.created_at) as created_at, name, relation_type, "\
        "(SELECT COUNT(id) FROM "#DB_FAMILY_MEMBERS" WHERE family_id = %d AND deleted_at IS NULL) as members_count "\
        "FROM family_relationships fr "\
        "LEFT JOIN families f ON f.id = fr.related_family_id "\
        "WHERE family_id = %d and relation_type = %d "\
        "LIMIT %d, "#FAMILIES_PER_PAGE,
        families[familyIndex][F_ID],
        families[familyIndex][F_ID],
        _:relationType,
        offset
    );

    mysql_tquery(mysql, bigstring, FamilyText(Family:OnRelationsLoadDone), "dd", playerid, familyIndex);
    SetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET, offset);
    SetPVarInt(playerid, PVAR_FAMILIES_FROM_RL_MANAGE, fromManage);
    SetPVarInt(playerid, PVAR_FAMILIES_CURRENT_RELATION, _:relationType);
    return true;
}

stock Family:GetSellPriceForModel(model)
{
    for (new i = 0; i < sizeof available_family_cars; i++) {
        if (available_family_cars[i][FAC_MODEL] != model)
            continue;

        return available_family_cars[i][FAC_SELL_PRICE];
    }

    return FAMILY_DEFAULT_SELL_PRICE;
}

stock FamilyCarPrice:Family:GetSellPriceTypeForModel(model)
{
    for (new i = 0; i < sizeof available_family_cars; i++) {
        if (available_family_cars[i][FAC_MODEL] != model)
            continue;

        return available_family_cars[i][FAC_PRICE_TYPE];
    }

    return FAMILY_CASH;
}

stock Family:GetSellPriceStringForModel(model)
{
    new price[20];

    new price_numeric = Family:GetSellPriceForModel(model);

    /*
    switch (Family:GetSellPriceTypeForModel(model)) {
        case FAMILY_CASH: format(price, sizeof price, "{"#DC_GREEN"}$%d", price_numeric);
        case DONATE: format(price, sizeof price, "{"#DC_GOLD"}%d RUB", price_numeric);
    }
    */
    format(price, sizeof price, "{"#DC_GREEN"}$%d", price_numeric);

    return price;
}

stock Family:OnPlayerPayDay(playerid)
{
    new repFamilyBonus = F_REP_NON_VIP_PAYDAY_RATE;

    switch (PlayerInfo[playerid][pVipStatus]) {
        case 2: repFamilyBonus = F_REP_PALLADIUM_VIP_PAYDAY_RATE;
        case 3: repFamilyBonus = F_REP_GOLD_VIP_PAYDAY_RATE;
    } 

    Family:IncrementFamilyInt(GetPlayerFamilyIndex(playerid), "points", repFamilyBonus);
}

stock Family:BuyNewVehicle(playerid, familyIndex, freeSlotIndex, vehicleIndex)
{
    new Float:x, Float:y, Float:z, Float:rot;

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, rot);

    family_cars[familyIndex][freeSlotIndex][FV_MODEL] = available_family_cars[vehicleIndex][FAC_MODEL];
    family_cars[familyIndex][freeSlotIndex][FV_X] = x + 0.02;
    family_cars[familyIndex][freeSlotIndex][FV_Y] = y;
    family_cars[familyIndex][freeSlotIndex][FV_Z] = z;
    family_cars[familyIndex][freeSlotIndex][FV_ROT] = rot;

    format(
        bigstring,
        sizeof bigstring,
        "INSERT INTO "#DB_FAMILY_VEHICLES" (vehicle_model, family_id, x, y, z, rotation) VALUES (%d, %d, %.2f, %.2f, %.2f, %.2f)",
        available_family_cars[vehicleIndex][FAC_MODEL],
        families[familyIndex][F_ID],
        x + 0.02, y, z, rot
    );
    mysql_tquery(mysql, bigstring, FamilyText(Family:OnVehicleBought), "dddd", playerid, familyIndex, freeSlotIndex, vehicleIndex);
    Family:CalculateVehicleBoughtRep(playerid, familyIndex);
    bigstring[0] = EOS;
    return true;
}

stock Family:GetRankByAccountId(familyIndex, accountId)
{
    format(
        bigstring,
        sizeof bigstring,
        "SELECT rank_id FROM "DB_FAMILY_MEMBERS" WHERE family_id = %d AND member_id = %d",
        families[familyIndex][F_ID],
        accountId
    );

    new Cache:request_account_exists = mysql_query(mysql, bigstring);

    new rank;

    cache_get_value_name_int(0, "rank_id", rank);

    cache_delete(request_account_exists);

    return rank;
}

stock Family:IsAccountRelatedWithFamily(familyIndex, accountId)
{
    format(
        bigstring,
        sizeof bigstring,
        "SELECT 1 FROM "DB_FAMILY_MEMBERS" WHERE family_id = %d AND member_id = %d",
        families[familyIndex][F_ID],
        accountId
    );

    new Cache:request_account_exists = mysql_query(mysql, bigstring);

    new rows = cache_num_rows();

    cache_delete(request_account_exists);

    return rows > 0;
}

stock Family:Create3DTextForPlayer(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    format(
        bigstring,
        sizeof bigstring,
        "{"#DC_MAIN"}Семья {"#DC_WHITE"}%s",
        families[familyIndex][F_NAME]
    );

    PlayerInfo[playerid][p_family_3dtext] = CreateDynamic3DTextLabel(bigstring, 0xFFFFFFFF, 0.0, 0.0, 0.38, 10.0, .attachedplayer = playerid);

    bigstring[0] = EOS;
}

stock Family:RecreateFamily3DTextLabels(familyIndex)
{
    foreach (new i: Player) {
        if (PlayerInfo[i][p_family_index] != familyIndex)
            continue;
        
        Family:Destroy3DTextOfPlayer(i);
        Family:Create3DTextForPlayer(i);
    }
}

stock Family:Destroy3DTextOfPlayer(playerid)
{
    if (!IsValidDynamic3DTextLabel(PlayerInfo[playerid][p_family_3dtext])) {
        return;
    }

    DestroyDynamic3DTextLabel(PlayerInfo[playerid][p_family_3dtext]);
    PlayerInfo[playerid][p_family_3dtext] = Text3D:INVALID_3DTEXT_ID;
}

stock Family:NotifyPlayerOnJoin(playerid)
{
    new familyIndex = GetPlayerFamilyIndex(playerid);

    if (strlen(families[familyIndex][F_NOTIFICATION]) < 1) {
        return;
    }

    Family:SendPrivateMessage(playerid, "Сообщение от руководителя семьи:");
    Family:SendPrivateMessage(playerid, families[familyIndex][F_NOTIFICATION]);
}

stock Family:GetFamiliesCount()
{
    new Cache:request_families_count = mysql_query(mysql, "SELECT 1 FROM "DB_FAMILIES" WHERE deleted_at IS NULL");

    new rows = cache_num_rows();

    cache_delete(request_families_count);

    return rows;
}

stock Family:Create(name[], cleanName[FAMILY_MAX_COLORED_SYMBOLS], ownerId, size = sizeof name)
{
    mysql_escape_string(name, name, size);
    mysql_escape_string(cleanName, cleanName);

    format(
        bigstring,
        sizeof bigstring,
        "INSERT INTO "DB_FAMILIES" (name, clean_name) VALUES ('%s', '%s')",
        name,
        cleanName
    );

    new familyIndex = Family:GetFreeFamilySlot();

    strcat(families[familyIndex][F_NAME], name);

    mysql_tquery(mysql, bigstring, FamilyText(Family:OnFamilySaved), "dd", ownerId, familyIndex);
    bigstring[0] = EOS;
}

publics: Family:OnVehicleBought(playerid, familyIndex, freeSlotIndex, vehicleIndex)
{
    family_cars[familyIndex][freeSlotIndex][FV_ID] = cache_insert_id();

    SetPVarInt(playerid, PVAR_FAMILIES_CURRENT_VEHICLE, freeSlotIndex);

    return Dialog_Show(playerid, Dialog:dFamilyVehColor);
}

publics: Family:OnSearchDone(playerid)
{
    if (!cache_num_rows()) {
        return Dialog_Show(playerid, Dialog:dFamilyNothingFound);
    }

    bigstring[0] = EOS;

    strcat(bigstring, "{"#DC_MAIN"}Семья\t{"#DC_MAIN"}Количество участников\t{"#DC_MAIN"}Дата создания\n");

    new name[FAMILY_MAX_COLORED_SYMBOLS], created_at[20], members_count, family_id, totalFamilies = 0;

    new offset = GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET);

    ClearPlayerListitemData(playerid);

    for(new i = 0; i < cache_num_rows(); i++) {
        cache_get_value_name_int(i, "id", family_id);
        cache_get_value_name_int(i, "members_count", members_count);
        cache_get_value_name(i, "name", name);
        cache_get_value_name(i, "created_at", created_at);

        SetPlayerListitemData(playerid, totalFamilies, family_id);

        format(
            totalstring,
            sizeof totalstring,
            "{"#DC_MAIN"}%d. {"#DC_WHITE"}%s\t{"#DC_GREEN"}%d чел.\t{"#DC_WHITE"}%s\n",
            offset + totalFamilies + 1,
            name,
            members_count,
            created_at
        );

        strcat(bigstring, totalstring);
        totalFamilies++;
    }

    if (offset + totalFamilies < GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_TOTAL)) {
        strcat(bigstring, "{"#DC_MAIN"}Далее \t{"#DC_WHITE"}--->\n");
        SetPlayerListitemData(playerid, totalFamilies, FAMILIES_SEARCH_ID_NEXT);
        totalFamilies++;
    }
    
    if (offset > 0) {
        strcat(bigstring, "{"#DC_WHITE"}<---\t{"#DC_MAIN"}Назад\n");
        SetPlayerListitemData(playerid, totalFamilies, FAMILIES_SEARCH_ID_BACK);
    }


    totalstring[0] = EOS;
    
    Dialog_Open(
        playerid,
        Dialog:dFamilySearchList,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}Поиск семей",
        bigstring,
        "Выбрать",
        "Назад"
    );

    bigstring[0] = EOS;

    return true;
}

publics: Family:OnMembersLoadDone(playerid, familyIndex)
{
    totalstring[0] = EOS;

    strcat(totalstring, "{"#DC_MAIN"}Имя\t{"#DC_MAIN"}Последний вход\t{"#DC_MAIN"}Ранг\t{"#DC_MAIN"}Номер телефона\n");

    new name[FAMILY_MAX_COLORED_SYMBOLS],
        rank_id, number, target_id,
        created_at[20], totalFamilies, phone[25];

    new offset = GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET);

    ClearPlayerListitemData(playerid);

    for(new i = 0; i < cache_num_rows(); i++) {
        cache_get_value_name(i, "name", name);
        cache_get_value_name_int(i, "rank_id", rank_id);
        cache_get_value_name_int(i, "number", number);
        cache_get_value_name(i, "last_played", created_at);

        target_id = GetPlayerIdByName(name);

        if (!number) {
            strcat(phone, "{"#DC_GRAY"}Отсутствует");
        } else {
            format(phone, sizeof phone, "%d", number);
        }

        format(
            bigstring,
            sizeof bigstring,
            "{"#DC_MAIN"}%d. {"#DC_WHITE"}%s\t{"#DC_WHITE"}%s\t{"#DC_WHITE"}%s [%d]\t{"#DC_WHITE"}%s\n",
            offset + totalFamilies + 1,
            name,
            target_id == INVALID_PLAYER_ID ? created_at : "{"#DC_GREEN"}Онлайн",
            family_ranks[familyIndex][rank_id - 1][FR_NAME],
            rank_id,
            phone
        );

        strcat(totalstring, bigstring);
        totalFamilies++;
    }

    if (offset + totalFamilies < GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_TOTAL)) {
        strcat(totalstring, "{"#DC_MAIN"}Далее \t{"#DC_WHITE"}--->\n");
        SetPlayerListitemData(playerid, totalFamilies, FAMILIES_SEARCH_ID_NEXT);
        totalFamilies++;
    }
    
    if (offset > 0) {
        strcat(totalstring, "{"#DC_WHITE"}<---\t{"#DC_MAIN"}Назад\n");
        SetPlayerListitemData(playerid, totalFamilies, FAMILIES_SEARCH_ID_BACK);
    }


    bigstring[0] = EOS;
    
    Dialog_Open(
        playerid,
        Dialog:dFamilyMembers,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}Список участников",
        totalstring,
        "Выбрать",
        "Назад"
    );

    totalstring[0] = EOS;

    return true;
}

publics: Family:OnRelationsLoadDone(playerid, familyIndex)
{
    totalstring[0] = EOS;

    strcat(totalstring, "{"#DC_MAIN"}Семья\t{"#DC_MAIN"}Участники\t{"#DC_MAIN"}Инициированы\n");

    new name[FAMILY_MAX_COLORED_SYMBOLS], fr_id, totalMembers, created_at[20], totalFamilies;

    new offset = GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_OFFSET);

    ClearPlayerListitemData(playerid);

    for(new i = 0; i < cache_num_rows(); i++) {
        cache_get_value_name(i, "name", name);
        cache_get_value_name_int(i, "related_family_id", fr_id);
        cache_get_value_name_int(i, "members_count", totalMembers);
        cache_get_value_name(i, "created_at", created_at);

        SetPlayerListitemData(playerid, totalFamilies, fr_id);

        format(
            bigstring,
            sizeof bigstring,
            "{"#DC_MAIN"}%d. {"#DC_WHITE"}%s\t{"#DC_GREEN"}%d чел.\t{"#DC_WHITE"}%s\n",
            offset + totalFamilies + 1,
            name,
            totalMembers,
            created_at
        );

        strcat(totalstring, bigstring);
        totalFamilies++;
    }

    if (offset + totalFamilies < GetPVarInt(playerid, PVAR_FAMILIES_SEARCH_TOTAL)) {
        strcat(totalstring, "{"#DC_MAIN"}Далее \t{"#DC_WHITE"}--->\n");
        SetPlayerListitemData(playerid, totalFamilies, FAMILIES_SEARCH_ID_NEXT);
        totalFamilies++;
    }
    
    if (offset > 0) {
        strcat(totalstring, "{"#DC_WHITE"}<---\t{"#DC_MAIN"}Назад\n");
        SetPlayerListitemData(playerid, totalFamilies, FAMILIES_SEARCH_ID_BACK);
        totalFamilies++;
    }

    if (GetPVarInt(playerid, PVAR_FAMILIES_FROM_RL_MANAGE)) {
        SetPlayerListitemData(playerid, totalFamilies, FAMILIES_ADD_RELATION);
        strcat(totalstring, "{"#DC_GREEN"}Добавить семью\n");
    }

    bigstring[0] = EOS;

    if (!GetPVarInt(playerid, PVAR_FAMILIES_FROM_RL_MANAGE) && totalFamilies == 0) {
        return Dialog_MessageEx(
            playerid,
            Dialog:dFamilyNotificationView,
            "{"#DC_MAIN"}Список связанных семей",
            "{"#DC_WHITE"}Связи не найдены",
            "Назад",
            "" 
        );
    }
    
    Dialog_Open(
        playerid,
        Dialog:dFamilyRelations,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}Список связанных семей",
        totalstring,
        "Выбрать",
        "Назад"
    );

    totalstring[0] = EOS;

    return true;
}

publics: Family:OnLoadMember(playerid)
{
    if (!cache_num_rows()) {
        return;
    }

    new familyId, familyRank;

    cache_get_value_name_int(0, "family_id", familyId);
    cache_get_value_name_int(0, "rank_id", familyRank);

    // actual rank id is stored in db, while we need just an index of an array
    PlayerInfo[playerid][p_family_rank_index] = familyRank - 1;

    Family:LoadFamilyForPlayer(playerid, familyId);
}

publics: Family:OnFamilySaved(ownerId, familyIndex)
{
    new familyId = cache_insert_id();

    bigstring[0] = EOS;

    for (new i = 0; i < FAMILY_MAX_RANKS; i++) {
        format(
            bigstring,
            sizeof bigstring,
            "INSERT INTO "DB_FAMILY_RANKS" (family_id, rank_id, title) VALUES (%d, %d, '%s')",
            familyId,
            i + 1,
            family_default_ranks[i]
        );

        // should be called synchronously
        // to make sure all ranks will be saved when we'll load family
        mysql_query(mysql, bigstring);
    }

    format(
        bigstring,
        sizeof bigstring,
        "INSERT INTO "DB_FAMILY_MEMBERS" (family_id, member_id, rank_id) VALUES (%d, %d, "#FAMILY_OWNER_RANK")",
        familyId,
        GetPlayerAccountID(ownerId)
    );

    mysql_tquery(mysql, bigstring);

    Family:LoadFamilyForPlayer(ownerId, familyId);

    PlayerInfo[ownerId][p_family_rank_index] = FAMILY_OWNER_RANK_INDEX;

    Family:SendPrivateMessage(ownerId, "Поздравляем с созданием семьи! Чтобы ознакомиться со списком доступных команд, введите /help -> Семья");

    bigstring[0] = EOS;
}