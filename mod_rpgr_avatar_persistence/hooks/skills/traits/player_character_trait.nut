local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("skills/traits/player_character_trait", function( object )
{
    AP.Standard.wrap(object, "getTooltip", function( _tooltipArray )
    {
        if (!AP.Standard.getSetting("ModifyTooltip"))
        {
            return _tooltipArray;
        }

        if (!AP.Persistence.isWithinInjuryThreshold(this.getContainer().getActor()))
        {
            return _tooltipArray;
        }

        local id = 10, type = "text";
        _tooltipArray.push(AP.Standard.generateTooltipTableEntry(id, type, "obituary.png", "[color=" + ::Const.UI.Color.PositiveValue + "]" + "Will survive[/color] being struck down by most foes"));

        if (!::RPGR_AR_ModuleFound || ::RPGR_AR_ModuleFound && !::RPGR_Avatar_Resistances.Standard.getSetting("ModifyTooltip"))
        {
            _tooltipArray.push(AP.Standard.generateTooltipTableEntry(id, type, "warning.png", format("Loses persistence when %s", AP.Persistence.retrieveThresholdWarningText())));
        }

        return _tooltipArray;
    }, "overrideReturn");
});