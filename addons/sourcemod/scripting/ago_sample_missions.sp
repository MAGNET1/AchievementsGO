#include <AchievementsGO>
#include <store>
#include <sdkhooks>

#define MISSIONS_NUM 8
#define LEVELS 4

#define KILLER 0
#define HEAD_HUNTER 1
#define GRENADIER 2
#define INCENDIARY 3
#define PLANTER 4
#define DEFUSER 5
#define WEALTH 6
#define AWP_MASTER 7

int missionID[MISSIONS_NUM][LEVELS];

public void OnPluginStart() {
  HookEvent("player_death", PlayerDeath);
  HookEvent("bomb_defused", BombDefused);
  HookEvent("bomb_planted", BombPlanted);
}

public void AGO_OnRegisterAchievements() {
  AGO_AddAchievement("Killer [Beginner]", "Kill 50 enemies\nPrice: 10 credits", "Zabójca", 50, 0, OnIdGranted);
  AGO_AddAchievement("Killer [Advanced]", "Kill 250 enemies\nPrice: 20 credits", "Zabójca", 250, 1, OnIdGranted);
  AGO_AddAchievement("Killer [Veteran]", "Kill 750 enemies\nPrice: 30 credits", "Zabójca", 750, 2, OnIdGranted);
  AGO_AddAchievement("Killer [Expert]", "Kill 1500 enemies\nPrice: 40 credits", "Zabójca", 1500, 3, OnIdGranted);
  AGO_AddAchievement("Head Hunter [Beginner]", "Kill 25 enemies with HS\nPrice: 10 credits", "Head Hunter", 25, 4, OnIdGranted);
  AGO_AddAchievement("Head Hunter [Advanced]", "Kill 125 enemies with HS\nPrice: 20 credits", "Head Hunter", 125, 5, OnIdGranted);
  AGO_AddAchievement("Head Hunter [Veteran]", "Kill 325 enemies with HS\nPrice: 30 credits", "Head Hunter", 375, 6, OnIdGranted);
  AGO_AddAchievement("Head Hunter [Expert]", "Kill 750 enemies with HS\nPrice: 40 credits", "Head Hunter", 750, 7, OnIdGranted);
  AGO_AddAchievement("Grenadier [Beginner]", "Kill 5 enemies with grenade\nPrice: 10 credits", "Grenadier", 5, 8, OnIdGranted);
  AGO_AddAchievement("Grenadier [Advanced]", "Kill 20 enemies with grenade\nPrice: 20 credits", "Grenadier", 20, 9, OnIdGranted);
  AGO_AddAchievement("Grenadier [Veteran]", "Kill 100 enemies with grenade\nPrice: 30 credits", "Grenadier", 100, 10, OnIdGranted);
  AGO_AddAchievement("Grenadier [Expert]", "Kill 250 enemies with grenade\nPrice: 40 credits", "Grenadier", 250, 11, OnIdGranted);
  AGO_AddAchievement("Incendiary [Beginner]", "Kill 5 enemies with molotov\nPrice: 10 credits", "Incendiary", 5, 12, OnIdGranted);
  AGO_AddAchievement("Incendiary [Advanced]", "Kill 20 enemies with molotov\nPrice: 20 credits", "Incendiary", 20, 13, OnIdGranted);
  AGO_AddAchievement("Incendiary [Veteran]", "Kill 100 enemies with molotov\nPrice: 30 credits", "Incendiary", 100, 14, OnIdGranted);
  AGO_AddAchievement("Incendiary [Expert]", "Kill 250 enemies with molotov\nPrice: 40 credits", "Incendiary", 250, 15, OnIdGranted);
  AGO_AddAchievement("Planter [Beginner]", "Plant 10 bombs\nPrice: 10 credits", "Planter", 10, 16, OnIdGranted);
  AGO_AddAchievement("Planter [Advanced]", "Plant 50 bombs\nPrice: 20 credits", "Planter", 50, 17, OnIdGranted);
  AGO_AddAchievement("Planter [Veteran]", "Plant 250 bombs\nPrice: 30 credits", "Planter", 250, 18, OnIdGranted);
  AGO_AddAchievement("Planter [Expert]", "Plant 750 bombs\nPrice: 40 credits", "Planter", 750, 19, OnIdGranted);
  AGO_AddAchievement("Defuser [Beginner]", "Defuse 10 bombs\nPrice: 10 credits", "Defuser", 10, 20, OnIdGranted);
  AGO_AddAchievement("Defuser [Advanced]", "Defuse 50 bombs\nPrice: 20 credits", "Defuser", 50, 21, OnIdGranted);
  AGO_AddAchievement("Defuser [Veteran]", "Defuse 250 bombs\nPrice: 30 credits", "Defuser", 250, 22, OnIdGranted);
  AGO_AddAchievement("Defuser [Expert]", "Defuse 750 bombs\nPrice: 40 credits", "Defuser", 750, 23, OnIdGranted);
  AGO_AddAchievement("Wealth [Beginner]", "Spend 50000$\nPrice: 10 credits", "Wealth", 50000, 24, OnIdGranted);
  AGO_AddAchievement("Wealth [Advanced]", "Spend 500000$\nPrice: 20 credits", "Wealth", 500000, 25, OnIdGranted);
  AGO_AddAchievement("Wealth [Veteran]", "Spend 1200000$\nPrice: 30 credits", "Wealth", 1200000, 26, OnIdGranted);
  AGO_AddAchievement("Wealth [Expert]", "Spend 6400000$\nPrice: 40 credits", "Wealth", 6400000, 27, OnIdGranted);
  AGO_AddAchievement("AWP Master [Beginner]", "Kill 25 enemies with AWP\nPrice: 10 credits", "AWP Master", 25, 28, OnIdGranted);
  AGO_AddAchievement("AWP Master [Advanced]", "Kill 125 enemies with AWP\nPrice: 20 credits", "AWP Master", 125, 29, OnIdGranted);
  AGO_AddAchievement("AWP Master [Veteran]", "Kill 325 enemies with AWP\nPrice: 30 credits", "AWP Master", 375, 30, OnIdGranted);
  AGO_AddAchievement("AWP Master [Expert]", "Kill 750 enemies with AWP\nPrice: 40 credits", "AWP Master", 750, 31, OnIdGranted);
}

public void OnIdGranted(int achievementID, int temporaryID) {
  if (temporaryID == 0) {
    missionID[0][0] = achievementID;
    return;
  }
  missionID[temporaryID / 4][temporaryID % 4] = achievementID;
}

void AddPoint(int client, int which) {
  AGO_AddPoint(client, missionID[which][0]);
  if (AGO_IsAchievementCompleted(client, missionID[which][0]))
    AGO_AddPoint(client, missionID[which][1]);
  if (AGO_IsAchievementCompleted(client, missionID[which][1]))
    AGO_AddPoint(client, missionID[which][2]);
  if (AGO_IsAchievementCompleted(client, missionID[which][2]))
    AGO_AddPoint(client, missionID[which][3]);
}

void AddPoints(int client, int which, int n) {
  AGO_AddPoints(client, missionID[which][0], n);
  if (AGO_IsAchievementCompleted(client, missionID[which][0]))
    AGO_AddPoints(client, missionID[which][1], n);
  if (AGO_IsAchievementCompleted(client, missionID[which][1]))
    AGO_AddPoints(client, missionID[which][2], n);
  if (AGO_IsAchievementCompleted(client, missionID[which][2]))
    AGO_AddPoints(client, missionID[which][3], n);
}

void AddPointsZephyrus(int client, int n) {
  Store_SetClientCredits(client, Store_GetClientCredits(client) + n);
}

public void AGO_OnAchievementAccomplished(int client, int IdOfAchievement) {
  for (int i = 0; i < MISSIONS_NUM; i++) {
    for (int j = 0; j < LEVELS; j++) {
      if (missionID[i][j] == IdOfAchievement) {
        AddPointsZephyrus(client, 10 * (j + 1)); // BEGINNER - 10, ADVANCED - 20, VETERAN - 30, EXPERT - 40
        return;
      }
    }
  }
}

public Action PlayerDeath(Event event, char[] name, bool dontbroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  int killer = GetClientOfUserId(event.GetInt("attacker"));
  bool headshot = event.GetBool("headshot");

  char weaponName[128];
  event.GetString("weapon", weaponName, sizeof(weaponName));

  if (!IsValidClient(client) || !IsValidClient(killer))
    return Plugin_Continue;

  AddPoint(killer, KILLER);

  if (headshot)
    AddPoint(killer, HEAD_HUNTER);

  if (StrEqual(weaponName, "hegrenade"))
    AddPoint(killer, GRENADIER);

  if (StrEqual(weaponName, "inferno"))
    AddPoint(killer, INCENDIARY);

  if (StrEqual(weaponName, "awp"))
    AddPoint(killer, AWP_MASTER);

  return Plugin_Continue;
}

public Action BombPlanted(Event event,
  const char[] name, bool dontbroadcast) {
  AddPoint(GetClientOfUserId(event.GetInt("userid")), PLANTER);
}

public Action BombDefused(Event event,
  const char[] name, bool dontbroadcast) {
  AddPoint(GetClientOfUserId(event.GetInt("userid")), DEFUSER);
}

public Action CS_OnGetWeaponPrice(int client,
  const char[] weapon, int & price) {
  AddPoints(client, WEALTH, price);
}

public bool IsValidClient(int client) {
  if (client >= 1 && client <= MaxClients && IsClientInGame(client))
    return true;

  return false;
}