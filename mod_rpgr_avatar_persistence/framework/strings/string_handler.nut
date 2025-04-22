::AP.Strings <-
{
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

		if (_fragmentsArray.len() % 2 != 0)
		{
			_fragmentsArray.push("");
		}

		for( local i = 0; i < _fragmentsArray.len(); i++ )
		{
			local fragment = (_colour != null && i % 2 != 0) ? ::PRM.Standard.colourWrap(_fragmentsArray[i], _colour) : _fragmentsArray[i];
			compiledString = ::PRM.Standard.appendToStringList(fragment, compiledString, " ");
		}

		return compiledString;
	}

	function getFragmentsAsCompiledString( _fragmentBase, _tableKey, _subTableKey = null, _colour = ::PRM.Standard.Colour.Red )
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

	function getField( _tableName, _fieldName )
	{
		local field = this.getTopLevelField(_tableName, _fieldName);

		if (field == null)
		{
			::PRM.Standard.log(format("Could not find %s in the specified string database %s.", _fieldName, _tableName), true);
		}

		return field;
	}

	function getTopLevelField( _tableName, _fieldName )
	{
		if (!(_fieldName in this[_tableName]))
		{
			return null;
		}

		return this[_tableName][_fieldName];
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