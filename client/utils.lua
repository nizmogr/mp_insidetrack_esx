Utils = {
    Scaleform = -1,
    ChooseHorseVisible = false,
    BetVisible = false,
    PlayerBalance = 10000,
    CurrentHorse = -1,
    MaxBet = Config.MaxBet,
    MinBet = Config.MinBet,
    CurrentBet = Config.CurrentBet,
    CurrentGain = Config.CurrentGain,
    HorsesPositions = {},
    CurrentWiner = -1,
    CurrentSoundId = -1,
    InsideTrackActive = false,
    BigScreen = {
        enable = Config.Screenon, -- Set it to false if you don't need the big screen
        coords = vector3(Config.BigScreen.x , Config.BigScreen.y , Config.BigScreen.z)
    }
}

function Utils:GetMouseClickedButton()
    local returnValue = -1

    CallScaleformMovieMethodWithNumber(self.Scaleform, 'SET_INPUT_EVENT', 237.0, -1082130432, -1082130432, -1082130432, -1082130432)
    BeginScaleformMovieMethod(self.Scaleform, 'GET_CURRENT_SELECTION')

    returnValue = EndScaleformMovieMethodReturnValue()

    while not IsScaleformMovieMethodReturnValueReady(returnValue) do
        Wait(0)
    end

    return GetScaleformMovieMethodReturnValueInt(returnValue)
end

function Utils.GetRandomHorseName()
    local random = math.random(0, 99)
    local randomName = (random < 10) and ('ITH_NAME_00'..random) or ('ITH_NAME_0'..random)

    return randomName
end