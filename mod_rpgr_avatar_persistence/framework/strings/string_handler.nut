::AP.Strings <-
{	// TODO: standardise as per the new WFR convention.
	function createTables()
	{
		this.Generic <- {};
		this.Items <- {};
		this.Skills <- {};
		this.Settings <- {};
		this.Events <- {};
	}

	function compileFragments( _fragmentsArray, _colour )
	{
		local compiledString = "";
		local colourWrap = @(_string) _colour == null ? _string : ::AP.Standard.colourWrap(_string, _colour);

		if (_fragmentsArray.len() % 2 != 0)
		{
			_fragmentsArray.push("");
		}

		for( local i = 0; i < _fragmentsArray.len(); i++ )
		{
			local fragment = i % 2 == 0 ? _fragmentsArray[i] : colourWrap(_fragmentsArray[i]);
			compiledString = ::AP.Standard.appendToStringList(fragment, compiledString, "");
		}

		return compiledString;
	}

	function getFragmentsAsCompiledString( _fragmentBase, _tableKey, _subTableKey = null, _colour = ::AP.Standard.Colour.Red )
	{
		local fragmentsArray = this.getFragmentsAsSortedArray(_fragmentBase, _tableKey, _subTableKey);
		return this.compileFragments(fragmentsArray, _colour);
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

	function initialise()
	{
		this.createTables();
		this.loadFiles();
	}

	function loadFiles()
	{
		this.loadFolder("generic");
		this.loadFolder("settings");
		this.loadFolder("events");
		this.loadFolder("items");
		this.loadFolder("skills");
	}

	function loadFolder( _path )
	{
		::AP.Manager.includeFiles(format("mod_rpgr_avatar_persistence/framework/strings/%s", _path));
	}
};