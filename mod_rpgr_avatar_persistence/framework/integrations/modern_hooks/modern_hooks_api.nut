::AP.Integrations.ModernHooks <-
{
	function hook( _path, _function )
	{
		::AP.Interfaces.ModernHooks.rawHook(_path, _function);
	}

	function hookBase( _path, _function )
	{
		this.hook(_path, _function);
	}

	function hookTree( _path, _function )
	{
		::AP.Interfaces.ModernHooks.rawHookTree(_path, _function);
	}
};