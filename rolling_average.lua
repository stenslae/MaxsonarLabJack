--[[
    Name: rolling_average.lua
    Desc: Implements a moving-average script. After collecting each
          new value, average AIN value is provided.
    Note: Averaged from 10 seconds of data, measures every second. Is saved to user ram.

          Testing was performed with a T7, FW 1.0299,
          and Kipling 3.1.17 open to the Lua Script Debugger tab
--]]

--The following can be updated:
  -- The analog inputs/registers to read & average
  local channels = {0, 1, 2, 3}
  -- Number of scans to cache & average
  local numscans = 10
  -- Sampling interval, 1 per second
  local intrvlhz = 1
  --The resolultion index of the ain channels
  local resindx = 12


--Local functions for faster processing
local ljWrite = MB.W
local ljRead = MB.R
local ljnameToAddress = MB.nameToAddress


--Initialize variables
local ainavg = {}
local sums = {}
local index = 1
local ain = {}
local count = 0
local intrvlms = math.floor(1/intrvlhz * 1000)
local numchannels = table.getn(channels)

--Build arrays and set ram registers.
for i=1,numchannels do
  ainavg[i] = -9999.0
  ljWrite((46000 + ((i-1)*2)), 3, ainavg[i])
  ain[i] = {}
end

--Set resindex to 12
ljWrite(ljnameToAddress("AIN_ALL_RESOLUTION_INDEX"), 0, resindx) 

-- Configure an interval
LJ.IntervalConfig(0, intrvlms)

-- Begin loop
while true do
  -- Execute loop every intrvlms.
  if LJ.CheckInterval(0) then
      -- Read the AIN channels
    for i=1,numchannels do 
      ain[i][index]= ljRead(ljnameToAddress("AIN"..(i-1)), 3)
    end

    --Find the average of each channel's current readings
    for i=1,numchannels do
        sums[i] = 0
        for j=1,index do
          sums[i] = sums[i] + ain[i][j]
        end
        ainavg[i] = sums[i] / index
        -- Save result to USER_RAM#_F32 register
        ljWrite((46000 + ((i-1)*2)), 3, ainavg[i])
    end

    -- Execute if numscans or more scans have been made
    if index==numscans then
        --Prepare the array for new reading by shifting the array over and adjusting index.
        for i=1,numchannels do 
          table.remove(ain[i], 1) 
        end
        index = index - 1
    end
    
    --Save number of scans to user ram
    ljWrite((46000 + ((numchannels)*2)), 3, count)
    count = count + 1 
    index = index +1
  end
end 
