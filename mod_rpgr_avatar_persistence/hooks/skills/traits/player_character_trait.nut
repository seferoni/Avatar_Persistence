local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("skills/traits/player_character_trait", function( _object )
{
	AP.Standard.wrap(_object, "getTooltip", function( _tooltipArray )
	{
		if (!AP.Standard.getSetting("ModifyTooltip"))
		{
			return;
		}

		# Hide entries when the player sustains permanent injuries numbering greater than the designated threshold.
		if (!AP.Persistence.isWithinInjuryThreshold(this.getContainer().getActor()))
		{
			return;
		}

		local push = @(_entry) _tooltipArray.push(_entry);

		# Create persistence entry.
		push({id = 10, type = "text", icon = AP.Persistence.Tooltip.Icons.Persistence, text = format("%s being struck down by most foes", AP.Standard.colourWrap("Will survive", AP.Standard.Colour.Green))})

		# Create warning entry.
		push({id = 10, type = "text", icon = AP.Persistence.Tooltip.Icons.Warning, text = format("Loses persistence when %s", AP.Persistence.getThresholdWarningText())});

		return _tooltipArray;
	}, "overrideReturn");
});