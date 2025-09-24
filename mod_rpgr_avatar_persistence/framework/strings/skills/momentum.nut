::AP.Strings.Skills.Momentum <-
{
	Name = "Momentum",
	Description = "This character's indomitable spirit permits their vigour to be raised for each powerful foe felled by their hand. This effect is fortified for as long as they remain in a small company, but is diminished upon each defeat.",

	StatePrefix = "Momentum: ",
	StateBelowRosterThreshold = "Fortified",
	StateDisabled = "Disabled",
	StateRosterThresholdExceeded = "Weakened",

	NoBonusesText = "This character currently possesses no Momentum.",
	RosterThresholdTooltip = "Fortified until the company hires %s more brothers.",
	RosterThresholdExceededTooltip = "Weakened until the company is reduced to a size of %s brothers or fewer.",

	RosterThresholdTooltipBaselineFragmentA = "Fortified until",
	RosterThresholdTooltipBaselineFragmentB = "any additional brothers",
	RosterThresholdTooltipBaselineFragmentC = "are hired.",
};