-- Script for binding any key to triger pressing A and B button at same time.
-- Could be useful for Double Dragon games series and Nekketsu,
-- where for jumping player must press A+B buttons.
-- NOTE: Script work's only for player 1.

inputTbl = {}
ab_button = ";"

function a_and_b()
  if emu.isKeyPressed(ab_button) then
    inputTbl = emu.getInput(0)
    inputTbl.a = true
    inputTbl.b = true
    emu.setInput(0, inputTbl)
  end
end

emu.addEventCallback(a_and_b, emu.eventType.inputPolled)
