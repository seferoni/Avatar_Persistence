::AP.Patcher.hook("scripts/states/tactical_state", function( p )
{
	::AP.Patcher.wrap(p, "gatherBrothers", function( _isVictory )
	{
		if (::AP.Utilities.isCombatInArena())
		{	# Arena defeat logic does not require modification to achieve desired behaviour.
			return;
		}

		if (::AP.Utilities.getPlayerInRoster(::Tactical.getSurvivorRoster()) == null)
		{	# A struck-down player character is always added to the survivor roster.
			return;
		}

		if (!_isVictory && ::Tactical.Entities.getCombatResult() == ::Const.Tactical.CombatResult.PlayerDestroyed)
		{
			::AP.Persistence.setQueueDefeatRoutineState(true);
		}

		return true;
	}, "overrideArguments");
});