--[[
    Name: threshold_and_average.lua
    Desc: Implements a rolling average that cuts 25% of the values of the top and bottom.
    Note: Averaged from 12 seconds of data. Is saved to user ram.

          Testing was performed with a T7, FW 1.0299,
          and Kipling 3.1.17 open to the Lua Script Debugger tab
          
    Last modified: 11/14/2023 4:20PM
--]]

--Configuration items:
  -- Analog inputs to read
  local channels = {0, 1, 2, 3}
  -- Number of scans to cache & average
  local numscans = 60
  -- Scans per second
  local scanrate = 50
  --The resolution index of the ain channels
  local resindx = 0
  --Amount of scans to remove. Make sure thresh*numscans is an integer.
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
local aincopy = {}
local count = 0
local intrvlms = math.floor(1/scanrate * 1000)
local numchannels = table.getn(channels)

--Initialize arrays
for i=1,numchannels do
  ain[i] = {}
  aincopy[i]={}
  --ainavg = -9999
end

--Set ram register counter to 0
ljWrite(ljnameToAddress("USER_RAM0_F32"), 0, count) 

--Set resolution index
ljWrite(ljnameToAddress("AIN_ALL_RESOLUTION_INDEX"), 0, resindx) 

--Configure an interval
LJ.IntervalConfig(0, intrvlms)

if (top == 0 or top == 1) and (bottom == 0 or bottom == 1) then
  -- Begin loop
  while true do
    -- Execute code every intrvlms.
    if LJ.CheckInterval(0) then
      -- Read the AIN channels
      for i=1,numchannels do 
        ain[i][index]= ljRead(ljnameToAddress("AIN"..channels[i]), 3)
      end
      
      -- Execute if numscans or more scans have been made
      if index==(numscans+1) then
        --Cut off data from the top and/or bottom based on the threshold percentage
        for i =1,numchannels do
          -- removes first/oldest element in array copy
          table.remove(ain[i],1)
          --copies 60 elements to array 
          for j =1, numscans do
            aincopy[i][j] = ain[i][j]
          end
          --sorts remaining 60 elements in copy array 
          table.sort(aincopy[i])

          for j=1, numscans*thresh do
            if top == 1 then
              --removes last element in sorted array
              table.remove(aincopy[i])
            end
            if bottom == 1 then
              --removes first element in sorted array
              table.remove(aincopy[i], 1)
            end
          end
        end
        --Find the average of each channel's current readings
        local ainavg = {}
        for i=1, numchannels do
          sums[i] = 0
          
          --sums the scans remaining in the copied and sorted array 
          for j=1,(numscans - (numscans* 2* thresh)) do
            sums[i] = sums[i] + aincopy[i][j]
            
          end
          --divides the sums by the size of the array 
          ainavg[i] = sums[i] / (table.getn(aincopy[i]))
          
          -- Save result to USER_RAM#_F32 register
          ljWrite((46000 + ((i)*2)), 3, ainavg[i])
        end
      end
      
      --Write iteration count to user ram
      ljWrite((46000), 3, count)
      --iterates index until it reaches numscans+1 and stops iterating
      if(index <= numscans) then
        index = index + 1
      else
        index = numscans +1
      end
      count = count + 1 
    end
  end
else end