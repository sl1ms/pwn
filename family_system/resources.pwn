#define     FAMILY_PRICE                    690
#define     FAMILY_RENAME_PRICE             199
#define     FAMILY_CREATION_MIN_LEVEL       3

#define     FAMILY_VEHICLE_REPAIR_PRICE     500
#define     FAMILY_VEHICLE_RESPAWN_PRICE    200
#define     FAMILY_VEHICLE_UNLOAD_COST      50

// Снятие наличных
#define     FAMILY_MIN_WITHDRAW             100
#define     FAMILY_MAX_WITHDRAW             50000
#define     FAMILY_WITHDRAW_TIMEOUT         300

// Репутация

#define     F_REP_DONATE_VEHICLE_BUY       100

// За PayDay

#define    F_REP_NON_VIP_PAYDAY_RATE       1
#define    F_REP_PALLADIUM_VIP_PAYDAY_RATE 2
#define    F_REP_GOLD_VIP_PAYDAY_RATE      3

// Общее количество машин, доступное для покупки в семью
#define     FAMILY_MAX_VEHICLES             10

#define     FAMILY_MIN_SYMBOLS              5
#define     FAMILY_MAX_SYMBOLS              24
#define     FAMILY_MAX_COLORED_SYMBOLS      62
#define     FAMILY_MAX_NOTIFICATION_SYMBOLS 64

#define     FAMILY_PICKUP_MODEL             1314
#define     FAMILY_PICKUP_MODEL_TYPE        1
#define     FAMILY_PICKUP_WORLD             123
#define     FAMILY_PICKUP_POS               2249.1543, 791.3837, 1127.4229

// % от суммы, который вернется при продаже авто
#define     FAMILY_VEHICLE_SELL_FACTOR      0.5

// Цена продажи на случай, если автомобиль не найден в списке доступных для покупки
#define     FAMILY_DEFAULT_SELL_PRICE       30000

#define     FAMILY_MIN_DONATE               100
#define     FAMILY_MAX_DONATE               100000

#define     FAMILIES_PER_PAGE               15

#define     FAMILIES_VEHICLE_PER_PLAYERS    4

#define     FAMILY_OWNER_RANK               6
#define     FAMILY_DEPUTY_RANK              5
#define     FAMILY_OWNER_RANK_INDEX         (FAMILY_OWNER_RANK - 1)
#define     FAMILY_DEPUTY_RANK_INDEX        (FAMILY_DEPUTY_RANK - 1)
#define     FAMILY_INITIAL_RANK_INDEX       0
#define     FAMILY_MAX_RANKS                FAMILY_OWNER_RANK

#define     FAMILY_MIN_INVITE_RANK          4
#define     FAMILY_MIN_INVITE_RANK_INDEX    (FAMILY_MIN_INVITE_RANK - 1)

#define     FAMILY_MAX_RANK_SYMBOLS         16
#define     FAMILY_MIN_RANK_SYMBOLS         4

#define     MAX_LOADED_FAMILIES             MAX_PLAYERS

#define     FAMILY_ACTIONS_PREFIX           "[Family] "
#define     FAMILY_CHAT_PREFIX              "[FC] "

// База данных
#define     DB_FAMILIES                     "families"
#define     DB_FAMILY_RANKS                 "family_ranks"
#define     DB_FAMILY_MEMBERS               "family_members"
#define     DB_FAMILY_VEHICLES              "family_vehicles"
#define     DB_FAMILY_RELATIONSHIPS         "family_relationships"

#define     INVALID_FAMILY_ID               -1

#define     GetPlayerFamilyIndex(%0)        PlayerInfo[%0][p_family_index]
#define     GetPlayerFamilyRankIndex(%0)    PlayerInfo[%0][p_family_rank_index]
#define     GetPlayerFamilyRankName(%0)     family_ranks[GetPlayerFamilyIndex(%0)][GetPlayerFamilyRankIndex(%0)][FR_NAME]

#define     GetFamilyRankName(%0,%1)        family_ranks[%0][%1][FR_NAME]
#define     IsFamilyMember(%0)              (GetPlayerFamilyIndex(%0) != INVALID_FAMILY_ID)

#define     Family:%0( 		                FM_%0(
#define     FamilyText(Family:%0)           #FM_%0

#define     PVAR_FAMILIES_SEARCH_OFFSET     "PVAR_FAMILIES_SEARCH_OFFSET"
#define     PVAR_FAMILIES_SEARCH_TOTAL      "PVAR_FAMILIES_SEARCH_TOTAL"
#define     PVAR_FAMILIES_SEARCH_CURRENT    "PVAR_FAMILIES_SEARCH_CURRENT"
#define     PVAR_FAMILIES_CURRENT_RELATION  "PVAR_FAMILIES_CURRENT_RELATION"
#define     PVAR_FAMILIES_CURRENT_VEHICLE   "PVAR_FAMILIES_CURRENT_VEHICLE"
#define     PVAR_FAMILIES_CURRENT_RANK      "PVAR_FAMILIES_CURRENT_RANK"
#define     PVAR_FAMILIES_EDIT_VEH_RANK     "PVAR_FAMILIES_EDIT_VEH_RANK"
#define     PVAR_FAMILIES_SELL_VEH          "PVAR_FAMILIES_SELL_VEH"
#define     PVAR_FAMILIES_INVITED_BY        "PVAR_FAMILIES_INVITED_BY"
#define     PVAR_FAMILIES_FROM_RL_MANAGE    "PVAR_FAMILIES_FROM_RL_MANAGE"
#define     PVAR_FAMILIES_RELATION_ID       "PVAR_FAMILIES_RELATION_ID"
#define     PVAR_FAMILIES_SEARCH_ORDER      "PVAR_FAMILIES_SEARCH_ORDER"

#define     FAMILIES_SEARCH_ID_NEXT         -3
#define     FAMILIES_SEARCH_ID_BACK         -4
#define     FAMILIES_ADD_RELATION           -5

enum RelationType {
    FRIENDLY,
    HOSTILE
}

enum FamilyOrderBy {
    CREATED_AT_ASC,
    CREATED_AT_DESC,
    MEMBERS_ASC,
    MEMBERS_DESC
}

enum FamilyResources {
    F_PICKUP,
    Text3D:F_TEXT_ID,
    F_SPHERE_ID
}

enum FamilyVehicleState {
    NOT_SPAWNED,
    ALIVE,
    DEAD
}

enum FamilyAvailableColor {
    FC_COLOR[10],
    FC_COLOR_NAME[20]
}

enum FamilyCarPrice {
    FAMILY_CASH,
    DONATE
}

enum FamilyAvailableCar {
    FAC_MODEL,
    FAC_PRICE,
    FAC_SELL_PRICE, // everything is being sold by family cash
    FamilyCarPrice:FAC_PRICE_TYPE
}

enum FamilyVehicleBuyReputation {
    FVR_MIN_PRICE,
    FVR_MAX_PRICE,
    FVR_RATE
}

enum FamilyStruct {
    F_ID,
    F_BALANCE,
    F_COLOR[10],
    F_NAME[FAMILY_MAX_COLORED_SYMBOLS],
    F_NOTIFICATION[FAMILY_MAX_NOTIFICATION_SYMBOLS],
    F_WITHDRAW_TIMEOUT,
};

enum FamilyRankStruct {
    FR_ID,
    FR_NAME[FAMILY_MAX_RANK_SYMBOLS]
};

enum FamilyVehicleStruct {
    FV_ID,
    FV_MODEL,
    FV_RANK,

    FV_COLOR_1,
    FV_COLOR_2,
    FV_VEHICLE_ID,
    FamilyVehicleState:FV_STATE,
    Text3D:FV_3DTEXT,

    Float:FV_X,
    Float:FV_Y,
    Float:FV_Z,
    Float:FV_ROT
};

new family_resources[FamilyResources];

new family_cars[MAX_LOADED_FAMILIES][FAMILY_MAX_VEHICLES][FamilyVehicleStruct];
new family_ranks[MAX_LOADED_FAMILIES][FAMILY_MAX_RANKS][FamilyRankStruct];

new family_search_requests[MAX_PLAYERS][FAMILY_MAX_COLORED_SYMBOLS];

new families[MAX_LOADED_FAMILIES][FamilyStruct];

new default_family_rank[FamilyRankStruct] = {
    INVALID_FAMILY_ID,
    ""
};

new default_family[FamilyStruct] = {
    INVALID_FAMILY_ID,
    INVALID_FAMILY_ID,
    "B789CF",
    "",
    "",
    INVALID_FAMILY_ID
};

new default_family_vehicle[FamilyVehicleStruct] = {
    INVALID_FAMILY_ID,
    INVALID_FAMILY_ID,
    1,
    INVALID_FAMILY_ID,
    INVALID_FAMILY_ID,
    INVALID_VEHICLE_ID,
    NOT_SPAWNED,
    Text3D:INVALID_3DTEXT_ID,
    Float:INVALID_FAMILY_ID,
    Float:INVALID_FAMILY_ID,
    Float:INVALID_FAMILY_ID,
    Float:INVALID_FAMILY_ID
};

new family_default_ranks[][FAMILY_MAX_RANK_SYMBOLS] = {
    "Рядовой",
    "Участник",
    "Клубный игрок",
    "Крутой чувак",
    "Заместитель",
    "Руководитель"
};

new family_available_colors[][FamilyAvailableColor] = {
    {"33AAFF", "Синий"},
    {"AA3333", "Красный"},
    {"33CC66", "Зеленый"},
    {"FCBA03", "Золотой"},
    {"FF9900", "Оранжевый"},
    {"E75480", "Розовый"},
    {"7733ff", "Индиго"},
    {"4287f5", "Голубой"},
    {"ab4e52", "Светло-красный"},
    {"B789CF", "Фиолетовый"}
};

new family_vehicle_buy_rep[][FamilyVehicleBuyReputation] = {
    {0, 50_000, 5},
    {50_000, 100_000, 12},
    {100_000, 500_000, 20},
    {500_000, -1, 50}
};

new available_family_cars[][FamilyAvailableCar] = {
    {522, 300, 150, FAMILY_CASH},
    {541, 300, 150, DONATE}
};