::AP.Patcher.hook("scripts/scenarios/world/starting_scenario", function( p )
{
	::AP.Patcher.wrap(p, "onCombatFinished", function( ... )
	{
		if (!::AP.Standard.getFlag("AvatarStatusConferred", ::World.Statistics))
		{	# Allows for execution of the vanilla method in cases where the elixir has never been used.
			return;
		}

		if (::AP.Persistence.getPlayerInRoster(::World.getPlayerRoster()) != null)
		{	# This condition is evaluated in precisely the same way as implemented in scenarios that feature player characters.
			return true;
		}

		return false;
	}, "overrideMethod");
});