--[[
    Name: threshold_and_average.lua
    Desc: Implements a rolling average that cuts 25% of the values of the top and bottom.
    Note: Averaged from 12 seconds of data. Is saved to user ram.

          Testing was performed with a T7, FW 1.0299,
          and Kipling 3.1.17 open to the Lua Script Debugger tab
--]]

--The following can be updated:
  -- The analog inputs/registers to read & average
  local channels = {0, 1, 2, 3}
  -- Number of scans to cache & average
  local numscans = 60
  -- Sampling interval
  local intrvlhz = 5
  --The resolultion index of the ain channels
  local resindx = 8
  --The percentage that will be removed
  local thresh = .25
  --Are you removing from the top (1=yes 0=no) and/or bottom (1=yes 0=no)?
  local top = 1
  local bottom = 1

--Local functions for faster processing
local ljWrite = MB.W
local ljRead = MB.R
local ljnameToAddress = MB.nameToAddress


--Initialize variables
local sums = {}
local index = 1
local ain = {}
local count = 0
local intrvlms = math.floor(1/intrvlhz * 1000)
local numchannels = table.getn(channels)

--Build arrays.
for i=1,numchannels do
  ain[i] = {}
  ainavg = -9999
end

--Set ram register counter to 0
ljWrite(ljnameToAddress("USER_RAM4_F32"), 0, count) 

--Set resindex to 12
ljWrite(ljnameToAddress("AIN_ALL_RESOLUTION_INDEX"), 0, resindx) 

-- Configure an interval
LJ.IntervalConfig(0, intrvlms)


if (top == 0 or top == 1) and (bottom == 0 or bottom == 1) then
  -- Begin loop
  while true do
    -- Execute loop every intrvlms.
    if LJ.CheckInterval(0) then
        -- Read the AIN channels
      for i=1,numchannels do 
        ain[i][index]= ljRead(ljnameToAddress("AIN"..channels[i]), 3)
      end
  
      -- Execute if numscans or more scans have been made
      if index==numscans then
        --Cut off data from the top and/or bottom based on the threshold percentage
        for i =1,numchannels do
          table.sort(ain[i])
          for j=1, numscans*thresh do
            if top == 1 then
              table.remove(ain[i])
            end
            if bottom == 1 then
              table.remove(ain[i], 1) 
            end
          end
        end
        
        index = index -thresh*numscans*top -numscans*thresh*bottom
        
        --Find the average of each channel's current readings
        local ainavg = {}
        for i=1, numchannels do
          sums[i] = 0
          for j=1,index do
            sums[i] = sums[i] + ain[i][j]
          end
          ainavg[i] = sums[i] / index
          -- Save result to USER_RAM#_F32 register
          ljWrite((46000 + ((i-1)*2)), 3, ainavg[i])
        end
      end
      
      --Save number of scans to user ram
      ljWrite((46000 + ((numchannels)*2)), 3, count)
      index = index +1
      count = count + 1 
    end
  end 
else print("Only 1 and 0 are valid values for top and bottom.") end