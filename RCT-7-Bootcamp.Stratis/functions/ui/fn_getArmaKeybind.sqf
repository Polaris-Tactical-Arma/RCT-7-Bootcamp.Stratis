/*
	Author: Eduard Schwarzkopf
	
	Description:
	get Arma keybinds as a string
	
	Parameter(s):
	0: inputAction - https://community.bistudio.com/wiki/inputAction/actions
	
	Returns:
	string
*/

_actionName = param[0, "",[""]];
(actionKeysNames _actionName) regexReplace ["""", ""];
