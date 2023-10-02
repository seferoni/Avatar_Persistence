local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("skills/traits/player_character_trait", function( _object )
{
    AP.Standard.wrap(_object, "getTooltip", function( _tooltipArray )
    {
        if (!AP.Standard.getSetting("ModifyTooltip"))
        {
            return;
        }

        if (!AP.Persistence.isWithinInjuryThreshold(this.getContainer().getActor()))
        {
            return;
        }

        local id = 10, type = "text";
        _tooltipArray.push(AP.Standard.makeTooltip(id, type, "obituary.png", format("%s being struck down by most foes", AP.Standard.colourWrap("Will survive", "PositiveValue"))));

        if (!AP.Internal.ARFound || (AP.Internal.ARFound && !::RPGR_Avatar_Resistances.Standard.getSetting("ModifyTooltip")))
        {
            _tooltipArray.push(AP.Standard.makeTooltip(id, type, "warning.png", format("Loses persistence when %s", AP.Persistence.getThresholdWarningText())));
        }

        return _tooltipArray;
    }, "overrideReturn");
});