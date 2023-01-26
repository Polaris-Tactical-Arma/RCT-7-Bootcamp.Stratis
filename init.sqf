_clientID = clientOwner;
_UID = getPlayerUID player;
_name = name player;

initDb = [_clientID, _UID, _name];
publicVariableServer "initDb";