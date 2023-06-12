::mods_hookExactClass("states/tactical_state", function( object )
{
    local gB_nullCheck = "gatherBrothers" in object ? object.gatherBrothers : null;
    local parentName = object.SuperName;
    object.gatherBrothers <- function( _isVictory )
    {
        local vanilla_gatherBrothers = gB_nullCheck == null ? this[parentName].gatherBrothers : gB_nullCheck;
        local survivorRoster = ::Tactical.getSurvivorRoster().getAll();
        local isPlayer = false;

        foreach( bro in survivorRoster )
        {
            if (bro.getFlags().get("IsPlayerCharacter"))
            {
                isPlayer = true;
                break;
            }
        }

        if (!isPlayer)
        {
            return vanilla_gatherBrothers(_isVictory);
        }

        return vanilla_gatherBrothers(isPlayer);
    }
});