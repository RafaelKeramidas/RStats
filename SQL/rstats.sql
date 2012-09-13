/* *                                                   	* *
 * Raf's Stats System - SQL Code            	          *
 * *                                                    * *
 * @Author  Rafael 'R@f' Keramidas <rafael@keramid.as>    *
 * @Date    13th September 2012                           *
 * @Version 1.0                                           *
 * @Licence GPLv3                                         *
 * *													* */

CREATE TABLE rstats_users (
	userid MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
	username VARCHAR(24) NOT NULL,
	status BOOLEAN NOT NULL,
	score INT UNSIGNED NOT NULL,
	health FLOAT UNSIGNED NOT NULL,
	armour FLOAT UNSIGNED NOT NULL,
	skin SMALLINT(5) UNSIGNED NOT NULL,
	money INT UNSIGNED NOT NULL,
	color INT UNSIGNED NOT NULL,
	wantedlevel TINYINT(3) UNSIGNED NOT NULL,
	PRIMARY KEY(userid)
) ENGINE=InnoDB;

CREATE TABLE rstats_deaths (
	deathid INT UNSIGNED NOT NULL AUTO_INCREMENT,
	victimid MEDIUMINT(8) UNSIGNED NOT NULL,
	killerid MEDIUMINT(8) UNSIGNED,
	reason TINYINT(3) UNSIGNED NOT NULL,
	deathtime DATETIME NOT NULL,
	PRIMARY KEY(deathid),
	INDEX(killerid),
	INDEX(victimid),
	FOREIGN KEY(victimid) REFERENCES rstats_users(userid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rstats_connects (
	connectid INT UNSIGNED NOT NULL AUTO_INCREMENT,
	playerid MEDIUMINT(8) UNSIGNED NOT NULL,
	connecttime DATETIME NOT NULL,
	ipaddress VARCHAR(16),
	PRIMARY KEY(connectid),
	INDEX(playerid),
	FOREIGN KEY(playerid) REFERENCES rstats_users(userid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rstats_disconnects (
	disconnectid INT UNSIGNED NOT NULL AUTO_INCREMENT,
	connectid INT UNSIGNED NOT NULL,
	disconnecttime DATETIME NOT NULL,
	reason TINYINT(3) UNSIGNED NOT NULL,
	PRIMARY KEY(disconnectid),
	INDEX(connectid),
	FOREIGN KEY(connectid) REFERENCES rstats_connects(connectid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rstats_spawns (
	spawnid INT UNSIGNED NOT NULL AUTO_INCREMENT,
	playerid MEDIUMINT(8) UNSIGNED NOT NULL,
	spawntime DATETIME NOT NULL,
	PRIMARY KEY(spawnid),
	INDEX(playerid),
	FOREIGN KEY(playerid) REFERENCES rstats_users(userid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rstats_chatmessages (
	chatid INT UNSIGNED NOT NULL AUTO_INCREMENT,
	playerid MEDIUMINT(8) UNSIGNED NOT NULL,
	chatmsg VARCHAR(128) NOT NULL,
	messagetime DATETIME NOT NULL,
	PRIMARY KEY(chatid),
	INDEX(playerid),
	FOREIGN KEY(playerid) REFERENCES rstats_users(userid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rstats_commands (
	commandid INT UNSIGNED NOT NULL AUTO_INCREMENT,
	playerid MEDIUMINT(8) UNSIGNED NOT NULL,
	commandtext VARCHAR(128) NOT NULL,
	commandtime DATETIME NOT NULL,
	PRIMARY KEY(commandid),
	INDEX(playerid),
	FOREIGN KEY(playerid) REFERENCES rstats_users(userid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rstats_vehicleusage (
	vehusageid INT UNSIGNED NOT NULL AUTO_INCREMENT,
	playerid MEDIUMINT(8) UNSIGNED NOT NULL,
	modelid SMALLINT(5) UNSIGNED NOT NULL,
	vehentertime DATETIME NOT NULL,
	PRIMARY KEY(vehusageid),
	INDEX(playerid),
	FOREIGN KEY(playerid) REFERENCES rstats_users(userid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE rstats_pickedpickups (
	pickedid INT UNSIGNED NOT NULL AUTO_INCREMENT,
	playerid MEDIUMINT(8) UNSIGNED NOT NULL,
	pickupid SMALLINT(5) UNSIGNED NOT NULL,
	pickedtime DATETIME NOT NULL,
	PRIMARY KEY(pickedid),
	INDEX(playerid),
	FOREIGN KEY(playerid) REFERENCES rstats_users(userid) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
