local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("entity/tactical/player", function( object )
{
    /*local parentName = object.SuperName;

    local iRK_nullCheck = "isReallyKilled" in object ? object.isReallyKilled : null;
    object.isReallyKilled <- function( _fatalityType )
    {
        local vanilla_isReallyKilled = iRK_nullCheck == null ? this[parentName].isReallyKilled : iRK_nullCheck;

        if (!AP.isActorEligible(this.getFlags()))
        {
            return vanilla_isReallyKilled(_fatalityType);
        }

        if (!AP.isWithinInjuryThreshold(this))
        {
            return true;
        }

        if (::Math.rand(1, 100) > AP.Mod.ModSettings.getSetting("PermanentInjuryChance").getValue())
        {
            return AP.executePersistenceRoutine(this, "Was struck down");
        }

        local injuryCandidates = [];
        injuryCandidates.extend(AP.generateInjuryCandidates(this));

        if (injuryCandidates.len() == 0)
        {
            AP.logWrapper("No injury candidates were found eligible for application to the player.", true);
            return AP.executePersistenceRoutine(this, "Was struck down");
        }

        this.getSkills().add(::new("scripts/skills/" + injuryCandidates[::Math.rand(0, injuryCandidates.len() - 1)].Script));
        return AP.executePersistenceRoutine(this, "Was grievously struck down");
    }*/

    AP.Standard.wrap(object, "isReallyKilled", function( _fatalityType )
    {
        if (!AP.isActorEligible(this.getFlags()))
        {
            return null;
        }

        if (!AP.isWithinInjuryThreshold(this))
        {
            return null;
        }

        if (::Math.rand(1, 100) > AP.Standard.getSetting("PermanentInjuryChance"))
        {
            return AP.Persistence.executePersistenceRoutine(this, "Was struck down");
        }

        local injuryCandidates = AP.Persistence.generateInjuryCandidates(this);

        if (injuryCandidates.len() == 0)
        {
            AP.Standard.logWrapper("No injury candidates were found eligible for application to the player.", true);
            return AP.Persistence.executePersistenceRoutine(this, "Was struck down");
        }

        this.getSkills().add(::new("scripts/skills/" + injuryCandidates[::Math.rand(0, injuryCandidates.len() - 1)].Script));
        return AP.Persistence.executePersistenceRoutine(this, "Was grievously struck down");
    }, {Order = null, ReturnSequence = null, HookProcedure = "overrideMethod"});
});