::AP.Manager <-
{
	function awake()
	{
		this.createTables();
		this.updateIntegrationRegistry();
		this.register();
	}

	function createMSUInterface()
	{
		if (!this.isMSUInstalled())
		{
			return;
		}

		::AP.Interfaces.MSU <- ::MSU.Class.Mod(::AP.ID, ::AP.Version, ::AP.Name);
	}

	function createTables()
	{
		::AP.Interfaces <- {};
	}

	function formatVersion()
	{
		if (this.isMSUInstalled())
		{
			return;
		}

		if (this.isModernHooksInstalled())
		{
			return;
		}

		::AP.Version = this.parseSemVer(::AP.Version);
	}

	function isMSUInstalled()
	{
		return ::AP.Internal.MSUFound;
	}

	function isModernHooksInstalled()
	{
		return ::AP.Internal.ModernHooksFound;
	}

	function initialise()
	{
		this.createMSUInterface();
		this.loadLibraries();
		this.loadHandlers();
		this.initialiseHandlers();
		this.loadFiles();
	}

	function initialiseHandlers()
	{
		::AP.Database.initialise();
		::AP.Strings.initialise();
		::AP.Integrations.initialise();
	}

	function includeFiles( _path )
	{
		local filePaths = ::IO.enumerateFiles(_path);

		foreach( file in filePaths )
		{
			::include(file);
		}
	}

	function loadHandlers()
	{
		::include("mod_rpgr_avatar_resistances/framework/database/database_handler.nut");
		::include("mod_rpgr_avatar_resistances/framework/strings/string_handler.nut");
		::include("mod_rpgr_avatar_resistances/framework/integrations/mod_integration.nut");
	}

	function loadLibraries()
	{
		::include("mod_rpgr_avatar_resistances/framework/libraries/standard_library.nut");
		::include("mod_rpgr_avatar_resistances/framework/libraries/patcher_library.nut");
	}

	function loadFiles()
	{
		this.includeFiles("mod_rpgr_avatar_resistances/framework/classes/main");
		this.includeFiles("mod_rpgr_avatar_resistances/framework/classes/utilities");
		this.includeFiles("mod_rpgr_avatar_resistances/hooks");
	}

	function parseSemVer( _versionString )
	{
		local stringArray = split(_versionString, ".");

		if (stringArray.len() > 3)
		{
			stringArray.resize(3);
		}

		return format("%s.%s%s", stringArray[0], stringArray[1], stringArray[2]).tofloat();
	}

	function queue()
	{
		local queued = @() ::AP.Manager.initialise();

		if (this.isModernHooksInstalled())
		{
			::AP.Interfaces.ModernHooks.queue(">mod_msu", queued);
			return;
		}

		::mods_queue(::AP.ID, ">mod_msu", queued);
	}

	function register()
	{
		this.formatVersion();
		this.registerMod();
	}

	function registerJS( _path )
	{
		if (this.isModernHooksInstalled())
		{
			::Hooks.registerJS(format("ui/mods/mod_rpgr_avatar_resistances/%s", _path));
			return;
		}

		::mods_registerJS(format("mod_rpgr_avatar_resistances/%s", _path));
	}

	function registerMod()
	{
		if (this.isModernHooksInstalled())
		{
			::AP.Interfaces.ModernHooks <- ::Hooks.register(::AP.ID, ::AP.Version, ::AP.Name);
			return;
		}

		::mods_registerMod(::AP.ID, ::AP.Version, ::AP.Name);
	}

	function updateIntegrationRegistry()
	{
		this.updateMSUState();
		this.updateModernHooksState();
	}

	function updateMSUState()
	{
		::AP.Internal.MSUFound <- "MSU" in ::getroottable();
	}

	function updateModernHooksState()
	{
		::AP.Internal.ModernHooksFound <- "Hooks" in ::getroottable();
	}
};