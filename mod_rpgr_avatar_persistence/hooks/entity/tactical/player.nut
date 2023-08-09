::mods_hookExactClass("entity/tactical/player", function( object )
{
    local parentName = object.SuperName;

    local iRK_nullCheck = "isReallyKilled" in object ? object.isReallyKilled : null;
    object.isReallyKilled <- function( _fatalityType )
    {
        local vanilla_isReallyKilled = iRK_nullCheck == null ? this[parentName].isReallyKilled : iRK_nullCheck;

        if (!::RPGR_Avatar_Persistence.isActorEligible(this.getFlags()))
        {
            return vanilla_isReallyKilled(_fatalityType);
        }

        if (!::RPGR_Avatar_Persistence.isWithinInjuryThreshold(this))
        {
            return true;
        }

        if (::Math.rand(1, 100) > ::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("PermanentInjuryChance").getValue())
        {
            return ::RPGR_Avatar_Persistence.executePersistenceRoutine(this, "Was struck down");
        }

        local injuryCandidates = [];
        injuryCandidates.extend(::RPGR_Avatar_Persistence.generateInjuryCandidates(this));

        if (injuryCandidates.len() == 0)
        {
            ::logInfo("[Avatar Persistence] No injury candidates were found eligible for application to the player.");
            return ::RPGR_Avatar_Persistence.executePersistenceRoutine(this, "Was struck down");
        }

        this.getSkills().add(::new("scripts/skills/" + injuryCandidates[::Math.rand(0, injuryCandidates.len() - 1)].Script));
        return ::RPGR_Avatar_Persistence.executePersistenceRoutine(this, "Was grievously struck down");
    }
});