--//Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--/Veriables
local Assets = ReplicatedStorage.Assets
local UIAssets = Assets.UI
local MessageDisplayFrames = UIAssets.MessageDisplayFrames
--//PlayerGui
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Displays = PlayerGui:WaitForChild("Displays")
local Frame = Displays:WaitForChild("Frame")
local MessagesContainer = Frame:WaitForChild("MessagesContainer")
--//Packages/Janitor for system cleanup
local Janitor = require(ReplicatedStorage.Packages.Janitor)
-- Main module
local AnnouncementDisplay = {}
AnnouncementDisplay.__index = AnnouncementDisplay
AnnouncementDisplay.VerifiedBadge = utf8.char(0xE000)
AnnouncementDisplay.UsernameColor = {1, 0.203922, 0.215686}

--//types for type checking and auto completing
export type AnnouncementDisplay = typeof(setmetatable({} :: {
	Message: string,
	Duration: number,
	User: string,
	Frame: Frame,
	Janitor: any,
}, AnnouncementDisplay))
--//Init function for creating a new message to display on the screen
function AnnouncementDisplay.new(Message: string,Duration: number,Username: string): AnnouncementDisplay
	local self: AnnouncementDisplay = setmetatable({}, AnnouncementDisplay)

	self.Message = Message
	self.Duration = Duration
	self.User = Username
	self.Janitor = Janitor.new()

	return self
end
--//Clone the frame and place it in the MessageContainer for the player to see it
function AnnouncementDisplay.CreateFrame(self: AnnouncementDisplay)
	local MsgFrame = MessageDisplayFrames.Announcement:Clone()
	MsgFrame.Parent = MessagesContainer

	self.Frame = MsgFrame
	self.Janitor:Add(MsgFrame, "Destroy")

	return MsgFrame
end
--// tween the frame size to 0 to make it invisible and then tween it back to its normal size to make a smooth message appearance-
--In case there were multiple UI's in the uilistlayout 
function AnnouncementDisplay.TweenFrame(self: AnnouncementDisplay)
	self.Frame.Size = UDim2.new(0, 0, 0, 0)
	self.Frame.Transparency = 1
	-- Tween the frame's transparency to 0 
	local BarTween = TweenService:Create(self.Frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})
	
	-- Make all the ui elements inside the frame invisible
	for _, Instance in self.Frame:GetDescendants() do
		if Instance:IsA("TextLabel") then
			Instance.TextTransparency = 1
		elseif Instance:IsA("UIStroke") then
			Instance.Transparency = 1
		elseif Instance:IsA("Frame") then
			Instance.BackgroundTransparency = 1
		end
	end
	
	BarTween:Play()
	--Use janitor to call "Destroy" function when the duration of the message is over
	self.Janitor:Add(BarTween, "Destroy")

	local TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    -- Tween the frame's size to its normal size to animate all the existing messages frames in the container 
	local SizeTween = TweenService:Create(self.Frame, TweenInfo, {
		Size = UDim2.new(1, 0, 1, 0)
	})
	--Janitor clean up
	self.Janitor:Add(SizeTween, "Destroy")
	SizeTween:Play()
	-- wait for the frame to appear
	SizeTween.Completed:Wait()
    -- looping through all the ui elements inside the frame to make them visible
	for _, Instance in self.Frame:GetDescendants() do
		local Tween

		if Instance:IsA("TextLabel") then
			Tween = TweenService:Create(Instance, TweenInfo, {
				TextTransparency = 0
			})
		elseif Instance:IsA("UIStroke") then
			Tween = TweenService:Create(Instance, TweenInfo, {
				Transparency = 0
			})
		elseif Instance:IsA("Frame") then
			Tween = TweenService:Create(Instance, TweenInfo, {
				BackgroundTransparency = 0
			})
		end
        -- adding each tween to the janitor and playing it
		if Tween then
			self.Janitor:Add(Tween, "Destroy")
			Tween:Play()
		end
	end

	task.wait(self.Duration) -- waiting for the duration of the message to be over

    -- looping through all the ui elements inside the frame to make them invisible
	for _, Instance in self.Frame:GetDescendants() do
		local Tween

		if Instance:IsA("TextLabel") then
			Tween = TweenService:Create(Instance, TweenInfo, {
				TextTransparency = 1
			})
		elseif Instance:IsA("UIStroke") then
			Tween = TweenService:Create(Instance, TweenInfo, {
				Transparency = 1
			})
		elseif Instance:IsA("Frame") then
			Tween = TweenService:Create(Instance, TweenInfo, {
				BackgroundTransparency = 1
			})
		end
        -- adding the tween to janitor and playing it
		if Tween then
			self.Janitor:Add(Tween, "Destroy")
			Tween:Play()
		end
	end

	task.wait(TweenInfo.Time) -- waiting for the tweens to finish

	self:Destroy() -- end everything and clean up all the tweens and connections
end
-- function to create the message and combine all the message and the username and the color together to form a message
function AnnouncementDisplay.formatMessage(self: AnnouncementDisplay): string
	local Color = AnnouncementDisplay.UsernameColor -- username color
    -- returning the message in a html format with the verified badge and the username color, along side with the message
	return "<font color='rgb("
		.. tostring(math.floor(Color[1] * 255)) .. ","
		.. tostring(math.floor(Color[2] * 255)) .. ","
		.. tostring(math.floor(Color[3] * 255)) .. ")'>"
		.. self.User
		.. "</font><font color='rgb(0,162,255)'>"
		.. AnnouncementDisplay.VerifiedBadge
		.. "</font>: "
		.. self.Message
end
-- function to create the frame and use the module in general
function AnnouncementDisplay.Display(self: AnnouncementDisplay)
	local MsgFrame = self:CreateFrame()
	MsgFrame.Text.Text = self:formatMessage()
	self:TweenFrame()
end
-- function to delete and clean up all the existing connections
function AnnouncementDisplay.Destroy(self: AnnouncementDisplay)
	self.Janitor:Destroy()
end

return AnnouncementDisplay

--[[
   Usage:
   Make a 'local script' inside of PlayerScripts or startergui
   then require the module and create a new announcement display
   ----------------------------------------------------------------------------------------------------------------------------------------
    local RS = game:GetService("ReplicatedStorage")
    local Networker = require(RS.Shared.Services.Network.Networker)
    local AnnouncementDisplay = require(RS.Shared.Services.Displays.AnnouncementDisplay)

    Networker.DisplayMessage.Display.listen(function(Data)
	    local Announcement = AnnouncementDisplay.new(Data.DisplayMessage,Data.DisplayDuration,Data.DisplayName)
	    Announcement:Display()
    end)
   ----------------------------------------------------------------------------------------------------------------------------------------
   For the networking i used bytenet but you can use any networking library you want as long as you are recieving and the data from the server
   the usage of normal remote events is the same but i prefer bytenet
   
   and its important to check that the player running the command in the server is an admin not a player
   
   you are able to do that by blocking the server from firing the packet if their userid not listed as an admin by the following piece of code
   ----------------------------------------------------------------------------------------------------------------------------------------
   
        local userid = context.Executor.UserId
		local IsAdmin = Administators[userid]
		
		if not IsAdmin then
			return "You don't have permission to run this command"
		end
        
        a piece of cmdr server code to check if the player is an admin
   ----------------------------------------------------------------------------------------------------------------------------------------
]]

--[[
youtube video link that shows how the system works
https://www.youtube.com/watch?v=9F-y7z_97iA
]]
