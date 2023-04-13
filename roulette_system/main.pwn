stock DonateRoulette:ShowPlayerInterface(playerid)
{
    new type_roulette = GetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE);

    DonateRoulette:CreatePlayerTextDraws(playerid);

    for(new idx; idx != MAX_GLOBAL_TD_ROULETTE; idx++)
        TextDrawShowForPlayer(playerid, TD_roulette[idx]);

    new prize_id;

    for(new idx; idx != MAX_ROULETTE_SLOTS_TD; idx++)
    {
        prize_id = g_player_roulette_prize_id[playerid][type_roulette][idx];

        PlayerTextDrawSetPreviewModel(
            playerid, 
            PTD_roulette[playerid][idx], 
            g_roulette_prize[type_roulette][prize_id][PRIZE_MODELID]
        );

        PlayerTextDrawSetPreviewRot(
            playerid, 
            PTD_roulette[playerid][idx], 
            g_roulette_prize[type_roulette][prize_id][PRIZE_ROT_X],
            g_roulette_prize[type_roulette][prize_id][PRIZE_ROT_Y],
            g_roulette_prize[type_roulette][prize_id][PRIZE_ROT_Z],
            g_roulette_prize[type_roulette][prize_id][PRIZE_ROT_SCALE]
        );
    }

    switch(type_roulette)
    {
        case ROULETTE_TYPE_BRONZE: 
        {
            format(totalstring, sizeof totalstring, "BRONZE_~W~ROULETTE");
            PlayerTextDrawSetString(playerid, PTD_roulette[playerid][5], totalstring);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][5], COLOR_ROULETTE_BRONZE_TEXT);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][6], COLOR_ROULETTE_SELECT_BRONZE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][7], COLOR_ROULETTE_SELECT_BRONZE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][8], COLOR_ROULETTE_SELECT_BRONZE);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][9], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][10], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][11], COLOR_ROULETTE_SELECT_NONE);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][12], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][13], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][14], COLOR_ROULETTE_SELECT_NONE);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][15], COLOR_ROULETTE_SELECT_TEXT_BRONZE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][16], COLOR_ROULETTE_SELECT_TEXT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][17], COLOR_ROULETTE_SELECT_TEXT_NONE);
        }

        case ROULETTE_TYPE_SILVER: 
        {
            format(totalstring, sizeof totalstring, "SILVER_~W~ROULETTE");
            PlayerTextDrawSetString(playerid, PTD_roulette[playerid][5], totalstring);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][5], COLOR_ROULETTE_SILVER_TEXT);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][6], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][7], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][8], COLOR_ROULETTE_SELECT_NONE);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][9], COLOR_ROULETTE_SELECT_SILVER);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][10], COLOR_ROULETTE_SELECT_SILVER);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][11], COLOR_ROULETTE_SELECT_SILVER);
            
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][12], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][13], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][14], COLOR_ROULETTE_SELECT_NONE);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][15], COLOR_ROULETTE_SELECT_TEXT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][16], COLOR_ROULETTE_SELECT_TEXT_SILVER);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][17], COLOR_ROULETTE_SELECT_TEXT_NONE);
        }

        case ROULETTE_TYPE_GOLD: 
        {
            format(totalstring, sizeof totalstring, "GOLD_~W~ROULETTE"); 
            PlayerTextDrawSetString(playerid, PTD_roulette[playerid][5], totalstring);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][5], COLOR_ROULETTE_GOLD_TEXT);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][6], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][7], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][8], COLOR_ROULETTE_SELECT_NONE);

            PlayerTextDrawColor(playerid, PTD_roulette[playerid][9], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][10], COLOR_ROULETTE_SELECT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][11], COLOR_ROULETTE_SELECT_NONE);
            
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][12], COLOR_ROULETTE_SELECT_GOLD);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][13], COLOR_ROULETTE_SELECT_GOLD);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][14], COLOR_ROULETTE_SELECT_GOLD);
            
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][15], COLOR_ROULETTE_SELECT_TEXT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][16], COLOR_ROULETTE_SELECT_TEXT_NONE);
            PlayerTextDrawColor(playerid, PTD_roulette[playerid][17], COLOR_ROULETTE_SELECT_TEXT_GOLD);
        }
    }

    totalstring[0] = EOS;

    for(new idx; idx != MAX_PLAYER_PTD_ROULETTE; idx++)
        PlayerTextDrawShow(playerid, PTD_roulette[playerid][idx]);

    SelectTextDraw(playerid, 0xFFFFFF00);

    SetPVarInt(playerid, PVAR_SHOW_ROULETTE_INTERFACE, 1);
    SetPVarInt(playerid, PVAR_SELECT_SLOT_ROULETTE, 1);

    DonateRoulette:UpdatePlayerCountSpin(playerid);

    return true;
}

stock DonateRoulette:HidePlayerInterface(playerid, bool:is_update = false)
{
    if(GetPVarInt(playerid, PVAR_STATE_ROULETTE))
        return Hud:ShowNotification(playerid, ERROR, "сейчас невозможно выполнить данное действие");

    for(new idx; idx != MAX_GLOBAL_TD_ROULETTE; idx++)
        TextDrawHideForPlayer(playerid, TD_roulette[idx]);

    for(new idx; idx != MAX_PLAYER_PTD_ROULETTE; idx++)
        PlayerTextDrawHide(playerid, PTD_roulette[playerid][idx]);

    DeletePVar(playerid, PVAR_SHOW_ROULETTE_INTERFACE);
    DonateRoulette:DestroyPlayerTextDraws(playerid);

    if(is_update)
        callcmd::roulette(playerid);

    return true;
}

stock DonateRoulette:GeneratePrize(playerid)
{
    new random_id_prize;

    for(new idx; idx != MAX_ROULETTE_SLOTS; idx++)
    {
        for(new idx_t; idx_t != MAX_ROULETTE_TYPES; idx_t++)
        {
            if(g_player_roulette_prize_id[playerid][idx_t][idx] != -1)
                continue;

            switch(idx_t)
            {
                case ROULETTE_TYPE_BRONZE: 
                    random_id_prize = random_ex(0, MAX_ROULETTE_PRIZE_BRONZE - 1, 1);

                case ROULETTE_TYPE_SILVER: 
                    random_id_prize = random_ex(0, MAX_ROULETTE_PRIZE_SILVER - 1, 1);

                case ROULETTE_TYPE_GOLD: 
                    random_id_prize = random_ex(0, MAX_ROULETTE_PRIZE_GOLD - 1, 1);
            }

            g_player_roulette_prize_id[playerid][idx_t][idx] = random_id_prize;
        }
    }

    return true;
}

stock DonateRoulette:ClearPlayerData(playerid)
{
    for(new idx; idx != MAX_ROULETTE_TYPES; idx++)
        for(new idx_slot; idx_slot != MAX_ROULETTE_SLOTS; idx_slot++)
            g_player_roulette_prize_id[playerid][idx][idx_slot] = -1;

    DonateRoulette:GeneratePrize(playerid);

    return true;
}

stock DonateRoulette:UpdatePlayerCountSpin(playerid)
{
    if(!GetPVarInt(playerid, PVAR_SHOW_ROULETTE_INTERFACE))
        return true;

    new type_roulette = GetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE);

    new index_slot = Inventory:GetItemSlotPlayerData(playerid, g_roulette[type_roulette][R_ITEM_ID]);
    new count_roulette =  Inventory:GetCountItemPlayerData(playerid, index_slot);

    format(totalstring, sizeof totalstring, "%d", count_roulette);
    PlayerTextDrawSetString(playerid, PTD_roulette[playerid][18], totalstring);

    DonateRoulette:UpdatePlayerTextDraw(playerid, PTD_roulette[playerid][18]);

    totalstring[0] = EOS;

    return true;
}

stock DonateRoulette:UpdatePlayerTextDraw(playerid, PlayerText:playertextid)
{
    PlayerTextDrawHide(playerid, playertextid);
    PlayerTextDrawShow(playerid, playertextid);

    return true;
}

stock DonateRoulette:CreateGlobalTextDraws()
{
    TD_roulette[0] = TextDrawCreate(190.000000, 178.100067, "LD_SPAC:white");
    TextDrawTextSize(TD_roulette[0], 279.000000, 82.000000);
    TextDrawAlignment(TD_roulette[0], 1);
    TextDrawColor(TD_roulette[0], 370546431);
    TextDrawBackgroundColor(TD_roulette[0], 255);
    TextDrawFont(TD_roulette[0], 4);
    TextDrawSetProportional(TD_roulette[0], 0);

    TD_roulette[1] = TextDrawCreate(185.000030, 243.499542, "ld_beat:chit");
    TextDrawTextSize(TD_roulette[1], 30.000000, 37.000000);
    TextDrawAlignment(TD_roulette[1], 1);
    TextDrawColor(TD_roulette[1], 370546431);
    TextDrawBackgroundColor(TD_roulette[1], 255);
    TextDrawFont(TD_roulette[1], 4);
    TextDrawSetProportional(TD_roulette[1], 0);

    TD_roulette[2] = TextDrawCreate(443.801361, 243.499542, "ld_beat:chit");
    TextDrawTextSize(TD_roulette[2], 30.000000, 37.000000);
    TextDrawAlignment(TD_roulette[2], 1);
    TextDrawColor(TD_roulette[2], 370546431);
    TextDrawBackgroundColor(TD_roulette[2], 255);
    TextDrawFont(TD_roulette[2], 4);
    TextDrawSetProportional(TD_roulette[2], 0);

    TD_roulette[3] = TextDrawCreate(200.000000, 247.000000, "LD_SPAC:white");
    TextDrawTextSize(TD_roulette[3], 259.499969, 27.499998);
    TextDrawAlignment(TD_roulette[3], 1);
    TextDrawColor(TD_roulette[3], 370546431);
    TextDrawBackgroundColor(TD_roulette[3], 255);
    TextDrawFont(TD_roulette[3], 4);
    TextDrawSetProportional(TD_roulette[3], 0);

    TD_roulette[4] = TextDrawCreate(215.000000, 196.800598, "LD_SPAC:white");
    TextDrawTextSize(TD_roulette[4], 228.869857, 59.749778);
    TextDrawAlignment(TD_roulette[4], 1);
    TextDrawColor(TD_roulette[4], -1738494977);
    TextDrawBackgroundColor(TD_roulette[4], 255);
    TextDrawFont(TD_roulette[4], 4);
    TextDrawSetProportional(TD_roulette[4], 0);

    TD_roulette[5] = TextDrawCreate(217.000000, 198.800323, "LD_SPAC:white");
    TextDrawTextSize(TD_roulette[5], 224.830017, 55.879928);
    TextDrawAlignment(TD_roulette[5], 1);
    TextDrawColor(TD_roulette[5], 370546431);
    TextDrawBackgroundColor(TD_roulette[5], 255);
    TextDrawFont(TD_roulette[5], 4);
    TextDrawSetProportional(TD_roulette[5], 0);

    TD_roulette[6] = TextDrawCreate(214.000000, 192.300018, "particle:lamp_shad_64");
    TextDrawTextSize(TD_roulette[6], 233.000000, 61.830055);
    TextDrawAlignment(TD_roulette[6], 1);
    TextDrawColor(TD_roulette[6], -241);
    TextDrawBackgroundColor(TD_roulette[6], 255);
    TextDrawFont(TD_roulette[6], 4);
    TextDrawSetProportional(TD_roulette[6], 0);

    TD_roulette[7] = TextDrawCreate(199.000000, 187.000000, "LD_SPAC:white");
    TextDrawTextSize(TD_roulette[7], 255.000000, 4.210000);
    TextDrawAlignment(TD_roulette[7], 1);
    TextDrawColor(TD_roulette[7], 370546431);
    TextDrawBackgroundColor(TD_roulette[7], 255);
    TextDrawFont(TD_roulette[7], 4);
    TextDrawSetProportional(TD_roulette[7], 0);

    TD_roulette[8] = TextDrawCreate(199.000000, 262.800231, "LD_SPAC:white");
    TextDrawTextSize(TD_roulette[8], 255.000000, 4.210000);
    TextDrawAlignment(TD_roulette[8], 1);
    TextDrawColor(TD_roulette[8], 370546431);
    TextDrawBackgroundColor(TD_roulette[8], 255);
    TextDrawFont(TD_roulette[8], 4);
    TextDrawSetProportional(TD_roulette[8], 0);

    TD_roulette[9] = TextDrawCreate(187.399719, 148.499969, "ld_beat:chit");
    TextDrawTextSize(TD_roulette[9], 15.000000, 17.000000);
    TextDrawAlignment(TD_roulette[9], 1);
    TextDrawColor(TD_roulette[9], 370546431);
    TextDrawBackgroundColor(TD_roulette[9], 255);
    TextDrawFont(TD_roulette[9], 4);
    TextDrawSetProportional(TD_roulette[9], 0);

    TD_roulette[10] = TextDrawCreate(456.000000, 148.399963, "ld_beat:chit");
    TextDrawTextSize(TD_roulette[10], 15.000000, 17.000000);
    TextDrawAlignment(TD_roulette[10], 1);
    TextDrawColor(TD_roulette[10], 370546431);
    TextDrawBackgroundColor(TD_roulette[10], 255);
    TextDrawFont(TD_roulette[10], 4);
    TextDrawSetProportional(TD_roulette[10], 0);

    TD_roulette[11] = TextDrawCreate(196.000000, 151.000000, "LD_SPAC:white");
    TextDrawTextSize(TD_roulette[11], 268.000000, 25.000000);
    TextDrawAlignment(TD_roulette[11], 1);
    TextDrawColor(TD_roulette[11], 370546431);
    TextDrawBackgroundColor(TD_roulette[11], 255);
    TextDrawFont(TD_roulette[11], 4);
    TextDrawSetProportional(TD_roulette[11], 0);

    TD_roulette[12] = TextDrawCreate(190.000000, 158.000000, "LD_SPAC:white");
    TextDrawTextSize(TD_roulette[12], 278.499969, 18.000000);
    TextDrawAlignment(TD_roulette[12], 1);
    TextDrawColor(TD_roulette[12], 370546431);
    TextDrawBackgroundColor(TD_roulette[12], 255);
    TextDrawFont(TD_roulette[12], 4);
    TextDrawSetProportional(TD_roulette[12], 0);

    TD_roulette[13] = TextDrawCreate(277.466583, 277.099975, "LD_SPAC:white"); // кликаб старт
    TextDrawTextSize(TD_roulette[13], 39.789859, 16.969963);
    TextDrawAlignment(TD_roulette[13], 1);
    TextDrawColor(TD_roulette[13], -1738494977);
    TextDrawBackgroundColor(TD_roulette[13], 255);
    TextDrawFont(TD_roulette[13], 4);
    TextDrawSetProportional(TD_roulette[13], 0);
    TextDrawSetSelectable(TD_roulette[13], true);

    TD_roulette[14] = TextDrawCreate(267.466583, 273.099975, "ld_beat:chit");
    TextDrawTextSize(TD_roulette[14], 21.100006, 24.870010);
    TextDrawAlignment(TD_roulette[14], 1);
    TextDrawColor(TD_roulette[14], -1738494977);
    TextDrawBackgroundColor(TD_roulette[14], 255);
    TextDrawFont(TD_roulette[14], 4);
    TextDrawSetProportional(TD_roulette[14], 0);

    TD_roulette[15] = TextDrawCreate(307.466583, 273.099975, "ld_beat:chit");
    TextDrawTextSize(TD_roulette[15], 21.100006, 24.870010);
    TextDrawAlignment(TD_roulette[15], 1);
    TextDrawColor(TD_roulette[15], -1738494977);
    TextDrawBackgroundColor(TD_roulette[15], 255);
    TextDrawFont(TD_roulette[15], 4);
    TextDrawSetProportional(TD_roulette[15], 0);

    TD_roulette[16] = TextDrawCreate(338.966888, 277.099975, "LD_SPAC:white"); // кликаб инв
    TextDrawTextSize(TD_roulette[16], 39.789859, 16.639963);
    TextDrawAlignment(TD_roulette[16], 1);
    TextDrawColor(TD_roulette[16], 842150655);
    TextDrawBackgroundColor(TD_roulette[16], 255);
    TextDrawFont(TD_roulette[16], 4);
    TextDrawSetProportional(TD_roulette[16], 0);
    TextDrawSetSelectable(TD_roulette[16], true);

    TD_roulette[17] = TextDrawCreate(328.966888, 273.099975, "ld_beat:chit");
    TextDrawTextSize(TD_roulette[17], 21.100006, 24.870010);
    TextDrawAlignment(TD_roulette[17], 1);
    TextDrawColor(TD_roulette[17], 842150655);
    TextDrawBackgroundColor(TD_roulette[17], 255);
    TextDrawFont(TD_roulette[17], 4);
    TextDrawSetProportional(TD_roulette[17], 0);

    TD_roulette[18] = TextDrawCreate(368.766265, 273.099975, "ld_beat:chit");
    TextDrawTextSize(TD_roulette[18], 21.100006, 24.870010);
    TextDrawAlignment(TD_roulette[18], 1);
    TextDrawColor(TD_roulette[18], 842150655);
    TextDrawBackgroundColor(TD_roulette[18], 255);
    TextDrawFont(TD_roulette[18], 4);
    TextDrawSetProportional(TD_roulette[18], 0);

    TD_roulette[19] = TextDrawCreate(298.466583, 280.099975, "START");
    TextDrawLetterSize(TD_roulette[19], 0.173332, 1.185184);
    TextDrawTextSize(TD_roulette[19], 0.000000, 54.000000);
    TextDrawAlignment(TD_roulette[19], 2);
    TextDrawColor(TD_roulette[19], -1);
    TextDrawSetShadow(TD_roulette[19], 0);
    TextDrawBackgroundColor(TD_roulette[19], 255);
    TextDrawFont(TD_roulette[19], 2);
    TextDrawSetProportional(TD_roulette[19], 1);

    TD_roulette[20] = TextDrawCreate(359.966888, 280.099975, "INV");
    TextDrawLetterSize(TD_roulette[20], 0.173332, 1.185184);
    TextDrawTextSize(TD_roulette[20], 0.000000, 54.000000);
    TextDrawAlignment(TD_roulette[20], 2);
    TextDrawColor(TD_roulette[20], -1);
    TextDrawSetShadow(TD_roulette[20], 0);
    TextDrawBackgroundColor(TD_roulette[20], 255);
    TextDrawFont(TD_roulette[20], 2);
    TextDrawSetProportional(TD_roulette[20], 1);

    TD_roulette[21] = TextDrawCreate(452.700042, 177.601013, "LD_BEAT:chit"); // Кликаб. вопросик
    TextDrawTextSize(TD_roulette[21], 17.000000, 20.000000);
    TextDrawAlignment(TD_roulette[21], 1);
    TextDrawColor(TD_roulette[21], 842150655);
    TextDrawBackgroundColor(TD_roulette[21], 255);
    TextDrawFont(TD_roulette[21], 4);
    TextDrawSetProportional(TD_roulette[21], 0);
    TextDrawSetSelectable(TD_roulette[21], true);

    TD_roulette[22] = TextDrawCreate(461.499969, 181.401062, "?");
    TextDrawLetterSize(TD_roulette[22], 0.201664, 1.268146);
    TextDrawTextSize(TD_roulette[22], 0.000000, 295.000000);
    TextDrawAlignment(TD_roulette[22], 2);
    TextDrawColor(TD_roulette[22], -1);
    TextDrawSetShadow(TD_roulette[22], 0);
    TextDrawBackgroundColor(TD_roulette[22], 255);
    TextDrawFont(TD_roulette[22], 2);
    TextDrawSetProportional(TD_roulette[22], 1);

    TD_roulette[23] = TextDrawCreate(213.333343, 181.477752, "LD_BEAT:chit");
    TextDrawLetterSize(TD_roulette[23], 0.041333, 0.153481);
    TextDrawTextSize(TD_roulette[23], 10.699996, 13.000000);
    TextDrawAlignment(TD_roulette[23], 1);
    TextDrawColor(TD_roulette[23], -1263225601);
    TextDrawBackgroundColor(TD_roulette[23], 255);
    TextDrawFont(TD_roulette[23], 4);
    TextDrawSetProportional(TD_roulette[23], 0);

    TD_roulette[24] = TextDrawCreate(214.266632, 182.836990, "LD_BEAT:chit");
    TextDrawLetterSize(TD_roulette[24], 0.041333, 0.153481);
    TextDrawTextSize(TD_roulette[24], 8.899997, 10.400000);
    TextDrawAlignment(TD_roulette[24], 1);
    TextDrawColor(TD_roulette[24], 370546431);
    TextDrawBackgroundColor(TD_roulette[24], 255);
    TextDrawFont(TD_roulette[24], 4);
    TextDrawSetProportional(TD_roulette[24], 0);

    TD_roulette[25] = TextDrawCreate(218.699920, 187.725906, "LD_SPAC:white");
    TextDrawTextSize(TD_roulette[25], 5.000000, 9.000000);
    TextDrawAlignment(TD_roulette[25], 1);
    TextDrawColor(TD_roulette[25], 370546431);
    TextDrawBackgroundColor(TD_roulette[25], 255);
    TextDrawFont(TD_roulette[25], 4);
    TextDrawSetProportional(TD_roulette[25], 0);

    TD_roulette[26] = TextDrawCreate(209.066909, 205.607055, "");
    TextDrawTextSize(TD_roulette[26], 25.000000, -33.000000);
    TextDrawAlignment(TD_roulette[26], 1);
    TextDrawColor(TD_roulette[26], -1263225601);
    TextDrawBackgroundColor(TD_roulette[26], 0);
    TextDrawFont(TD_roulette[26], 5);
    TextDrawSetProportional(TD_roulette[26], 0);
    TextDrawSetPreviewModel(TD_roulette[26], 19177);
    TextDrawSetPreviewRot(TD_roulette[26], 0.000000, 0.000000, 0.000000, 1.000000);

    return true;
}

stock DonateRoulette:CreatePlayerTextDraws(playerid)
{
    PTD_roulette[playerid][0] = CreatePlayerTextDraw(playerid, 226.099365, 204.799911, ""); // 1 СЛОТ
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][0], 36.000000, 44.419998);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][0], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][0], 808464639);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][0], 5);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][0], 0);
    PlayerTextDrawSetPreviewVehCol(playerid, PTD_roulette[playerid][0], 1, 1);

    PTD_roulette[playerid][1] = CreatePlayerTextDraw(playerid, 268.900054, 204.899948, ""); // 2 СЛОТ
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][1], 36.000000, 44.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][1], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][1], -1);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][1], 808464639);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][1], 5);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][1], 0);
    PlayerTextDrawSetPreviewVehCol(playerid, PTD_roulette[playerid][1], 1, 1);

    PTD_roulette[playerid][2] = CreatePlayerTextDraw(playerid, 311.400360, 204.899948, ""); // 3 СЛОТ
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][2], 36.000000, 44.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][2], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][2], -1);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][2], 808464639);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][2], 5);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][2], 0);
    PlayerTextDrawSetPreviewVehCol(playerid, PTD_roulette[playerid][2], 1, 1);

    PTD_roulette[playerid][3] = CreatePlayerTextDraw(playerid, 354.098663, 204.799911, ""); // 4 СЛОТ
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][3], 36.000000, 44.419998);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][3], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][3], -1);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][3], 808464639);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][3], 5);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][3], 0);
    PlayerTextDrawSetPreviewVehCol(playerid, PTD_roulette[playerid][3], 1, 1);

    PTD_roulette[playerid][4] = CreatePlayerTextDraw(playerid, 396.998443, 204.799911, ""); // 5 СЛОТ
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][4], 36.000000, 44.419998);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][4], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][4], -1);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][4], 808464639);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][4], 5);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][4], 0);
    PlayerTextDrawSetPreviewVehCol(playerid, PTD_roulette[playerid][4], 1, 1);

    PTD_roulette[playerid][5] = CreatePlayerTextDraw(playerid, 329.299896, 181.500640, "BRONZE_~W~ROULETTE"); //(Бронза: -186861825 | Сильвер: -1381191937 | Голд: -172014593)
    PlayerTextDrawLetterSize(playerid, PTD_roulette[playerid][5], 0.181997, 1.185184);
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][5], 0.000000, 276.309906);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][5], 2);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][5], -186861825);
    PlayerTextDrawSetShadow(playerid, PTD_roulette[playerid][5], 0);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][5], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][5], 2);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][5], 1);

    PTD_roulette[playerid][6] = CreatePlayerTextDraw(playerid, 199.900054, 156.000000, "LD_SPAC:white"); // Бронза (неактив: 842150655 | актив: 1665872127) 
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][6], 49.509983, 15.459993);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][6], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][6], 1665872127);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][6], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][6], 4);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][6], 0);
    PlayerTextDrawSetSelectable(playerid, PTD_roulette[playerid][6], true);

    PTD_roulette[playerid][7] = CreatePlayerTextDraw(playerid, 191.200195, 152.299957, "ld_beat:chit");
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][7], 19.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][7], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][7], 1665872127);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][7], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][7], 4);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][7], 0);

    PTD_roulette[playerid][8] = CreatePlayerTextDraw(playerid, 241.199707, 152.299957, "ld_beat:chit"); //
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][8], 19.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][8], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][8], 1665872127);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][8], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][8], 4);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][8], 0);

    PTD_roulette[playerid][9] = CreatePlayerTextDraw(playerid, 302.100128, 156.199996, "LD_SPAC:white"); // Сильвер (неактив: 842150655 | актив: 1179010815)
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][9], 49.809978, 15.359992);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][9], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][9], 842150655);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][9], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][9], 4);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][9], 0);
    PlayerTextDrawSetSelectable(playerid, PTD_roulette[playerid][9], true);

    PTD_roulette[playerid][10] = CreatePlayerTextDraw(playerid, 292.200195, 152.399963, "ld_beat:chit");
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][10], 19.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][10], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][10], 842150655);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][10], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][10], 4);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][10], 0);

    PTD_roulette[playerid][11] = CreatePlayerTextDraw(playerid, 342.200195, 152.399963, "ld_beat:chit"); //
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][11], 19.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][11], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][11], 842150655);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][11], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][11], 4);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][11], 0);

    PTD_roulette[playerid][12] = CreatePlayerTextDraw(playerid, 406.900054, 156.000000, "LD_SPAC:white"); // Голд (неактив: 842150655 | актив: -2057166593)
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][12], 49.509983, 15.459993);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][12], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][12], 842150655);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][12], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][12], 4);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][12], 0);
    PlayerTextDrawSetSelectable(playerid, PTD_roulette[playerid][12], true);

    PTD_roulette[playerid][13] = CreatePlayerTextDraw(playerid, 398.200195, 152.299957, "ld_beat:chit");
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][13], 19.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][13], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][13], 842150655);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][13], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][13], 4);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][13], 0);

    PTD_roulette[playerid][14] = CreatePlayerTextDraw(playerid, 448.199707, 152.299957, "ld_beat:chit"); // 
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][14], 19.000000, 23.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][14], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][14], 842150655);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][14], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][14], 4);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][14], 0);

    PTD_roulette[playerid][15] = CreatePlayerTextDraw(playerid, 225.699798, 158.300582, "BRONZE"); // (неактив: 1515870975 | актив: -186861825)
    PlayerTextDrawLetterSize(playerid, PTD_roulette[playerid][15], 0.175666, 1.143700);
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][15], 0.000000, 59.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][15], 2);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][15], -186861825);
    PlayerTextDrawSetShadow(playerid, PTD_roulette[playerid][15], 0);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][15], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][15], 2);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][15], 1);

    PTD_roulette[playerid][16] = CreatePlayerTextDraw(playerid, 326.699798, 158.300582, "SILVER"); // (неактив: 1515870975 | актив: -1381191937)
    PlayerTextDrawLetterSize(playerid, PTD_roulette[playerid][16], 0.175666, 1.143700);
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][16], 0.000000, 60.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][16], 2);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][16], 1515870975);
    PlayerTextDrawSetShadow(playerid, PTD_roulette[playerid][16], 0);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][16], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][16], 2);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][16], 1);

    PTD_roulette[playerid][17] = CreatePlayerTextDraw(playerid, 432.499786, 158.300582, "GOLD"); // (неактив: 1515870975 | актив: -172014593)
    PlayerTextDrawLetterSize(playerid, PTD_roulette[playerid][17], 0.175666, 1.143700);
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][17], 0.000000, 60.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][17], 2);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][17], 1515870975);
    PlayerTextDrawSetShadow(playerid, PTD_roulette[playerid][17], 0);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][17], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][17], 2);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][17], 1);

    PTD_roulette[playerid][18] = CreatePlayerTextDraw(playerid, 226.364898, 182.788146, "_"); // Количество доступных прокрутов
    PlayerTextDrawLetterSize(playerid, PTD_roulette[playerid][18], 0.207995, 1.048292);
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][18], 2000.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][18], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][18], -1);
    PlayerTextDrawSetShadow(playerid, PTD_roulette[playerid][18], 0);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][18], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][18], 1);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][18], 1);

    PTD_roulette[playerid][19] = CreatePlayerTextDraw(playerid, 329.666961, 260.618530, "_"); // Название предмета
    PlayerTextDrawLetterSize(playerid, PTD_roulette[playerid][19], 0.150000, 0.994371);
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][19], 0.000000, 274.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][19], 2);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][19], -1061109505);
    PlayerTextDrawSetShadow(playerid, PTD_roulette[playerid][19], 0);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][19], 255);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][19], 2);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][19], 1);

    PTD_roulette[playerid][19] = CreatePlayerTextDraw(playerid, 298.366607, 250.033828, "");
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][19], 62.000000, -90.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][19], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][19], -1738494977);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][19], 0);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][19], 5);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][19], 0);
    PlayerTextDrawSetPreviewModel(playerid, PTD_roulette[playerid][19], 19177);
    PlayerTextDrawSetPreviewRot(playerid, PTD_roulette[playerid][19], 5.000000, 0.000000, 0.000000, 0.500000);

    PTD_roulette[playerid][20] = CreatePlayerTextDraw(playerid, 298.366607, 246.733627, "");
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][20], 62.000000, -90.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][20], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][20], 370546431);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][20], 0);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][20], 5);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][20], 0);
    PlayerTextDrawSetPreviewModel(playerid, PTD_roulette[playerid][20], 19177);
    PlayerTextDrawSetPreviewRot(playerid, PTD_roulette[playerid][20], 5.000000, 0.000000, 0.000000, 0.500000);

    PTD_roulette[playerid][21] = CreatePlayerTextDraw(playerid, 298.366607, 203.433853, "");
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][21], 62.000000, 90.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][21], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][21], -1738494977);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][21], 0);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][21], 5);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][21], 0);
    PlayerTextDrawSetPreviewModel(playerid, PTD_roulette[playerid][21], 19177);
    PlayerTextDrawSetPreviewRot(playerid, PTD_roulette[playerid][21], 5.000000, 0.000000, 0.000000, 0.500000);

    PTD_roulette[playerid][22] = CreatePlayerTextDraw(playerid, 298.366607, 206.733581, "");
    PlayerTextDrawTextSize(playerid, PTD_roulette[playerid][22], 62.000000, 90.000000);
    PlayerTextDrawAlignment(playerid, PTD_roulette[playerid][22], 1);
    PlayerTextDrawColor(playerid, PTD_roulette[playerid][22], 370546431);
    PlayerTextDrawBackgroundColor(playerid, PTD_roulette[playerid][22], 0);
    PlayerTextDrawFont(playerid, PTD_roulette[playerid][22], 5);
    PlayerTextDrawSetProportional(playerid, PTD_roulette[playerid][22], 0);
    PlayerTextDrawSetPreviewModel(playerid, PTD_roulette[playerid][22], 19177);
    PlayerTextDrawSetPreviewRot(playerid, PTD_roulette[playerid][22], 5.000000, 0.000000, 0.000000, 0.500000);

    return true;
}

stock DonateRoulette:DestroyPlayerTextDraws(playerid)
{
    for(new idx; idx != MAX_PLAYER_PTD_ROULETTE; idx++)
    {
        PlayerTextDrawDestroy(playerid, PTD_roulette[playerid][idx]);
        PTD_roulette[playerid][idx] = PlayerText:INVALID_TEXT_DRAW;
    }

    return true;
}

stock DonateRoulette:IsRangeTextDraw(Text:clickedid)
    return (clickedid == TD_roulette[13] || clickedid == TD_roulette[16] || clickedid == TD_roulette[21]);

stock DonateRoulette:IsRangePlayerTextDraw(playerid, PlayerText:playertextid)
    return (playertextid == PTD_roulette[playerid][6] || playertextid == PTD_roulette[playerid][9] || playertextid == PTD_roulette[playerid][12]);

stock DonateRoulette:OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(GetPVarInt(playerid, PVAR_STATE_ROULETTE))
        return Hud:ShowNotification(playerid, ERROR, "сейчас невозможно выполнить данное действие");

    if(clickedid == TD_roulette[13]) // START
        return DonateRoulette:StartScrollingRoulette(playerid);

    if(clickedid == TD_roulette[16]) // INV
    {
        DonateRoulette:HidePlayerInterface(playerid);
        callcmd::inv(playerid);

        return true;
    }
    
    if(clickedid == TD_roulette[21]) // INFO
    {
        new type_roulette = GetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE);

        switch(type_roulette)
        {
            case ROULETTE_TYPE_BRONZE:
            {
                Dialog_Open(
                    playerid, Dialog:D_INFORMATION_ROULETTE, DIALOG_STYLE_MSGBOX,
                    "{"#DC_MAIN"}Информация о рулетке",
                    "Тут\n\
                    Информация\n\
                    о\n\
                    BRONZE\n\
                    рулетке",
                    "Назад", "Закрыть"
                );
            }

            case ROULETTE_TYPE_SILVER:
            {
                Dialog_Open(
                    playerid, Dialog:D_INFORMATION_ROULETTE, DIALOG_STYLE_MSGBOX,
                    "{"#DC_MAIN"}Информация о рулетке",
                    "Тут\n\
                    Информация\n\
                    о\n\
                    SILVER\n\
                    рулетке",
                    "Назад", "Закрыть"
                );
            }

            case ROULETTE_TYPE_GOLD:
            {
                Dialog_Open(
                    playerid, Dialog:D_INFORMATION_ROULETTE, DIALOG_STYLE_MSGBOX,
                    "{"#DC_MAIN"}Информация о рулетке",
                    "Тут\n\
                    Информация\n\
                    о\n\
                    GOLD\n\
                    рулетке",
                    "Назад", "Закрыть"
                );
            }
        }

        DonateRoulette:HidePlayerInterface(playerid);

        return true;
    }

    return true;
}

stock DonateRoulette:OnClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(GetPVarInt(playerid, PVAR_STATE_ROULETTE))
        return Hud:ShowNotification(playerid, ERROR, "сейчас невозможно выполнить данное действие");

    new type_roulette = GetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE);
    new new_type_roulette;

    if(playertextid == PTD_roulette[playerid][6]) new_type_roulette = ROULETTE_TYPE_BRONZE;
    else if(playertextid == PTD_roulette[playerid][9]) new_type_roulette = ROULETTE_TYPE_SILVER;
    else new_type_roulette = ROULETTE_TYPE_GOLD;

    if(type_roulette == new_type_roulette)
        return true;

    SetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE, new_type_roulette);

    DeletePVar(playerid, PVAR_SELECT_SLOT_ROULETTE);
    DeletePVar(playerid, PVAR_ROULETTE_COUNT_SCROLL);

    DonateRoulette:HidePlayerInterface(playerid, true);

    return true;
}

stock DonateRoulette:StartScrollingRoulette(playerid)
{
    new type_roulette = GetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE);
    new item_id = g_roulette[type_roulette][R_ITEM_ID];
    new slot_index = Inventory:GetItemSlotPlayerData(playerid, item_id);

    if(slot_index == -1)
    {
        format(totalstring, sizeof totalstring, "у Вас нет %s {"#DC_GREY"}рулетки", g_roulette[type_roulette][R_NAME]);
        return Hud:ShowNotification(playerid, ERROR, totalstring);
    }

    Inventory:SetCountItemPlayerData(playerid, slot_index, -1);

    SetPVarInt(playerid, PVAR_STATE_ROULETTE, 1);

    DonateRoulette:UpdatePlayerCountSpin(playerid);

    SetPVarInt(playerid, PVAR_SELECT_SLOT_ROULETTE, 0);

    for(new idx; idx != MAX_ROULETTE_SLOTS_TD; idx++)
        DonateRoulette:ScrollRoulette(playerid, idx, idx);

    DonateRoulette:Scroll(playerid);

    return true;
}

stock DonateRoulette:ScrollRoulette(playerid, index, index_slot)
{
    new type_roulette = GetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE);
    new prize_id = g_player_roulette_prize_id[playerid][type_roulette][index];

    PlayerTextDrawSetPreviewModel(
        playerid, 
        PTD_roulette[playerid][index_slot], 
        g_roulette_prize[type_roulette][prize_id][PRIZE_MODELID]
    );

    PlayerTextDrawSetPreviewRot(
        playerid, 
        PTD_roulette[playerid][index_slot], 
        g_roulette_prize[type_roulette][prize_id][PRIZE_ROT_X],
        g_roulette_prize[type_roulette][prize_id][PRIZE_ROT_Y],
        g_roulette_prize[type_roulette][prize_id][PRIZE_ROT_Z],
        g_roulette_prize[type_roulette][prize_id][PRIZE_ROT_SCALE]
    );

    PlayerTextDrawSetPreviewVehCol(playerid, PTD_roulette[playerid][index_slot], 1, 1);

    DonateRoulette:UpdatePlayerTextDraw(playerid, PTD_roulette[playerid][index_slot]);

    return true;
}

stock DonateRoulette:IsItem(item_id)
{
    switch(item_id)
    {
        case ITEM_ROULETTE_GOLD, ITEM_ROULETTE_BRONZE, ITEM_ROULETTE_SILVER,        \
            ITEM_VIP_SILVER_3, ITEM_VIP_SILVER_5, ITEM_VIP_SILVER_7,                \
            ITEM_VIP_PALLADIUM_3, ITEM_VIP_PALLADIUM_5, ITEM_VIP_PALLADIUM_7,       \
            ITEM_VIP_GOLD_3, ITEM_VIP_GOLD_5, ITEM_VIP_GOLD_7,                      \
            ITEM_KIT_SIM,                                                           \
            ITEM_VEH_FBI, ITEM_VEH_BULLET, ITEM_VEH_HOTRING, ITEM_VEH_DUNE,         \
            ITEM_VEH_ELEGY, ITEM_VEH_HUNTLEY, ITEM_VEH_HUSTLER, ITEM_VEH_STRATUM,    \
            ITEM_VEH_SULTAN, ITEM_VEH_JESTER, ITEM_VEH_TAHOMA, ITEM_VEH_CLOVER,     \
            ITEM_VEH_FAGGIO, ITEM_VEH_BMX: return true;

        default:
            return false;
    }

    return false;
}

forward DonateRoulette:Scroll(playerid);
public DonateRoulette:Scroll(playerid)
{
    new type_roulette = GetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE);
    new count_scrolls = GetPVarInt(playerid, PVAR_ROULETTE_COUNT_SCROLL) + 1;
    new index = GetPVarInt(playerid, PVAR_SELECT_SLOT_ROULETTE);

    SetPVarInt(playerid, PVAR_ROULETTE_COUNT_SCROLL, count_scrolls);

    if(count_scrolls >= TOTAL_SCROLL_GIVE_PRIZE)
    {
        new idx_slot;

        if(index == MAX_ROULETTE_SLOTS - 1) idx_slot = 0;
        else idx_slot = index + 1;

        new chance_give_prize = random_ex(1, 100, 1);
        new prize_id = g_player_roulette_prize_id[playerid][type_roulette][idx_slot];
        new chance_win_prize = g_roulette_prize[type_roulette][prize_id][PRIZE_PROCENT_WIN];

        if(chance_win_prize >= chance_give_prize)
        {
            new item_id = g_roulette_prize[type_roulette][prize_id][PRIZE_ITEM];

            new value_min = g_roulette_prize[type_roulette][prize_id][PRIZE_VALUE_MIN];
            new value_max = g_roulette_prize[type_roulette][prize_id][PRIZE_VALUE_MAX];
            new value_prize;

            switch(item_id)
            {
                case ITEM_VIP_GOLD, ITEM_VIP_PALLADIUM, ITEM_VIP_SILVER:
                    value_prize = random_ex(value_min, value_max, 2);

                default: value_prize = random_ex(value_min, value_max, 1);
            }

            switch(item_id)
            {
                case ITEM_BACKPACK:
                {
                    if(PlayerInfo[playerid][P_IMPROVEDBACKPACK])
                    {
                        format(
                            totalstring, sizeof totalstring, 
                            "[Рулетка] {"#DC_WHITE"}У Вас уже имеется улучшенный рюкзак. Вам была выдана %s {"#DC_WHITE"}рулетка в количестве {"#DC_YELLOW"}1 шт.",
                            g_roulette[type_roulette][R_NAME]
                        );

                        Inventory:GiveItemPlayerData(playerid, g_roulette[type_roulette][R_ITEM_ID], 1);
                        DonateRoulette:UpdatePlayerCountSpin(playerid);
                    }
                    else
                    {
                        format(
                            totalstring, sizeof totalstring, 
                            "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}улучшенный рюкзак", 
                            inventory_items[item_id][ITEM_NAME]
                        );

                        PlayerInfo[playerid][P_BACKPACK]            = 1;
                        PlayerInfo[playerid][P_IMPROVEDBACKPACK]    = 1;
                    }
                }

                case ITEM_VEH_FBI, ITEM_VEH_BULLET, ITEM_VEH_HOTRING, ITEM_VEH_DUNE,        \
                    ITEM_VEH_ELEGY, ITEM_VEH_HUNTLEY, ITEM_VEH_HUSTLER, ITEM_VEH_STRATUM,    \
                    ITEM_VEH_SULTAN, ITEM_VEH_JESTER, ITEM_VEH_TAHOMA, ITEM_VEH_CLOVER,     \
                    ITEM_VEH_FAGGIO, ITEM_VEH_BMX:
                {
                    new index_slot = Inventory:GetItemSlotPlayerData(playerid, item_id);

                    if(index_slot != -1)
                    { 
                        new roulette_give_count = 0;

                        switch(chance_win_prize)
                        {
                            case ROULETTE_CHANCE_HIGH: roulette_give_count = 1;
                            case ROULETTE_CHANCE_MEDIUM: roulette_give_count = 2;
                            case ROULETTE_CHANCE_LOW: roulette_give_count = 3;
                            case ROULETTE_CHANCE_RARE: roulette_give_count = 4;
                            case ROULETTE_CHANCE_LEGENDARY: roulette_give_count = 10;
                        }

                        Inventory:GiveItemPlayerData(playerid, g_roulette[type_roulette][R_ITEM_ID], roulette_give_count);
                        DonateRoulette:UpdatePlayerCountSpin(playerid);

                        format(
                            totalstring, sizeof totalstring, 
                            "[Рулетка] {"#DC_WHITE"}У Вас уже имеется сертификат на данный транспорт. Вам выдана %s {"#DC_WHITE"}рулетка в количестве {"#DC_YELLOW"}%d шт.",
                            g_roulette[type_roulette][R_NAME],
                            roulette_give_count
                        );
                    }
                    else
                    {
                        format(
                            totalstring, sizeof totalstring, 
                            "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}%s", 
                            inventory_items[item_id][ITEM_NAME]
                        );

                        Inventory:GiveItemPlayerData(playerid, item_id, 1);
                    }
                }

                case ITEM_LIC_KIT:
                {
                    new bool:result = false;

                    for(new idx; idx != MAX_SELL_TYPE_LICENSE; idx++)
                    {
                        Players:SetPlayerLicense(playerid, GIVE_LIC, idx);

                        result = true;
                    }

                    format(totalstring, sizeof totalstring, "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}комплект лицензий");

                    if(!result)
                    {
                        SendClientMessage(
                            playerid, COLOR_MAIN, 
                            "[Рулетка] {"#DC_WHITE"}У вас уже есть полный комплект лицензий, поэтому Вам начислено {"#DC_GREEN"}5.000$ {"#DC_WHITE"}в качестве компенсации"
                        );

                        PlayerInfo[playerid][pCash] += 5000;
                    }
                }

                case ITEM_EXP:
                {
                    format(totalstring, sizeof totalstring, "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}%d EXP{"#DC_WHITE"}. Приз был автоматически активирован!", value_prize);
                    GivePlayerExp(playerid, value_prize);
                }

                case ITEM_DONATE:
                {
                    format(totalstring, sizeof totalstring, "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}%d RUB{"#DC_WHITE"}. Приз был зачислен на Ваш счет!", value_prize);
                    PlayerInfo[playerid][pDonateMoney] += value_prize;
                }

                case ITEM_MONEY:
                {
                    format(totalstring, sizeof totalstring, "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}%d ${"#DC_WHITE"}. Средства были зачислены на Ваш счет!", value_prize);
                    PlayerInfo[playerid][pCash] += value_prize;
                }

                case ITEM_LAW:
                {
                    format(totalstring, sizeof totalstring, "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}%d законопослушности{"#DC_WHITE"}. Приз был автоматически активирован!", value_prize);
                    
                    PlayerInfo[playerid][pLaw] += value_prize;

                    if(PlayerInfo[playerid][pLaw] > 100)
                        PlayerInfo[playerid][pLaw] = 100;
                }

                case ITEM_SKILL_GUN:
                {
                    format(totalstring, sizeof totalstring, "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}навыки владения всем оружием");
                    
                    for(new idx; idx != MAX_GUN_SKILLS; idx++)
                        Players:SetWeaponSkillLevel(playerid, idx, 100);
                }

                case ITEM_VIP_GOLD:
                {
                    format(
                        totalstring, sizeof totalstring, 
                        "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_YELLOW"}VIP GOLD {"#DC_WHITE"}на {"#DC_MAIN"}%d д.", 
                        value_prize
                    );
                    
                    switch(value_prize)
                    {
                        case 3: Inventory:GiveItemPlayerData(playerid, ITEM_VIP_GOLD_3, 1);
                        case 5: Inventory:GiveItemPlayerData(playerid, ITEM_VIP_GOLD_5, 1);
                        case 7: Inventory:GiveItemPlayerData(playerid, ITEM_VIP_GOLD_7, 1);
                    }
                }

                case ITEM_VIP_PALLADIUM:
                {
                    format(
                        totalstring, sizeof totalstring, 
                        "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}VIP PALLADIUM {"#DC_WHITE"}на {"#DC_MAIN"}%d д.", 
                        value_prize
                    );
                    
                    switch(value_prize)
                    {
                        case 3: Inventory:GiveItemPlayerData(playerid, ITEM_VIP_PALLADIUM_3, 1);
                        case 5: Inventory:GiveItemPlayerData(playerid, ITEM_VIP_PALLADIUM_5, 1);
                        case 7: Inventory:GiveItemPlayerData(playerid, ITEM_VIP_PALLADIUM_7, 1);
                    }
                }

                case ITEM_VIP_SILVER:
                {
                    format(
                        totalstring, sizeof totalstring, 
                        "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_GRAY"}VIP SILVER {"#DC_WHITE"}на {"#DC_MAIN"}%d д.", 
                        value_prize
                    );
                    
                    switch(value_prize)
                    {
                        case 3: Inventory:GiveItemPlayerData(playerid, ITEM_VIP_SILVER_3, 1);
                        case 5: Inventory:GiveItemPlayerData(playerid, ITEM_VIP_SILVER_5, 1);
                        case 7: Inventory:GiveItemPlayerData(playerid, ITEM_VIP_SILVER_7, 1);
                    }
                }

                default:
                {
                    format(
                        totalstring, sizeof totalstring, 
                        "[Рулетка] {"#DC_WHITE"}Поздравляем, Вы выиграли {"#DC_BEIGE"}%s {"#DC_WHITE"}в количестве {"#DC_MAIN"}%d шт.", 
                        inventory_items[item_id][ITEM_NAME], value_prize
                    );

                    Inventory:GiveItemPlayerData(playerid, item_id, value_prize);
                }
            }
            
            SendClientMessage(playerid, COLOR_MAIN, totalstring);

            totalstring[0] = EOS;

            DeletePVar(playerid, PVAR_ROULETTE_COUNT_SCROLL);
            DeletePVar(playerid, PVAR_STATE_ROULETTE);

            DonateRoulette:ClearPlayerData(playerid);

            return true;
        }
    }

    if(index == MAX_ROULETTE_SLOTS - 1) SetPVarInt(playerid, PVAR_SELECT_SLOT_ROULETTE, 0);
    else SetPVarInt(playerid, PVAR_SELECT_SLOT_ROULETTE, index + 1);

    for(new idx; idx != MAX_ROULETTE_SLOTS_TD; idx++)
    {
        if(index + idx >= MAX_ROULETTE_SLOTS)
        {
            switch(index)
            {
                case 11: DonateRoulette:ScrollRoulette(playerid, idx - 4, idx);                                        
                case 12: DonateRoulette:ScrollRoulette(playerid, idx - 3, idx); 
                case 13: DonateRoulette:ScrollRoulette(playerid, idx - 2, idx); 
                case 14: DonateRoulette:ScrollRoulette(playerid, idx - 1, idx); 
            }
        }
        else DonateRoulette:ScrollRoulette(playerid, index + idx, idx);
    }

    SetTimerEx(DonateRouletteText(DonateRoulette:Scroll), 550, false, "d", playerid);

    return true;
}

DialogResponse:D_ROULETTE_LIST_BUY(playerid, response, listitem, inputtext[])
{
    if(!response)
        return Dialog_Show(playerid, Dialog:dDonate);

    SetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE, listitem);
    Dialog_Show(playerid, Dialog:D_ROULETTE_BUY);

    return true;
}

DialogResponse:D_ROULETTE_BUY(playerid, response, listitem, inputtext[])
{
    if(!response)
        return Dialog_Show(playerid, Dialog:D_ROULETTE_LIST_BUY);

    new type_roulette = GetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE);
    new price_roulette = g_roulette_buy_kit_price[type_roulette][listitem];

    if(PlayerInfo[playerid][pDonateMoney] < price_roulette)
        return Hud:ShowNotification(playerid, ERROR, "у Вас недостаточно средств для покупки");

    PlayerInfo[playerid][pDonateMoney] -= price_roulette;

    new count_roulette = 0;

    switch(listitem)
    {
        case ROULETTE_KIT_ONE: count_roulette = 1;
        case ROULETTE_KIT_THREE: count_roulette = 3;
        case ROULETTE_KIT_FIVE: count_roulette = 5;
        case ROULETTE_KIT_TEN: count_roulette = 10;
    }

    Inventory:GiveItemPlayerData(playerid, g_roulette[type_roulette][R_ITEM_ID], count_roulette);

    format(
        totalstring, sizeof totalstring, 
        "Вы успешно купили %s {"#DC_WHITE"}в количестве {"#DC_YELLOW"}%d шт.", 
        g_roulette[type_roulette][R_NAME],
        count_roulette
    );
    Hud:ShowNotification(playerid, SUCCESS, totalstring, 10000);

    format(
        totalstring, sizeof totalstring, 
        "UPDATE `accounts` SET `donate` = '%s' WHERE `id` = '%d'", 
        PlayerInfo[playerid][pDonateMoney],
        GetPlayerAccountID(playerid)
    );
    mysql_tquery(mysql, totalstring, "", "");

    totalstring[0] = EOS;

    return true;
}

DialogResponse:D_INFORMATION_ROULETTE(playerid, response, listitem, inputtext[])
{
    if(!response)
        return CancelSelectTextDraw(playerid);    

    callcmd::roulette(playerid);

    return true;
}

DialogCreate:D_ROULETTE_LIST_BUY(playerid)
{
    format(bigstring, sizeof bigstring, "{"#DC_WHITE"}Название\t{"#DC_WHITE"}Цена\n");

    for(new idx; idx != MAX_ROULETTE_TYPES; idx++)
    {
        format(
            totalstring, sizeof totalstring, 
            "{"#DC_MAIN"}- {"#DC_WHITE"}Рулетка %s\t{"#DC_GREEN"}от %d RUB\n",
            g_roulette[idx][R_NAME],
            g_roulette[idx][R_PRICE]
        );
        strcat(bigstring, totalstring);
    }

    Dialog_Open(
        playerid, Dialog:D_ROULETTE_LIST_BUY, DIALOG_STYLE_TABLIST_HEADERS,
        "{"#DC_MAIN"}Покупка рулетки",
        bigstring,
        "Далее", "Назад"
    );

    totalstring[0] = EOS;
    bigstring[0] = EOS;

    return true;
}

DialogCreate:D_ROULETTE_BUY(playerid)
{
    new type_roulette = GetPVarInt(playerid, PVAR_SELECT_TYPE_ROULETTE);

    format(
        bigstring, sizeof bigstring, 
        "{"#DC_WHITE"}Название\t{"#DC_WHITE"}Цена\n\
        {"#DC_MAIN"}- {"#DC_WHITE"}Один прокрут рулетки\t{"#DC_GREEN"}%d RUB\n\
        {"#DC_MAIN"}- {"#DC_WHITE"}Три прокрута рулетки\t{"#DC_GREEN"}%d RUB\n\
        {"#DC_MAIN"}- {"#DC_WHITE"}Пять прокрутов рулетки\t{"#DC_GREEN"}%d RUB\n\
        {"#DC_MAIN"}- {"#DC_WHITE"}Десять прокрутов рулетки\t{"#DC_GREEN"}%d RUB",
        g_roulette_buy_kit_price[type_roulette][ROULETTE_KIT_ONE],
        g_roulette_buy_kit_price[type_roulette][ROULETTE_KIT_THREE],
        g_roulette_buy_kit_price[type_roulette][ROULETTE_KIT_FIVE],
        g_roulette_buy_kit_price[type_roulette][ROULETTE_KIT_TEN]
    );
    
    format(str_small, sizeof str_small, "{"#DC_MAIN"}Покупка рулетки %s", g_roulette[type_roulette][R_NAME]);

    Dialog_Open(
        playerid, Dialog:D_ROULETTE_BUY, DIALOG_STYLE_TABLIST_HEADERS,
        str_small, bigstring,
        "Далее", "Назад"
    );

    bigstring[0] = EOS;
    str_small[0] = EOS;

    return true;
}

DialogCreate:D_INFORMATION_ROULETTE(playerid)
    return true;


cmd:roulette(playerid)
{
    DonateRoulette:ShowPlayerInterface(playerid);
    return CMD_RESULT_SUCCESS;
}