::AP.Database <-
{
	function createTables()
	{
		this.Settings <- {};
		this.Generic <- {};
		this.Blueprints <- {};
		this.Events <- {};
		this.Skills <- {};
	}

	function getExactField( _tableName, _subTableName, _fieldName )
	{
		return this[_tableName][_subTableName][_fieldName];
	}

	function getField( _tableName, _fieldName )
	{
		local field = this.getTopLevelField(_tableName, _fieldName);

		if (field == null)
		{
			::AP.Standard.log(format("Could not find %s in the specified database %s.", _fieldName, _tableName), true);
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

	function getIcon( _iconKey )
	{
		if (!_iconKey in this.Generic.Icons)
		{
			::AP.Standard.log(format("Could not find image path corresponding to icon key %s.", _iconKey), true);
			return null;
		}

		return this.Generic.Icons[_iconKey];
	}

	function getSettingParameters()
	{
		local agglomeratedParameters = {};

		foreach( parameterType, parameterTable in this.Settings )
		{
			::AP.Standard.extendTable(parameterTable, agglomeratedParameters);
		}

		return agglomeratedParameters;
	}

	function getSettingCategories()
	{
		return ::AP.Standard.getKeys(this.Settings);
	}

	function initialise()
	{
		this.createTables();
		this.loadFiles();
	}

	function loadFolder( _path )
	{
		::AP.Manager.includeFiles(format("mod_rpgr_avatar_persistence/framework/database/%s", _path));
	}

	function loadFiles()
	{
		this.loadFolder("dictionaries");
		this.loadFolder("settings");
	}
};