this.ap_momentum_effect <- ::inherit("scripts/skills/ap_skill",
{
	m = {},
	function create()
	{
		this.ap_skill.create();
		this.assignPropertiesByName("Momentum");
		this.initialiseFlags();
	}

	function applySkillBonuses( _currentProperties )
	{
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			_currentProperties[attribute] += this.getAttributeBonus(attribute);
		}
	}

	function createAttributeEntries()
	{
		local entries = [];
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			local bonus = this.getAttributeBonus(attribute);

			if (bonus == 0)
			{
				continue;
			}

			::AP.Standard.constructEntry
			(
				attribute,
				format("%s %s", ::AP.Standard.colourWrap(format("+%i", bonus), ::AP.Standard.Colour.Green), ::AP.Utilities.getAttributeString(attribute)),
				entries
			);
		}

		if (entries.len() == 0)
		{
			::AP.Standard.constructEntry
			(
				"Warning",
				::AP.Standard.colourWrap(this.getString("NoBonusesText"), ::AP.Standard.Colour.Red),
				entries
			);
		}

		return entries;
	}

	function createMomentumStateEntry()
	{
		local colour = ::AP.Standard.Colour.Red;
		local suffix = this.getString("StateRosterThresholdExceeded");
		local bonusMultiplier = this.getAttributeBonusMultiplier();

		if (this.isWithinRosterThreshold())
		{
			colour = ::AP.Standard.Colour.Green;
			suffix = this.getString("StateBelowRosterThreshold");
		}

		return ::AP.Standard.constructEntry
		(
			"Momentum",
			format("%s %s (x%i)", this.getString("StatePrefix"), ::AP.Standard.colourWrap(suffix, colour), bonusMultiplier)
		);
	}

	function getAttributeBonus( _attributeKey )
	{
		return this.getNaiveAttributeBonus(_attributeKey) * this.getAttributeBonusMultiplier();
	}

	function getAttributeBonusMultiplier()
	{
		local nominalMultiplier = 1;

		if (this.isWithinRosterThreshold())
		{
			nominalMultiplier++;
		}

		return nominalMultiplier;
	}

	function getNaiveAttributeBonus( _attributeKey )
	{
		return ::AP.Standard.getFlag(_attributeKey, this);
	}

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push(this.createMomentumStateEntry());
		push(this.createAttributeEntries());
		return tooltipArray;
	}

	function getViableAttributeByEntity( _targetEntity )
	{
		local targetProperties = _targetEntity.getBaseProperties();
		local viableAttributes = this.getViableAttributesForScaling();
		viableAttributes.sort(function( _firstAttribute, _secondAttribute )
		{
			if (targetProperties[_firstAttribute] > targetProperties[_secondAttribute])
			{
				return -1;
			}

			if (targetProperties[_firstAttribute] < targetProperties[_secondAttribute])
			{
				return 1;
			}

			return 0;
		});
		return viableAttributes[::Math.rand(0, 2)];
	}

	function getViableAttributesForScaling()
	{
		return clone this.getSkillData().ScalableAttributes;
	}

	function incrementAttributeBonus( _attributeKey )
	{
		this.setAttributeBonus(_attributeKey, this.getNaiveAttributeBonus(_attributeKey) + 1);
	}

	function initialiseFlags()
	{
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			if (this.getNaiveAttributeBonus(attribute) != false)
			{
				continue;
			}

			this.setAttributeBonus(attribute, 0);
		}
	}

	function isAttributeEligibleForScaling( _targetEntity, _attribute )
	{
		local playerProperties = this.getContainer().getActor().getCurrentProperties();
		local targetProperties = _targetEntity.getBaseProperties();

		if (playerProperties[_attribute] >= targetProperties[_attribute])
		{
			return false;
		}

		return true;
	}

	function isWithinRosterThreshold()
	{
		return ::World.getPlayerRoster().getAll().len() <= ::AP.Standard.getParameter("MomentumRosterThreshold");
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		local eligibleAttribute = this.getViableAttributeByEntity(_targetEntity);

		if (!this.isAttributeEligibleForScaling(_targetEntity, eligibleAttribute))
		{
			return;
		}

		this.spawnOverlayOnCurrentTile();
		this.incrementAttributeBonus(eligibleAttribute);
	}

	function onUpdate( _properties )
	{
		this.ap_skill.onUpdate(_properties);
		this.applySkillBonuses(_properties);
	}

	function resetMomentum()
	{
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			this.setAttributeBonus(attribute, 0);
		}
	}

	function setAttributeBonus( _attributeKey, _attributeBonus )
	{
		::AP.Standard.setFlag(_attributeKey, _attributeBonus, this);
	}
});