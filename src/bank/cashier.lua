local monitor, drive, surface, screen, width, height, font, buttons, printer, speaker

MAINFRAME_ID = 0
PAYOUT_FEE = 5

local currencyValues = {
    [ "numismatics:spur" ] = 1,
    [ "numismatics:bevel" ] = 8,
    [ "numismatics:sprocket" ] = 16,
    [ "numismatics:cog "] = 64,
    [ "numismatics:crown "] = 512,
    [ "numismatics:sun "] = 4096
}