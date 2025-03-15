this.ap_momentum_effect <- ::inherit("scripts/skills/ap_skill",
{
	m = {},
	function create()
	{
		this.ap_skill.create();
		this.assignPropertiesByName("Momentum");
	}

	function assignGenericProperties()
	{
		this.ap_skill.create();
		this.m.IsHidden = !::AP.Standard.getParameter("EnableMomentum") && !this.isViableForEffect();
	}

	function createIntervalEntry()
	{
		return ::AP.Standard.constructEntry
		(
			"Time",
			format(::AP.Strings.Skills.MomentumIntervalText, ::AP.Standard.colourWrap(this.getBattlesUntilNextStack(), ::AP.Standard.Colour.Red))
		);
	}

	function createStacksEntry()
	{
		local stacks = this.getCurrentStacks();
		return ::AP.Standard.constructEntry
		(
			"Special",
			format("%s %s", ::AP.Strings.Skills.MomentumValue, ::AP.Standard.colourWrap(stacks, ::AP.Standard.Colour.Green))
		);
	}

	function createStaminaEntry()
	{
		local staminaBonus = this.getStaminaBonus();
		return ::AP.Standard.constructEntry
		(
			"Stamina",
			format("%s %s", ::AP.Standard.colourWrap(format("+%i", staminaBonus), ::AP.Standard.Colour.Green), ::AP.Strings.Generic.Stamina)
		);
	}

	function getBattlesSurvived()
	{
		return ::AP.Standard.getFlag("BattlesSurvived", this);
	}

	function getBattlesUntilNextStack()
	{
		local battlesSurvived = this.getBattlesSurvived();
		return ::AP.Standard.getNearestTen(battlesSurvived, true) - battlesSurvived;
	}

	function getCurrentStacks()
	{
		local battlesSurvived = this.getBattlesSurvived();
		return ::AP.Standard.getNearestTen(battlesSurvived) / 10;
	}

	function getStaminaBonus()
	{
		return this.getCurrentStacks() * ::AP.Persistence.Parameters.MomentumBaseStaminaBonus;
	}

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, entries);

		push(this.createStacksEntry());
		push(this.createStaminaEntry());
		push(this.createIntervalEntry());
	}

	function isViableForEffect()
	{
		if (this.getBattlesSurvived() < ::AP.Persistence.Parameters.MomentumBaseIntervalDays)
		{
			return false;
		}

		return true;
	}

	function incrementBattlesSurvived()
	{
		local battlesSurvived = this.getBattlesSurvived();
		this.setBattlesSurvived(battlesSurvived + 1);
	}

	function setBattlesSurvived( _integer = 0 )
	{
		::AP.Standard.setFlag("BattlesSurvived", _integer, this);
	}

	function onUpdate( _properties )
	{
		this.ap_skill.onUpdate(_properties);

		if (this.m.IsHidden)
		{
			return;
		}

		_properties.Stamina += this.getStaminaBonus();
	}
});