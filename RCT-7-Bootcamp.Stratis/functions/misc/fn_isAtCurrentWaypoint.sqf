_unit = param[0, objNull, [objNull]];
_distance = param[1, 2, [0]];

_group = group _unit;
_i = currentWaypoint _group;
_pos = waypointPosition [_group, _i];
_dist = _pos distance _unit;
_dist < _distance;