--[[
    Name: 1hz_ain_averages.lua
    Desc: Implements a moving-average script. After collecting each
          new value, average AIN value is provided.
    Note: Averaged from 10 seconds of data, measures every second. Is saved to user ram.

          Testing was performed with a T7, FW 1.0299,
          and Kipling 3.1.17 open to the Lua Script Debugger tab
--]]

--Local functions for faster processing
local ljWrite = MB.W
local ljRead = MB.R
local ljnameToAddress = MB.nameToAddress

-- Sampling interval, 1 per second
local intrvlhz = 1
local intrvlms = math.floor(1/intrvlhz * 1000)

-- Number of samples to cache & average
local numsamp = 10

-- The analog inputs/registers to read & average
local channels = {ljnameToAddress("AIN0"),ljnameToAddress("AIN1"), ljnameToAddress("AIN2"), ljnameToAddress("AIN3")}
local numchannels = table.getn(channels)

--Initialize sum calculation variables
local index = 1
local ainavg = {}
local sums = {}

--Build array for AIN measurements
local ain = {}
for i=1,numchannels-1 do
  ainavg[i] = 0
  ain[i] = {}
  for j=1,numsamp do
    ain[i][j]= 0
  end
end

--Set resindex to 12 for AIN0-AIN3
for i=0,3 do
  ljWrite(((ljnameToAddress"AIN0_RESOLUTION_INDEX")+(i)), 0, 12) 
end

-- Configure an interval
LJ.IntervalConfig(0, intrvlms)

-- Begin loop
while true do
  -- A reading is taken every 10 seconds
  if LJ.CheckInterval(0) then
    -- Read the AIN channels
    for i=1,numchannels-1 do
      ain[i][index] = ljRead(ljnameToAddress("AIN"..(i-1)), 3)
    end
    
    --If 10 readings have been made for each channel
    if index==10 then
      --Find the average of each channel's readings
      for i=1,numchannels-1 do
        sums[i] = 0
        for j=1,numsamp do
          sums[i] = sums[i] + ain[i][j]
        end
        ainavg[i] = sums[i] / numsamp
        -- Save result to USER_RAM#_F32 register
        ljWrite((46000 + (channels[i])), 3, ainavg[i])
      end
      --Prepare the array for new reading by shifting the array over and adjusting index.
      for i=1, numchannels-1 do
        table.remove(ain[i], 1)
        table.insert(ain[i], numsamp, 0)
      end
      index = index - 1
    end
    index = index + 1
  end
end 
