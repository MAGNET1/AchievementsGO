#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <multicolors>

#define TAG "{purple}[AchievementsGO]{default}"

#define ACHIEVEMENT_MAX_NAME_LENGTH 64
#define ACHIEVEMENT_MAX_DESCRIPTION_LENGTH 128
#define ACHIEVEMENT_MAX_CATEGORY_LENGTH 128

#define NOT_ASSIGNED 0
#define NOT_FOUND - 1
#define SERVER 0
#define ALL - 1

Database DB;
bool isMysql;

int AmountOfActiveAchievements = 0;

bool IsConnectionEstablished = false;
bool AreAllAchievementsLoaded = false;

ConVar cv_databaseTimeKick;
ConVar cv_achievementNotificationChat;
ConVar cv_achievementNotificationHint;
ConVar cv_achievementNotificationAll;
ConVar cv_playersAmount;

ArrayList AchievementID;
ArrayList AchievementName;
ArrayList AchievementDescription;
ArrayList AchievementCategory;
ArrayList AchievementValue;
ArrayList AchievementPluginID;

ArrayList CategoryList;

ArrayList Player_AchievementID[MAXPLAYERS];
ArrayList Player_AchievementProgress[MAXPLAYERS];
ArrayList Player_AchievementFinished[MAXPLAYERS];

Handle Forward_AllAchievementsLoaded;
Handle Forward_OnRegisterAchievements;
Handle Forward_OnAchievementAccomplished;
Handle Forward_OnPlayerAchievementsLoaded;

int AccomplishedAchievements[MAXPLAYERS];
bool isLoaded[MAXPLAYERS];

int theBiggestAchievementID;

public Plugin myinfo = {
    name = "AchievementsGO",
    author = "MAGNET | YouTube: Koduj z Magnetem",
    description = "Tool for creating your own achievements/missions",
    version = "2.2",
    url = "http://go-code.pl/"
};

public OnPluginStart() {
    Database.Connect(OnSQLConnect, "AchievementsGO");

    AchievementID = CreateArray();
    AchievementName = CreateArray(ACHIEVEMENT_MAX_NAME_LENGTH + 1);
    AchievementDescription = CreateArray(ACHIEVEMENT_MAX_DESCRIPTION_LENGTH + 1);
    AchievementCategory = CreateArray(ACHIEVEMENT_MAX_CATEGORY_LENGTH + 1);
    AchievementValue = CreateArray();
    AchievementPluginID = CreateArray();
    
    CategoryList = CreateArray(ACHIEVEMENT_MAX_CATEGORY_LENGTH + 1);

    for (int i = 0; i < MAXPLAYERS; i++) {
        Player_AchievementID[i] = CreateArray();
        Player_AchievementProgress[i] = CreateArray();
        Player_AchievementFinished[i] = CreateArray();
    }

    InitGlobalForwards(); // AchievementsGO_Forwards.sp
    InitConVars(); // AchievementsGO_ConVars.sp

    RegConsoleCmd("sm_ac", ShowAchievementsMenu);
    RegConsoleCmd("sm_achievements", ShowAchievementsMenu);
    RegConsoleCmd("sm_mission", ShowAchievementsMenu);
    RegConsoleCmd("sm_missions", ShowAchievementsMenu);

    LoadTranslations("ago.phrases");
}

public void OnClientAuthorized(int client, const char[] auth) {
    AccomplishedAchievements[client] = 0;
    ClearArray(Player_AchievementID[client]);
    ClearArray(Player_AchievementProgress[client]);
    ClearArray(Player_AchievementFinished[client]);

    LoadPlayerAchievements(client);
}

public void OnClientDisconnect(int client) {
    UpdatePlayerData(client); //AchievementsGO_SQLUpdate.sp
    isLoaded[client] = false;
}

public void OnMapStart() {
    PrecacheSounds(); // MailboxGO_Sounds.sp
    DownloadSounds();
}

public void OnAllPluginsLoaded() {
    AreAllAchievementsLoaded = true;
    SendForwardAllAchievementsLoaded();
}

#include <AchievementsGO/AchievementsGO_ConVars.sp>
#include <AchievementsGO/AchievementsGO_Natives.sp>
#include <AchievementsGO/AchievementsGO_Forwards.sp>
#include <AchievementsGO/AchievementsGO_SQLConnect.sp>
#include <AchievementsGO/AchievementsGO_SQLLoadData.sp>
#include <AchievementsGO/AchievementsGO_SQLUpdate.sp>
#include <AchievementsGO/AchievementsGO_Menu.sp>
#include <AchievementsGO/AchievementsGO_Sound.sp>