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
local cut = {}
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


-- Begin loop
while true do
  -- Execute loop every intrvlms.
  if LJ.CheckInterval(0) then
    -- Read the AIN channels
    for i=1,numchannels do 
      ain[i][index]= ljRead(ljnameToAddress("AIN"..channels[i]), 3)
    end
  
    --Removes the top and bottom percentages of your readings and stores into a new array.
    for i=1,numchannels do
      cut[i] = ain[i]
      table.sort(cut[i])
      local count = 0
      for j=1, index  do
        if top==1 then
          table.remove(cut[i])
        if bottom==1 then
          table.remove(cut[i], 1) 
        else
          count = count +1
        end
      end
    end
    
    --Find the average of each channel's current readings
    local ainavg = {}
    if count ~=0 then
      for i=1,numchannels do
        sums[i] = 0
        for j=1,count do
              sums[i] = sums[i] + cut[i][j]
        end
          ainavg[i] = sums[i] / count
          -- Save result to USER_RAM#_F32 register
          ljWrite((46000 + ((i-1)*2)), 3, ainavg[i])
      end
      else 
        for i=1,numchannels do ljWrite((46000 + ((i-1)*2)), 3, 0) end 
      end
    end
    local cut = {}
  
    --Keep the amount of scans calulated to a max of 60
    if index==numscans then
      table.remove(ain[i], 1)
      index = index -1
    end
      
    --Save number of scans to user ram
    ljWrite((46000 + ((numchannels)*2)), 3, count)
    index = index +1
    count = count + 1 
  end
end