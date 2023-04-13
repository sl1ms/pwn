#define GetJobCollectorData(%0)                             g_job_collector[%0]
#define SetJobCollectorData(%0,%1)                          g_job_collector[%0] = %1

#define GetJobCollectorDataArray(%0,%1)                     g_job_collector[%0][%1]
#define SetJobCollectorDataArray(%0,%1,%2)                  g_job_collector[%0][%1] = %2

#define SetPlayerJobCollector(%0,%1,%2)                     g_player_job_collector[%0][%1] = %2
#define GetPlayerJobCollector(%0,%1)                        g_player_job_collector[%0][%1]

#define SetPlayerJobCollectorArray(%0,%1,%2,%3)             g_player_job_collector[%0][%1][%2] = %3
#define GetPlayerJobCollectorArray(%0,%1,%2)                g_player_job_collector[%0][%1][%2]

#define SetJobCollectorLobbyData(%0,%1,%2)                  g_jc_lobby_data[%0][%1] = %2
#define GetJobCollectorLobbyData(%0,%1)                     g_jc_lobby_data[%0][%1]

#define SetJobCollectorLobbyDataArray(%0,%1,%2,%3)          g_jc_lobby_data[%0][%1][%2] = %3
#define GetJobCollectorLobbyDataArray(%0,%1,%2)             g_jc_lobby_data[%0][%1][%2]

#define GetJobCollectorAttackGroup(%0,%1)                   g_jc_attack_group[%0][%1]
#define SetJobCollectorAttackGroup(%0,%1,%2)                g_jc_attack_group[%0][%1] = %2
#define GetJobCollectorAttackGroupArray(%0,%1,%2)           g_jc_attack_group[%0][%1][%2]
#define SetJobCollectorAttackGroupArray(%0,%1,%2,%3)        g_jc_attack_group[%0][%1][%2] = %3

#define MAX_JOB_COLLECTOR_VEHICLES                          10
#define MAX_JC_PICKUP_TEXT                                  64

#define BANK_VIRTUAL_WORLD                                  126
#define BANK_INTERIOR                                       0

#define MAX_JOB_COLLECTOR_ACTORS                            3

#define MAX_JC_DRAWDISTANCE_TEXT_3D                         5.0

#define MAX_JC_WEAPON_AMMO_DEAGLE                           50
#define MAX_JC_WEAPON_AMMO_MP5                              100

#define MAX_JC_LIMIT_TIME_TAKE_ITEM                         10

#define JC_SKIN_BOY                                         71
#define JC_SKIN_GIRL                                        191

#define PRICE_JC_RENT_VEHICLE                               200

#define MODEL_JC_VEHICLE                                    428

#define MAX_J�_ITEMS                                        3
#define MAX_JC_MONEY_BAG                                    5

#define MAX_JOB_COLLECTOR_VEHICLES_POS                      4

#define JC_MONEY_BAD_SALARY                                 200

#define MODELID_JC_MONEY_BAG                                11745

#define COLOR_JOB_CHAT                                      0x228B22FF
#define COLOR_LOBBY_CHAT                                    0x27cbe8FF

#define JC_LOBBY_ROW_INVITE                                 1
#define JC_LOBBY_ROW_UNINVITE                               2

#define MAX_JC_LOBBY_PLAYER                                 4
#define MAX_JC_LOBBY                                        10

#define INVALID_ATM_KEY                                     -1
#define INVALID_ATM_ID                                      -1
#define INVALID_JC_LOBBY_ID                                 -1

#define PVAR_JC_LOBBY_TYPE_LIST                             "PVAR_JC_LOBBY_TYPE_LIST"
#define PVAR_JC_LOBBY_ID                                    "PVAR_JC_LOBBY_ID"

#define PVAR_SELECT_ROW_UNINVITE                            "PVAR_SELECT_ROW_UNINVITE"
#define PVAR_ATTACK_VEH_PUT_ID                              "PVAR_ATTACK_VEH_PUT_ID"
#define PVAR_COLLECTOR_VEH_PUT_ID                           "PVAR_COLLECTOR_VEH_PUT_ID"

#define MAX_GANG_FRACTION                                   5

#define LIMIT_HOUR_ATTACK                                   2
#define TIME_BUY_SPECTATE                                   30
#define TIME_SPECTATE                                       10

#define MAX_JC_ATTACK_PLAYERS                               6
#define MIN_JC_ATTACK_PLAYERS                               3

#define PRICE_ATTACK_BUY                                    1000
#define MONEY_JC_ATTACK                                     5000

new g_job_collector_veh_count = MAX_JOB_COLLECTOR_VEHICLES;

enum {
    JC_PICKUP_DRESSING_ROOM,        // ����� ����������
    JC_PICKUP_SAFE,                 // ����� �����
    MAX_JOB_COLLECTOR_PICKUPS       // ������������ ���������� �������
};

enum {
    JC_ITEM_ARMOUR,
    JC_ITEM_DEAGLE,
    JC_ITEM_MP5
};

enum E_JOB_COLLECTOR_PICKUP {
    JC_PICKUP_ID,
    JC_PICKUP_MODEL,
    Float:JC_PICKUP_X,
    Float:JC_PICKUP_Y,
    Float:JC_PICKUP_Z,
    JC_PICKUP_TEXT[MAX_JC_PICKUP_TEXT]
};

new g_job_collector_pickup[MAX_JOB_COLLECTOR_PICKUPS][E_JOB_COLLECTOR_PICKUP] = {
    {INVALID_PICKUP_ID, 1275, 1395.9198, -1685.5999, 40.2919, "����������"},    // ����������, ������ ������ � �����������
    {INVALID_PICKUP_ID, 1550, 1401.0365, -1681.1648, 40.2938, "����"}           // ����� � �����
};

enum E_JOB_COLLECTOR_ACTOR {
    JC_ACTOR_ID,
    JC_ACTOR_ACTION_TYPE,
    JC_ACTOR_TYPE,
    JC_ACTOR_SKIN,
    Float:JC_ACTOR_X,
    Float:JC_ACTOR_Y,
    Float:JC_ACTOR_Z,
    Float:JC_ACTOR_ANGLE,
    JC_ACTOR_ANIM_LIB[MAX_ANIM_LIB_LEN],
    JC_ACTOR_ANIM_NAME[MAX_ANIM_NAME_LEN],
    JC_ACTOR_WORLD,
    JC_ACTOR_INTERIOR,
    JC_ACTOR_NAME[64]
};
new g_job_collector_actor[MAX_JOB_COLLECTOR_ACTORS][E_JOB_COLLECTOR_ACTOR] = {
    {
        INVALID_ACTOR_ID, ACTOR_ACTION_JOB_COLLECTOR, ACTOR_TYPE_DEFAULT, 
        71, 1403.6422, -1702.1075, 42.9380, 170.6659, "DEALER", "DEALER_IDLE",
        BANK_VIRTUAL_WORLD, BANK_INTERIOR, "Christopher Miller\n{"#DC_YELLOW"}��������� ������ ����������"
    },  // ���������������
    {
        INVALID_ACTOR_ID, ACTOR_ACTION_DEFAULT, ACTOR_TYPE_DEFAULT,
        163,1393.3536, -1685.6691, 40.2919, 241.9661, "PED", "SEAT_down",
        BANK_VIRTUAL_WORLD, BANK_INTERIOR, "none"
    },  // �������� � �����
    {
        INVALID_ACTOR_ID, ACTOR_ACTION_JC_OLD_BANK, ACTOR_TYPE_DEFAULT,
        228, 2255.2639, -1107.7421, 37.9766, 294.6046, "DEALER", "DEALER_IDLE",
        0, 0, "Owen Reed\n{"#DC_YELLOW"}������ �������� �����"
    }   // ������ �������� �����
};

enum E_JOB_COLLECTOR_PLAYER {
    JC_ANTIFLOOD[MAX_J�_ITEMS],
    JC_SKIN,
    bool:JC_WORK_DAY,
    JC_ATM_KEY,
    JC_LOBBY_ID
};
new g_player_job_collector[MAX_PLAYERS][E_JOB_COLLECTOR_PLAYER];
new g_player_job_collector_default[E_JOB_COLLECTOR_PLAYER] = {
    {0, 0, 0},
    0,
    false,
    INVALID_ATM_KEY,
    INVALID_JC_LOBBY_ID
};

new Float:g_job_collector_veicle_pos[MAX_JOB_COLLECTOR_VEHICLES_POS][4] = {
    {1363.4451, -1635.3954, 13.5075, 271.4178},
    {1363.5516, -1643.2983, 13.5080, 270.9870},
    {1363.4242, -1651.0858, 13.5070, 270.1409},
    {1363.7736, -1658.7644, 13.5072, 272.0242}
};


new bool:g_bank_safe_state = false;
new g_bank_safe_timer;

enum E_JC_LOBBY_STRUCT {
    JC_LOBBY_CREATED_ID,                    // ��������� �����
    JC_LOBBY_PLAYERID[MAX_JC_LOBBY_PLAYER], // ��������� �����
    JC_LOBBY_VEHICLEID,                     // ��������� ����������� � �����
    JC_LOBBY_ATM_ID,                        // ID ���������, ������� ���������� ���������
    JC_LOBBY_ATM_KEY,                       // ���-��� �� ���������
    JC_LOBBY_ACTIVE_PLAYERID                // �����, ������� ����� ����������� ��������
};
new g_jc_lobby_data[MAX_JC_LOBBY][E_JC_LOBBY_STRUCT];
new g_jc_lobby_data_null[E_JC_LOBBY_STRUCT] = {
    INVALID_PLAYER_ID,          // JC_LOBBY_CREATED_ID
    {                           
        INVALID_PLAYER_ID,
        INVALID_PLAYER_ID,
        INVALID_PLAYER_ID,
        INVALID_PLAYER_ID
    },                          // JC_LOBBY_PLAYERID
    INVALID_VEHICLE_ID,         // JC_LOBBY_VEHICLEID
    INVALID_ATM_ID,             // JC_LOBBY_ATM_ID
    INVALID_ATM_KEY,            // JC_LOBBY_ATM_KEY
    INVALID_PLAYER_ID           // JC_LOBBY_ACTIVE_PLAYERID
};

enum E_JC_ATTACK_STRUCT {
    AG_LIMIT,                                   // ����� �� ���������
    AG_PLAYERS[MAX_JC_ATTACK_PLAYERS],          // ���������, ��������� � ������
    AG_LOBBY_ID,                                // ID ����� ������������
    AG_ACTIVE_TIME,                             // �������� ����� �� ����� �������
    AG_TIMER,                                   // ������ ��� ���������� ����� ��� � ������
    AG_LIMIT_BUY,                               // ����� �� ������� �������
    AG_VEHICLEID_ATTACK,                        // ID ����������, �� ������� ��������
    AG_VEHICLEID                                // ID ���������� �� ������� ��������� �����
};
new g_jc_attack_group[MAX_GANG_FRACTION][E_JC_ATTACK_STRUCT];
new g_jc_attack_group_default[E_JC_ATTACK_STRUCT] = {
    0,                                          // AG_LIMIT
    {
        INVALID_PLAYER_ID,
        INVALID_PLAYER_ID,
        INVALID_PLAYER_ID,
        INVALID_PLAYER_ID,
        INVALID_PLAYER_ID,
        INVALID_PLAYER_ID
    },                                          // AG_PLAYERS
    INVALID_JC_LOBBY_ID,                        // AG_LOBBY_ID
    0,                                          // AG_ACTIVE_TIME
    INVALID_TIMER,                              // AG_TIMER
    0,                                          // AG_LIMIT_BUY
    INVALID_VEHICLE_ID,                         // AG_VEHICLEID_ATTACK
    INVALID_VEHICLE_ID                          // AG_VEHICLEID
};