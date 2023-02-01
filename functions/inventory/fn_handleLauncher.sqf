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

if (getNumber(configfile >> "CfgWeapons" >> _launcher >> "rhs_disposable") isEqualTo 1) then {

	player addWeapon "rhs_weap_M136";

} else {

	_ammo = getArray (configFile >> "CfgWeapons" >> _launcher >> "magazines") # 0;
	player removeSecondaryWeaponItem _ammo;
	player addMagazine [_ammo, 1];
	player reload [];

};

true;