public void UpdatePlayerData(int client) {
    if (!IsValidClient(client) || !IsConnectionEstablished || !AreAllAchievementsLoaded)
        return;

    char query[512];
    for (int i = 0; i < Player_AchievementID[client].Length; i++) {
        int ID = Player_AchievementID[client].Get(i);
        int progress = Player_AchievementProgress[client].Get(i);
        int finished = Player_AchievementFinished[client].Get(i);

        Format(query, 511, "UPDATE `Players` SET `Progress`=%d,`Finished`=%d,`LastConnected`=%d WHERE `SteamID`=%d AND `AchievementID`=%d", progress, finished, GetTime(), GetSteamAccountID(client), ID);
        DB.Query(CheckPlayerAchievementUpdateResults, query, _, DBPrio_Normal);
    }
}

public void CheckPlayerAchievementUpdateResults(Database db, DBResultSet results, const char[] error, any data) {
    if (db == null)
        LogMessage("Could not update player achievement informations! Error: %s", error);
}