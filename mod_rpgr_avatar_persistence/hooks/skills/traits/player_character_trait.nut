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

		local threshold = AP.Standard.getSetting("PermanentInjuryThreshold"),
		warningText = "Loses persistence when any permanent injuries are sustained";

		if (threshold != 0)
		{
			warningText = format("Loses persistence when more than %s permanent injuries are sustained at a time", AP.Standard.colourWrap(threshold, AP.Standard.Colour.Red));
		}

		# Create warning entry.
		push({id = 10, type = "text", icon = AP.Persistence.Tooltip.Icons.Warning, text = warningText});

		return _tooltipArray;
	}, "overrideReturn");
});