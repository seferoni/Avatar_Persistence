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
		this.m.IsHidden = ::AP.Standard.getSetting("EnableMomentum") && this.isViableForEffect();
	}

	function createIntervalEntry()
	{
		return ::AP.Standard.constructEntry
		(
			"Time",
			format()::AP.Strings.Skills.MomentumIntervalText
		);
	}

	function createSkillEntry()
	{

	}

	function getTimeUntilNextStack()
	{

	}

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, entries);

		push(this.createSkillEntry());
		push(this.createIntervalEntry());
	}

	function isViableForEffect()
	{
		if (this.getAcquisitionDay() - ::World.getTime().Days < ::AP.Persistence.Parameters.MomentumBaseIntervalDays)
		{
			return false;
		}

		return true;
	}

	function onUpdate( _properties )
	{

	}
});