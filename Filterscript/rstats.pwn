/***                                                    ***
 * RStats - Raf's Stats System - Filterscript             *
 ***                                                    ***
 * @Author  Rafael 'R@f' Keramidas <rafael@keramid.as>    *
 * @Date    13th September 2012                           *
 * @Version 1.0.0                                         *
 * @Licence GPLv3                                         *
 ***													***/

#include <a_samp>
#include <a_mysql>

/* CONFIG */
#define MYSQL_HOST 		"localhost" /* MySQL Host */
#define MYSQL_USER 		"root"      /* MySQL User */
#define MYSQL_PASS 		""          /* MySQL Password */
#define MYSQL_DB   		"rstats"    /* MySQL Database */
#define MYSQL_DEBUG     true        /* MySQL Debug */
#define USER_UPDATE  	15          /* Update account every XX seconds */
#define ONCLICK_STATS   true        /* Show stats when the users is clicked on the player list */
#define RANDOM_ANN      true        /* Enable random stats announces */
#define ANN_INTERVAL    5           /* Announce every XX minutes */
#define DATE_FORMAT     "%m-%d-%Y"  /* http://www.w3schools.com/sql/func_date_format.asp */

/* DO NOT EDIT BELOW (if you don't know what you're doing) */

/* Script Info */
#define MAJOR_VERSION   1
#define MINOR_VERSION   0
#define BUGFIX          0
#define LAST_UPDATE     "13.09.2012"

/* Colors */
#define COLOR_LIGHTBLUE	0x33DAFFAA
#define COLOR_RED 		0xFF0000FF
#define COLOR_WHITE 	0xFFFFFFAA
#define COLOR_YELLOW    0xFFD700AA

/* Unknown types */
#define UNKNOWN_VEHICLE "612"
#define UNKNOWN_WEAPON  "55"

new
	iUserid[MAX_PLAYERS],
	iConnectid[MAX_PLAYERS],
	sMysqlQuery[384],
	playerUpdateTimer[MAX_PLAYERS];
	
/* Found this list in one of my old scripts, don't remember who's the original author */
new aVehName[][] =
{
	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
	"Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
	"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
	"Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
	"Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
	"Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
	"Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
	"Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
	"Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
	"Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
	"Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
	"Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
	"Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
	"Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
	"Blista Compact", "Police Maverick", "Boxvillde", "Benson", "Mesa", "RC Goblin",
	"Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
	"Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
	"Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
	"FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
	"Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
	"Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
	"Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
	"Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
	"Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
	"Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
	"Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
	"Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
	"News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
	"Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
	"Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
	"Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
	"Tiller", "Utility Trailer", "Unknown"
};

/* List created by myself, use it for your projects ;-) */
new aWeapName[][] =
{
	"Fist", "Brass Knuckles", "Golf Club", "Nightstick", "Knife", "Baseball Bat",
	"Shovel", "Pool Cue", "Katana", "Chainsaw", "Double-ended Dildo", "Dildo",
	"Vibrator", "Silver Vibrator", "Flowers", "Cane", "Grenade", "Tear Gas",
	"Molotov Cocktail", "", "", "", "", "9mm", "Silenced 9mm", "Desert Eagle", "Shotgun",
	"Sawnoff Shotgun", "Combat Shotgun", "Micro SMG", "MP5", "AK-47", "M4", "Tec-9",
	"Country Rifle", "Sniper Rifle", "RPG", "HS Rocket", "Flamethrower", "Minigun",
	"Satchel Charge", "Detonator", "Spraycan", "Fire Extinguisher", "Camera",
	"Night Vision Googles", "Thermal Googles", "Parachute", "Fake Pistol", "Vehicle",
	"Helicopter Blades", "Explosion", "Drowned", "Splat", "Unknown"
};

/*############################################################################*/

public OnFilterScriptInit()
{
	mysql_debug(MYSQL_DEBUG);

	printf("++++++++++++++++++++++++++++++++++++++");
	printf("++ RStats - Raf's Stats System      ++");
	printf("++ V%d.%d.%d - Last update: %s ++", MAJOR_VERSION, MINOR_VERSION, BUGFIX, LAST_UPDATE);
	printf("++ Script by Rafael 'R@f' Keramidas ++");
	printf("++++++++++++++++++++++++++++++++++++++\n");
	
    for(new x = 1; x < 4; x++) {
		mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PASS);
		if(mysql_ping() != 1) {
			printf("RStats: MySQL Connection failed. Trying again (%d/3)", x);
			if(x == 3) {
				printf("RStats: MySQL Connection couldn't be establshed !");
			}
		}
		else {
			printf("RStats: MySQL Connection establshed !");
			break;
		}
	}
	
	#if RANDOM_ANN == true
	SetTimer("randomStatsMessages", ANN_INTERVAL * 60000, true);
	#endif
	
	return true;
}

/*############################################################################*/

public OnFilterScriptExit()
{
    mysql_close();
	return true;
}

/*############################################################################*/

public OnPlayerConnect(playerid)
{
	new
	    sPlayerName[MAX_PLAYER_NAME],
		sPlayerIP[20];

	if(!userExists(playerid)) {
	    GetPlayerName(playerid, sPlayerName, sizeof(sPlayerName));
		format(sMysqlQuery, sizeof(sMysqlQuery), "INSERT INTO rstats_users VALUES(null, '%s', 0, 0, 0, 0, 0, 0, 0, 0)", sPlayerName);
		mysql_query(sMysqlQuery);
	}

	iUserid[playerid] = getUserID(playerid);

	/* Update status */
	format(sMysqlQuery, sizeof(sMysqlQuery), "UPDATE rstats_users SET status = 1 WHERE userid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);

	/* Add connection */
	GetPlayerIp(playerid, sPlayerIP, sizeof(sPlayerIP));
	format(sMysqlQuery, sizeof(sMysqlQuery), "INSERT INTO rstats_connects VALUES(null, %d, NOW(), '%s')", iUserid[playerid], sPlayerIP);
	mysql_query(sMysqlQuery);
	
	iConnectid[playerid] = mysql_insert_id();

	playerUpdateTimer[playerid] = SetTimerEx("updatePlayerInfos", USER_UPDATE * 1000, true, "i", playerid);
	return true;
}


/*############################################################################*/

public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(playerUpdateTimer[playerid]);
	updatePlayerInfos(playerid);

	format(sMysqlQuery, sizeof(sMysqlQuery), "UPDATE rstats_users SET status = 0 WHERE userid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);

	format(sMysqlQuery, sizeof(sMysqlQuery), "INSERT INTO rstats_disconnects VALUES(null, %d, NOW(), %d)", iConnectid[playerid], reason);
	mysql_query(sMysqlQuery);
	
	iUserid[playerid] = 0;
	return true;
}

/*############################################################################*/

public OnPlayerSpawn(playerid) {
    format(sMysqlQuery, sizeof(sMysqlQuery), "INSERT INTO rstats_spawns VALUES(null, %d, NOW())", iUserid[playerid]);
	mysql_query(sMysqlQuery);
}

/*############################################################################*/

public OnPlayerDeath(playerid, killerid, reason)
{
    new
		iDid,
		iKid;

	iDid = iUserid[playerid];
	if(killerid == INVALID_PLAYER_ID)
	    iKid = 0;
 	else
		iKid = iUserid[killerid];

	format(sMysqlQuery, sizeof(sMysqlQuery), "INSERT INTO rstats_deaths VALUES(null, %d, %d, %d, NOW())", iDid, iKid, reason);
	mysql_query(sMysqlQuery);
	return true;
}

/*############################################################################*/

public OnPlayerText(playerid, text[])
{
	format(sMysqlQuery, sizeof(sMysqlQuery), "INSERT INTO rstats_chatmessages VALUES(null, %d, '%s', NOW())", iUserid[playerid], text);
	mysql_query(sMysqlQuery);
	return true;
}

/*############################################################################*/

public OnPlayerCommandText(playerid, cmdtext[])
{
	new
	    sCmd[128],
	    sTmp[128],
	    iIndex,
	    iPid;

    sCmd = strtok(cmdtext, iIndex);

    format(sMysqlQuery, sizeof(sMysqlQuery), "INSERT INTO rstats_commands VALUES(null, %d, '%s', NOW())", iUserid[playerid], cmdtext);
	mysql_query(sMysqlQuery);
	
	if (strcmp(sCmd, "/mystats", true) == 0) {
	    showStatsDialog(playerid);
		return true;
	}

	if (strcmp(sCmd, "/stats", true) == 0) {
	    sTmp = strtok(cmdtext, iIndex);
	    if(!strlen(sTmp))
		{
			SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /stats [playerid]");
			return true;
		}

		iPid = strval(sTmp);
		if (!(IsPlayerConnected(iPid)))
		{
			SendClientMessage(playerid, COLOR_RED, "RStats: Player is not connected!");
			return true;
		}

		showStatsDialog(iPid);
		return true;
	}
	
	return false;
}

/*############################################################################*/

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
    {
        new
			iModelID = GetVehicleModel(GetPlayerVehicleID(playerid));

		format(sMysqlQuery, sizeof(sMysqlQuery), "INSERT INTO rstats_vehicleusage VALUES(null, %d, %d, NOW())", iUserid[playerid], iModelID);
		mysql_query(sMysqlQuery);
	}
	return true;
}

/*############################################################################*/

public OnPlayerPickUpPickup(playerid, pickupid)
{
    format(sMysqlQuery, sizeof(sMysqlQuery), "INSERT INTO rstats_pickedpickups VALUES(null, %d, %d, NOW())", iUserid[playerid], pickupid);
	mysql_query(sMysqlQuery);
	return true;
}

/*############################################################################*/

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	#if ONCLICK_STATS == true
    showStatsDialog(clickedplayerid);
    #endif
	return true;
}

/*############################################################################*/

forward updatePlayerInfos(playerid);
public updatePlayerInfos(playerid) {
    new
		Float:fHealth,
		Float:fArmour;

    GetPlayerHealth(playerid, fHealth);
    GetPlayerArmour(playerid, fArmour);

	format(sMysqlQuery, sizeof(sMysqlQuery), "UPDATE rstats_users SET score = %d, health = %.2f, armour = %.2f, skin = %d, money = %d, color = %d, wantedlevel = %d WHERE userid = %d", GetPlayerScore(playerid), fHealth, fArmour, GetPlayerSkin(playerid), GetPlayerMoney(playerid), GetPlayerColor(playerid), GetPlayerWantedLevel(playerid), iUserid[playerid]);
	mysql_query(sMysqlQuery);
	return true;
}

/*############################################################################*/

forward showStatsDialog(playerid);
public showStatsDialog(playerid) {
	new
	    sPlayerName[MAX_PLAYER_NAME],
	    sMsgBoxTitle[40],
	    sMsgBoxText[512],
		sString[320];

	if(IsPlayerConnected(playerid)) {
	    GetPlayerName(playerid, sPlayerName, sizeof(sPlayerName));
        format(sMsgBoxTitle, sizeof(sMsgBoxTitle), "Stats for %s", sPlayerName);
        format(sString, sizeof(sString), "{DE2828}Kills: {FFFFFF}%d\n{DE2828}Deaths: {FFFFFF}%d\n{DE2828}K/D Ratio: {FFFFFF}%.2f\n{DE2828}Most used weapon: {FFFFFF}%s\n{DE2828}Main death cause: {FFFFFF}%s\n{DE2828}Connects: {FFFFFF}%d\n{DE2828}Leaves: {FFFFFF}%d\n{DE2828}Timeouts: {FFFFFF}%d\n{DE2828}Kicks/Bans: {FFFFFF}%d",
            getPlayerKillCount(playerid),
			getPlayerDeathCount(playerid),
			getPlayerKDRatio(playerid),
			aWeapName[getPlayerMostUsedWeapon(playerid)-1],
			aWeapName[getPlayerMainDeathCause(playerid)-1],
			getPlayerConnectCount(playerid),
			getPlayerLeaveCount(playerid),
			getPlayerTimeoutCount(playerid),
			getPlayerKickCount(playerid));
		format(sMsgBoxText, sizeof(sMsgBoxText), "%s\n{DE2828}Spawns: {FFFFFF}%d\n{DE2828}Chat messages: {FFFFFF}%d\n{DE2828}Commands: {FFFFFF}%d\n{DE2828}Vehicles used: {FFFFFF}%d\n{DE2828}Most used vehicle: {FFFFFF}%s\n{DE2828}Pickups picked: {FFFFFF}%d\n",
			sString,
			getPlayerSpawnCount(playerid),
			getPlayerMessageCount(playerid),
			getPlayerCommandCount(playerid),
			getPlayerVehUsageCount(playerid),
			aVehName[getPlayerMostUsedVehicle(playerid)-400],
			getPlayerPickedPickupsCount(playerid));
			
    	ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, sMsgBoxTitle, sMsgBoxText, "Close", "");
	}
	else {
	    SendClientMessage(playerid, COLOR_RED, "RStats: Player is not connected!");
	}
	return true;
}

/*############################################################################*/

forward statsMessages(iMsg, bool:bRandom);
public statsMessages(iMsg, bool:bRandom) {
	new
		sMessage[128],
		sResult[MAX_PLAYER_NAME],
		sCounter[11];
	    
	switch(iMsg) {
	    case 0: {
	        /* Most used vehicle */
	        format(sMessage, sizeof(sMessage), "RStats: The most used vehicle is the %s", aVehName[getMostUsedVehicle()-400]);
	        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
	    }
		case 1: {
		    /* Most used weapon */
		    format(sMessage, sizeof(sMessage), "RStats: The most used weapon is the %s", aWeapName[getMostUsedWeapon()-1]);
	        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
		}
		case 2: {
		    /* Main death cause */
		    format(sMessage, sizeof(sMessage), "RStats: The main death cause is : %s", aWeapName[getMainDeathCause()-1]);
	        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
		}
		case 3: {
		    /* Spawn count */
		    format(sMessage, sizeof(sMessage), "RStats: Number of spawns %d", getSpawnCount());
	        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
		}
		case 4: {
		    /* Money count */
		    format(sMessage, sizeof(sMessage), "RStats: Current money count is %d$", getMoneyCount());
	        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
		}
		case 5: {
		    /* Score count */
		    format(sMessage, sizeof(sMessage), "RStats: Current score count is %d", getScoreCount());
	        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
		}
		case 6: {
			/* User count */
			format(sMessage, sizeof(sMessage), "RStats: Current users count is %d", getUserCount());
	        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
		}
		case 7: {
		    /* User with the most connexions */
		    sMysqlQuery = "SELECT u.username AS username, COUNT(c.connectid) AS connectcount FROM rstats_connects c INNER JOIN rstats_users u ON c.playerid = u.userid GROUP BY c.playerid ORDER BY connectcount DESC LIMIT 0,1";
			mysql_query(sMysqlQuery);
			mysql_store_result();
			if(mysql_num_rows() != 0) {
				while(mysql_fetch_row_format(sMysqlQuery, "|")) {
				    mysql_fetch_field_row(sResult, "username");
				    mysql_fetch_field_row(sCounter, "connectcount");
				}
				mysql_free_result();

				format(sMessage, sizeof(sMessage), "RStats: The user with the most connexions is %s (%d)", sResult, strval(sCounter));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
			}
			else if(bRandom == true) {
			    randomStatsMessages();
			}
		}
		case 8: {
		    /* User with the most timeouts */
			sMysqlQuery = "SELECT u.username AS username, COUNT( d.disconnectid ) AS timeoutcount FROM rstats_disconnects d INNER JOIN rstats_connects c ON c.connectid = d.connectid INNER JOIN rstats_users u ON c.playerid = u.userid WHERE d.reason = 0 GROUP BY c.playerid ORDER BY timeoutcount DESC LIMIT 0,1";
			mysql_query(sMysqlQuery);
			mysql_store_result();
			if(mysql_num_rows() != 0) {
				while(mysql_fetch_row_format(sMysqlQuery, "|")) {
				    mysql_fetch_field_row(sResult, "username");
				    mysql_fetch_field_row(sCounter, "timeoutcount");
				}
				mysql_free_result();

				format(sMessage, sizeof(sMessage), "RStats: The user with the most timeouts is %s (%d)", sResult, strval(sCounter));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
 			}
			else if(bRandom == true) {
			    randomStatsMessages();
			}
		}
		case 9: {
		    /* User who spawned the most */
		    sMysqlQuery = "SELECT u.username AS username, COUNT(s.spawnid) AS spawncount FROM rstats_spawns s INNER JOIN rstats_users u ON s.playerid = u.userid GROUP BY s.playerid ORDER BY spawncount DESC LIMIT 0,1";
			mysql_query(sMysqlQuery);
			mysql_store_result();
			if(mysql_num_rows() != 0) {
				while(mysql_fetch_row_format(sMysqlQuery, "|")) {
				    mysql_fetch_field_row(sResult, "username");
				    mysql_fetch_field_row(sCounter, "spawncount");
				}
				mysql_free_result();

				format(sMessage, sizeof(sMessage), "RStats: The user with the most spawns is %s (%d)", sResult, strval(sCounter));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
			}
			else if(bRandom == true) {
			    randomStatsMessages();
			}
		}
		case 10: {
		    /* User who killed the most */
		    sMysqlQuery = "SELECT u.username AS username, COUNT(d.deathid) AS killcount FROM rstats_deaths d INNER JOIN rstats_users u ON d.killerid = u.userid WHERE d.killerid <> 0 GROUP BY d.killerid ORDER BY killcount DESC LIMIT 0,1";
			mysql_query(sMysqlQuery);
			mysql_store_result();
			if(mysql_num_rows() != 0) {
				while(mysql_fetch_row_format(sMysqlQuery, "|")) {
				    mysql_fetch_field_row(sResult, "username");
				    mysql_fetch_field_row(sCounter, "killcount");
				}
				mysql_free_result();

				format(sMessage, sizeof(sMessage), "RStats: The user with the most kills is %s (%d)", sResult, strval(sCounter));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
			}
			else if(bRandom == true) {
			    randomStatsMessages();
			}
		}
		case 11: {
		    /* User who died the most */
		    sMysqlQuery = "SELECT u.username AS username, COUNT(d.deathid) AS deathcount FROM rstats_deaths d INNER JOIN rstats_users u ON d.victimid = u.userid GROUP BY d.victimid ORDER BY deathcount DESC LIMIT 0,1";
			mysql_query(sMysqlQuery);
			mysql_store_result();
			if(mysql_num_rows() != 0) {
				while(mysql_fetch_row_format(sMysqlQuery, "|")) {
				    mysql_fetch_field_row(sResult, "username");
				    mysql_fetch_field_row(sCounter, "deathcount");
				}
				mysql_free_result();

				format(sMessage, sizeof(sMessage), "RStats: The user with the most deaths is %s (%d)", sResult, strval(sCounter));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
            }
			else if(bRandom == true) {
			    randomStatsMessages();
			}
		}
		case 12: {
		    /* User who used the most cars */
		    sMysqlQuery = "SELECT u.username AS username, COUNT(v.vehusageid) AS vehusagecount FROM rstats_vehicleusage v INNER JOIN rstats_users u ON v.playerid = u.userid GROUP BY v.playerid ORDER BY vehusagecount DESC LIMIT 0,1";
			mysql_query(sMysqlQuery);
			mysql_store_result();
			if(mysql_num_rows() != 0) {
				while(mysql_fetch_row_format(sMysqlQuery, "|")) {
				    mysql_fetch_field_row(sResult, "username");
				    mysql_fetch_field_row(sCounter, "vehusagecount");
				}
				mysql_free_result();

				format(sMessage, sizeof(sMessage), "RStats: The user who used the most vehicles is %s (%d)", sResult, strval(sCounter));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
            }
			else if(bRandom == true) {
			    randomStatsMessages();
			}
		}
		case 13: {
		    /* User who sent the most chat messages */
		    sMysqlQuery = "SELECT u.username AS username, COUNT(c.chatid) AS chatmsgcount FROM rstats_chatmessages c INNER JOIN rstats_users u ON c.playerid = u.userid GROUP BY c.playerid ORDER BY chatmsgcount DESC LIMIT 0,1";
			mysql_query(sMysqlQuery);
			mysql_store_result();
			if(mysql_num_rows() != 0) {
				while(mysql_fetch_row_format(sMysqlQuery, "|")) {
				    mysql_fetch_field_row(sResult, "username");
				    mysql_fetch_field_row(sCounter, "chatmsgcount");
				}
				mysql_free_result();

				format(sMessage, sizeof(sMessage), "RStats: The user who sent the most chat messages is %s (%d)", sResult, strval(sCounter));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
            }
			else if(bRandom == true) {
			    randomStatsMessages();
			}
		}
		case 14: {
		    /* User who wrote the most commands */
		    sMysqlQuery = "SELECT u.username AS username, COUNT(c.commandid) AS commandcount FROM rstats_commands c INNER JOIN rstats_users u ON c.playerid = u.userid GROUP BY c.playerid ORDER BY commandcount DESC LIMIT 0,1";
			mysql_query(sMysqlQuery);
			mysql_store_result();
			if(mysql_num_rows() != 0) {
				while(mysql_fetch_row_format(sMysqlQuery, "|")) {
				    mysql_fetch_field_row(sResult, "username");
				    mysql_fetch_field_row(sCounter, "commandcount");
				}
				mysql_free_result();

				format(sMessage, sizeof(sMessage), "RStats: The user who send the most commands is %s (%d)", sResult, strval(sCounter));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
            }
			else if(bRandom == true) {
			    randomStatsMessages();
			}
		}
		case 15: {
		    /* User who picked the most pickups */
		    sMysqlQuery = "SELECT u.username AS username, COUNT(p.pickedid) AS pickedcount FROM rstats_pickedpickups p INNER JOIN rstats_users u ON p.playerid = u.userid GROUP BY p.playerid ORDER BY pickedcount DESC LIMIT 0,1";
			mysql_query(sMysqlQuery);
			mysql_store_result();
			if(mysql_num_rows() != 0) {
				while(mysql_fetch_row_format(sMysqlQuery, "|")) {
				    mysql_fetch_field_row(sResult, "username");
				    mysql_fetch_field_row(sCounter, "commandcount");
				}
				mysql_free_result();

				format(sMessage, sizeof(sMessage), "RStats: The user who picked the most pickups is %s (%d)", sResult, strval(sCounter));
		        SendClientMessageToAll(COLOR_LIGHTBLUE, sMessage);
            }
			else if(bRandom == true) {
			    randomStatsMessages();
			}
		}
		/* Coming in a later version */
		case 16: {
		    /* Day with the most connects */
		}
		case 17: {
		    /* Day with the most kick/bans */
		}
		case 18: {
			/* Day with the most timeouts */
		}
		case 19: {
		    /* Day with the most spawns */
		}
		case 20: {
		    /* Day with the most deaths */
		}
		case 21: {
		    /* Day with the most cars used */
		}
		case 22: {
		    /* Day with the most sent messages */
		}
		case 23: {
		    /* Day with the most commands sent */
		}
		default: {
		    randomStatsMessages();
		}
	}
	return true;
}

/*############################################################################*/

forward randomStatsMessages();
public randomStatsMessages() {
    statsMessages(random(15), true);
}

/*############################################################################*/

strtok (const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

/*############################################################################*/

forward userExists(playerid);
public userExists(playerid) {
    new
	    sPlayerName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, sPlayerName, sizeof(sPlayerName));

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT userid FROM rstats_users WHERE username = '%s'", sPlayerName);
	mysql_query(sMysqlQuery);
	mysql_store_result();

	if(mysql_num_rows() == 0) {
	    mysql_free_result();
		return false;
	}
	else {
	    mysql_free_result();
		return true;
	}
}

/*############################################################################*/

forward getUserID(playerid);
public getUserID(playerid) {
	new
	    sPlayerName[MAX_PLAYER_NAME],
		iUser;

	GetPlayerName(playerid, sPlayerName, sizeof(sPlayerName));

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT userid FROM rstats_users WHERE username = '%s'", sPlayerName);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iUser = mysql_fetch_int();
	mysql_free_result();

	return iUser;
}

/*############################################################################*/

forward getKillCount();
public getKillCount() {
	new
		iKillCount;

	mysql_query("SELECT COUNT(*) AS killcount FROM rstats_deaths WHERE killerid <> 0");
	mysql_store_result();
	iKillCount = mysql_fetch_int();
	mysql_free_result();

	return iKillCount;
}

/*############################################################################*/

forward getDeathCount();
public getDeathCount() {
	new
		iDeathCount;

	mysql_query("SELECT COUNT(*) AS deathcount FROM rstats_deaths");
	mysql_store_result();
	iDeathCount = mysql_fetch_int();
	mysql_free_result();

	return iDeathCount;
}

/*############################################################################*/

forward getConnectCount();
public getConnectCount() {
	new
		iConnectCount;

	mysql_query("SELECT COUNT(*) AS connectcount FROM rstats_connects");
	mysql_store_result();
	iConnectCount = mysql_fetch_int();
	mysql_free_result();

	return iConnectCount;
}

/*############################################################################*/

forward getLeaveCount();
public getLeaveCount() {
	new
		iDisconnectCount;

	mysql_query("SELECT COUNT(*) AS disconnectcount FROM rstats_disconnects WHERE reason = 1");
	mysql_store_result();
	iDisconnectCount = mysql_fetch_int();
	mysql_free_result();

	return iDisconnectCount;
}

/*############################################################################*/

forward getTimeoutCount();
public getTimeoutCount() {
	new
		iDisconnectCount;

	mysql_query("SELECT COUNT(*) AS disconnectcount FROM rstats_disconnects WHERE reason = 0");
	mysql_store_result();
	iDisconnectCount = mysql_fetch_int();
	mysql_free_result();

	return iDisconnectCount;
}

/*############################################################################*/

forward getKickCount();
public getKickCount() {
	new
		iDisconnectCount;

	mysql_query("SELECT COUNT(*) AS disconnectcount FROM rstats_disconnects WHERE reason = 2");
	mysql_store_result();
	iDisconnectCount = mysql_fetch_int();
	mysql_free_result();

	return iDisconnectCount;
}

/*############################################################################*/

forward getSpawnCount();
public getSpawnCount() {
	new
		iSpawnCount;

	mysql_query("SELECT COUNT(*) AS spawncount FROM rstats_spawns");
	mysql_store_result();
	iSpawnCount = mysql_fetch_int();
	mysql_free_result();

	return iSpawnCount;
}

/*############################################################################*/

forward getMessageCount();
public getMessageCount() {
	new
		iMessageCount;

	mysql_query("SELECT COUNT(*) AS messagecount FROM rstats_chatmessages");
	mysql_store_result();
	iMessageCount = mysql_fetch_int();
	mysql_free_result();

	return iMessageCount;
}

/*############################################################################*/

forward getCommandCount();
public getCommandCount() {
	new
		iCommandCount;

	mysql_query("SELECT COUNT(*) AS commandcount FROM rstats_commands");
	mysql_store_result();
	iCommandCount = mysql_fetch_int();
	mysql_free_result();

	return iCommandCount;
}

/*############################################################################*/

forward getVehUsageCount();
public getVehUsageCount() {
	new
		iVehUsageCount;

	mysql_query("SELECT COUNT(*) AS vehusagecount FROM rstats_vehicleusage");
	mysql_store_result();
	iVehUsageCount = mysql_fetch_int();
	mysql_free_result();

	return iVehUsageCount;
}

/*############################################################################*/

forward getVehModelUsageCount(modelid);
public getVehModelUsageCount(modelid) {
	new
		iVehUsageCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS vehusagecount FROM rstats_vehicleusage WHERE modelid = %d", modelid);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iVehUsageCount = mysql_fetch_int();
	mysql_free_result();

	return iVehUsageCount;
}

/*############################################################################*/

forward getPickedPickupsCount();
public getPickedPickupsCount() {
	new
		iPickedPickupsCount;

	mysql_query("SELECT COUNT(*) AS pkdpickups FROM rstats_pickedpickups");
	mysql_store_result();
	iPickedPickupsCount = mysql_fetch_int();
	mysql_free_result();

	return iPickedPickupsCount;
}

/*############################################################################*/

forward getMoneyCount();
public getMoneyCount() {
	new
		iMoneyCount;

	mysql_query("SELECT SUM(money) AS moneycount FROM rstats_users");
	mysql_store_result();
	iMoneyCount = mysql_fetch_int();
	mysql_free_result();

	return iMoneyCount;
}

/*############################################################################*/

forward getScoreCount();
public getScoreCount() {
	new
		iScoreCount;

	mysql_query("SELECT SUM(score) AS scorecount FROM rstats_users");
	mysql_store_result();
	iScoreCount = mysql_fetch_int();
	mysql_free_result();

	return iScoreCount;
}

/*############################################################################*/

forward getUserCount();
public getUserCount() {
    new
		iUserCount;

	mysql_query("SELECT COUNT(*) AS usercount FROM rstats_users");
	mysql_store_result();
	iUserCount = mysql_fetch_int();
	mysql_free_result();

	return iUserCount;
}

/*############################################################################*/

forward getMostUsedVehicle();
public getMostUsedVehicle() {
    new
		sModelid[5];

	mysql_query("SELECT modelid, COUNT(*) AS modelcount FROM rstats_vehicleusage GROUP BY modelid ORDER BY modelcount DESC LIMIT 0,1");
	mysql_store_result();
	if(mysql_num_rows() != 0) {
		while(mysql_fetch_row_format(sMysqlQuery, "|")) {
		    mysql_fetch_field_row(sModelid, "modelid");
		}
	}
	else {
	    sModelid = UNKNOWN_VEHICLE;
	}
	
	mysql_free_result();

	return strval(sModelid);
}

/*############################################################################*/

forward getMostUsedWeapon();
public getMostUsedWeapon() {
    new
		sWeaponid[5];

	mysql_query("SELECT reason, COUNT(*) AS reasoncount FROM rstats_deaths WHERE killerid <> 0 GROUP BY reason ORDER BY reasoncount DESC LIMIT 0,1");
	mysql_store_result();
	if(mysql_num_rows() != 0) {
		while(mysql_fetch_row_format(sMysqlQuery, "|")) {
		    mysql_fetch_field_row(sWeaponid, "reason");
		}
	}
	else {
	    sWeaponid = UNKNOWN_WEAPON;
	}
	    
	mysql_free_result();

	return strval(sWeaponid);
}

/*############################################################################*/

forward getMainDeathCause();
public getMainDeathCause() {
    new
		sReasonid[5];

	mysql_query("SELECT reason, COUNT(*) AS reasoncount FROM rstats_deaths GROUP BY reason ORDER BY reasoncount DESC LIMIT 0,1");
	mysql_store_result();
	if(mysql_num_rows() != 0) {
		while(mysql_fetch_row_format(sMysqlQuery, "|")) {
		    mysql_fetch_field_row(sReasonid, "reason");
		}
	}
	else {
	    sReasonid = UNKNOWN_WEAPON;
	}

	mysql_free_result();

	return strval(sReasonid);
}

/*############################################################################*/

forward getPlayerKillCount(playerid);
public getPlayerKillCount(playerid) {
	new
		iKillCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS killcount FROM rstats_deaths WHERE killerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iKillCount = mysql_fetch_int();
	mysql_free_result();

	return iKillCount;
}

/*############################################################################*/

forward getPlayerDeathCount(playerid);
public getPlayerDeathCount(playerid) {
	new
		iDeathCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS deathcount FROM rstats_deaths WHERE victimid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iDeathCount = mysql_fetch_int();
	mysql_free_result();

	return iDeathCount;
}

/*############################################################################*/

forward Float:getPlayerKDRatio(playerid);
public Float:getPlayerKDRatio(playerid) {
	new
		iKillCount = getPlayerKillCount(playerid),
		iDeathCount = getPlayerDeathCount(playerid),
		Float:fRatio = 0.0;

	if(iKillCount == 0 || iDeathCount == 0) {
	    fRatio = 0;
	}
	else {
	    fRatio = iKillCount/iDeathCount;
	}

	return fRatio;
}

/*############################################################################*/

forward getPlayerConnectCount(playerid);
public getPlayerConnectCount(playerid) {
	new
		iConnectCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS connectcount FROM rstats_connects WHERE playerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iConnectCount = mysql_fetch_int();
	mysql_free_result();

	return iConnectCount;
}

/*############################################################################*/

forward getPlayerLeaveCount(playerid);
public getPlayerLeaveCount(playerid) {
	new
		iDisconnectCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(d.disconnectid) AS disconnectcount FROM rstats_disconnects d INNER JOIN rstats_connects c ON c.connectid = d.connectid WHERE d.reason = 1 AND c.playerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iDisconnectCount = mysql_fetch_int();
	mysql_free_result();

	return iDisconnectCount;
}

/*############################################################################*/

forward getPlayerTimeoutCount(playerid);
public getPlayerTimeoutCount(playerid) {
	new
		iDisconnectCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(d.disconnectid) AS disconnectcount FROM rstats_disconnects d INNER JOIN rstats_connects c ON c.connectid = d.connectid WHERE d.reason = 0 AND c.playerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iDisconnectCount = mysql_fetch_int();
	mysql_free_result();

	return iDisconnectCount;
}

/*############################################################################*/

forward getPlayerKickCount(playerid);
public getPlayerKickCount(playerid) {
	new
		iDisconnectCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(d.disconnectid) AS disconnectcount FROM rstats_disconnects d INNER JOIN rstats_connects c ON c.connectid = d.connectid WHERE d.reason = 2 AND c.playerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iDisconnectCount = mysql_fetch_int();
	mysql_free_result();

	return iDisconnectCount;
}

/*############################################################################*/

forward getPlayerSpawnCount(playerid);
public getPlayerSpawnCount(playerid) {
	new
		iSpawnCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS spawncount FROM rstats_spawns WHERE playerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iSpawnCount = mysql_fetch_int();
	mysql_free_result();

	return iSpawnCount;
}

/*############################################################################*/

forward getPlayerMessageCount(playerid);
public getPlayerMessageCount(playerid) {
	new
		iMessageCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS messagecount FROM rstats_chatmessages WHERE playerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iMessageCount = mysql_fetch_int();
	mysql_free_result();

	return iMessageCount;
}

/*############################################################################*/

forward getPlayerCommandCount(playerid);
public getPlayerCommandCount(playerid) {
	new
		iCommandCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS commandcount FROM rstats_commands WHERE playerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iCommandCount = mysql_fetch_int();
	mysql_free_result();

	return iCommandCount;
}

/*############################################################################*/

forward getPlayerVehUsageCount(playerid);
public getPlayerVehUsageCount(playerid) {
	new
		iVehUsageCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS vehusagecount FROM rstats_vehicleusage WHERE playerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iVehUsageCount = mysql_fetch_int();
	mysql_free_result();

	return iVehUsageCount;
}

/*############################################################################*/

forward getPlayerVehModelUsageCount(playerid, modelid);
public getPlayerVehModelUsageCount(playerid, modelid) {
	new
		iVehUsageCount;

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS vehusagecount FROM rstats_vehicleusage WHERE modelid = %d AND playerid = %d", modelid, iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iVehUsageCount = mysql_fetch_int();
	mysql_free_result();

	return iVehUsageCount;
}

/*############################################################################*/

forward getPlayerPickedPickupsCount(playerid);
public getPlayerPickedPickupsCount(playerid) {
	new
		iPickedPickupsCount;

    format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT COUNT(*) AS pkdpickups FROM rstats_pickedpickups WHERE playerid = %d", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	iPickedPickupsCount = mysql_fetch_int();
	mysql_free_result();

	return iPickedPickupsCount;
}

/*############################################################################*/

forward getPlayerMostUsedVehicle(playerid);
public getPlayerMostUsedVehicle(playerid) {
    new
		sModelid[11];

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT modelid, COUNT(*) AS modelcount FROM rstats_vehicleusage WHERE playerid = %d GROUP BY modelid ORDER BY modelcount DESC LIMIT 0,1", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	if(mysql_num_rows() != 0) {
		while(mysql_fetch_row_format(sMysqlQuery, "|")) {
		    mysql_fetch_field_row(sModelid, "modelid");
		}
	}
	else {
	    sModelid = UNKNOWN_VEHICLE;
	}
	mysql_free_result();

	return strval(sModelid);
}

/*############################################################################*/

forward getPlayerMostUsedWeapon(playerid);
public getPlayerMostUsedWeapon(playerid) {
    new
		sWeaponid[5];

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT reason, COUNT(*) AS reasoncount FROM rstats_deaths WHERE killerid = %d GROUP BY reason ORDER BY reasoncount DESC LIMIT 0,1", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	if(mysql_num_rows() != 0) {
		while(mysql_fetch_row_format(sMysqlQuery, "|")) {
		    mysql_fetch_field_row(sWeaponid, "reason");
		}
	}
	else {
	    sWeaponid = UNKNOWN_WEAPON;
	}
	
	mysql_free_result();

	return strval(sWeaponid);
}

/*############################################################################*/

forward getPlayerMainDeathCause(playerid);
public getPlayerMainDeathCause(playerid) {
    new
		sReasonid[5];

	format(sMysqlQuery, sizeof(sMysqlQuery), "SELECT reason, COUNT(*) AS reasoncount FROM rstats_deaths WHERE victimid = %d GROUP BY reason ORDER BY reasoncount DESC LIMIT 0,1", iUserid[playerid]);
	mysql_query(sMysqlQuery);
	mysql_store_result();
	if(mysql_num_rows() != 0) {
		while(mysql_fetch_row_format(sMysqlQuery, "|")) {
		    mysql_fetch_field_row(sReasonid, "reason");
		}
	}
	else {
	    sReasonid = UNKNOWN_WEAPON;
	}

	mysql_free_result();

	return strval(sReasonid);
}

/*############################################################################*/


