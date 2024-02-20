local AP = ::RPGR_Avatar_Persistence;
::mods_hookBaseClass("scenarios/world/starting_scenario", function( _object )
{
	AP.Standard.wrap(_object, "onCombatFinished", function( ... )
	{
		if (!AP.Standard.getFlag("AvatarStatusConferred", ::World.Statistics))
		{	# Allows for execution of the vanilla method in cases where the elixir has never been used.
			return;
		}

		if (AP.Persistence.isPlayerInRoster(AP.Persistence.Rosters.World))
		{	# This condition is evaluated in precisely the same way as implemented in scenarios that feature player characters.
			return true;
		}

		return false;
		# overrideReturn is a viable alternative - but overrideMethod is more efficient, which is important considering how frequently onCombatFinished is called.
	}, "overrideMethod");
});