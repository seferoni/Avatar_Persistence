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

        _tooltipArray.push({id = 10, type = "text", icon = "ui/icons/obituary.png", text = format("%s being struck down by most foes", AP.Standard.colourWrap("Will survive", "PositiveValue"))});

        if (!AP.Internal.ARFound || (AP.Internal.ARFound && !::RPGR_Avatar_Resistances.Standard.getSetting("ModifyTooltip")))
        {
            _tooltipArray.push({id = 10, type = "text", icon = "ui/icons/warning.png", text = format("Loses persistence when %s", AP.Persistence.getThresholdWarningText())});
        }

        return _tooltipArray;
    }, "overrideReturn");
});