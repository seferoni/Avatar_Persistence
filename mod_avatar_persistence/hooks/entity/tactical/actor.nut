::mods_hookExactClass("entity/tactical/actor", function( object )
{
    local k_nullCheck = "kill" in object ? object.kill : null;
    local parentName = object.SuperName;
    object.kill <- function( _killer = null, _skill = null, _fatalityType = ::Const.FatalityType.None, _silent = true )
    {
        local vanilla_kill = k_nullCheck == null ? this[parentName].kill : k_nullCheck;

        if (!this.getFlags().get("IsPlayerCharacter"))
        {
            return vanilla_kill(_killer, _skill, _fatalityType, _silent);
        }

        local injuryCount = this.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len();

        if (injuryCount > ::Avatar_Persistence.Mod.ModSettings.getSetting("PermanentInjuryThreshold").getValue())
        {
            return vanilla_kill(_killer, _skill, _fatalityType, _silent);
        }

        return vanilla_kill(_killer, _skill, ::Const.FatalityType.None, _silent);
    }
});
