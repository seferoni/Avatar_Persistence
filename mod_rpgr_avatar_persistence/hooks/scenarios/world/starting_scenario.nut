::AP.Patcher.hookTree("scripts/scenarios/world/starting_scenario", function( p )
{
	::AP.Patcher.wrap(p, "onCombatFinished", function( _originalValue )
	{
		if (!::AP.Standard.getFlag("AvatarStatusConferred", ::World.Statistics))
		{	# Allows for execution of the vanilla method in cases where the elixir has never been used.
			return _originalValue;
		}

		if (::AP.Utilities.getPlayerInRoster(::World.getPlayerRoster()) != null)
		{	# This condition is evaluated in precisely the same way as implemented in scenarios that feature player characters.
			return true;
		}

		return false;
	});

	::AP.Patcher.wrap(p, "onSpawnPlayer", function()
	{
		if (!::AP.Standard.getParameter("AddElixirOnStart"))
		{
			return;
		}

		::World.Assets.getStash().add(::new(::AP.Utilities.getCommonField("ItemPaths").DiluteElixir));
	});
});