::mods_hookExactClass("states/tactical_state", function( object )
{
    local parentName = object.SuperName;

    local gB_nullCheck = "gatherBrothers" in object ? object.gatherBrothers : null;
    object.gatherBrothers <- function( _isVictory )
    {
        local vanilla_gatherBrothers = gB_nullCheck == null ? this[parentName].gatherBrothers : gB_nullCheck;

        if (!::RPGR_Avatar_Persistence.isPlayerInSurvivorRoster())
        {
            return vanilla_gatherBrothers(_isVictory);
        }

        ::World.Statistics.getFlags().set("LastCombatVictory", _isVictory);

        if (!::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("LoseItemsUponDefeat").getValue())
        {
            return vanilla_gatherBrothers(true);
        }

        if (!_isVictory)
        {
            ::RPGR_Avatar_Persistence.removeItemsUponCombatLoss();
        }

        return vanilla_gatherBrothers(true);
    }
});