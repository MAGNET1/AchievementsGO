public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    RegPluginLibrary("AchievementsGO");

    CreateNative("AGO_AddAchievement", AddAchievement);

    CreateNative("AGO_AddPoint", AddPoint);
    CreateNative("AGO_AddPoints", AddPoints);
    CreateNative("AGO_RemovePoint", RemovePoint);
    CreateNative("AGO_RemovePoints", RemovePoints);
    CreateNative("AGO_ResetAchievement", ResetAchievement);

    CreateNative("AGO_GetNameByIndex", GetNameByIndex);
    CreateNative("AGO_GetIndexByName", GetIndexByName);
    CreateNative("AGO_GetDescriptionByIndex", GetDescriptionByIndex);
    CreateNative("AGO_GetCategoryByIndex", GetCategoryByIndex);

    CreateNative("AGO_GetAchievementProgress", GetAchievementProgress);
    CreateNative("AGO_IsAchievementCompleted", IsAchievementCompleted);
    CreateNative("AGO_GetAmountOfAchievements", GetAmountOfAchievements);
    CreateNative("AGO_GetAchievementValue", GetAchievementValue);

    CreateNative("AGO_IsWorking", IsWorking);

    CreateNative("AGO_UpdatePlayer", UpdatePlayer);
    CreateNative("AGO_SetPoints", SetPoints);

    return APLRes_Success;
}

public int UpdatePlayer(Handle plugin, int numParams) {
    if (!IsConnectionEstablished)
        return false;

    UpdatePlayerData(GetNativeCell(1));
    return true;
}

public int IsWorking(Handle plugin, int numParams) {
    return IsConnectionEstablished;
}

public int AddAchievement(Handle plugin, int numParams) {

    char name[ACHIEVEMENT_MAX_NAME_LENGTH];
    char description[ACHIEVEMENT_MAX_DESCRIPTION_LENGTH];
    char category[ACHIEVEMENT_MAX_DESCRIPTION_LENGTH];

    GetNativeString(1, name, ACHIEVEMENT_MAX_NAME_LENGTH);
    if (IsStringContainingRestrictedCharacters(name)) {
        LogError("[%s] Name contains characters, that aren't allowed! (', \" or |)", name);
        return false;
    }

    GetNativeString(2, description, ACHIEVEMENT_MAX_DESCRIPTION_LENGTH);
    if (IsStringContainingRestrictedCharacters(description)) {
        LogError("[%s] Description contains characters, that aren't allowed! (', \" or |)", name);
        return false;
    }

    GetNativeString(3, category, ACHIEVEMENT_MAX_CATEGORY_LENGTH);
    if (IsStringContainingRestrictedCharacters(category)) {
        LogError("[%s] Category name contains characters, that aren't allowed! (', \" or |)", name);
        return false;
    }

    int value = GetNativeCell(4);
    int temporaryID = GetNativeCell(5);
    Function functionCallback = GetNativeCell(6);

    DataPack NewAchievementData = new DataPack();
    NewAchievementData.WriteCell(plugin);
    NewAchievementData.WriteFunction(functionCallback);
    NewAchievementData.WriteCell(temporaryID);
    NewAchievementData.WriteString(name);
    NewAchievementData.WriteString(description);
    NewAchievementData.WriteString(category);
    NewAchievementData.WriteCell(value);

    SQL_LoadAchievement(NewAchievementData);
    return true;
}

void AddCategoryToList(char[] tab) {
    if (StrEqual(tab, "")) return;

    char TempBuffer[ACHIEVEMENT_MAX_CATEGORY_LENGTH];

    for (int i = 0; i < GetArraySize(CategoryList); i++) {
        CategoryList.GetString(i, TempBuffer, sizeof(TempBuffer));
        if (StrEqual(TempBuffer, tab)) return;
    }

    CategoryList.PushString(tab);
}

bool IsStringContainingRestrictedCharacters(char[] tab) {
    if ((StrContains(tab, "'") != -1) || (StrContains(tab, "|") != -1) || (StrContains(tab, "\"") != -1)) return true;

    return false;
}

// @@ Add/Remove points

public int AddPoint(Handle plugin, int numParams) {
    return UpdatePoints(GetNativeCell(1), GetNativeCell(2), 1);
}

public int AddPoints(Handle plugin, int numParams) {
    return UpdatePoints(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}

public int RemovePoint(Handle plugin, int numParams) {
    return UpdatePoints(GetNativeCell(1), GetNativeCell(2), -1);
}

public int RemovePoints(Handle plugin, int numParams) {
    return UpdatePoints(GetNativeCell(1), GetNativeCell(2), -GetNativeCell(3));
}

public int ResetAchievement(Handle plugin, int numParams) {
    if (!IsEnoughPlayers())
        return false;

    int client = GetNativeCell(1);

    if (!IsValidClient(client))
        return false;

    int IdOfAchievement = GetNativeCell(2);
    if (IdOfAchievement == NOT_FOUND)
        return false;

    int PosOfAchievement = FindAchievementPosInPlayerArray(client, IdOfAchievement);

    if (PosOfAchievement == NOT_FOUND)
        return false;

    if (Player_AchievementFinished[client].Get(PosOfAchievement))
        --AccomplishedAchievements[client];

    Player_AchievementFinished[client].Set(PosOfAchievement, 0);
    Player_AchievementProgress[client].Set(PosOfAchievement, 0);

    UpdatePlayerData(client);

    return true;
}

public int SetPoints(Handle plugin, int numParams) {
    if (!IsEnoughPlayers())
        return false;

    int client = GetNativeCell(1);

    if (!IsValidClient(client))
        return false;

    int IdOfAchievement = GetNativeCell(2);
    if (IdOfAchievement == NOT_FOUND)
        return false;

    int amount = GetNativeCell(3);

    if (amount < 0)
        amount = 0;

    int PosOfAchievement = FindAchievementPosInPlayerArray(client, IdOfAchievement);

    if (PosOfAchievement == NOT_FOUND)
        return false;

    if (Player_AchievementFinished[client].Get(PosOfAchievement) == 1)
        return false;

    int value = AchievementValue.Get(GetAchievementPosById(IdOfAchievement));
    Player_AchievementProgress[client].Set(PosOfAchievement, amount);

    // Achievement accomplished
    if (amount >= value) {
        Player_AchievementProgress[client].Set(PosOfAchievement, value); // just setting the value so that it is nicely rounded (10/10, 5/5 etc.)
        Player_AchievementFinished[client].Set(PosOfAchievement, 1);

        ++AccomplishedAchievements[client];

        PlaySound_Accomplished(client);
        UpdatePlayerData(client); //AchievementsGO_SQLUpdate.sp
        InformPlayersAchievementAccomplished(client, GetAchievementPosById(IdOfAchievement));
        SendForwardAchievementAccomplished(client, IdOfAchievement); // AchievementsGO_Forwards.sp
    }

    return true;
}

public int UpdatePoints(int client, int IdOfAchievement, int amount) {
    if (!IsEnoughPlayers())
        return NOT_FOUND;

    if (!IsValidClient(client) || IdOfAchievement == NOT_FOUND)
        return NOT_FOUND;

    int PosOfAchievement = FindAchievementPosInPlayerArray(client, IdOfAchievement);
    int value = AchievementValue.Get(GetAchievementPosById(IdOfAchievement));

    if (PosOfAchievement == NOT_FOUND)
        return NOT_FOUND;

    int CurrentProgress = Player_AchievementProgress[client].Get(PosOfAchievement);

    if (Player_AchievementFinished[client].Get(PosOfAchievement) == 1)
        return CurrentProgress;

    int NewProgress = CurrentProgress + amount;
    if (NewProgress < 0)
        NewProgress = 0;
    Player_AchievementProgress[client].Set(PosOfAchievement, NewProgress);

    // Achievement accomplished
    if (NewProgress >= value) {
        Player_AchievementProgress[client].Set(PosOfAchievement, value); // just setting the value so that it is nicely rounded (10/10, 5/5 etc.)
        Player_AchievementFinished[client].Set(PosOfAchievement, 1);

        ++AccomplishedAchievements[client];

        PlaySound_Accomplished(client);
        UpdatePlayerData(client); //AchievementsGO_SQLUpdate.sp
        InformPlayersAchievementAccomplished(client, GetAchievementPosById(IdOfAchievement));
        SendForwardAchievementAccomplished(client, IdOfAchievement); // AchievementsGO_Forwards.sp
    }

    return NewProgress;
}

// @@ Forward stuff

public void InformPlayersAchievementAccomplished(int client, int AchievementPos) {
    char Name[MAX_NAME_LENGTH];
    char AchievementNamee[129];
    AchievementName.GetString(AchievementPos, AchievementNamee, sizeof(AchievementNamee));
    GetClientName(client, Name, sizeof(Name));
    if (cv_achievementNotificationChat.IntValue)    CPrintToChat(client, "%s %T", TAG, "Achievement accomplished chat", client, AchievementNamee);
    if (cv_achievementNotificationHint.IntValue)    PrintHintText(client, "%T", "Achievement accomplished hinttext", client, AchievementNamee);
    if (cv_achievementNotificationAll.IntValue) {
        for (int i = 1; i < MAXPLAYERS; i++) {
            if (!IsClientInGame(i))
                continue;

            CPrintToChat(i, "%s %T", TAG, "Achievement accomplished chat all", client, client, AchievementNamee);
        }
    }
}

public int FindAchievementPosInPlayerArray(int client, int IdOfAchievement) {
    for (int i = 0; i < GetArraySize(Player_AchievementID[client]); i++) {
        if (Player_AchievementID[client].Get(i) == IdOfAchievement)
            return i;
    }
    return NOT_FOUND;
}

// @@ Information retrieval

public int GetIndexByName(Handle plugin, int numParams) {
    char Name[256];
    GetNativeString(1, Name, sizeof(Name));
    char ArrayName[256];

    for (int i = 0; i < AmountOfActiveAchievements; i++) {
        AchievementName.GetString(i, ArrayName, sizeof(ArrayName));
        if (StrEqual(Name, ArrayName))
            return i;
    }
    return NOT_FOUND;
}

public int GetNameByIndex(Handle plugin, int numParams) {
    int IdOfAchievement = GetNativeCell(1);
    if (IdOfAchievement == NOT_FOUND)
        return NOT_FOUND;

    int len = GetNativeCell(3);
    char Name[256];
    int AchievementPos = GetAchievementPosById(IdOfAchievement);

    if (AchievementPos != NOT_FOUND)
        AchievementName.GetString(AchievementPos, Name, sizeof(Name));
    else
        Format(Name, sizeof(Name), "NOT FOUND");

    SetNativeString(2, Name, len);

    if (AchievementPos == NOT_FOUND)
        return NOT_FOUND;

    return 0;
}

public int GetDescriptionByIndex(Handle plugin, int numParams) {
    int IdOfAchievement = GetNativeCell(1);
    if (IdOfAchievement == NOT_FOUND)
        return NOT_FOUND;

    int len = GetNativeCell(3);
    char Name[256];
    int AchievementPos = GetAchievementPosById(IdOfAchievement);

    if (AchievementPos != NOT_FOUND)
        AchievementDescription.GetString(AchievementPos, Name, sizeof(Name));
    else
        Format(Name, sizeof(Name), "NOT FOUND");

    SetNativeString(2, Name, len);

    if (AchievementPos == NOT_FOUND)
        return NOT_FOUND;

    return 0;
}

public int GetCategoryByIndex(Handle plugin, int numParams) {
    int IdOfAchievement = GetNativeCell(1);
    if (IdOfAchievement == NOT_FOUND)
        return NOT_FOUND;

    int len = GetNativeCell(3);
    char Name[256];
    int AchievementPos = GetAchievementPosById(IdOfAchievement);

    if (AchievementPos != NOT_FOUND)
        AchievementCategory.GetString(AchievementPos, Name, sizeof(Name));
    else
        Format(Name, sizeof(Name), "NOT FOUND");

    SetNativeString(2, Name, len);

    if (AchievementPos == NOT_FOUND)
        return NOT_FOUND;

    return 0;
}

public int GetAchievementProgress(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    int IdOfAchievement = GetNativeCell(2);
    if (IdOfAchievement == NOT_FOUND)
        return NOT_FOUND;

    int PlayerAchievementPos = FindAchievementPosInPlayerArray(client, IdOfAchievement);

    if (PlayerAchievementPos == NOT_FOUND)
        return NOT_FOUND;

    return Player_AchievementProgress[client].Get(PlayerAchievementPos);
}

public int IsAchievementCompleted(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    int IdOfAchievement = GetNativeCell(2);
    if (IdOfAchievement == NOT_FOUND)
        return false;

    int PlayerAchievementPos = FindAchievementPosInPlayerArray(client, IdOfAchievement);

    if (PlayerAchievementPos == NOT_FOUND)
        return false;

    if (Player_AchievementFinished[client].Get(PlayerAchievementPos))
        return true;

    return false;
}

public int GetAmountOfAchievements(Handle plugin, int numParams) {
    return AmountOfActiveAchievements;
}

public int GetAchievementValue(Handle plugin, int numParams) {
    int IdOfAchievement = GetNativeCell(2);

    if (IdOfAchievement == NOT_FOUND)
        return NOT_FOUND;

    int AchievementPos = GetAchievementPosById(IdOfAchievement);

    if (AchievementPos != NOT_FOUND)
        return AchievementValue.Get(AchievementPos);

    return NOT_FOUND;
}

bool IsValidClient(int client) {
    if (client >= 1 && client < MAXPLAYERS && IsClientInGame(client)) return true;

    return false;
}

bool IsEnoughPlayers() {
    return (GetClientCount(true) >= cv_playersAmount.IntValue);
}