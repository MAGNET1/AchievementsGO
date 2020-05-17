public void OnSQLConnect(Database db, const char[] error, any data) {
    if (db == INVALID_HANDLE) {
        LogError("Database failure: %s", error);
        SetFailState("Databases won't work! Plugin turns off...");
        return;
    }

    DB = db;

    char buffer[32];

    SQL_GetDriverIdent(SQL_ReadDriver(DB), buffer, sizeof(buffer));
    isMysql = StrEqual(buffer, "mysql", false);

    Transaction tableTransaction = new Transaction();

    if (isMysql) {
        tableTransaction.AddQuery("CREATE TABLE IF NOT EXISTS `Achievements` (`ID`	INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT, `Name` VARCHAR(256) NOT NULL, `Description` VARCHAR(256) NOT NULL, `Category` VARCHAR(256), `Value`	INTEGER(8) NOT NULL);");
    } else {
        tableTransaction.AddQuery("CREATE TABLE IF NOT EXISTS `Achievements` (`ID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `Name` VARCHAR(256) NOT NULL, `Description` VARCHAR(256) NOT NULL, `Category` VARCHAR(256), `Value`	INTEGER(8) NOT NULL);");
    }

    tableTransaction.AddQuery("CREATE TABLE IF NOT EXISTS `Players` (`SteamID` INTEGER NOT NULL, `AchievementID` INTEGER NOT NULL, `Progress` INTEGER NOT NULL, `Finished` INTEGER NOT NULL, `LastConnected` INTEGER NOT NULL, UNIQUE(`SteamID`,`AchievementID`));");

    SQL_ExecuteTransaction(DB, tableTransaction, SQL_CreateTableOnSuccess, SQL_CreateTableOnFailure, _, DBPrio_High);
}

public void SQL_CreateTableOnSuccess(Database db, any data, int numQueries, Handle[] results, any[] queryData) {
    IsConnectionEstablished = true;
    SendForwardOnRegisterAchievements();
    DeleteOldRecords();
}

public void SQL_CreateTableOnFailure(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
    IsConnectionEstablished = false;
    LogError("Could not create tables! Error: %s", error);
    SetFailState("SQL tables hasn't been created! Plugin turns off...");
}

void DeleteOldRecords() {
    if (cv_databaseTimeKick.IntValue <= 0)
        return;

    int deleteBefore = GetTime() - (cv_databaseTimeKick.IntValue*86400);

    char buffer[512];
    Format(buffer, sizeof(buffer), "DELETE FROM `Players` WHERE LastConnected < %d", deleteBefore);
    DB.Query(DeleteInactive_Query, buffer, _, DBPrio_High);
}

public void DeleteInactive_Query(Database db, DBResultSet results, const char[] error, any data) {
	if (db == null || results == null) {
		LogError("Could not delete inactive players' rows! Error: %s", error);
		return;
	}

	if (results.AffectedRows > 0)
		LogMessage("Deleted %d rows due to players' inactivity", results.AffectedRows);
}