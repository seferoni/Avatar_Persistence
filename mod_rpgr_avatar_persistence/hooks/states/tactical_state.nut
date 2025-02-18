::AP.Patcher.hook("scripts/states/tactical_state", function( p )
{
	::AP.Patcher.wrap(p, "gatherBrothers", function( _isVictory )
	{
		if (::AP.Persistence.isCombatInArena())
		{
			return;
		}

		if (!::AP.Persistence.isPlayerInRoster(::Tactical.getSurvivorRoster()))
		{
			return;
		}

		if (!::AP.Standard.getSetting("LoseItemsUponDefeat"))
		{
			return true;
		}

		if (!_isVictory)
		{
			::AP.Persistence.executeDefeatRoutine();
		}

		return true;
	}, "overrideArguments");
});