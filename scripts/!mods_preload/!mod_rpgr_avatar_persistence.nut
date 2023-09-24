::RPGR_Avatar_Persistence <-
{
    ID = "mod_rpgr_avatar_persistence",
    Name = "RPG Rebalance - Avatar Persistence",
    Version = "1.2.0"
    Defaults =
    {
        PermanentInjuryChance = 100,
        PermanentInjuryThreshold = 1,
        ItemRemovalChance = 33,
        ItemRemovalCeiling = 6,
        LoseItemsUponDefeat = false,
        ModifyTooltip = true,
        VerboseLogging = false
    }
}

::mods_registerMod(::RPGR_Avatar_Persistence.ID, ::RPGR_Avatar_Persistence.Version, ::RPGR_Avatar_Persistence.Name);
::mods_queue(::RPGR_Avatar_Persistence.ID, "mod_msu(>=1.2.6)", function()
{
    ::RPGR_Avatar_Persistence.MSUFound <- ::mods_getRegisteredMod("mod_msu") != null;
    ::RPGR_AR_ModuleFound <- ::mods_getRegisteredMod("mod_rpgr_avatar_resistances") != null;

    if (!::RPGR_Avatar_Persistence.MSUFound)
    {
        return;
    }

    ::RPGR_Avatar_Persistence.Mod <- ::MSU.Class.Mod(::RPGR_Avatar_Persistence.ID, ::RPGR_Avatar_Persistence.Version, ::RPGR_Avatar_Persistence.Name);

    local pageGeneral = ::RPGR_Avatar_Persistence.Mod.ModSettings.addPage("General");
    local pageItemLoss = ::RPGR_Avatar_Persistence.Mod.ModSettings.addPage("Item Loss");

    local permanentInjuryChance = pageGeneral.addRangeSetting("PermanentInjuryChance", 100, 1, 100, 1, "Permanent Injury Chance");
    permanentInjuryChance.setDescription("Determines the percentage chance for the player character to suffer permanent injuries upon defeat.");

    local permanentInjuryThreshold = pageGeneral.addRangeSetting("PermanentInjuryThreshold", 1, 0, 8, 1, "Permanent Injury Threshold");
    permanentInjuryThreshold.setDescription("Determines the threshold value of the number of permanent injuries the player character can have before persistence is lost.");

    local itemRemovalChance = pageItemLoss.addRangeSetting("ItemRemovalChance", 33, 1, 100, 1, "Item Removal Chance");
    itemRemovalChance.setDescription("Determines the percentage chance for individual items to be removed from the player's stash. Does nothing if Lose Items Upon Defeat is disabled.");

    local itemRemovalCeiling = pageItemLoss.addRangeSetting("ItemRemovalCeiling", 6, 1, 10, 1, "Item Removal Ceiling");
    itemRemovalCeiling.setDescription("Determines the maximum number of items that may be removed per instance of player defeat. Does nothing if Lose Items Upon Defeat is disabled.");

    local loseItemsUponDefeat = pageGeneral.addBooleanSetting("LoseItemsUponDefeat", false, "Lose Items Upon Defeat");
    loseItemsUponDefeat.setDescription("Determines whether items kept in the player's stash are removed at random upon defeat, in the case of persistence.");

    local modifyTooltip = pageGeneral.addBooleanSetting("ModifyTooltip", true, "Modify Tooltip");
    modifyTooltip.setDescription("Determines whether the player character trait tooltip reflects changes brought about by this mod.");

    local verboseLogging = pageGeneral.addBooleanSetting("VerboseLogging", false, "Verbose Logging");
    verboseLogging.setDescription("Enables verbose logging. Recommended for testing purposes only, as the volume of logged messages can make parsing the log more difficult for general use and debugging.");
});

