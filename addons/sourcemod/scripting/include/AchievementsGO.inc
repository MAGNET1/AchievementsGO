#if defined _AchievementsGO_included_
  #endinput
#endif
#define _AchievementsGO_included_
 
/**
 * Adds new achievement. This operation must be processed within AGO_OnRegisterAchievements()
 * function to make sure everything will load properly
 *
 * @param Name				Name of the achievement (up to 64 characters)
 * @param Description		Short description (up to 128 characters)
 * @param Category			Category of a certain Achievement. If you want it to be in the main section, leave blank ("")
 * @param Value				Sets the goal that achievement must meet to be accomplished
 * @param temporaryID		Value, that goes back in the handler. Helps to identify achievement. See example code for better understanding
 * @param functionCallback	Function, that will be called after achievement has been fully loaded. See example plugin
 * @return					true if achievement will be inserted. false otherwise
 */
native bool AGO_AddAchievement(char[] Name, char[] Description, char[] Category, int Value, int temporaryID, Function functionCallback);

/**
 * Adds one point to the player's achievement. Doesn't work if Achievement if already accomplished
 *
 * @param client			ID of the client
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @param enforce	  if true, omits minimal players restriction (ago_players_amount ConVar)
 * @return					Current achievement progress or -1 if failure.
 */
native int AGO_AddPoint(int client, int IdOfAchievement, bool enforce=false);

/**
 * Adds points to the player's achievement. Doesn't work if Achievement if already accomplished
 *
 * @param client			ID of the client
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @param amount			Amount of points to be given
 * @param enforce	  if true, omits minimal players restriction (ago_players_amount ConVar)
 * @return					Current achievement progress or -1 if failure.
 */
native int AGO_AddPoints(int client, int IdOfAchievement, int amount, bool enforce=false);

/**
 * Removes one point of the player's achievement. Doesn't work if Achievement if already accomplished
 *
 * @param client			ID of the client
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @param enforce	  if true, omits minimal players restriction (ago_players_amount ConVar)
 * @return					Current achievement progress or -1 if failure.
 */
native int AGO_RemovePoint(int client, int IdOfAchievement, bool enforce=false);

/**
 * Removes points of the player's achievement. Doesn't work if Achievement if already accomplished
 *
 * @param client			ID of the client
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @param amount			Amount of points to be taken away from
 * @param enforce	  if true, omits minimal players restriction (ago_players_amount ConVar)
 * @return					Current achievement progress or -1 if failure.
 */
native int AGO_RemovePoints(int client, int IdOfAchievement, int amount, bool enforce=false);

/**
 * Resets Achievement's progress. It also marks Achievement as not completed
 *
 * @param client			ID of the client
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @param enforce	  if true, omits minimal players restriction (ago_players_amount ConVar)
 * @return					true, if reset succeded. false otherwise.
 */
native bool AGO_ResetAchievement(int client, int IdOfAchievement, bool enforce=false);

/**
 * Sets the concrete amount of points to a given Achievement. Doesn't work if Achievement if already accomplished
 *
 * @param client			ID of the client
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @param amount			Amount of points to be set   
 * @param enforce	  if true, omits minimal players restriction (ago_players_amount ConVar)
 * @return					Current achievement progress or -1 if failure.
 */
native bool AGO_SetPoints(int client, int IdOfAchievement, int amount, bool enforce=false);

/**
 * Retrieves Achievement's name by its index
 *
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @param tab				Char[] array for Achievement's name
 * @param size				Size of the given array
 * @return					0 if success. On failure: -1 and array contains "NOT FOUND" string
 */
native void AGO_GetNameByIndex(int IdOfAchievement, char[] tab, int size);

/**
 * Retrieves Achievement's index, based on its name
 *
 * @param name				Array containing Achievement's name
 * @return					Achievement index if success. Otherwise, returns -1.
 */
native int AGO_GetIndexByName(char[] name);

/**
 * Retrieves Achievement's description by its index
 *
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @param tab				Char[] array for Achievement's description
 * @param size				Size of the given array
 * @return					0 if success. On failure: -1 and array contains "NOT FOUND" string
 */
native void AGO_GetDescriptionByIndex(int IdOfAchievement, char[] tab, int size);

/**
 * Retrieves current player Achievement's progress
 *
 * @param client			ID of the client
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @return					Achievement's progress on success. Otherwise, returns -1.
 */
native int AGO_GetAchievementProgress(int client, int IdOfAchievement);

/**
 * Checks if a certain achievement has been completed
 *
 * @param client			ID of the client
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 * @return					true - accomplished. false - not accomplished or invalid Achievement ID
 */
native int AGO_IsAchievementCompleted(int client, int IdOfAchievement);

/**
 * Returns the current amount of active Achievements
 *
 * @return					Amount of active achievements
 */
native int AGO_GetAmountOfAchievements();

/**
 * Checks whether or not the SQL tables has been succesfully created.
 *
 * @return					1: Tables created, 0: tables not created
 */
native int AGO_AreTablesCreated();

/**
 * Checks if a certain achievement has been completed
 *
 * @param client			ID of the client
 * @return					1: Success, 0: Failed
 */
 native void AGO_UpdatePlayer(int client);



/**
 * Called when all the achievements from all the plugins has been succesfully loaded
 */
forward void AGO_OnAllAchievementsLoaded();

/**
 * Called when a Achievement has been accomplished by a player
 *
 * @param client			ID of the client
 * @param IdOfAchievement	ID of achievement (retrieved from AGO_AddAchievement() function)
 */
forward void AGO_OnAchievementAccomplished(int client, int IdOfAchievement);

/**
 * Called when an engine is ready for registering new Achivements.That's the only place where it can be done
 */
forward void AGO_OnRegisterAchievements();

/**
 * Called when Achievements has been succesfully loaded for a certain player
 *
 * @param client			ID of the client
 */
forward void AGO_OnPlayerAchievementsLoaded(int client);