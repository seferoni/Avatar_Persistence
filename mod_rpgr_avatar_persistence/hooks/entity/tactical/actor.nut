local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("entity/tactical/actor", function( object )
{
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
    }, "overrideArguments");
});
