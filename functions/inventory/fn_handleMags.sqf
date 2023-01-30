/*
Author: Eduard Schwarzkopf

Description:
	Removes ammo from player and gives him a magazin for his current equipped weapon

Parameter(s):
	None

Returns:
	true
*/

_ammo = getArray (configFile >> "CfgWeapons" >> currentWeapon player >> "magazines") # 0;
player removePrimaryWeaponItem _ammo;
player addMagazine [_ammo, 30];
player reload [];

true;