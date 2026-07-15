--[[ Code by myd3(MaybeNotFish)]]
--//Services
local Players = game:GetService("Players")
--//Veriables/Player reference
local Player = Players.LocalPlayer
--//Module
local VisualsService = {}
VisualsService.__index = VisualsService
--//types for type checking and auto completing
export type VisualsService = typeof(setmetatable({} :: {
	Part : BasePart,
	FavoratedPartical : string
}, VisualsService))
--// Initializer to set up the module and decide wether to emit all the particals inside the part or just emit the favorated one
function VisualsService.Init(Part : BasePart?, Favorated : string?)
	local self = setmetatable({}, VisualsService) -- Creating the second table to combine both of the helper table and the main table
	
	if Favorated then -- check if the favorated partical is given
		self.FavoratedPartical = Favorated
	end
	if Part then -- check if the part is given sometimes we would want to emit only one thing so we are going to make this nil
		self.Part = Part
	end
	
	return self -- returning the self(combained tables to call the other functions)
	
end
--// Main function
function VisualsService.Play(self : VisualsService)
	--// return player fastmode boolean inside the player instance
	local FastMode = Player:GetAttribute("FastMode")
    --//Checking first for the favoratedPartical
	if self.FavoratedPartical then
		local Particle:ParticleEmitter
        -- Looking for the partical inside the part
		for _,v in self.Part:GetDescendants() do
			if v:IsA("ParticleEmitter") and v.Name == self.FavoratedPartical then
				--//Sign the partical the nil veriable we just created
				Particle = v
			end
		end
        --// Get the emit count of the partical
		local EmitCount = Particle:GetAttribute("EmitCount") or 1 -- 1 in case the attribute doesnt exist
		if EmitCount == 1 then
			-- if the emit count is only 1 then emit it
			Particle:Emit(EmitCount)
			return
		else
			--// checking if fastmode is on
			if FastMode then
                --// if fast mode is on than divide the emit count by 2 
				EmitCount = math.floor(EmitCount / 2) -- math.floor so we get a u8 number not a float
				Particle:Emit(EmitCount) -- emit
			else
				Particle:Emit(EmitCount) -- emit the normal amount if fastmode is off
			end
		end
		return
	end
	-- now to the main part where we emit all the particals inside the part
	--// loop through all the instances inside the part
	for _,v in self.Part:GetDescendants() do
		--// check if the instance is a partical emitter
		if v:IsA("ParticleEmitter") then
			--// get the emit count of the partical
			local EmitCount = v:GetAttribute("EmitCount") or 1 -- or 1 if it doesnt exist
			if EmitCount == 1 then -- if its only 1 then emit it
				v:Emit(EmitCount) -- emit
			else -- or
				if FastMode then -- check if fastmode is on
					EmitCount = math.floor(EmitCount / 2) -- divide the emit count by 2
					v:Emit(EmitCount) -- emit
				else
					v:Emit(EmitCount) -- emit the normal amount if fastmode is off
				end
			end
		end
	end
end
-- // Play the particals that are inside the characters because in roblox when you clone a part and then try to emit immediately it does not emit
-- thats why when the game starts i store the initial particals in attachements inside the torso/humanoidrootpart
function VisualsService.PlayInCharacter(self : VisualsService,Name:string)
	local Character = Player.Character -- get the player character
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") -- humanoidrootpart
	if not HumanoidRootPart then return end
	local Visuals = HumanoidRootPart:FindFirstChild(Name) -- find the attachement inside the humanoidrootpart
	
	local FastMode = Player:GetAttribute("FastMode") -- return the fast mode boolean
	
	-- loop through all the instances and repeat the same process as shown above
	for _,v in Visuals:GetDescendants() do
		if v:IsA("ParticleEmitter") then
			local EmitCount = v:GetAttribute("EmitCount") or 1
			if EmitCount == 1 then
				v:Emit(EmitCount)
			else
				if FastMode then
					EmitCount = math.floor(EmitCount / 2)
					v:Emit(EmitCount)
				else
					v:Emit(EmitCount)
				end
			end
		end
	end	
	
end

return VisualsService

--// Youtube link of a video that shows how the system works 
   --https://www.youtube.com/watch?v=A8aPMTZ1HuA
