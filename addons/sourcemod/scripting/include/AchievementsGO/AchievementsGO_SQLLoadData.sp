// @@ Loading Achievement ID and inserting into SQL if doesn't exist

void SQL_LoadAchievement(DataPack NewAchievementData) // AchievementsGO_Natives.sp
{
    // LogMessage("Load attempt...");
    char Name[ACHIEVEMENT_MAX_NAME_LENGTH];

    NewAchievementData.Reset();
    NewAchievementData.ReadCell(); // first position in the DataPack is a plugin handle - we don't need it for now...
    NewAchievementData.ReadFunction(); // second position in the DataPack is a function callback - we don't need it for now...
    NewAchievementData.ReadCell(); // third position in the DataPack is a temporary id - we don't need it for now...
    NewAchievementData.ReadString(Name, ACHIEVEMENT_MAX_NAME_LENGTH);

    char buffer[256];
    Format(buffer, sizeof(buffer), "SELECT `ID` FROM `Achievements` WHERE `Name`='%s'", Name);
    DB.Query(LoadAchievementIdResult, buffer, NewAchievementData, DBPrio_High);
}

public void LoadAchievementIdResult(Database db, DBResultSet results, const char[] error, DataPack NewAchievementData) {
    if (db == null || results == null) {
        PrintToServer("error (AchievementsGO)! %s", error);
        LogError("Could not retrieve Achievement ID from database! Error: %s", error);
        return;
    }

    // if no rows, we're dealing with new achievement. Hence, it needs to be added to the database
    if (results.RowCount == 0) {
        InsertNewAchievement(NewAchievementData);
        return;
    }

    int IdOfNewAchievement;

    while (results.FetchRow()) {
        IdOfNewAchievement = results.FetchInt(0);
    }

    // LogMessage("Loaded! ID: %d", IdOfNewAchievement);

    if (theBiggestAchievementID < IdOfNewAchievement)
        theBiggestAchievementID = IdOfNewAchievement;

    AddAchievementToArrays(IdOfNewAchievement, NewAchievementData);

    NewAchievementData.Reset();
    Handle pluginID = NewAchievementData.ReadCell();

    Function functionCallback = NewAchievementData.ReadFunction();
    int temporaryID = NewAchievementData.ReadCell();

    Call_StartFunction(pluginID, functionCallback);
    Call_PushCell(IdOfNewAchievement);
    Call_PushCell(temporaryID);
    Call_Finish();

    UpdateAchievementInfo(IdOfNewAchievement, NewAchievementData);

    AmountOfActiveAchievements++;
}

void InsertNewAchievement(DataPack NewAchievementData) {

    // LogMessage("Inserting...");

    char Name[ACHIEVEMENT_MAX_NAME_LENGTH];
    char Description[ACHIEVEMENT_MAX_DESCRIPTION_LENGTH];
    char Category[ACHIEVEMENT_MAX_CATEGORY_LENGTH];
    int Value;

    NewAchievementData.Reset();
    NewAchievementData.ReadCell(); // first position in the DataPack is a plugin handle - we don't need it for now...
    NewAchievementData.ReadFunction(); // second position in the DataPack is a function callback - we don't need it for now...
    NewAchievementData.ReadCell(); // third position in the DataPack is a temporary id - we don't need it for now...
    NewAchievementData.ReadString(Name, ACHIEVEMENT_MAX_NAME_LENGTH);
    NewAchievementData.ReadString(Description, ACHIEVEMENT_MAX_DESCRIPTION_LENGTH);
    NewAchievementData.ReadString(Category, ACHIEVEMENT_MAX_CATEGORY_LENGTH);
    Value = NewAchievementData.ReadCell();

    char buffer[256];
    Format(buffer, sizeof(buffer), "INSERT INTO `Achievements`(`Name`,`Description`,`Category`,`Value`) VALUES('%s','%s','%s',%d)", Name, Description, Category, Value);
    DB.Query(InsertAchievementIdResult, buffer, NewAchievementData, DBPrio_High);
}

public void InsertAchievementIdResult(Database db, DBResultSet results, const char[] error, DataPack NewAchievementData) {
    if (db == null || results == null) {
        PrintToServer("error (AchievementsGO)! %s", error);
        LogError("Could not insert new achievement to the database! Error: %s", error);
        return;
    }

    SQL_LoadAchievement(NewAchievementData);
}

public void AddAchievementToArrays(int IdOfNewAchievement, DataPack NewAchievementData) {
    char Name[ACHIEVEMENT_MAX_NAME_LENGTH];
    char Description[ACHIEVEMENT_MAX_DESCRIPTION_LENGTH];
    char Category[ACHIEVEMENT_MAX_CATEGORY_LENGTH];
    int Value;
    int PluginID;

    NewAchievementData.Reset();
    PluginID = NewAchievementData.ReadCell();
    NewAchievementData.ReadFunction(); // second position in the DataPack is a function callback - we don't need it for now...
    NewAchievementData.ReadCell(); // third position in the DataPack is a temporary id - we don't need it for now...
    NewAchievementData.ReadString(Name, ACHIEVEMENT_MAX_NAME_LENGTH);
    NewAchievementData.ReadString(Description, ACHIEVEMENT_MAX_DESCRIPTION_LENGTH);
    NewAchievementData.ReadString(Category, ACHIEVEMENT_MAX_CATEGORY_LENGTH);
    Value = NewAchievementData.ReadCell();

    AchievementID.Push(IdOfNewAchievement);
    AchievementName.PushString(Name);
    AchievementDescription.PushString(Description);
    AchievementCategory.PushString(Category);
    AchievementValue.Push(Value);
    AchievementPluginID.Push(PluginID);

    AddCategoryToList(Category);
}

public void UpdateAchievementInfo(int IdOfNewAchievement, DataPack NewAchievementData) {
    char Name[ACHIEVEMENT_MAX_NAME_LENGTH];
    char Description[ACHIEVEMENT_MAX_DESCRIPTION_LENGTH];
    char Category[ACHIEVEMENT_MAX_CATEGORY_LENGTH];
    int Value;

    NewAchievementData.Reset();
    NewAchievementData.ReadCell(); // first position in the DataPack is a plugin handle - we don't need it for now...
    NewAchievementData.ReadFunction(); // second position in the DataPack is a function callback - we don't need it for now...
    NewAchievementData.ReadCell(); // third position in the DataPack is a temporary id - we don't need it for now...
    NewAchievementData.ReadString(Name, ACHIEVEMENT_MAX_NAME_LENGTH);
    NewAchievementData.ReadString(Description, ACHIEVEMENT_MAX_DESCRIPTION_LENGTH);
    NewAchievementData.ReadString(Category, ACHIEVEMENT_MAX_CATEGORY_LENGTH);
    Value = NewAchievementData.ReadCell();

    char FormatBuffer[512];
    Format(FormatBuffer, sizeof(FormatBuffer), "UPDATE `Achievements` SET `Name`='%s', `Description`='%s', `Category`='%s', `Value`=%d WHERE `ID`=%d", Name, Description, Category, Value, IdOfNewAchievement);
    DB.Query(UpdateAchievementResults, FormatBuffer, NewAchievementData, DBPrio_High);
}

public void UpdateAchievementResults(Database db, DBResultSet results, const char[] error, DataPack NewAchievementData) {
    delete NewAchievementData;

    if (db == null || results == null) {
        PrintToServer("error (AchievementsGO)! %s", error);
        LogError("Could not update achievement info! Error: %s", error);
    }
}

// @@ Load player Achievements

public Action WaitLoad(Handle timer, int clientUserId) {
    int client = GetClientOfUserId(clientUserId);
    if (client)
        LoadPlayerAchievements(client);
}

void LoadPlayerAchievements(int client) {
    if (IsFakeClient(client) || IsClientSourceTV(client) || isLoaded[client])
        return;

    if (!IsConnectionEstablished || !AreAllAchievementsLoaded) {
        // LogMessage("Cannot load %N...", client);
        CreateTimer(0.5, WaitLoad, GetClientUserId(client));
        return;
    }
    isLoaded[client] = true;
    // LogMessage("%N joining...", client);

    char query[512];
    Format(query, sizeof(query), "SELECT `AchievementID`,`Progress` FROM `Players` WHERE `SteamID`=%d", GetSteamAccountID(client));
    DB.Query(ProcessPlayerAchievementResults, query, GetClientUserId(client), DBPrio_Normal);
}

public void ProcessPlayerAchievementResults(Database db, DBResultSet results, const char[] error, int clientUserId) {
    if (db == null || results == null) {
        PrintToServer("error (AchievementsGO)! %s", error);
        LogError("Could not load player achievements! Error: %s", error);
        return;
    }

    int client = GetClientOfUserId(clientUserId);
    if (!client)
        return;

    // I've created a tricky method to avoid performing multiple queries for each achievement

    // first, I alloc an array with amount of elements equal to the biggest ID among available achievements...
    bool[] achievementsList = new bool[theBiggestAchievementID + 1];

    // next, I mark active achievements. This way, I'm aware which achievements are ON (since some might have been disabled)
    for (int i = 0; i < AchievementID.Length; i++) {
        achievementsList[AchievementID.Get(i)] = true;
    }

    AccomplishedAchievements[client] = 0;

    int IdOfNewAchievement;

    while (results.FetchRow()) {
        IdOfNewAchievement = results.FetchInt(0);

        // if we're dealing with achievement that is inactive, we simply skip...
        if (!achievementsList[IdOfNewAchievement])
            continue;

        int progress = results.FetchInt(1);
        int achievementValue = AchievementValue.Get(GetAchievementPosById(IdOfNewAchievement));
        int finished = 0;
        if (progress >= achievementValue) {
            ++AccomplishedAchievements[client];
            finished = 1;
        }

        // LogMessage("Inserting: %d", IdOfNewAchievement);

        Player_AchievementID[client].Push(IdOfNewAchievement);
        Player_AchievementProgress[client].Push(results.FetchInt(1));
        Player_AchievementFinished[client].Push(finished);

        // since we're done dealing with this achievement, it can me unmarked now...
        achievementsList[IdOfNewAchievement] = false;
    }

    char buffer[512];

    // now, if there are any indexes marked as true, we are sure that these are achievements, that aren't present in Players' table. We need to add them
    // this way, amount of queries have been greatly reduced, as previously each achievement required one query, regardless of its presence in DB.

    bool wasAnyInsert = false;
    Transaction tableTransaction = new Transaction();
    for (int i = 0; i <= theBiggestAchievementID; i++) {
        if (!achievementsList[i])
            continue;

        wasAnyInsert = true;

        // LogMessage("Inserting new: %d", i);

        Player_AchievementID[client].Push(i);
        Player_AchievementProgress[client].Push(0);
        Player_AchievementFinished[client].Push(0);

        Format(buffer, sizeof(buffer), "INSERT INTO `Players` VALUES(%d,%d,0,0,%d)", GetSteamAccountID(client), i, GetTime());
        tableTransaction.AddQuery(buffer);
        // DB.Query(ProcessPlayerInsertionResults, buffer, _, DBPrio_High);
    }

    if (wasAnyInsert) {
        SQL_ExecuteTransaction(DB, tableTransaction, SQL_InsertRowsOnSuccess, SQL_InsertRowsOnFailure, GetClientUserId(client), DBPrio_Normal);
    }
    else {
        delete tableTransaction;
        SendForwardPlayerAchievementsLoaded(client);
    }
}

public void SQL_InsertRowsOnSuccess(Database db, int clientUserId, int numQueries, Handle[] results, any[] queryData) {
    int client = GetClientOfUserId(clientUserId);
    if (!client)
        return;

    SendForwardPlayerAchievementsLoaded(client);
}

public void SQL_InsertRowsOnFailure(Database db, int clientUserId, int numQueries, const char[] error, int failIndex, any[] queryData) {
    int client = GetClientOfUserId(clientUserId);
    if (!client)
        LogError("Could not insert new rows for the player! Error: %s", error);
    else
        LogError("Could not insert new rows for the player %N! Error: %s", client, error);
}

/*public void ProcessPlayerInsertionResults(Database db, DBResultSet results, const char[] error, any data) {
    if (db == null) {
        LogError("Could not insert new achievement row! Error: %s", error);
    }
}*/