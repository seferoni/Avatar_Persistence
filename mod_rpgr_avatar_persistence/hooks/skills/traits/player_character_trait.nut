::AP.Patcher.hook("scripts/skills/traits/player_character_trait", function( p )
{
	::AP.Patcher.wrap(p, "getTooltip", function( _tooltipArray )
	{
		if (!::AP.Standard.getParameter("ModifyTooltip"))
		{
			return;
		}

		_tooltipArray.extend(::AP.Skills.createPlayerCharacterTraitTooltipEntries(this.getContainer().getActor()));
		return _tooltipArray;
	});

	::AP.Patcher.wrap(p, "onAdded", function()
	{
		::AP.Skills.addMomentum(this.getContainer().getActor());
	});
});