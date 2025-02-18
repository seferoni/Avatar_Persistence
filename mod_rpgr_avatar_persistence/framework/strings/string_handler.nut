::AP.Strings <-
{
	function compileFragments( _fragmentsArray, _colour )
	{
		local compiledString = "";

		if (_fragmentsArray.len() % 2 != 0)
		{
			_fragmentsArray.push("");
		}

		for( local i = 0; i < _fragmentsArray.len(); i++ )
		{
			local fragment = i % 2 == 0 ? _fragmentsArray[i] : ::AP.Standard.colourWrap(_fragmentsArray[i], ::AP.Standard.Colour[_colour]);
			compiledString = ::AP.Standard.appendToStringList(fragment, compiledString, "");
		}

		return compiledString;
	}

	function getFragmentsAsSortedArray( _fragmentBase, _tableKey, _subTableKey )
	{
		local fragmentKeys = [];
		local database = _subTableKey == null ? this[_tableKey] : this[_tableKey][_subTableKey];

		foreach( key, string in database )
		{
			if (key.find(_fragmentBase) != null)
			{
				fragmentKeys.push(key);
			}
		}

		fragmentKeys.sort();
		return fragmentKeys.map(@(_fragmentKey) database[_fragmentKey]);
	}

	function getFragmentsAsCompiledString( _fragmentBase, _tableKey, _subTableKey = null, _colour = "Red")
	{
		local fragmentsArray = this.getFragmentsAsSortedArray(_fragmentBase, _tableKey, _subTableKey);
		return this.compileFragments(fragmentsArray, _colour);
	}

	function initialise()
	{
		this.loadFiles();
	}

	function loadFiles()
	{
		this.loadFolder("main");
		this.loadFolder("edicts");
		this.loadFolder("lairs");
	}

	function loadFolder( _path )
	{
		::AP.Manager.includeFiles(format("mod_rpgr_avatar_resistances/framework/strings/%s", _path));
	}
};