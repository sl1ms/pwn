#define BYTES_PER_CELL                  (cellbits / 8)

#define CS_PACKET_ID_MAIN 				220 // ����� ������ ��������� �������

#define CS_PACKET_ID_HUD_NOTIFY 		189 // ����� ������ ���� (�����������)
#define CS_PACKET_ID_HUD_INFO 			190 // ����� ������ ���� (����)

#define CEF_CUSTOM_PACKET				230
#define CEF_REMOTE_EVENT				2

#define MAX_CLIENTSIDE_ALLOW_KEYS		255
#define ClientSide:%0( 					CSDE_%0(

enum
{
	OUT_PACKET_GET_NUMMBER = 0,			// ����
	OUT_PACKET_TOGGLE_CH_WH,			// ��������� ������������ WH
	OUT_PACKET_TOGGLE_KEYS,				// ��������� ������ ������������ �������
	OUT_PACKET_CHAT_STATE,				// ����� ������ ���� (������������ ������ � ���� ����, ��� ������ ���)
	OUT_PACKET_ADMIN_STATE,				// ���������� ����������
	OUT_PACKET_VEH_SP_FUEL,				// ���������: �������
	OUT_PACKET_VEH_SP_MILEAGE,			// ���������: ������
	OUT_PACKET_VEH_SP_BELT,				// ���������: ������
	OUT_PACKET_VEH_SP_TLIGHTS,			// ���������: ��������� ������������
	OUT_PACKET_SETTNG_SPEED_OFF,		// ���������: ���������� ����������
	OUT_PACKET_TOGGLE_B_TRANSITION,		// ������� ����� ���������
	OUT_PACKET_TOGGLE_CH_GM,			// ��������� ������������ GM
	OUT_PACKET_TOGGLE_CH_AIRBRAKE,		// ��������� ������������ AirBrake
	OUT_PACKET_OPEN_URL,				// ������� URL
	OUT_PACKET_SET_HUD_STATE,			// ��������� ����

	// usage: ClientSide:SendBSBool(playerid, OUT_PACKET_TOGGLE_GM, true)
	OUT_PACKET_TOGGLE_GM,				// ������������

	// usage: ClientSide:SendBSInt(playerid, OUT_PACKET_SET_MODEL_INDEX, vehicle_id, model_id);
 	OUT_PACKET_SET_MODEL_INDEX,				// ���������� ������������� �������� ������ (�������� ��������, ��� �������� ������������)
	OUT_PACKET_CHECK_HAS_CLIENT,			// �������� �� ������� ������� � ������
}

enum
{
	IN_PACKET_SEND_KEY = 0,			// ����� ���������� �������
	IN_PACKET_SEND_CHAT_STATE,		// ����� ���������� ��������� ����
	IN_PACKET_SEND_TLIGHT_SOUND,	// ����� ����������� ���� �����������
	IN_PACKET_HAS_CLIENT,			// ����� ����� ������������� ������
	IN_PACKET_REPAIR_CAR,			// ����� ����������� ������� ������
}

stock ClientSide:SetVehicleModelIDForPlayer(playerid, vehicleid, modelid)
{
	new BitStream:bs = BS_New();

	BS_WriteValue(
		bs,
	 	PR_UINT8, CS_PACKET_ID_MAIN,
		PR_UINT8, OUT_PACKET_SET_MODEL_INDEX,
		PR_UINT16, vehicleid,
		PR_UINT16, modelid
	);

	PR_SendPacket(bs, playerid);
	BS_Delete(bs);

	return 1;
}

stock ClientSide:SendCheckHasClient(playerid)
{
	new BitStream:bs = BS_New();
	BS_WriteValue(
		bs,
	 	PR_UINT8, CS_PACKET_ID_MAIN,
		PR_UINT8, OUT_PACKET_CHECK_HAS_CLIENT
	);
	PR_SendPacket(bs, playerid);
	BS_Delete(bs);
}

stock ClientSide:SendBSBool(playerid, out_packet, bool: value)
{
	new BitStream:bs = BS_New();
	BS_WriteValue(
		bs,
	 	PR_UINT8, CS_PACKET_ID_MAIN,
		PR_UINT8, out_packet,
		PR_BOOL, value
	);
	PR_SendPacket(bs,playerid);
	BS_Delete(bs);
	return 1;
}

stock ClientSide:SendBSInt(playerid, out_packet, int_type, value)
{
	// * �������� ��� ��������� �������
	new BitStream:bs = BS_New();
	BS_WriteValue(
		bs,
	 	PR_UINT8, CS_PACKET_ID_MAIN,
		PR_UINT8, out_packet,
		int_type, value
	);
	PR_SendPacket(bs, playerid);
	BS_Delete(bs);
	return 1;
}

stock ClientSide:OnIncomingPacket(playerid, packetid, BitStream:bs)
{
	if (packetid == CS_PACKET_ID_MAIN) {
		new cmd_index;

		BS_IgnoreBits(bs, 8);
		BS_ReadValue(
			bs,
			PR_UINT8, cmd_index
		);

		switch (cmd_index) {
			case IN_PACKET_HAS_CLIENT: {
				PlayerInfo[playerid][is_clientside_supported] = true;
				SCM(playerid, -1, "Client side detected");
			}
			case IN_PACKET_REPAIR_CAR: {
				if (!AdminLogged[playerid]) {
					return;
				}

				RepairVehicle(GetPlayerVehicleID(playerid));			
			}
		}
	}

	if (packetid == CEF_CUSTOM_PACKET) {
		new cmd_index;

		new total_used;
		
		BS_GetNumberOfBytesUsed(bs, total_used);

		// Skip 2 bytes (packetid & cmd_index) to get the message
		total_used -= 2;

		BS_IgnoreBits(bs, 8);
		BS_ReadValue(bs, PR_UINT8, cmd_index);

		if (cmd_index != CEF_REMOTE_EVENT) {
			return;
		}

		bigstring[0] = EOS;

      	BS_ReadValue(bs,PR_STRING, bigstring, total_used);

		printf("got %d cmd_index", cmd_index);
		printf("total size: %d", total_used);
		printf("str test %s", bigstring);

		new Node:json, ret;

		ret = JsonParse(bigstring, json);
		bigstring[0] = EOS;

		if (ret) {
			printf("got %d while parsing json. Str: %s, pid: %d", ret, bigstring, playerid);
			return;
		}
		
		new event_name[32];

		ret = JsonGetString(json, "event", event_name);

		if (ret) {
			return;
		}

		CEF_HandleRemoteResponse(playerid, event_name, json);
	}
}