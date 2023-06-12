::Avatar_Persistence <-
{
    ID = "mod_avatar_persistence",
    Name = "RPG Rebalance - Avatar Persistence",
    Version = "1.1.0"
};

::mods_registerMod(::Avatar_Persistence.ID, ::Avatar_Persistence.Version, ::Avatar_Persistence.Name);
::mods_queue(::Avatar_Persistence.ID, "mod_msu(>=1.2.6)", function()
{
    ::Avatar_Persistence.Mod <- ::MSU.Class.Mod(::Avatar_Persistence.ID, ::Avatar_Persistence.Version, ::Avatar_Persistence.Name);
    // module interfacing
    ::RPGR_AR_ModuleFound <- ::mods_getRegisteredMod("mod_avatar_resistances") != null;
    // pages
    local pageGeneral = ::Avatar_Persistence.Mod.ModSettings.addPage("General");
    // settings
    local permanentInjuryChance = pageGeneral.addRangeSetting("PermanentInjuryChance", 33, 1, 100, 1, "Permanent Injury Chance");
    permanentInjuryChance.setDescription("Percentage chance for the player character to suffer permanent injuries upon defeat.");

    local permanentInjuryThreshold = pageGeneral.addRangeSetting("PermanentInjuryThreshold", 3, 1, 8, 1, "Permanent Injury Threshold");
    permanentInjuryThreshold.setDescription("Determines the threshold value of the number of permanent injuries the player character can have before persistence is lost.");

    local modifyTooltip = pageGeneral.addBooleanSetting("ModifyTooltip", true, "Modify Tooltip");
    modifyTooltip.setDescription("Determines whether the player character trait tooltip reflects changes brought about by this mod. Designed for compatibility.");

    // MSU setup ends here
    foreach( file in ::IO.enumerateFiles("mod_avatar_persistence/hooks") )
    {
        ::include(file);
    }
});