-- MySQL dump 10.13  Distrib 5.7.38, for Linux (x86_64)
--
-- Host: localhost    Database: vultix_server
-- ------------------------------------------------------
-- Server version	5.7.38-0ubuntu0.18.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `clanPlayers`
--

DROP TABLE IF EXISTS `clanPlayers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clanPlayers` (
  `memberId` int(11) NOT NULL,
  `clanId` int(11) NOT NULL,
  `role` varchar(16) NOT NULL,
  `isCurrent` tinyint(1) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  `actionById` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clanPlayers`
--

LOCK TABLES `clanPlayers` WRITE;
/*!40000 ALTER TABLE `clanPlayers` DISABLE KEYS */;
/*!40000 ALTER TABLE `clanPlayers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clans`
--

DROP TABLE IF EXISTS `clans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clans` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `tag` varchar(255) NOT NULL,
  `description` varchar(1000) NOT NULL,
  `color` varchar(7) NOT NULL,
  `creatorId` int(11) NOT NULL,
  `win` int(11) NOT NULL,
  `lose` int(11) NOT NULL,
  `draw` int(11) NOT NULL,
  `cwPlayed` int(11) NOT NULL,
  `numberOfPlayers` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clans`
--

LOCK TABLES `clans` WRITE;
/*!40000 ALTER TABLE `clans` DISABLE KEYS */;
/*!40000 ALTER TABLE `clans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clanwarRoundKills`
--

DROP TABLE IF EXISTS `clanwarRoundKills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clanwarRoundKills` (
  `clanwarId` int(11) NOT NULL,
  `roundNumber` tinyint(4) NOT NULL,
  `playerId` int(11) NOT NULL,
  `kills` int(11) NOT NULL,
  `deaths` int(11) NOT NULL,
  `assists` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clanwarRoundKills`
--

LOCK TABLES `clanwarRoundKills` WRITE;
/*!40000 ALTER TABLE `clanwarRoundKills` DISABLE KEYS */;
/*!40000 ALTER TABLE `clanwarRoundKills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clanwarRoundWins`
--

DROP TABLE IF EXISTS `clanwarRoundWins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clanwarRoundWins` (
  `clanwarId` int(11) NOT NULL,
  `roundNumber` int(11) NOT NULL,
  `winnerId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clanwarRoundWins`
--

LOCK TABLES `clanwarRoundWins` WRITE;
/*!40000 ALTER TABLE `clanwarRoundWins` DISABLE KEYS */;
/*!40000 ALTER TABLE `clanwarRoundWins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clanwars`
--

DROP TABLE IF EXISTS `clanwars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clanwars` (
  `clanwarId` int(11) NOT NULL,
  `clan1Id` int(11) NOT NULL,
  `clan2Id` int(11) NOT NULL,
  `score1` tinyint(4) NOT NULL,
  `score2` tinyint(4) NOT NULL,
  `winnerId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clanwars`
--

LOCK TABLES `clanwars` WRITE;
/*!40000 ALTER TABLE `clanwars` DISABLE KEYS */;
/*!40000 ALTER TABLE `clanwars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maps`
--

DROP TABLE IF EXISTS `maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `maps` (
  `id` int(11) NOT NULL,
  `resName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mapName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mapAuthor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mapTag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mapTester` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `mapUploader` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `testDate` int(11) NOT NULL,
  `comment` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maps`
--

LOCK TABLES `maps` WRITE;
/*!40000 ALTER TABLE `maps` DISABLE KEYS */;
INSERT INTO `maps` VALUES (1,'DD_Cross_ZY','[DD] Cross ZY (CW)','Zaya, Shark, Frost, pax','[DD]','true','EYzqmt','APOC.ZeYaD22','0',1643334739,'Good map.');
/*!40000 ALTER TABLE `maps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `players`
--

DROP TABLE IF EXISTS `players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `players` (
  `memberId` int(11) NOT NULL,
  `nickname` varchar(22) NOT NULL,
  `serial` varchar(32) NOT NULL,
  `lastSeen` int(10) unsigned NOT NULL,
  `isOnline` tinyint(1) NOT NULL,
  `playtime` int(10) unsigned NOT NULL,
  `playtimeFriendly` varchar(40) NOT NULL,
  `kills` int(10) unsigned NOT NULL,
  `deaths` int(10) unsigned NOT NULL,
  `assists` int(10) unsigned NOT NULL,
  `totalCws` int(10) unsigned NOT NULL,
  `wonCws` int(10) unsigned NOT NULL,
  `lostCws` int(10) unsigned NOT NULL,
  `drawCws` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `players`
--

LOCK TABLES `players` WRITE;
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
/*!40000 ALTER TABLE `players` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `server_players`
--

DROP TABLE IF EXISTS `server_players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `server_players` (
  `idign` int(11) DEFAULT '0',
  `nameinserver` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `serial` varchar(35) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IP` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logged` varchar(6) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registerDate` int(11) DEFAULT '0',
  `lastOnline` int(11) DEFAULT '0',
  `timesJoined` int(11) DEFAULT '0',
  `country` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `likedMaps` text COLLATE utf8mb4_unicode_ci,
  `favMaps` text COLLATE utf8mb4_unicode_ci,
  `training_maplists` text COLLATE utf8mb4_unicode_ci,
  `ignoredPlayers` text COLLATE utf8mb4_unicode_ci,
  `maptesting_month` int(11) DEFAULT '0',
  `playtime` int(11) DEFAULT '0',
  `deathmatch_points` int(11) DEFAULT '0',
  `dd_points` int(11) DEFAULT '0',
  `race_points` int(11) DEFAULT '0',
  `hunter_points` int(11) DEFAULT '0',
  `shooter_points` int(11) DEFAULT '0',
  `catch_points` int(11) DEFAULT '0',
  `deathmatch_rank` int(11) DEFAULT '0',
  `dd_rank` int(11) DEFAULT '0',
  `race_rank` int(11) DEFAULT '0',
  `hunter_rank` int(11) DEFAULT '0',
  `shooter_rank` int(11) DEFAULT '0',
  `catch_rank` int(11) DEFAULT '0',
  `login_day` int(11) DEFAULT '0',
  `login_streak` int(11) DEFAULT '0',
  `global_points` int(11) DEFAULT '0',
  `daily_points_day` int(11) DEFAULT '0',
  `daily_busted_points` int(11) DEFAULT '0',
  `deathmatch_mapsPlayed` int(11) DEFAULT '0',
  `dd_mapsPlayed` int(11) DEFAULT '0',
  `race_mapsPlayed` int(11) DEFAULT '0',
  `hunter_mapsPlayed` int(11) DEFAULT '0',
  `shooter_mapsPlayed` int(11) DEFAULT '0',
  `catch_mapsPlayed` int(11) DEFAULT '0',
  `sprint_points` int(11) DEFAULT '0',
  `gladiator_mapsPlayed` int(11) DEFAULT '0',
  `busted_mapsPlayed` int(11) DEFAULT '0',
  `os_mapsPlayed` int(11) DEFAULT '0',
  `shooter_level` int(11) DEFAULT '0',
  `accName` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `money` int(11) DEFAULT '0',
  `target_kills` int(11) DEFAULT '0',
  `deathmatch_hunterKills` int(11) DEFAULT '0',
  `race_finishedFirst` int(11) DEFAULT '0',
  `free_maps` int(11) DEFAULT '0',
  `general_moneySpent` int(11) DEFAULT '0',
  `general_mapsBought` int(11) DEFAULT '0',
  `deathmatch_mapsWon` int(11) DEFAULT '0',
  `deathmatch_highestStreak` int(11) DEFAULT '0',
  `deathmatch_mapsFinished` int(11) DEFAULT '0',
  `os_mapsWon` int(11) DEFAULT '0',
  `os_highestStreak` int(11) DEFAULT '0',
  `os_deaths` int(11) DEFAULT '0',
  `os_kills` int(11) DEFAULT '0',
  `os_mapsFinished` int(11) DEFAULT '0',
  `dd_mapsWon` int(11) DEFAULT '0',
  `dd_highestStreak` int(11) DEFAULT '0',
  `dd_deaths` int(11) DEFAULT '0',
  `dd_kills` int(11) DEFAULT '0',
  `dd_mapsFinished` int(11) DEFAULT '0',
  `race_mapsWon` int(11) DEFAULT '0',
  `race_highestStreak` int(11) DEFAULT '0',
  `race_deaths` int(11) DEFAULT '0',
  `race_kills` int(11) DEFAULT '0',
  `race_mapsFinished` int(11) DEFAULT '0',
  `hunter_mapsWon` int(11) DEFAULT '0',
  `hunter_highestStreak` int(11) DEFAULT '0',
  `hunter_deaths` int(11) DEFAULT '0',
  `hunter_kills` int(11) DEFAULT '0',
  `hunter_mapsFinished` int(11) DEFAULT '0',
  `shooter_mapsWon` int(11) DEFAULT '0',
  `shooter_highestStreak` int(11) DEFAULT '0',
  `shooter_deaths` int(11) DEFAULT '0',
  `shooter_kills` int(11) DEFAULT '0',
  `shooter_mapsFinished` int(11) DEFAULT '0',
  `catch_mapsWon` int(11) DEFAULT '0',
  `catch_highestStreak` int(11) DEFAULT '0',
  `catch_deaths` int(11) DEFAULT '0',
  `catch_kills` int(11) DEFAULT '0',
  `catch_mapsFinished` int(11) DEFAULT '0',
  `sprint_mapsWon` int(11) DEFAULT '0',
  `sprint_highestStreak` int(11) DEFAULT '0',
  `sprint_deaths` int(11) DEFAULT '0',
  `sprint_kills` int(11) DEFAULT '0',
  `sprint_mapsFinished` int(11) DEFAULT '0',
  `gladiator_mapsWon` int(11) DEFAULT '0',
  `gladiator_highestStreak` int(11) DEFAULT '0',
  `gladiator_deaths` int(11) DEFAULT '0',
  `gladiator_kills` int(11) DEFAULT '0',
  `gladiator_mapsFinished` int(11) DEFAULT '0',
  `busted_mapsWon` int(11) DEFAULT '0',
  `busted_highestStreak` int(11) DEFAULT '0',
  `busted_deaths` int(11) DEFAULT '0',
  `busted_kills` int(11) DEFAULT '0',
  `busted_mapsFinished` int(11) DEFAULT '0',
  `sprint_rank` int(11) DEFAULT '0',
  `gladiator_rank` int(11) DEFAULT '0',
  `busted_rank` int(11) DEFAULT '0',
  `os_rank` int(11) DEFAULT '0',
  `daily_deathmatch_points` int(11) DEFAULT '0',
  `daily_os_points` int(11) DEFAULT '0',
  `daily_dd_points` int(11) DEFAULT '0',
  `daily_race_points` int(11) DEFAULT '0',
  `daily_hunter_points` int(11) DEFAULT '0',
  `daily_shooter_points` int(11) DEFAULT '0',
  `daily_catch_points` int(11) DEFAULT '0',
  `daily_sprint_points` int(11) DEFAULT '0',
  `daily_gladiator_points` int(11) DEFAULT '0',
  `os_points` int(11) DEFAULT '0',
  `gladiator_points` int(11) DEFAULT '0',
  `busted_points` int(11) DEFAULT '0',
  `language` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sprint_mapsPlayed` int(11) DEFAULT '0',
  `global_rank` int(11) DEFAULT '0',
  `deathmatch_toptimesCreated` int(11) DEFAULT '0',
  `deathmatch_t1Created` int(11) DEFAULT '0',
  `deathmatch_t1Beaten` int(11) DEFAULT '0',
  `specDMWINRATIO` int(11) DEFAULT '0',
  `specDMPASSRATE` int(11) DEFAULT '0',
  `training_mapsTrained` int(11) DEFAULT '0',
  `training_mapsPassed` int(11) DEFAULT '0',
  `training_toptimesCreated` int(11) DEFAULT '0',
  `hunter_rocketsFired` int(11) DEFAULT '0',
  `shooter_rocketsFired` int(11) DEFAULT '0',
  `admin_mutes` int(11) DEFAULT '0',
  `admin_kicks` int(11) DEFAULT '0',
  `admin_bans` int(11) DEFAULT '0',
  `specRACEFINISHFIRSTRATIO` int(11) DEFAULT '0',
  `race_toptimesCreated` int(11) DEFAULT '0',
  `race_t1Created` int(11) DEFAULT '0',
  `race_t1Beaten` int(11) DEFAULT '0',
  `deathmatch_deaths` int(11) DEFAULT '0',
  `specHUNTERKDR` int(11) DEFAULT '0',
  `specDDKDR` int(11) DEFAULT '0',
  `specSHOOTERKDR` int(11) DEFAULT '0',
  `deathmatch_hunterDeaths` int(11) DEFAULT '0',
  `admin_mapsTested` int(11) DEFAULT '0',
  `admin_mapsAccepted` int(11) DEFAULT '0',
  `admin_mapsDeclined` int(11) DEFAULT '0',
  `maptesting_tested_month` int(11) DEFAULT '0',
  `admin_mapsMoved` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `server_players`
--

LOCK TABLES `server_players` WRITE;
/*!40000 ALTER TABLE `server_players` DISABLE KEYS */;
/*!40000 ALTER TABLE `server_players` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-05-05 23:00:28
