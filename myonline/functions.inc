MyOnline:OnPlayerResetStats(playerid) {
    for(new index; index < MAX_MY_ONLINE_PARAGRAPHS; index++) {
        my_online_data[playerid][index] = 0;
    }
    return 1;
}
MyOnline:LoadPlayerData(playerid) {
    totalstring[0] = EOS;
    cache_get_value_name(0, "my_online_data", totalstring);
    sscanf(totalstring, "p<,>a<i>[6]", my_online_data[playerid]);
    totalstring[0] = EOS;

    new 
        bool: m_online_reset_data[3],
        bool: m_online_update_last_day;

    cache_get_value_name_bool(0, "m_online_reset_hour", m_online_reset_data[0]);
    cache_get_value_name_bool(0, "m_online_reset_week", m_online_reset_data[1]);
    cache_get_value_name_bool(0, "m_online_reset_month", m_online_reset_data[2]);
    cache_get_value_name_bool(0, "m_online_update_last_day", m_online_update_last_day);

    if m_online_reset_data[0] == true *then {
        my_online_data[playerid][MY_ONLINE_FOR_LAST_HOUR] = 0;
    }
    if m_online_reset_data[1] == true *then {
        my_online_data[playerid][MY_ONLINE_FOR_WEEK] = 0;
    }
    if m_online_reset_data[2] == true *then {
        my_online_data[playerid][MY_ONLINE_FOR_MONTH] = 0;
    }
    if m_online_update_last_day == true *then {
        my_online_data[playerid][MY_ONLINE_FOR_YESTERDAY] = my_online_data[playerid][MY_ONLINE_FOR_LAST_DAY];
        my_online_data[playerid][MY_ONLINE_FOR_LAST_DAY] = 0;
    }
    return 1;
}
MyOnline:SavePlayerData(playerid) {
    mysql_format(
        mysql, 
        totalstring, 
        256, 
        "update `accounts` set `my_online_data` = '%d,%d,%d,%d,%d,%d' where `id` = '%d'",
        my_online_data[playerid][MY_ONLINE_FOR_LAST_HOUR],
        my_online_data[playerid][MY_ONLINE_FOR_LAST_DAY],
        my_online_data[playerid][MY_ONLINE_FOR_YESTERDAY],
        my_online_data[playerid][MY_ONLINE_FOR_WEEK],
        my_online_data[playerid][MY_ONLINE_FOR_MONTH],
        my_online_data[playerid][MY_ONLINE_FOR_ALL_TIME],
        GetPlayerAccountID(playerid)
    );
    mysql_tquery(mysql, totalstring);
    totalstring[0] = EOS;
    return 1;
}
MyOnline:UpdatePlayerData(playerid, type) {
    switch(type) {
        case MY_ONLINE_TYPE_UPDATE_ALL_TIME: {
            if !GetPVarInt(playerid, !"AFK_Time") *then {
                for(new index; index < MAX_MY_ONLINE_PARAGRAPHS; index++) {
                    my_online_data[playerid][index]++;
                }
            }
            return 1;
        }
        case MY_ONLINE_TYPE_RESET_LAST_HOUR: {
            my_online_data[playerid][MY_ONLINE_FOR_LAST_HOUR] = 0;
        }
        case MY_ONLINE_TYPE_RESET_WEEK, MY_ONLINE_TYPE_RESET_MONTH, MY_ONLINE_TYPE_UPDATE_LAST_DAY: {
            foreach(new index: Player) {
                if !IsPlayerLogged(index) *then continue;
                
                if type == MY_ONLINE_TYPE_RESET_MONTH *then my_online_data[index][MY_ONLINE_FOR_MONTH] = 0;
                if type == MY_ONLINE_TYPE_RESET_WEEK *then my_online_data[index][MY_ONLINE_FOR_WEEK] = 0;
                if type == MY_ONLINE_TYPE_UPDATE_LAST_DAY *then {
                    my_online_data[index][MY_ONLINE_FOR_YESTERDAY] = my_online_data[index][MY_ONLINE_FOR_LAST_DAY];
                    my_online_data[index][MY_ONLINE_FOR_LAST_DAY] = 0;
                }
            }
            if type == MY_ONLINE_TYPE_RESET_MONTH *then {
                mysql_tquery(mysql, "update `accounts` set `m_online_reset_month` = '1' where `online` = '0'");
            }
            if type == MY_ONLINE_TYPE_RESET_WEEK *then {
                mysql_tquery(mysql, "update `accounts` set `m_online_reset_week` = '1' where `online` = '0'");
            }
            if type == MY_ONLINE_TYPE_RESET_LAST_HOUR *then {
                mysql_tquery(mysql, "update `accounts` set `m_online_reset_hour` = '1' where `online` = '0'");
            }
            if type == MY_ONLINE_TYPE_UPDATE_LAST_DAY *then {
                mysql_tquery(mysql, "update `accounts` set `m_online_update_last_day` = '1' where `online` = '0'");
            }
        }
    }
    return 1;
}
MyOnline:TimeConvert(array[], array_size, seconds_count) {
    if array_size < 14 *then return 0;

    new total_seconds = seconds_count;
    
    new convert_hours = total_seconds / UNIX_HOUR /* seconds in a hour */;
    total_seconds %= UNIX_HOUR;
 
    new convert_minutes = total_seconds / UNIX_MINUTE /* seconds in a minute */;
    total_seconds %= UNIX_MINUTE;

    if convert_hours >= 10 *then {
        format(array, array_size, "%d ч.", convert_hours);
    }
    else if convert_hours >= 1 *then {
        format(array, array_size, "%d ч. %d мин.", convert_hours, convert_minutes);
    }
    else if convert_hours < 1 && convert_minutes > 1 *then {
        format(array, array_size, "%d мин. %d сек.", convert_minutes, total_seconds);
    }
    else format(array, array_size, "%d сек.", total_seconds);
    return 1;
}