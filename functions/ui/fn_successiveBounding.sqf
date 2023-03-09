_otherGroupLeader = _this;
_otherGroup = group _otherGroupLeader;
_i = currentWaypoint _otherGroup ;
_pos = waypointPosition [_otherGroup, _i + 1];
_dist = _pos distance _otherGroupLeader;
systemChat (["unit:",_this, "|| distance wp:", _dist] joinString "");
_dist < 2;