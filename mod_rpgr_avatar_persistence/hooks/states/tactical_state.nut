::AP.Patcher.hook("scripts/states/tactical_state", function( p )
{
	::AP.Patcher.wrap(p, "gatherBrothers", function( _isVictory )
	{
		if (::AP.Persistence.isCombatInArena())
		{
			return;
		}

		if (::AP.Persistence.getPlayerInRoster(::Tactical.getSurvivorRoster()) == null)
		{
			return;
		}

		if (!::AP.Standard.getParameter("LoseItemsUponDefeat"))
		{
			return true;
		}

		if (!_isVictory)
		{
			::AP.Persistence.fireDefeatEvent();
		}

		return true;
	}, "overrideArguments");
});