local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("entity/tactical/player", function( object )
{
    AP.Standard.wrap(object, "isReallyKilled", function( _fatalityType )
    {
        if (!AP.isActorViable(this))
        {
            return;
        }

        if (!AP.isWithinInjuryThreshold(this))
        {
            return;
        }

        if (::Math.rand(1, 100) > AP.Standard.getSetting("PermanentInjuryChance"))
        {
            return AP.Persistence.executePersistenceRoutine(this, "Was struck down");
        }

        local injuryCandidates = AP.Persistence.generateInjuryCandidates(this);

        if (injuryCandidates.len() == 0)
        {
            AP.Standard.logWrapper("No injury candidates were found viable for application to the player.", true);
            return AP.Persistence.executePersistenceRoutine(this, "Was struck down");
        }

        this.getSkills().add(::new("scripts/skills/" + injuryCandidates[::Math.rand(0, injuryCandidates.len() - 1)].Script));
        return AP.Persistence.executePersistenceRoutine(this, "Was grievously struck down");
    }, "overrideMethod");
});