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

		_tooltipArray.extend(AP.Persistence.createTooltipEntries());
		return _tooltipArray;
	}, "overrideReturn");
});