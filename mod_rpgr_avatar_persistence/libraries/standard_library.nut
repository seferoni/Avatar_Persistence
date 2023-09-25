local AP = ::RPGR_Avatar_Persistence;
::RPGR_Avatar_Persistence.Standard <-
{
    function cacheHookedMethod( _object, _functionName )
    {
        local naiveMethod = null,
        parentName = _object.SuperName;

        if (_functionName in _object)
        {
            naiveMethod = _object[_functionName];
        }

        return naiveMethod;
    }

    function concatenateArrays( ... )
    {
        local concatenatedArray = [];

        foreach( array in vargv )
        {
            concatenatedArray.extend(array);
        }

        return concatenatedArray;
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

        if (_procedure == "reverse")
        {
            orderedArray.reverse();
        }

        return orderedArray;
    }

    function getSetting( _settingID )
    {
        if (AP.MSUFound)
        {
            return AP.Mod.ModSettings.getSetting(_settingID).getValue();
        }

        if (!(_settingID in AP.Defaults))
        {
            this.logWrapper(format("Invalid settingID %s passed to getSetting, returning null.", _settingID), true);
            return null;
        }

        return AP.Defaults[_settingID];
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

    function overrideArguments( _object, _functionName, _function, _returnOverride = null )
    {
        local cachedMethod = this.cacheHookedMethod(_object, _functionName),
        parentName = _object.SuperName;

        _object[_functionName] = function( ... )
        {
            local originalMethod = cachedMethod == null ? this[parentName][_functionName] : cachedMethod,
            arguments = AP.Standard.concatenateArrays([this], vargv),
            newArguments = AP.Standard.concatenateArrays([this], _function.acall(arguments));

            if (newArguments == null)
            {
                return _returnOverride == null ? originalMethod.acall(_newArgumentsArray) : _returnOverride;
            }

            return originalMethod.acall(arguments);
        }
    }

    function orderedCall( _functions, _argumentsArray, _procedure, _returnOverride = null )
    {
        local returnValues = [];

        foreach( functionDef in _functions )
        {
            returnValues.push(functionDef.acall(_argumentsArray)); // TODO: see what context object we need to be in
        }

        return _procedure == "returnFirst" ? returnValues[0] : _procedure == "returnSecond" ? returnValue[1] : _returnOverride;
    }

    function wrap( _object, _functionName, _function, _procedures = [null, "returnFirst"], _returnOverride = null )
    {   // this works best for when wrapping a function to perform a set of procedures and then returning the original method's return value
        local cachedMethod = this.cacheHookedMethod(_object, _functionName),
        parentName = _object.SuperName;

        _object[_functionName] = function( ... )
        {
            local originalMethod = cachedMethod == null ? this[parentName][_functionName] : cachedMethod,
            orderedArray = AP.Standard.generateOrderedArray(_function, originalMethod, _procedures[0]),
            arguments = AP.Standard.concatenateArrays([this], vargv);
            return AP.Standard.orderedCall(orderedArray, arguments, _procedures[1], _returnOverride);
        }
    }
};

