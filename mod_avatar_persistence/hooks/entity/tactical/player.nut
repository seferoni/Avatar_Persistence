::mods_hookExactClass("entity/tactical/player", function( object )
{
    local iRK_nullCheck = "isReallyKilled" in object ? object.isReallyKilled : null;
    local parentName = object.SuperName;
    object.isReallyKilled <- function( _fatalityType )
    {
        local vanilla_isReallyKilled = iRK_nullCheck == null ? this[parentName].isReallyKilled : iRK_nullCheck;

        if (!this.getFlags().get("IsPlayerCharacter"))
        {
            return vanilla_isReallyKilled(_fatalityType);
        }

        local injuryCount = this.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len();

        if (injuryCount > ::Avatar_Persistence.Mod.ModSettings.getSetting("PermanentInjuryThreshold").getValue())
        {
            return true;
        }

        if (::Math.rand(1, 100) > ::Avatar_Persistence.Mod.ModSettings.getSetting("PermanentInjuryChance").getValue())
        {
            this.worsenMood(::Const.MoodChange.PermanentInjury, "Was struck down");
            ::Tactical.getSurvivorRoster().add(this);
            this.m.IsDying = false;
            return false;
        }

        local permanentInjuries = ::Const.Injury.Permanent;
        local injuryCandidates = [];
        local injuriesToCull = ["injury.missing_nose", "injury.missing_eye", "injury.missing_ear", "injury.brain_damage", "injury.missing_finger"];

        foreach( injury in permanentInjuries )
        {
            if (injuriesToCull.find(injury.ID) != null)
            {
                continue;
            }

            if (this.getSkills().hasSkill(injury.ID))
            {
                continue;
            }

            injuryCandidates.append(injury);
        }

        if (injuryCandidates.len() == 0)
        {
            this.worsenMood(::Const.MoodChange.PermanentInjury, "Was struck down");
            ::Tactical.getSurvivorRoster().add(this);
            this.m.IsDying = false;
            ::logInfo("No injury candidates to be applied.");
            return false;
        }

        this.getSkills().add(::new("scripts/skills/" + injuryCandidates[::Math.rand(0, injuryCandidates.len() - 1)].Script));
        this.worsenMood(::Const.MoodChange.PermanentInjury, "Was grievously struck down");
        ::Tactical.getSurvivorRoster().add(this);
        this.m.IsDying = false;
        return false;
    }
});