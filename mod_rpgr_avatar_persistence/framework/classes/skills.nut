::AP.Skills <-
{
	function addInjuryByScript( _injuryScript, _playerObject )
	{
		_playerObject.getSkills().add(::new(_injuryScript));
	}

	function addMomentum( _playerObject )
	{
		local skills = _playerObject.getSkills();

		if (skills.hasSkill("effects.ap_momentum"))
		{
			return;
		}

		skills.add(::new(::AP.Utilities.getField("SkillPaths").Momentum));
	}

	function createPlayerCharacterTraitTooltipEntries( _playerObject )
	{
		local entries = [];
		local push = @(_entry) ::AP.Standard.push(_entry, entries);

		push(this.createPlayerCharacterTraitTutorialEntry(_playerObject));
		return entries;
	}

	function createPlayerCharacterTraitTutorialEntry( _playerObject )
	{
		local threshold = ::AP.Standard.getParameter("PermanentInjuryThreshold");
		local thresholdDifferential = this.getPermanentInjuryThresholdDifferential(_playerObject);

		local iconKey = "Warning";
		local tutorialText = format(::AP.Utilities.getTooltipString("InjuryThresholdTooltip"), ::AP.Standard.colourWrap(threshold, ::AP.Standard.Colour.Red));

		if (thresholdDifferential == 0)
		{
			tutorialText = ::AP.Strings.getFragmentsAsCompiledString("InjuryThresholdTooltipBaselineFragment", "Persistence");
		}
		else if (thresholdDifferential > 0)
		{
			iconKey = "Skull";
			tutorialText = ::AP.Standard.colourWrap(::AP.Utilities.getTooltipString("InjuryThresholdExceededTooltip"), ::AP.Standard.Colour.Red);
		}

		return ::AP.Standard.constructEntry
		(
			iconKey,
			tutorialText
		);
	}

	function generateInjuryCandidates( _player )
	{
		return ::Const.Injury.Permanent.filter(function(_injuryIndex, _injuryTable )
		{
			if (::AP.Utilities.getField("ExcludedInjuries").find(_injuryTable.ID) != null)
			{
				return false;
			}

			if (_player.getSkills().hasSkill(_injuryTable.ID))
			{
				return false;
			}

			return true;
		});
	}

	function getPermanentInjuryCount( _playerObject )
	{
		return _playerObject.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len();
	}

	function getPermanentInjuryThresholdDifferential( _playerObject )
	{
		local permanentInjuries = this.getPermanentInjuryCount(_playerObject);
		return permanentInjuries - ::AP.Standard.getParameter("PermanentInjuryThreshold");
	}

	function getSkillField( _fieldName )
	{
		return ::AP.Database.getField("Skills", _fieldName);
	}

	function getSkillStringField( _fieldName )
	{
		return ::AP.Strings.getField("Skills", _fieldName);
	}

	function resetMomentum( _playerObject )
	{
		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			return;
		}

		_playerObject.getSkills().getSkillByID("effects.ap_momentum").resetMomentum();
	}
};