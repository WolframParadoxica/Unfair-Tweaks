local this = {}
function this:load()
    local hook = function(mission)
        for i = 0,7 do
			if Board:IsPawnSpace(Point(i,0)) and Board:GetPawn(Point(i,0)):GetType() == "Dam_Pawn" then
				Board:SetTerrain(Point(i,0), 0)
			end
		end
		if Board:IsPawnSpace(Point(4,6)) and Board:GetPawn(Point(4,6)):GetType() == "Train_Pawn" and Board:IsBuilding(Point(3,5)) and Board:IsBuilding(Point(5,5)) then
			Board:SetDangerous(Point(4,5))
		end
    end
    modApi:addMissionStartHook(hook)
end
return this