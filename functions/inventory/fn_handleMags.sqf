/*
	Author: Eduard Schwarzkopf
	
	Description:
	Removes ammo from player and gives him a magazin for his current equipped weapon
	
	Parameter(s):
	0: Integer - amount of magazines
	
	Returns:
	true
*/

_amount = param [0, 1, [1]];

_ammo = getArray (configFile >> "CfgWeapons" >> primaryWeapon player >> "magazines") # 0;

player removeMagazines _ammo;
player removePrimaryWeaponItem _ammo;

for "_i" from 1 to _amount do {
	player addMagazine [_ammo, 30];
};

player reload [];

true;