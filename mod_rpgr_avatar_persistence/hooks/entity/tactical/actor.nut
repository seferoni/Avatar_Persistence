local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("entity/tactical/actor", function( object )
{
    /*local parentName = object.SuperName;

    local k_nullCheck = "kill" in object ? object.kill : null;
    object.kill <- function( _killer = null, _skill = null, _fatalityType = ::Const.FatalityType.None, _silent = true )
    {
        local vanilla_kill = k_nullCheck == null ? this[parentName].kill : k_nullCheck;

        if (!AP.Persistence.isActorEligible(this.getFlags()))
        {
            return vanilla_kill(_killer, _skill, _fatalityType, _silent);
        }

        if (!AP.Persistence.isWithinInjuryThreshold(this))
        {
            return vanilla_kill(_killer, _skill, _fatalityType, _silent);
        }

        return vanilla_kill(_killer, _skill, ::Const.FatalityType.None, _silent);
    }*/

    AP.Standard.wrap(object, "kill", function( _killer = null, _skill = null, _fatalityType = ::Const.FatalityType.None, _silent = true )
    {
        if (!AP.Persistence.isActorEligible(this.getFlags()))
        {
            return null;
        }

        if (!AP.Persistence.isWithinInjuryThreshold(this))
        {
            return null;
        }

        return [_killer, _skill, ::Const.FatalityType.None, _silent];
    }, {Order = null, ReturnSequence = null, HookProcedure = "overrideArguments"});
});
