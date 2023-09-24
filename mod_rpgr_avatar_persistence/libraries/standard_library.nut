::RPGR_Avatar_Persistence.Standard <-
{
    function cacheHookedMethod( _object, _functionName )
    {
        local naiveMethod = null;
        local parentName = _object.SuperName;

        if (_functionName in _object)
        {
            naiveMethod = _object[_functionName];
        }

        return naiveMethod;
    }

    function generateTooltipTableEntry( _id, _type, _icon, _text )
    {
        local tableEntry =
        {
            id = _id,
            type = _type,
            icon = "ui/icons/" + _icon,
            text = _text
        }

        return tableEntry;
    }

    function generateOrderedArray( _firstEntry, _secondEntry, _procedure )
    {
        local orderedArray = [_firstEntry, _secondEntry];

        if (_procedure[0] == "reverse")
        {
            orderedArray.reverse();
        }

        return orderedArray;
    }

    function getSetting( _settingID )
    {
        if (::RPGR_Avatar_Persistence.MSUFound)
        {
            return ::RPGR_Raids.Mod.ModSettings.getSetting(_settingID).getValue();
        }

        if (!(_settingID in ::RPGR_Raids.Defaults))
        {
            this.logWrapper(format("Invalid settingID %s passed to getSetting, returning null.", _settingID), true);
            return null;
        }

        return ::RPGR_Raids.Defaults[_settingID];
    }

    function includeFiles( _path )
    {
        foreach( file in ::IO.enumerateFiles(_path) )
        {
            ::include(file);
        }
    }

    function logWrapper( _string, _isError = false )
    {
        if (_isError)
        {
            ::logError(format("[Avatar Persistence] %s", _string));
        }

        if (!this.getSetting("VerboseLogging"))
        {
            return;
        }

        ::logInfo(format("[Avatar Persistence] %s", _string));
    }

    function orderedCall( _functions, _argumentsArray, _procedure, _returnOverride = null )
    {
        local returnValues = [];

        foreach( functionDef in _functions )
        {
            returnValues.push(functionDef.acall(_argumentsArray)); // TODO: see what context object we need to be in
        }

        return _procedure[1] == "returnFirst" ? returnValues[0] : _procedure[1] == "returnSecond" ? returnValue[1] : _returnOverride;
    }

    function wrap( _object, _functionName, _function, _procedure = [null, "returnFirst"], _returnOverride = null )
    {
        local cachedMethod = this.cacheHookedMethod(_object, _functionName);
        local parentName = _object.SuperName;

        _object[_functionName] = function( ... )
        {
            local originalMethod = cachedMethod == null ? this[parentName][_functionName] : cachedMethod;
            local orderedArray = this.generateOrderedArray(_function, originalMethod, _procedure);
            local arguments = clone vargv;
            arguments.insert(0, this);
            return ::RPGR_Raids.Standard.orderedCall(orderedArray, arguments, _procedure, _returnOverride);
        }
    }
};

