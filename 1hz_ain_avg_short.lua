local channels = {0, 1, 2, 3}
local numscans = 10
local intrvlhz = 1
local resindx = 12
local ljWrite = MB.W
local ljRead = MB.R
local ljnameToAddress = MB.nameToAddress
local ainavg = {}
local sums = {}
local index = 1
local ain = {}
local count = 0
local intrvlms = math.floor(1/intrvlhz * 1000)
local numchannels = table.getn(channels)
for i=1,numchannels do
  ainavg[i] = -9999.0
  ljWrite((46000 + ((i-1)*2)), 3, ainavg[i])
  ain[i] = {} end
ljWrite(ljnameToAddress("AIN_ALL_RESOLUTION_INDEX"), 0, resindx)
LJ.IntervalConfig(0, intrvlms)
while true do
  if LJ.CheckInterval(0) then
    for i=1,numchannels do ain[i][index]= ljRead(ljnameToAddress("AIN"..(i-1)), 3) end
    if index==numscans then
      for i=1,numchannels do 
        sums[i] = 0
        for j=1,numscans do sums[i] = sums[i] + ain[i][j] end
        ainavg[i] = sums[i] / numscans
        ljWrite((46000 + ((i-1)*2)), 3, ainavg[i]) end
      for i=1,numchannels do table.remove(ain[i], 1) end
      index = index - 1 end
     ljWrite((46000 + ((numchannels)*2)), 3, count)
    count = count + 1 
    index = index +1 end end 