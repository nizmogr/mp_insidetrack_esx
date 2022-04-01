ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local cooldown = 60
local tick = 0
local checkRaceStatus = false
local gameOpen = false
local casinoAudioBank = 'DLC_VINEWOOD/CASINO_GENERAL' -- Do not edit

local function OpenInsideTrack()
    ESX.TriggerServerCallback('insidetrack:getbalance', function(cb)
        Utils.PlayerBalance = cb
        if Utils.PlayerBalance >= Utils.MaxBet then
            Utils.CurrentBet = Utils.MinBet
        else Utils.CurrentBet = Utils.MinBet
        end
    end)

    if Utils.InsideTrackActive then
        return
    end

    Utils.InsideTrackActive = true

    -- Scaleform
    Utils.Scaleform = RequestScaleformMovie('HORSE_RACING_CONSOLE')
    while not HasScaleformMovieLoaded(Utils.Scaleform) do
        Wait(0)
    end

    DisplayHud(false)
    SetPlayerControl(PlayerId(), false, 0)
    while not RequestScriptAudioBank(casinoAudioBank) do
        Wait(0)
    end

    Utils:ShowMainScreen()
    Utils:SetMainScreenCooldown(cooldown)

    -- Add horses
    Utils.AddHorses(Utils.Scaleform)
    Utils:DrawInsideTrack()
    Utils:HandleControls()
end

local function LeaveInsideTrack()
    Utils.InsideTrackActive = false
    DisplayHud(true)
    SetPlayerControl(PlayerId(), true, 0)
    SetScaleformMovieAsNoLongerNeeded(Utils.Scaleform)
    ReleaseNamedScriptAudioBank(casinoAudioBank)
    Utils:HandleBigScreen()
    Utils.Scaleform = -1
end

RegisterNetEvent('insidetrack:closeBetsNotEnough')
AddEventHandler('insidetrack:closeBetsNotEnough', function()
    LeaveInsideTrack()
    exports['t-notify']:Alert({style = 'error',message = 'Δεν έχεις αρκετές μάρκες', duration = 5500})
end)

RegisterNetEvent('insidetrack:closeBetsZeroChips')
AddEventHandler('insidetrack:closeBetsZeroChips', function()
    LeaveInsideTrack()
    exports['t-notify']:Alert({style = 'error',message = 'Δεν έχεις καθόλου μάρκες', duration = 5500})
end)

function Utils:DrawInsideTrack()
    Citizen.CreateThread(function()
        while self.InsideTrackActive do
            Wait(0)

            local xMouse, yMouse = GetDisabledControlNormal(2, 239), GetDisabledControlNormal(2, 240)

            -- Fake cooldown
            tick = (tick + 10)

            if (tick == 1000) then
                if (cooldown == 1) then
                    cooldown = 60
                end
                
                cooldown = (cooldown - 1)
                tick = 0

                self:SetMainScreenCooldown(cooldown)
            end
            
            -- Mouse control
            BeginScaleformMovieMethod(self.Scaleform, 'SET_MOUSE_INPUT')
            ScaleformMovieMethodAddParamFloat(xMouse)
            ScaleformMovieMethodAddParamFloat(yMouse)
            EndScaleformMovieMethod()

            -- Draw
            DrawScaleformMovieFullscreen(self.Scaleform, 255, 255, 255, 255)
        end
    end)
end

function Utils:HandleControls()
    Citizen.CreateThread(function()
        while self.InsideTrackActive do
            Wait(0)

            if IsControlJustPressed(2, 194) then
                LeaveInsideTrack()
            end

            if IsControlJustPressed(2, 202) then
                LeaveInsideTrack()
            end

            -- Left click
            if IsControlJustPressed(2, 237) then
                local clickedButton = self:GetMouseClickedButton()

                if self.ChooseHorseVisible then
                    if (clickedButton ~= 12) and (clickedButton ~= -1) then
                        self.CurrentHorse = (clickedButton - 1)
                        self:ShowBetScreen(self.CurrentHorse)
                        self.ChooseHorseVisible = false
                    end
                end

                -- Rules button
                if (clickedButton == 15) then
                    self:ShowRules()
                end

                -- Close buttons
                if (clickedButton == 12) then
                    if self.ChooseHorseVisible then
                        self.ChooseHorseVisible = false
                    end
                    
                    if self.BetVisible then
                        self:ShowHorseSelection()
                        self.BetVisible = false
                        self.CurrentHorse = -1
                    else
                        self:ShowMainScreen()
                    end
                end

                -- Start bet
                if (clickedButton == 1) then
                    self:ShowHorseSelection()
                end
                
                -- Start race
                if (clickedButton == 10) then
                    if  self.PlayerBalance >= self.CurrentBet then
                        self.CurrentSoundId = GetSoundId()
                        PlaySoundFrontend(self.CurrentSoundId, 'race_loop', 'dlc_vw_casino_inside_track_betting_single_event_sounds')
                        TriggerServerEvent("insidetrack:placebet", self.CurrentBet)
                        self:StartRace()
                        checkRaceStatus = true
                    else
                        return TriggerClientEvent('insidetrack:closeBetsNotEnough',self.source)
                    end
                end

                -- Change bet
                if (clickedButton == 8) then
                    if (self.CurrentBet < self.PlayerBalance) and (self.CurrentBet < self.MaxBet) then
                        self.CurrentBet = (self.CurrentBet + 500)
                        self.CurrentGain = (self.CurrentBet * 8)
                        if self.CurrentBet > self.PlayerBalance then
                            self.difference = self.CurrentBet - self.PlayerBalance 
                            self.CurrentBet = self.CurrentBet - self.difference
                        end
                        self:UpdateBetValues(self.CurrentHorse, self.CurrentBet, self.PlayerBalance, self.CurrentGain)
                    end
                end

                if (clickedButton == 9) then
                    if  self.CurrentBet % 500 ~= 0 then
                        self.CurrentBet = self.CurrentBet + self.difference
                    end
                        if (self.CurrentBet > 500) then
                            self.CurrentBet = (self.CurrentBet - 500)
                            self.CurrentGain = (self.CurrentBet * 8)
                            self:UpdateBetValues(self.CurrentHorse, self.       CurrentBet, self.PlayerBalance, self.CurrentGain)
                    end
                end

                if (clickedButton == 13) then
                    self:ShowMainScreen()
                end

                -- Check race
                while checkRaceStatus do
                    Wait(0)

                    local raceFinished = self:IsRaceFinished()

                    if (raceFinished) then
                        StopSound(self.CurrentSoundId)
                        ReleaseSoundId(self.CurrentSoundId)

                        self.CurrentSoundId = -1

                        if (self.CurrentHorse == self.CurrentWinner) then
                            -- Here you can add money
                            TriggerServerEvent("insidetrack:winchips", self.CurrentGain)
                            -- Refresh player balance
                            --ESX.TriggerServerCallback('insidetrack:getbalance', function(cb)
                                --self.PlayerBalance = cb
                            --end)
                            self.PlayerBalance = (self.PlayerBalance + self.CurrentGain)
                            self:UpdateBetValues(self.CurrentHorse, self.CurrentBet, self.PlayerBalance, self.CurrentGain)
                        else
                            ESX.TriggerServerCallback('insidetrack:getbalance', function(cb)
                                self.PlayerBalance = cb
                            end)
                        end

                        self:ShowResults()

                        self.CurrentHorse = -1
                        self.CurrentWinner = -1
                        self.HorsesPositions = {}

                        checkRaceStatus = false
                    end
                end
            end
        end
    end)
end

CreateThread(function()
	while true do
        Wait(0)
		-- draw every frame
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
        for _, v in ipairs(Config.OpenLocations) do
            local dist = #(coords - v.Pos)
            if(Config.MarkerDraw ~= -1 and dist < Config.DrawDistance) then
		    DrawMarker(Config.MarkerDraw, v.Pos[1], v.Pos[2], v.Pos[3], 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, Config.MarkerSize, Config.MarkerSize, 1.0, Config.MarkerColor[1], Config.MarkerColor[2], Config.MarkerColor[3], 100, false, true, 2, false, false, false, false)
	        end
            if(Config.MarkerDraw2 ~= -1 and dist < Config.DrawDistance) then
                DrawMarker(Config.MarkerDraw2, v.Pos[1], v.Pos[2], v.Pos[3], 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, Config.MarkerSize2, Config.MarkerSize2, Config.MarkerSize2 , Config.MarkerColor2[1], Config.MarkerColor2[2], Config.MarkerColor2[3], 100, false, true, 2, false, false, false, false)
                end
            if dist < Config.MarkerSize then
                ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to play Inside Track") 
                if IsControlJustReleased(0, 38) then
                    OpenInsideTrack()
                end
            end
        end
    end
end)

 RegisterCommand('itrack', OpenInsideTrack)