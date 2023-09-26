local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("states/tactical_state", function( object )
{
    AP.Standard.wrap(object, "gatherBrothers", function( _isVictory )
    {
        if (!::RPGR_Avatar_Persistence.isPlayerInSurvivorRoster())
        {
            return null;
        }

        if (!AP.Standard.getSetting("LoseItemsUponDefeat"))
        {
            return true;
        }

        if (!_isVictory)
        {
            AP.Persistence.removeItemsUponCombatLoss();
        }

        return true;
    }, "overrideArguments");
});