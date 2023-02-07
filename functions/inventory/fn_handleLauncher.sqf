/*
Author: Eduard Schwarzkopf

Description:
	Removes ammo from player and gives him a magazin for his current equipped weapon

Parameter(s):
	None

Returns:
	true
*/

_launcher = _this # 0;

if (secondaryWeapon player isNotEqualTo _launcher) then {
	player addWeapon _launcher;
};

if (getNumber(configfile >> "CfgWeapons" >> _launcher >> "rhs_disposable") isEqualTo 0) then {

	_ammo = getArray (configFile >> "CfgWeapons" >> _launcher >> "magazines") # 0;
	player removeSecondaryWeaponItem _ammo;
	player addSecondaryWeaponItem _ammo;
};

true;