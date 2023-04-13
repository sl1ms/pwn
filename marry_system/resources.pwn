#define MAX_MARRY_ACTORS                            3
#define MAX_MARRY_PICKUPS                           2

#define MARRY_WORLD_ID                              200
#define MARRY_INTERIOR_ID                           0

#define MARRY_POS_ENTER_INTERIOR                    260.5454, -242.3412, 1004.4092, 268.7353
#define MARRY_POS_LEAVE_INTERIOR                    294.2884, -239.1863, 1.6121, 270.3325

#define MARRY_PRICE_FLOWER                          25

#define MARRY_MAP_ICON_ID                           21
#define MARRY_MAP_ICON_POS                          289.2388, -239.1388, 2.6987

#define MAX_MARRY_VEHICLE_TYPES                     5
#define MAX_MARRY_VEHICLES                          10

#define MAX_MARRY_VEHICLE_COLORS                    9

#define MARRY_MINUTE_VEH_RENT                       20
#define MAX_MARRY_VEHICLE_POS                       11

#define COLOR_MARRY                                 0xF9847AFF
#define CLR_MARRY                                   "{F9847A}"

#define MAX_MARRY_MUSICS                            3

enum E_MARRY_ACTORS_STRUCT {
    M_ACTOR_ID,
    M_ACTOR_SKIN,
    Float:M_ACTOR_X,
    Float:M_ACTOR_Y,
    Float:M_ACTOR_Z,
    Float:M_ACTOR_ANGLE,
    M_ACTOR_NAME[64],
    M_ACTOR_AREA_ID,
    M_ACTOR_ACTION_TYPE,
    M_ACTOR_TYPE,
    M_ACTOR_AREA_ACTION_TYPE,
    M_ACTOR_AREA_TYPE
};
new g_marry_actors[MAX_MARRY_ACTORS][E_MARRY_ACTORS_STRUCT] = {
    {
        INVALID_ACTOR_ID, 68, 285.3833, -242.3190, 1004.4092, 89.1935, 
        "Noam Quere\n{"#DC_YELLOW"}Священнослужитель", INVALID_AREA_ID,
        ACTOR_ACTION_MARRY, ACTOR_TYPE_MARRY_PRIEST
    },
    {
        INVALID_ACTOR_ID, 54, 260.8254, -248.1899, 1004.4092, 317.6850, 
        "Minna Jonsson\n{"#DC_YELLOW"}Продавщица цветов", INVALID_AREA_ID,
        ACTOR_ACTION_MARRY, ACTOR_TYPE_MARRY_FLOWER
    },
    {
        INVALID_ACTOR_ID, 228, 262.2143, -235.6716, 1004.4092, 181.5062,
        "Scolaio DeMeo\n{"#DC_YELLOW"}Прокат свадебного транспорта", INVALID_AREA_ID,
        ACTOR_ACTION_MARRY, ACTOR_TYPE_MARRY_VEHICLE
    }
};

enum E_MARRY_PICKUP_STRUCT {
    M_PICKUP_MODELID,
    Float:M_PICKUP_X,
    Float:M_PICKUP_Y,
    Float:M_PICKUP_Z,
    M_PICKUP_WORLD,
    M_PICKUP_INTERIOR,
    M_PICKUP_ACTION_TYPE,
    M_PICKUP_TYPE
};
new g_marry_pickups[MAX_MARRY_PICKUPS][E_MARRY_PICKUP_STRUCT] = {
    {
        19132, 289.2388, -239.1388, 2.6987, 0, 0,
        PICKUP_ACTION_MARRY, PICKUP_TYPE_MARRY_ENTER
    },                                                                                      // Вход в церковь (пикап)
    {
        19132, 259.4174, -242.3128, 1004.4092, MARRY_WORLD_ID, MARRY_INTERIOR_ID,
        PICKUP_ACTION_MARRY, PICKUP_TYPE_MARRY_LEAVE
    }                                                                                       // Выход из церкви (пикап)
};

enum E_MARYY_VEHICLE_STRUCT {
    M_VEH_MODELID,
    M_VEH_NAME[64],
    M_VEH_PRICE
};
new g_marry_vehicle[MAX_MARRY_VEHICLE_TYPES][E_MARYY_VEHICLE_STRUCT] = {
    {560, "Sultan", 1500},
    {579, "Huntley", 2300},
    {429, "Banshee", 3000},
    {580, "Stafford", 5000},
    {409, "Stretch", 10000}
};

new g_total_marry_vehicles = MAX_MARRY_VEHICLES;

new Float:g_marry_vehicle_pos[MAX_MARRY_VEHICLE_POS][4] = {
    {296.8150, -194.2, 1.05, 180.0},
    {299.3880, -194.2, 1.05, 180.0},
    {301.8781, -194.2, 1.05, 180.0},
    {304.3545, -194.2, 1.05, 180.0},
    {306.7926, -194.2, 1.05, 180.0},
    {309.3047, -194.2, 1.05, 180.0},
    {311.8621, -194.2, 1.05, 180.0},
    {314.2894, -194.2, 1.05, 180.0},
    {316.8499, -194.2, 1.05, 180.0},
    {319.3941, -194.2, 1.05, 180.0},
    {308.5719, -217.3872, 1.2791, 269.7514} // Место спавна лимузина
};

enum E_MARRY_VEHICLE_COLOR_STRUCT {
    M_COLOR_HEX[8],
    M_COLOR_NAME[16],
    M_COLOR_ID
};
new g_marry_vehicle_color[MAX_MARRY_VEHICLE_COLORS][E_MARRY_VEHICLE_COLOR_STRUCT] = {
    {"FFFFFF", "Белый", 1},
    {"000000", "Чёрный", 0},
    {"AB3D3D", "Красный", 3},
    {"FCC457", "Желтый", 6},
    {"526DE7", "Синий", 7},
    {"B17980", "Розовый", 5},
    {"33CC66", "Зеленый", 128},
    {"FCBA03", "Золотой", 6},
    {"FF9900", "Оранжевый", 219}
};

enum E_MARRY_RENT_VEHICLE_STRUCT {
    R_VEHICLEID,
    R_TIME_END
};
new g_marry_rent_veh_player[MAX_PLAYERS][E_MARRY_RENT_VEHICLE_STRUCT];
new g_marry_rent_veh_player_null[E_MARRY_RENT_VEHICLE_STRUCT] = {
    INVALID_VEHICLE_ID,
    0
};

enum E_MARRY_MUSIC_STRUCT {
    M_MUSIC_URL[64],
    M_MUSIC_TIME
};
new g_marry_music[MAX_MARRY_MUSICS][E_MARRY_MUSIC_STRUCT] = {
    {"https://music.paradox-rp.com/marry_2.mp3", 218},
    {"https://music.paradox-rp.com/marry_3.mp3", 215},
    {"https://music.paradox-rp.com/marry_1.mp3", 290}
};

new g_marry_time[MAX_PLAYERS],
    g_marry_last_player_music[MAX_PLAYERS];