#define DonateRoulette:%0(                      ROLL_%0(
#define DonateRouletteText(DonateRoulette:%0)   #ROLL_%0

#define PVAR_SELECT_TYPE_ROULETTE               "PVAR_SELECT_TYPE_ROULETTE"
#define PVAR_SHOW_ROULETTE_INTERFACE            "PVAR_SHOW_ROULETTE_INTERFACE"
#define PVAR_STATE_ROULETTE                     "PVAR_STATE_ROULETTE"
#define PVAR_SELECT_SLOT_ROULETTE               "PVAR_SELECT_SLOT_ROULETTE"
#define PVAR_ROULETTE_COUNT_SCROLL              "PVAR_ROULETTE_COUNT_SCROLL"

#define MAX_KIT_ROULETTE                        4

#define MAX_ROULETTE_SLOTS                      15
#define MAX_ROULETTE_SLOTS_TD                   5

#define MAX_ROULETTE_PRIZE                      28

#define MAX_ROULETTE_PRIZE_BRONZE               25
#define MAX_ROULETTE_PRIZE_SILVER               26
#define MAX_ROULETTE_PRIZE_GOLD                 28

#define ROULETTE_CHANCE_HIGH                    50
#define ROULETTE_CHANCE_MEDIUM                  25
#define ROULETTE_CHANCE_LOW                     10
#define ROULETTE_CHANCE_RARE                    5
#define ROULETTE_CHANCE_LEGENDARY               1                 

#define MAX_GLOBAL_TD_ROULETTE                  27
#define MAX_PLAYER_PTD_ROULETTE                 23

#define TOTAL_SCROLL_GIVE_PRIZE                 8

#define COLOR_ROULETTE_BRONZE_TEXT              -186861825
#define COLOR_ROULETTE_SILVER_TEXT              -1381191937
#define COLOR_ROULETTE_GOLD_TEXT                -172014593

#define COLOR_ROULETTE_SELECT_NONE              842150655
#define COLOR_ROULETTE_SELECT_BRONZE            1665872127
#define COLOR_ROULETTE_SELECT_SILVER            1179010815
#define COLOR_ROULETTE_SELECT_GOLD              -2057166593

#define COLOR_ROULETTE_SELECT_TEXT_NONE         1515870975
#define COLOR_ROULETTE_SELECT_TEXT_BRONZE       -186861825
#define COLOR_ROULETTE_SELECT_TEXT_SILVER       -1381191937
#define COLOR_ROULETTE_SELECT_TEXT_GOLD         -172014593

enum E_ROULETTE_STRUCT {
    R_TYPE,
    R_PRICE,
    R_NAME[64],
    R_ITEM_ID
};

enum {
    ROULETTE_TYPE_BRONZE,
    ROULETTE_TYPE_SILVER,
    ROULETTE_TYPE_GOLD,
    MAX_ROULETTE_TYPES
};

new g_roulette[MAX_ROULETTE_TYPES][E_ROULETTE_STRUCT] = {
    {ROULETTE_TYPE_BRONZE, 39, "{"#DC_BEIGE"}«Bronze»", ITEM_ROULETTE_BRONZE},
    {ROULETTE_TYPE_SILVER, 69, "{"#DC_GRAY"}«Silver»", ITEM_ROULETTE_SILVER},
    {ROULETTE_TYPE_GOLD, 99, "{"#DC_YELLOW"}«Gold»", ITEM_ROULETTE_GOLD}
};

enum {
    ROULETTE_KIT_ONE,
    ROULETTE_KIT_THREE,
    ROULETTE_KIT_FIVE,
    ROULETTE_KIT_TEN,
    MAX_ROULETTE_KITS
};

new g_roulette_buy_kit_price[MAX_ROULETTE_TYPES][MAX_ROULETTE_KITS] = {
    {   // -- Bronze рулетка
        39,         // 1 прокрутка
        99,         // 3 прокрутки
        169,        // 5 прокруток
        329         // 10 прокруток
    },

    {   // -- Silver рулетка
        69,         // 1 прокрутка
        179,        // 3 прокрутки
        299,        // 5 прокруток
        579         // 10 прокруток
    },

    {   // -- Gold рулетка
        99,         // 1 прокрутка
        269,        // 3 прокрутки
        429,        // 5 прокруток
        849         // 10 прокруток
    }
};

enum E_ROULETTE_PRIZE_STRUCT {
    PRIZE_MODELID,
    PRIZE_ITEM,
    PRIZE_VALUE_MIN,
    PRIZE_VALUE_MAX,
    PRIZE_PROCENT_WIN,
    Float:PRIZE_ROT_X,
    Float:PRIZE_ROT_Y,
    Float:PRIZE_ROT_Z,
    Float:PRIZE_ROT_SCALE
};
new g_roulette_prize[MAX_ROULETTE_TYPES][MAX_ROULETTE_PRIZE][E_ROULETTE_PRIZE_STRUCT] = {
    /* 
        {
            Модель предмета, 
            ID предмета в инвентаре,
            Минимальное количество, которе может выпасть,
            Максимальное количество, которе может выпасть,
            Процент выпадания данного приза в рулетке из 100%,
            x, y, z, scale
        } 
    */
    {   // -- Список призов для "Bronze" рулетки
        /* 1 */{1239, ITEM_EXP, 1, 3, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.5},                       // Опыт
        /* 2 */{1274, ITEM_DONATE, 5, 100, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.5},                  // Донат
        /* 3 */{1550, ITEM_MONEY, 1000, 15000, ROULETTE_CHANCE_HIGH, -30.0, 5.0, 0.0, 1.1},            // Деньги
        /* 4 */{5, ITEM_SKIN_5, 1, 1, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 7.0, 1.0},                       // Скин ID:5
        /* 5 */{1, ITEM_SKIN_1, 1, 1, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 7.0, 1.0},                       // Скин ID:1
        /* 6 */{2044, ITEM_SKILL_GUN, 1, 1, ROULETTE_CHANCE_HIGH, -90.0, 0.0, 180.0, 1.0},             // Навыки владения оружием
        /* 7 */{1247, ITEM_LAW, 1, 5, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.3},                       // Законопослушность
        /* 8 */{1247, ITEM_LAW, 3, 10, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.3},                      // Законопослушность
        /* 9 */{481, ITEM_VEH_BMX, 1, 1, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 40.0, 1.0},                    // BMX

        /* 10 */{23, ITEM_SKIN_23, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 7.0, 1.0},                   // Скин ID:23
        /* 11 */{462, ITEM_VEH_FAGGIO, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 40.0, 1.0},              // Faggio
        /* 12 */{1581, ITEM_LIC_KIT, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 180.0, 1.2},               // Комплект лицензий
        /* 13 */{19035, ITEM_GLASS_GROZA, 1, 1, ROULETTE_CHANCE_MEDIUM, -10.0, 0.0, 90.0, 0.8},         // Очки "Гроза"

        /* 14 */{19078, ITEM_ACS_PARROT, 1, -91, ROULETTE_CHANCE_LOW, 0.0, -90.0, 0.0, 1.0},            // Аксессуар "Попугай на плечо"
        /* 15 */{566, ITEM_VEH_TAHOMA, 1, 1, ROULETTE_CHANCE_LOW, 0.0, 0.0, 40.0, 1.0},                 // Tahoma
        /* 16 */{954, ITEM_VIP_SILVER, 3, 7, ROULETTE_CHANCE_LOW, 0.0, 0.0, 0.0, 1.2},                  // VIP Silver
        /* 17 */{18638, ITEM_ACS_BUILD_HELMET, 1, 1, ROULETTE_CHANCE_LOW, 90.0, 180.0, 90.0, 1.0},      // Аксессуар "Строительная каска"

        /* 18 */{542, ITEM_VEH_CLOVER, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 40.0, 1.0},                // Clover
        /* 19 */{371, ITEM_BACKPACK, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 0.0, 1.3},                   // Улучшенный рюкзак
        /* 20 */{21, ITEM_SKIN_21, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 7.0, 1.0},                     // Скин ID:21
        /* 21 */{559, ITEM_VEH_JESTER, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 40.0, 1.0},                // Jester
        /* 22 */{19878, ITEM_ACS_SKATE_BOARD, 1, 1, ROULETTE_CHANCE_RARE, -20.0, 0.0, 0.0, 1.0},        // Аксессуар "Скейтборд"
        /* 23 */{954, ITEM_VIP_PALLADIUM, 3, 7, ROULETTE_CHANCE_RARE, 0.0, 0.0, 0.0, 1.2},              // VIP Palladium

        /* 24 */{560, ITEM_VEH_SULTAN, 1, 1, ROULETTE_CHANCE_LEGENDARY, 0.0, 0.0, 40.0, 1.0},           // Sultan
        /* 25 */{2404, ITEM_ACS_SERF_BOARD, 1, 1, ROULETTE_CHANCE_LEGENDARY, 0.0, -30.0, 180.0, 1.0},   // Аксессуар "Доска для серфинга"
        /* 26 */{-1, -1, -1, -1, -1, 0.0, 0.0, 0.0, 0.0},
        /* 27 */{-1, -1, -1, -1, -1, 0.0, 0.0, 0.0, 0.0},
        /* 28 */{-1, -1, -1, -1, -1, 0.0, 0.0, 0.0, 0.0}
    },
    { // -- Список призов для "Silver" рулетки
        /* 1 */{1239, ITEM_EXP, 2, 6, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.5},                       // Опыт
        /* 2 */{1274, ITEM_DONATE, 5, 150, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.5},                  // Донат
        /* 3 */{1550, ITEM_MONEY, 5000, 30000, ROULETTE_CHANCE_HIGH, -30.0, 5.0, 0.0, 1.1},            // Деньги
        /* 4 */{561, ITEM_VEH_STRATUM, 1, 1, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 40.0, 1.0},                // Stratum
        /* 5 */{2044, ITEM_SKILL_GUN, 1, 1, ROULETTE_CHANCE_HIGH, -90.0, 0.0, 180.0, 1.0},             // Навыки владения оружием
        /* 6 */{1247, ITEM_LAW, 3, 8, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.3},                       // Законопослушность
        /* 7 */{1247, ITEM_LAW, 5, 12, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.3},                      // Законопослушность
        /* 8 */{371, ITEM_BACKPACK, 1, 1, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.3},                   // Улучшенный рюкзак
        /* 9 */{19035, ITEM_GLASS_GROZA, 1, 1, ROULETTE_CHANCE_HIGH, -10.0, 0.0, 90.0, 0.8},           // Очки "Гроза"

        /* 10 */{28, ITEM_SKIN_28, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 7.0, 1.0},                   // Скин ID:28
        /* 11 */{167, ITEM_SKIN_167, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 7.0, 1.0},                 // Скин ID:167
        /* 12 */{566, ITEM_VEH_TAHOMA, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 40.0, 1.0},              // Tahoma
        /* 13 */{18638, ITEM_ACS_BUILD_HELMET, 1, 1, ROULETTE_CHANCE_MEDIUM, 90.0, 180.0, 90.0, 1.0},   // Аксессуар "Строительная каска"
        /* 14 */{1581, ITEM_LIC_KIT, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 180.0, 1.2},               // Комплект лицензий

        /* 15 */{19878, ITEM_ACS_SKATE_BOARD, 1, 1, ROULETTE_CHANCE_LOW, -20.0, 0.0, 0.0, 1.0},         // Аксессуар "Скейтборд"
        /* 16 */{559, ITEM_VEH_JESTER, 1, 1, ROULETTE_CHANCE_LOW, 0.0, 0.0, 40.0, 1.0},                 // Jester
        /* 17 */{1277, ITEM_KIT_SIM, 1, 1, ROULETTE_CHANCE_LOW, 0.0, 0.0, 180.0, 1.2},                  // Купон на покупку 4-х значного номера
        /* 18 */{579, ITEM_VEH_HUNTLEY, 1, 1, ROULETTE_CHANCE_LOW, 0.0, 0.0, 40.0, 1.0},                 // Huntley
        /* 19 */{954, ITEM_VIP_PALLADIUM, 3, 7, ROULETTE_CHANCE_LOW, 0.0, 0.0, 0.0, 1.2},               // VIP Palladium
        /* 20 */{2404, ITEM_ACS_SERF_BOARD, 1, 1, ROULETTE_CHANCE_LOW, 0.0, -30.0, 180.0, 1.0},         // Аксессуар "Доска для серфинга"

        /* 21 */{29, ITEM_SKIN_29, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 7.0, 1.0},                     // Скин ID:29
        /* 22 */{545, ITEM_VEH_HUSTLER, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 40.0, 1.0},               // Hustler
        /* 23 */{19078, ITEM_ACS_PARROT, 1, 1, ROULETTE_CHANCE_RARE, 0.0, -90.0, 0.0, 1.0},             // Аксессуар "Попугай на плечо"
        /* 24 */{562, ITEM_VEH_ELEGY, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 40.0, 1.0},                 // Elegy
        /* 25 */{954, ITEM_VIP_GOLD, 3, 7, ROULETTE_CHANCE_RARE, 0.0, 0.0, 0.0, 1.2},                   // VIP Gold

        /* 26 */{573, ITEM_VEH_DUNE, 1, 1, ROULETTE_CHANCE_LEGENDARY, 0.0, 0.0, 40.0, 1.0},             // Dune
        /* 27 */{-1, -1, -1, -1, -1, 0.0, 0.0, 0.0, 0.0},
        /* 28 */{-1, -1, -1, -1, -1, 0.0, 0.0, 0.0, 0.0}
    },
    { // -- Список призов для "Gold" рулетки
        /* 1 */{1239, ITEM_EXP, 4, 12, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.5},                      // Опыт
        /* 2 */{1274, ITEM_DONATE, 5, 200, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.5},                  // Донат
        /* 3 */{1550, ITEM_MONEY, 10000, 100000, ROULETTE_CHANCE_HIGH, -30.0, 5.0, 0.0, 1.1},          // Деньги
        /* 4 */{170, ITEM_SKIN_170, 1, 1, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 7.0, 1.0},                   // Скин ID:170
        /* 5 */{180, ITEM_SKIN_180, 1, 1, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 7.0, 1.0},                   // Скин ID:180
        /* 6 */{542, ITEM_VEH_CLOVER, 1, 1, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 40.0, 1.0},                // Clover
        /* 7 */{2044, ITEM_SKILL_GUN, 1, 1, ROULETTE_CHANCE_HIGH, -90.0, 0.0, 180.0, 1.0},             // Навыки владения оружием
        /* 8 */{1247, ITEM_LAW, 5, 10, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.3},                      // Законопослушность
        /* 9 */{1247, ITEM_LAW, 10, 25, ROULETTE_CHANCE_HIGH, 0.0, 0.0, 0.0, 1.3},                     // Законопослушность
        /* 10 */{19078, ITEM_ACS_PARROT, 1, 1, ROULETTE_CHANCE_HIGH, 0.0, -90.0, 0.0, 1.0},            // Аксессуар "Попугай на плечо"

        /* 11 */{181, ITEM_SKIN_181, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 7.0, 1.0},                 // Скин ID:181
        /* 12 */{217, ITEM_SKIN_217, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 7.0, 1.0},                 // Скин ID:217
        /* 13 */{579, ITEM_VEH_HUNTLEY, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 40.0, 1.0},              // Huntley
        /* 14 */{545, ITEM_VEH_HUSTLER, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 40.0, 1.0},             // Hustler
        /* 15 */{371, ITEM_BACKPACK, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 0.0, 1.3},                 // Улучшенный рюкзак
        /* 16 */{1581, ITEM_LIC_KIT, 1, 1, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 180.0, 1.2},               // Комплект лицензий
        /* 17 */{19878, ITEM_ACS_SKATE_BOARD, 1, 1, ROULETTE_CHANCE_MEDIUM, -20.0, 0.0, 0.0, 1.0},      // Аксессуар "Скейтборд"
        /* 18 */{954, ITEM_VIP_GOLD, 3, 7, ROULETTE_CHANCE_MEDIUM, 0.0, 0.0, 0.0, 1.2},                 // VIP Gold

        /* 29 */{560, ITEM_VEH_SULTAN, 1, 1, ROULETTE_CHANCE_LOW, 0.0, 0.0, 40.0, 1.0},                 // Sultan
        /* 20 */{223, ITEM_SKIN_223, 1, 1, ROULETTE_CHANCE_LOW, 0.0, 0.0, 7.0, 1.0},                    // Скин ID:223
        /* 21 */{2404, ITEM_ACS_SERF_BOARD, 1, 1, ROULETTE_CHANCE_LOW, 0.0, -30.0, 180.0, 1.0},         // Аксессуар "Доска для серфинга"
        /* 22 */{249, ITEM_SKIN_249, 1, 1, ROULETTE_CHANCE_LOW, 0.0, 0.0, 7.0, 1.0},                    // Скин ID:249
        /* 23 */{502, ITEM_VEH_HOTRING, 1, 1, ROULETTE_CHANCE_LOW, 0.0, 0.0, 40.0, 1.0},                // Hotring Racer

        /* 24 */{1277, ITEM_KIT_SIM, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 180.0, 1.2},                 // Купон на покупку 4-х значного номера
        /* 25 */{541, ITEM_VEH_BULLET, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 40.0, 1.0},                // Bullet
        /* 26 */{573, ITEM_VEH_DUNE, 1, 1, ROULETTE_CHANCE_RARE, 0.0, 0.0, 40.0, 1.0},                  // Dune

        /* 27 */{149, ITEM_SKIN_149, 1, 1, ROULETTE_CHANCE_LEGENDARY, 0.0, 0.0, 7.0, 1.0},              // Скин ID:149
        /* 28 */{528, ITEM_VEH_FBI, 1, 1, ROULETTE_CHANCE_LEGENDARY, 0.0, 0.0, 40.0, 1.0}               // FBI Truck
    }
};

new g_player_roulette_prize_id[MAX_PLAYERS][MAX_ROULETTE_TYPES][MAX_ROULETTE_SLOTS];

new Text:TD_roulette[MAX_GLOBAL_TD_ROULETTE];
new PlayerText:PTD_roulette[MAX_PLAYERS][MAX_PLAYER_PTD_ROULETTE];