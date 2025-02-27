this.ap_defeat_event <- ::inherit("scripts/events/ap_event",
{
	m = {},
	function create()
	{
		this.ap_event.create();
		this.createScreens();
	}

	function assignGenericProperties()
	{
		this.ap_event.assignGenericProperties();
		this.m.ID = "event.ap_defeat";
	}

	function createScreens()
	{
		local screens = this.m.Screens;
		local push = @(_entry) ::AP.Standard.push(_entry, screens);

		push(this.createIntroScreen());
	}

	function createIntroScreen()
	{	// TODO: incomplete
		local screen = this.constructScreen
		(

		);

	}


});

