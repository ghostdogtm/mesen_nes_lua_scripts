ram_table = {}
ram_write_ref = nil
init_code_stop_ref = nil
mode = ""
ram_size = 0x07FF

function initCodeStart()
  mode = isPowerOn() and "Power On" or "Reset"

  emu.log(mode .. " Start")

  for i = 0, ram_size do
    ram_table[i] = 0
  end

  if ram_write_ref ~= nil then
    emu.removeMemoryCallback(ram_write_ref, emu.memCallbackType.cpuWrite, 0, ram_size)
  end
  if init_code_stop_ref ~= nil then
    emu.removeEventCallback(init_code_stop_ref, emu.eventType.nmi)
  end

  ram_write_ref = emu.addMemoryCallback(ramWriteCallback, emu.memCallbackType.cpuWrite, 0, ram_size)
  init_code_stop_ref = emu.addEventCallback(initCodeStop, emu.eventType.nmi)
end

function ramWriteCallback(address, _)
  --emu.log("Write to ram address $" .. intToHex(address))
  ram_table[address] = 1
end

function initCodeStop()
  emu.log("Stop")
  emu.removeMemoryCallback(ram_write_ref, emu.memCallbackType.cpuWrite, 0, ram_size)
  saveRamActivityToFile()
  emu.removeEventCallback(init_code_stop_ref, emu.eventType.nmi)
end

function saveRamActivityToFile()
  local file_name = emu.getRomInfo().name:gsub("%.nes", ""):gsub("[%p%c]", ""):gsub(" ", "_"):lower()
  local file_path = emu.getScriptDataFolder() .. "/" .. file_name .. "_ram_activity.txt"
  local ram_file = io.open(file_path, "w+")
  ram_file:write(emu.getRomInfo().name, "\n")
  ram_file:write(mode, "\n")
  for i = 0, ram_size do
    ram_file:write(intToHex(i) .. ": " .. tostring(ram_table[i]), "\n")
  end
  ram_file:close()
  ram_file = nil
  emu.log("Saved to" .. file_path:gsub("/", "\\"))
end

function intToHex(value)
  return string.format("%04x", value)
end

function isPowerOn()
  return emu.getState().cpu.sp == 253
end

-- NOTE: Power on checks not always works correct, but reset event should be fine
-- To trigger power on state, pause emulator, do power cycle, hit run script, unpause emulator
if isPowerOn() then
  initCodeStart()
end

emu.addEventCallback(initCodeStart, emu.eventType.reset)
