/*
Author: Eduard Schwarzkopf

Description:
	Sets auto popup on popup targets to false and makes them lay down

Parameter(s):
	0: Object - Object that has all the targets synced to it
	1: Integer - 1 = Targets pop up; 0 = Targets lay down 
	2: Boolean (Optional) - set the "nopop" variable

Returns:
	true
*/

_nopop = param [2,false,[false]];

{
	if (_item isKindOf "TargetBase") then {
		_x animate["terc", _this # 1];
		if (_nopop) then { _x setVariable ["nopop", true]; };
	};
	
} forEach synchronizedObjects (_this # 0);

true;