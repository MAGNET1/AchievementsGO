void InitConVars() {
    cv_databaseTimeKick = CreateConVar("ago_database_time_kick", "30", "After how many days of inactivity player's records will be deleted? (0 - off, not recommended)");
    cv_achievementNotificationChat = CreateConVar("ago_achievement_notification_chat", "1", "Show chat notification when finishing achievement?");
    cv_achievementNotificationHint = CreateConVar("ago_achievement_notification_hint", "1", "Show HintText notification when finishing achievement?");
    cv_achievementNotificationAll = CreateConVar("ago_achievement_notification_all", "1", "Show chat notification to all players when player finishes achievement?");
    cv_playersAmount = CreateConVar("ago_players_amount", "3", "Minimal amount of players for the achievements to work");

    AutoExecConfig(true, "AchievementsGO");
}