#define MAX_INVENTORY_SLOTS                                 75

#define INVALID_INVENTORY_SLOT                              -1
#define INVALID_INVENTORY_ITEM                              0

#define GetPlayerInventoryData(%0,%1,%2)                    g_player_inventory[%0][%1][%2]
#define SetPlayerInventoryData(%0,%1,%2,%3)                 g_player_inventory[%0][%1][%2] = %3

#define DB_ACCOUNT_INVENTORY                                "`account_inventory`"

enum E_INVENTORY_STRUCT {
    I_ID[MAX_INVENTORY_SLOTS],
    I_ITEM[MAX_INVENTORY_SLOTS],
    I_COUNT[MAX_INVENTORY_SLOTS]
};
new g_player_inventory[MAX_PLAYERS][E_INVENTORY_STRUCT];