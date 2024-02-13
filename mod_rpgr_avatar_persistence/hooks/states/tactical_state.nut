local AP = ::RPGR_Avatar_Persistence;
::mods_hookExactClass("states/tactical_state", function( _object )
{
	AP.Standard.wrap(_object, "gatherBrothers", function( _isVictory )
	{
		if (!AP.Persistence.isPlayerInSurvivorRoster())
		{
			return;
		}

		if (!AP.Standard.getSetting("LoseItemsUponDefeat"))
		{
			return true;
		}

		if (!_isVictory)
		{
			AP.Persistence.executeDefeatRoutine();
		}

		return true;
	}, "overrideArguments");
});