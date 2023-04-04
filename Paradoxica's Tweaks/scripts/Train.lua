local function hook(mission)
	if Board:IsTerrain(Point(3,0),TERRAIN_MOUNTAIN) and Board:IsTerrain(Point(3,1),TERRAIN_MOUNTAIN) and Board:IsTerrain(Point(5,0),TERRAIN_MOUNTAIN) and Board:IsTerrain(Point(5,1),TERRAIN_MOUNTAIN) then
	
	Board:SetTerrain(Point(5,1), 0)
	
	end
end
modApi.events.onPreMissionAvailable:subscribe(hook)