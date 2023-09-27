local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("skills/traits/player_character_trait", function( object )
{
    AP.Standard.wrap(object, "getTooltip", function( ... )
    {
        local tooltipArray = vargv[0];

        if (!AP.Standard.getSetting("ModifyTooltip"))
        {
            return tooltipArray;
        }

        if (!AP.Persistence.isWithinInjuryThreshold(this.getContainer().getActor()))
        {
            return tooltipArray;
        }

        local id = 10, type = "text";
        tooltipArray.push(AP.Standard.generateTooltipTableEntry(id, type, "obituary.png", "[color=" + ::Const.UI.Color.PositiveValue + "]" + "Will survive[/color] being struck down by most foes"));

        if (!AP.Internal.ARFound || (AP.Internal.ARFound && !::RPGR_Avatar_Resistances.Standard.getSetting("ModifyTooltip")))
        {
            tooltipArray.push(AP.Standard.generateTooltipTableEntry(id, type, "warning.png", format("Loses persistence when %s", AP.Persistence.retrieveThresholdWarningText())));
        }

        return tooltipArray;
    }, "overrideReturn");
});