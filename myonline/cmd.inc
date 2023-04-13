CMD:myonline(playerid) {
    bigstring[0] = EOS;

    new m_online_time_str[MAX_MY_ONLINE_PARAGRAPHS][32];

    for(new index; index < MAX_MY_ONLINE_PARAGRAPHS; index++) {
        MyOnline:TimeConvert(m_online_time_str[index], 32, my_online_data[playerid][index]);
    }

    format(
        bigstring, 
        512, 
        "{"#DC_WHITE"}Текущее время: {"#DC_MAIN"}%02d:%02d:%02d\n\
        {"#DC_WHITE"}Дата: {"#DC_MAIN"}%02d.%02d.%04d\n\n\
        {"#DC_WHITE"}Время игры за последний час: {"#DC_MAIN"}%s\n\
        {"#DC_WHITE"}Время игре за прошедшие сутки: {"#DC_MAIN"}%s\n\
        {"#DC_WHITE"}Время игры за вчерашний день: {"#DC_MAIN"}%s\n\
        {"#DC_WHITE"}Время в игре за неделю: {"#DC_MAIN"}%s\n\
        {"#DC_WHITE"}Время в игре за месяц: {"#DC_MAIN"}%s\n\n\
        {"#DC_WHITE"}Наиграно суммарно за все время: {"#DC_MAIN"}%s", 
        s_up_hour, s_up_minute, s_up_second,
        current_day, current_month, current_year,
        m_online_time_str[MY_ONLINE_FOR_LAST_HOUR],
        m_online_time_str[MY_ONLINE_FOR_LAST_DAY],
        m_online_time_str[MY_ONLINE_FOR_YESTERDAY],
        m_online_time_str[MY_ONLINE_FOR_WEEK],
        m_online_time_str[MY_ONLINE_FOR_MONTH],
        m_online_time_str[MY_ONLINE_FOR_ALL_TIME]
    );
    Dialog_Open(playerid, Dialog:D_NULL, DSM, "Статистика онлайна", bigstring, !"Закрыть", !"");
    bigstring[0] = EOS;
    return 1;
}

CMD:test_myon(playerid) {
    my_online_data[playerid][MY_ONLINE_FOR_ALL_TIME] = UNIX_HOUR * 12;
    my_online_data[playerid][MY_ONLINE_FOR_LAST_DAY] = UNIX_MINUTE * 32;
    my_online_data[playerid][MY_ONLINE_FOR_LAST_HOUR] = UNIX_MINUTE * 5;
    my_online_data[playerid][MY_ONLINE_FOR_MONTH] = 15;
    return 1;
}