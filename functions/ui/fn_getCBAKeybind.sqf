_mod = param[0, "", [""]];
_actionName = param[1, "", [""]];

_entry = [_mod, _actionName] call CBA_fnc_getKeybind; 

if (isNil "_entry") exitWith { false; };
 
_firstKeybind = _entry # 5; 
 
_key = call compile (keyName (_firstKeybind # 0));
_output = [_key]; 
 
_extraKeys = _firstKeybind # 1; 
 
if (_extraKeys # 0) then { 
 _output pushBack "SHIFT"; 
}; 
 
if (_extraKeys # 1) then { 
 _output pushBack "CTRL"; 
}; 
 
 
if (_extraKeys # 0) then { 
 _output pushBack "ALT"; 
}; 
 
_output joinString " + ";