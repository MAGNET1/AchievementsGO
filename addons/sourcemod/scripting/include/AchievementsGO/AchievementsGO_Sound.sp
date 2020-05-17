public void PrecacheSounds() {
  PrecacheSound("*/AchievementsGO/accomplished2.mp3", true);
}

public void DownloadSounds() {
  AddFileToDownloadsTable("sound/AchievementsGO/accomplished2.mp3");
}

public void PlaySound_Accomplished(int client) {
  EmitSoundToClient(client, "*/AchievementsGO/accomplished2.mp3");
}