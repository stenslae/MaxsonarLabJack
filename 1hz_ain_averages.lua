--[[
    Name: 1hz_ain_averages.lua
    Desc: Implements a moving-average script. After collecting each
          new value, average AIN value is provided.
    Note: Averaged from 10 seconds of data, measures every second. Is saved to user ram.

          Testing was performed with a T7, FW 1.0299,
          and Kipling 3.1.17 open to the Lua Script Debugger tab
          
          To customize, change lines: 19, 23, and 26.
--]]

--Local functions for faster processing
local ljWrite = MB.W
local ljRead = MB.R
local ljnameToAddress = MB.nameToAddress

-- Sampling interval, 1 per second
local intrvlhz = 1
local intrvlms = math.floor(1/intrvlhz * 1000)

-- Number of scans to cache & average
local numscans = 10

-- The analog inputs/registers to read & average
local channels = {ljnameToAddress("AIN0"),ljnameToAddress("AIN1"), ljnameToAddress("AIN2"), ljnameToAddress("AIN3")}
local numchannels = table.getn(channels)

--Initialize arrays
local ainavg = {}
local sums = {}
local ain = {}

--Build arrays and set ram registers.
for i=1,numchannels-1 do
  ainavg[i] = -9999.0
  ljWrite((46000 + (channels[i])), 3, ainavg[i])
  ain[i] = {}
end

--Set resindex to 12 for AIN0-AIN3
for i=0,3 do
  ljWrite(((ljnameToAddress"AIN0_RESOLUTION_INDEX")+(i)), 0, 12) 
end

-- Configure an interval
LJ.IntervalConfig(0, intrvlms)

-- Begin loop
while true do
  -- Execute loop every intrvlms.
  if LJ.CheckInterval(0) then
    -- Read the AIN channels
    for i=1,numchannels-1 do
      table.insert(ain[i], ljRead(ljnameToAddress("AIN"..(i-1)), 3))
    end
    
    -- Execute if numscans or more scans have been made
    if table.getn(ain[1])==numscans then
      --Find the average of each channel's readings
      for i=1,numchannels-1 do
        sums[i] = 0
        for j=1,numscans do
          sums[i] = sums[i] + ain[i][j]
        end
        ainavg[i] = sums[i] / numscans
        -- Save result to USER_RAM#_F32 register
        ljWrite((46000 + (channels[i])), 3, ainavg[i])
      end
      --Prepare the array for new reading by shifting the array over and adjusting index.
      for i=1, numchannels-1 do
        table.remove(ain[i], 1)
      end
    end
  end
end
