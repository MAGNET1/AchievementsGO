public Action ShowAchievementsMenu(int client, int args) {
  if (!IsConnectionEstablished) {
    CPrintToChat(client, "Database error...");
    return Plugin_Continue;
  }

  Menu menu = new Menu(ShowAchievementsMenu_Handler);

  char FormatBufferName[128];
  char FormatBufferInfo[256];
  char FormatBufferWhole[256];
  char FormatBufferTitle[512];
  Format(FormatBufferTitle, sizeof(FormatBufferTitle), "%T", "MainMenuTitle", client, AccomplishedAchievements[client], AmountOfActiveAchievements);
  menu.SetTitle(FormatBufferTitle);

  if (AchievementName.Length == 0) {
    Format(FormatBufferTitle, sizeof(FormatBufferTitle), "%T", "MainMenuTitleNoAchievements", client);
    menu.SetTitle("There are no achievements...");
    Format(FormatBufferTitle, sizeof(FormatBufferTitle), "%T", "Exit", client);
    menu.AddItem("exit", FormatBufferTitle);
  }

  for (int i = 0; i < CategoryList.Length; i++) {
    CategoryList.GetString(i, FormatBufferInfo, sizeof(FormatBufferInfo));
    Format(FormatBufferWhole, sizeof(FormatBufferWhole), "> %s", FormatBufferInfo);
    menu.AddItem(FormatBufferInfo, FormatBufferWhole);
  }

  for (int i = 0; i < Player_AchievementID[client].Length; i++) {
    int AchievementPos = GetAchievementPosById(Player_AchievementID[client].Get(i));

    if (AchievementPos == NOT_FOUND)
      continue;

    char tmpCategory[ACHIEVEMENT_MAX_CATEGORY_LENGTH];
    AchievementCategory.GetString(AchievementPos, tmpCategory, sizeof(tmpCategory));
    if (!StrEqual(tmpCategory, ""))
      continue;

    int progress = Player_AchievementProgress[client].Get(i);
    int value = AchievementValue.Get(AchievementPos);
    AchievementName.GetString(AchievementPos, FormatBufferName, sizeof(FormatBufferName));

    Format(FormatBufferInfo, sizeof(FormatBufferInfo), "%d|%d", i, AchievementPos);
    if (Player_AchievementFinished[client].Get(i))
      Format(FormatBufferWhole, sizeof(FormatBufferWhole), "%s [✔]", FormatBufferName);
    else
      Format(FormatBufferWhole, sizeof(FormatBufferWhole), "%s (%d/%d)", FormatBufferName, progress, value);

    menu.AddItem(FormatBufferInfo, FormatBufferWhole);
  }

  menu.ExitButton = true;
  menu.Display(client, 60);

  return Plugin_Continue;
}

public int ShowAchievementsMenu_Handler(Menu menu, MenuAction action, int client, int item) {
  if (action == MenuAction_Select) {
    char InfoBuffer[256];
    menu.GetItem(item, InfoBuffer, sizeof(InfoBuffer));

    if (StrEqual(InfoBuffer, "exit"))
      return 0;

    if (StrContains(InfoBuffer, "|") != -1) {
      char str[2][8];
      ExplodeString(InfoBuffer, "|", str, sizeof(str), sizeof(str[]));
      DisplayAchievementDetails(client, StringToInt(str[0]), StringToInt(str[1]));
    } else {
      ShowCategoryAchievements(client, InfoBuffer);
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public void ShowCategoryAchievements(int client, char[] CategoryBuffer) {
  //PrintToChat(client, "ArraySize: %d", GetArraySize(Player_AchievementID[client]));
  Menu menu = new Menu(ShowCategoryAchievements_Handler);

  char FormatBufferName[128];
  char FormatBufferInfo[10];
  char FormatBufferWhole[256];
  char FormatBufferTitle[512];

  Format(FormatBufferTitle, sizeof(FormatBufferTitle), "%T", "CategoryMenuTitle", client, CategoryBuffer);
  menu.SetTitle(FormatBufferTitle);

  Format(FormatBufferTitle, sizeof(FormatBufferTitle), "%T", "Back", client);
  menu.AddItem("back", FormatBufferTitle);

  for (int i = 0; i < GetArraySize(Player_AchievementID[client]); i++) {
    int AchievementPos = GetAchievementPosById(Player_AchievementID[client].Get(i));

    if (AchievementPos == NOT_FOUND)
      continue;

    char tmpCategory[ACHIEVEMENT_MAX_CATEGORY_LENGTH];
    AchievementCategory.GetString(AchievementPos, tmpCategory, sizeof(tmpCategory));
    if (!StrEqual(tmpCategory, CategoryBuffer))
      continue;

    int progress = Player_AchievementProgress[client].Get(i);
    int value = AchievementValue.Get(AchievementPos);
    AchievementName.GetString(AchievementPos, FormatBufferName, sizeof(FormatBufferName));

    Format(FormatBufferInfo, sizeof(FormatBufferInfo), "%d|%d", i, AchievementPos);
    if (Player_AchievementFinished[client].Get(i))
      Format(FormatBufferWhole, sizeof(FormatBufferWhole), "%s [✔]", FormatBufferName);
    else
      Format(FormatBufferWhole, sizeof(FormatBufferWhole), "%s (%d/%d)", FormatBufferName, progress, value);

    menu.AddItem(FormatBufferInfo, FormatBufferWhole);
  }

  menu.ExitButton = true;
  menu.Display(client, 30);
}

public int ShowCategoryAchievements_Handler(Menu menu, MenuAction action, int client, int item) {
  if (action == MenuAction_Select) {
    char InfoBuffer[32];
    menu.GetItem(item, InfoBuffer, sizeof(InfoBuffer));
    if (StrEqual(InfoBuffer, "back")) ShowAchievementsMenu(client, 0);
    else if (!StrEqual(InfoBuffer, "exit")) {
      char str[2][8];
      ExplodeString(InfoBuffer, "|", str, sizeof(str), sizeof(str[]));
      DisplayAchievementDetails(client, StringToInt(str[0]), StringToInt(str[1]));
    }
  }
}

public int GetAchievementPosById(int id) {
  for (int i = 0; i < GetArraySize(AchievementName); i++) {
    if (GetArrayCell(AchievementID, i) == id) return i;
  }
  return NOT_FOUND;
}

public void DisplayAchievementDetails(int client, int i, int AchievementPos) {
  char FormatBufferTitle[512];
  char FormatBufferName[64];
  char FormatBufferDescription[256];
  char FormatBufferCategory[256];

  AchievementName.GetString(AchievementPos, FormatBufferName, sizeof(FormatBufferName));
  AchievementDescription.GetString(AchievementPos, FormatBufferDescription, sizeof(FormatBufferDescription));
  AchievementCategory.GetString(AchievementPos, FormatBufferCategory, sizeof(FormatBufferCategory));

  int progress = Player_AchievementProgress[client].Get(i);
  int value = AchievementValue.Get(AchievementPos);
  if (StrEqual(FormatBufferCategory, ""))
    Format(FormatBufferTitle, sizeof(FormatBufferTitle), "%T", "Achievement description no category", client, FormatBufferName, FormatBufferDescription, progress, value, Player_AchievementFinished[client].Get(i) ? "[✔]" : "");
  else
    Format(FormatBufferTitle, sizeof(FormatBufferTitle), "%T", "Achievement description category", client, FormatBufferName, FormatBufferDescription, FormatBufferCategory, progress, value, Player_AchievementFinished[client].Get(i) ? "[✔]" : "");

  Menu menu = new Menu(DisplayAchievementDetails_Handler);

  menu.SetTitle(FormatBufferTitle);

  Format(FormatBufferTitle, sizeof(FormatBufferTitle), "%T", "Back", client);
  menu.AddItem("back", FormatBufferTitle);

  menu.ExitButton = false;
  menu.Display(client, 20);
}

public int DisplayAchievementDetails_Handler(Menu menu, MenuAction action, int client, int item) {
  if (action == MenuAction_Select) {
    char InfoBuffer[32];
    menu.GetItem(item, InfoBuffer, sizeof(InfoBuffer));

    if (StrEqual(InfoBuffer, "back")) ShowAchievementsMenu(client, 0);
  }
}