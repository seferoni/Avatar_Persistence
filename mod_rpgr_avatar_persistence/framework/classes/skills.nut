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

		skills.add(::new(::AP.Utilities.getCommonField("SkillPaths").Momentum));
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
		local thresholdDifferential = this.getPermanentInjuryThresholdDifferential(_playerObject);
		local tooltipData = this.getTooltipDataByInjuryDifferential(thresholdDifferential);
		return ::AP.Standard.constructEntry
		(
			tooltipData.IconKey,
			tooltipData.Text
		);
	}

	function generateInjuryCandidates( _player )
	{
		return ::Const.Injury.Permanent.filter(function(_injuryIndex, _injuryTable )
		{
			if (::AP.Utilities.getCommonField("ExcludedInjuries").find(_injuryTable.ID) != null)
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

	function getSkillData( _key )
	{
		return this.getSkillField("SkillData")[_key];
	}

	function getSkillField( _fieldName )
	{
		return ::AP.Database.getField("Skills", _fieldName);
	}

	function getSkillStringField( _fieldName )
	{
		return ::AP.Strings.getField("Skills", _fieldName);
	}

	function getTooltipDataByInjuryDifferential( _injuryDifferential )
	{
		local colour = @(_string) ::AP.Standard.colourWrap(_string, ::AP.Standard.Colour.Red);
		local tooltipData =
		{
			IconKey = "Warning",
			Text = format(::AP.Utilities.getTooltipString("InjuryThresholdTooltip"), colour(threshold))
		};

		if (_injuryDifferential > 0)
		{
			tooltipData.IconKey = "Skull";
			tooltipData.Text = colour(::AP.Utilities.getTooltipString("InjuryThresholdExceededTooltip"));
		}
		else if (_injuryDifferential == 0)
		{
			tooltipData.Text = ::AP.Utilities.compileTooltipFragments("InjuryThresholdTooltipBaselineFragment");
		}

		return tooltipData;
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