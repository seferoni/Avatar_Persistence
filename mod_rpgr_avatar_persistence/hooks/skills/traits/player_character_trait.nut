local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("skills/traits/player_character_trait", function( object )
{
    /*local parentName = object.SuperName;

    local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
    object.getTooltip <- function()
    {
        local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();

        if (!::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("ModifyTooltip").getValue())
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

        if (!::RPGR_AR_ModuleFound || ::RPGR_AR_ModuleFound && !::RPGR_Avatar_Resistances.Mod.ModSettings.getSetting("ModifyTooltip").getValue())
        {
            tooltipArray.append(::RPGR_Avatar_Persistence.generateTooltipTableEntry(id, type, "warning.png", "Loses persistence when " + ::RPGR_Avatar_Persistence.retrieveThresholdWarningText()));
        }

        return tooltipArray;
    }*/

    AP.Standard.wrap(object, "getTooltip", function( _tooltipArray )
    {
        if (!::AP.Standard.getSetting("ModifyTooltip"))
        {
            return _tooltipArray;
        }

        if (!::AP.Persistence.isWithinInjuryThreshold(this.getContainer().getActor()))
        {
            return _tooltipArray;
        }

        local id = 10;
        local type = "text";

        _tooltipArray.append(AP.Standard.generateTooltipTableEntry(id, type, "obituary.png", "[color=" + ::Const.UI.Color.PositiveValue + "]" + "Will survive[/color] being struck down by most foes"));

        if (!::RPGR_AR_ModuleFound || ::RPGR_AR_ModuleFound && !AP.Standard.getSetting("ModifyTooltip"))
        {
            _tooltipArray.append(AP.Standard.generateTooltipTableEntry(id, type, "warning.png", format("Loses persistence when %s", AP.Persistence.retrieveThresholdWarningText())));
        }

        return _tooltipArray;
    }, {Order = null, ReturnSequence = null, HookProcedure = "overrideReturn"});

});