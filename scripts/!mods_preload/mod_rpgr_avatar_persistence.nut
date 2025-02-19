::AP <-
{
	ID = "mod_rpgr_avatar_persistence",
	Name = "RPG Rebalance - Avatar Persistence",
	Version = "3.0.0",
	Internal =
	{
		ManagerPath = "mod_rpgr_avatar_persistence/framework/internal/manager.nut",
		TERMINATE = "__end"
	}

	function loadManager()
	{
		::include(this.Internal.ManagerPath);
	}

	function initialise()
	{
		this.loadManager();
		this.Manager.awake();
		this.Manager.queue();
	}
};

::AP.initialise();