Config = {
    --Marker settings--
OpenLocations = {          --Markers Locations, you can put more than one marker to access the inside track menu
    {Pos = vector3(954.8044, 74.75604, 70.0227)},
},

MarkerDraw = 4,                  --Marker 1 Style
MarkerDraw2 = 6,                 --Marker 2 Style   (set to -1 if you don't want to use it)
MarkerColor = {190, 193, 196},   --Marker 1 Color
MarkerColor2 = {64, 173, 66},    --Marker 2 Color   
MarkerSize = 1.1,                --Marker 1 Size    (default: 1.1)
MarkerSize2 = 1.6,               --Marker 2 Size    
DrawDistance = 100,              --Marker draw distance

--Betting Settings--
Item = "chips",        -- Obviously the Items name
MaxBet = 10000,        -- Sets the max bet
MinBet = 500,          -- Sets the min bet
CurrentBet = 500,     --This and Current Gain combined sets the wining multiplier ex. if you set currentBet at 500 and currentGain at 3000 you get a reward x6, if you set currentBet at 500 and CurrentGain at 5000 you get reward x10
CurrentGain = 3000,
Screenon = true,      -- Set it to false if you don't need the big screen
BigScreen = {         -- Big screen coords
    x = 951.4286,
    y = 85.18682,
    z = 70.0227
}


}

