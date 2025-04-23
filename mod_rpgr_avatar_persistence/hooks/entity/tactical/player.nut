::AP.Patcher.hook("scripts/entity/tactical/player", function( p )
{
	::AP.Patcher.wrap(p, "isReallyKilled", function( _fatalityType )
	{
		if (!::AP.Utilities.isActorPlayerCharacter(this))
		{
			return;
		}

		if (::AP.Skills.getPermanentInjuryThresholdDifferential(this) > 0)
		{
			return;
		}

		if (::Math.rand(1, 100) > ::AP.Standard.getParameter("PermanentInjuryChance"))
		{
			::AP.Persistence.executePersistenceRoutine(this);
			return false;
		}

		local injuryCandidates = ::AP.Skills.generateInjuryCandidates(this);

		if (injuryCandidates.len() == 0)
		{
			::AP.Standard.log("No injury candidates were found viable for application to the player.", true);
			::AP.Persistence.executePersistenceRoutine(this);
			return false;
		}

		::AP.Skills.addInjuryByScript(format("scripts/skills/%s", injuryCandidates[::Math.rand(0, injuryCandidates.len() - 1)].Script), this);
		::AP.Persistence.executePersistenceRoutine(this, true);
		return false;
	}, "overrideMethod");
});