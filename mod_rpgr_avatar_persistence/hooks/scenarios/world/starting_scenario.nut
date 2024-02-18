local AP = ::RPGR_Avatar_Persistence;
::mods_hookBaseClass("scenarios/world/starting_scenario", function( _object )
{
	AP.Standard.wrap(_object, "onCombatFinished", function( ... )
	{
		if (!AP.Standard.getSetting("ElixirConfersAvatarStatus"))
		{
			return;
		}

		if (!AP.Standard.getFlag("AvatarStatusConferred", ::World.Statistics))
		{
			return;
		}

		local roster = ::World.getPlayerRoster().getAll();

		if (AP.Persistence.isPlayerInRoster())
		{
			return true;
		}

		return false;
	});
})