::mods_hookExactClass("skills/traits/player_character_trait", function( object )
{
    local parentName = object.SuperName;

    local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip <- function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();

        if (::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("ModifyTooltip").getValue() == false)
        {
            return tooltipArray;
        }

        if (!::RPGR_Avatar_Persistence.isWithinInjuryThreshold(this.getContainer().getActor()))
        {
            return tooltipArray;
        }

        local id = 10;
        local type = "text";

        tooltipArray.append(::RPGR_Avatar_Persistence.generateTooltipTableEntry(id, type, "obituary.png", "[color=" + ::Const.UI.Color.PositiveValue + "]" + "Will survive[/color] being struck down by most foes"));

        if (!::RPGR_AR_ModuleFound || ::RPGR_AR_ModuleFound && ::RPGR_Avatar_Resistances.Mod.ModSettings.getSetting("ModifyTooltip").getValue() == false)
        {
            local persistenceThresholdText = "Loses persistence when more than [color=" + ::Const.UI.Color.NegativeValue + "]" + ::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("PermanentInjuryThreshold").getValue() + "[/color] permanent injuries are suffered at a time";
            tooltipArray.append(::RPGR_Avatar_Persistence.generateTooltipTableEntry(id, type, "warning.png", persistenceThresholdText));
        }

        return tooltipArray;
    }
});