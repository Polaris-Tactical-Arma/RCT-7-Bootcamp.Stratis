_otherGroupLeader = _this;
_otherGroup = group _otherGroupLeader;
_i = currentWaypoint _otherGroup ;
_pos = waypointPosition [_otherGroup, _i];
_dist = _pos distance _otherGroupLeader;
_dist < 2;