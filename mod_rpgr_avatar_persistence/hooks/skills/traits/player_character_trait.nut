::AP.Patcher.hook("scripts/skills/traits/player_character_trait", function( p )
{
	::AP.Patcher.wrap(p, "getTooltip", function( _tooltipArray )
	{
		if (!::AP.Standard.getParameter("ModifyTooltip"))
		{
			return;
		}

		_tooltipArray.extend(::AP.Persistence.createTooltipEntries(this.getContainer().getActor()));
		return _tooltipArray;
	});

	::AP.Patcher.wrap(p, "onAdded", function()
	{
		::AP.Persistence.addMomentum(this.getContainer().getActor());
	});
});