::AP.Skills <-
{
	function addInjuryByScript( _injuryScript, _playerObject )
	{
		_playerObject.getSkills().add(::new(_injuryScript));
	}

	function addMomentum( _playerObject )
	{
		if (this.hasMomentum(_playerObject))
		{
			return;
		}

		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			return;
		}

		_playerObject.getSkills().add(::new(::AP.Utilities.getCommonField("SkillPaths").Momentum));
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

	function getSkillStringField( _fieldName, _logWarning = true )
	{
		return ::AP.Strings.getField("Skills", _fieldName, _logWarning);
	}

	function getTooltipDataByInjuryDifferential( _injuryDifferential )
	{
		local colour = @(_string) ::AP.Standard.colourWrap(_string, ::AP.Standard.Colour.Red);
		local tooltipData =
		{
			IconKey = "Warning",
			Text = format(::AP.Utilities.getTooltipString("InjuryThresholdTooltip"), colour(::Math.abs(_injuryDifferential) + 1))
		};

		if (_injuryDifferential >= 1)
		{
			tooltipData.IconKey = "Skull";
			tooltipData.Text = colour(::AP.Utilities.getTooltipString("InjuryThresholdExceededTooltip"));
		}
		else if (_injuryDifferential == 0)
		{
			tooltipData.Text = ::AP.Utilities.compileTooltipFragments("InjuryThresholdTooltipBaselineFragment", ::AP.Standard.Colour.Red);
		}

		return tooltipData;
	}

	function hasMomentum( _playerObject )
	{
		return _playerObject.getSkills().hasSkill("effects.ap_momentum");
	}

	function resetMomentum( _playerObject )
	{
		if (!this.hasMomentum(_playerObject))
		{
			return;
		}

		_playerObject.getSkills().getSkillByID("effects.ap_momentum").resetMomentum();
	}
};