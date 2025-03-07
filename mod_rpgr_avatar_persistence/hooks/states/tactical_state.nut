::AP.Patcher.hook("scripts/states/tactical_state", function( p )
{
	::AP.Patcher.wrap(p, "gatherBrothers", function( _isVictory )
	{
		if (::AP.Persistence.isCombatInArena())
		{	# Arena defeat logic does not require modification to achieve desired behaviour.
			return;
		}

		if (::AP.Persistence.getPlayerInRoster(::Tactical.getSurvivorRoster()) == null)
		{
			return;
		}

		if (!_isVictory)
		{
			::AP.Persistence.setQueueDefeatRoutineState(true);
		}

		return true;
	}, "overrideArguments");

	::AP.Patcher.wrap(p, "onFinish", function()
	{
		if (!::AP.Persistence.getQueueDefeatRoutineState())
		{
			return;
		}

		if (::AP.Persistence.getPlayerInRoster(::World.getPlayerRoster()) == null)
		{
			return;
		}

		// TODO: while the game is paused, the player retains access to all of their inventory items - loss is staggered. undesired behaviour!
		// need to remove items first, flag losses, and then produce appropriate list entries
		::Time.scheduleEvent(::TimeUnit.Virtual, 500, function( _dummy )
		{
			::AP.Persistence.fireDefeatEvent();
		}, null);
		::AP.Persistence.setQueueDefeatRoutineState(false);
	});
});