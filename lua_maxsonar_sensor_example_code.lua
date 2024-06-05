--The following is made for the T7/T7-Pro and is most effective when no condensation is expected on the sensor.
--The sensor has a range of 300mm to 5000mm
--Expected connections: Sensor - FIO0, AIN3, OBA(DAC0), GND

--The following value can be set to a range of 2.7 V to 5.0 V.
local vsupply =3.3

--Local functions for faster processing
local ljWrite = MB.WA
local ljRead = MB.R
local ljnameToAddress = MB.nameToAddress

--Initialize variables
local pwm = 0
local ain = 0
local names = {""DIO_EF_CLOCK0_ENABLE", "DIO_EF_CLOCK1_ENABLE", "DIO_EF_CLOCK2_ENABLE", "DIO_EF_CLOCK0_DIVISOR", "DIO_EF_CLOCK0_OPTIONS", "DIO_EF_CLOCK0_ROLL_VALUE", "DIO0_EF_ENABLE"}
local nums = {0, 0, 0, 1, 0, 0, 0}
local nValues = #names

--Configure Sensor
ljWrite(ljnameToAddress(names), nValues, nums)
print("Measuring...")

--The following sets up the DIO_EF to measure PWM output
local clockNames = {"DIO0_EF_INDEX", "DIO_EF_CLOCK0_ENABLE", "DIO0_EF_ENABLE"}
local clockNums = {5, 1, 1}
local nValues = #clockNames
ljWrite(ljnameToAddress(clockNames), nValues, clockNums)

--Configure a 7.5 seconds interval for the sensor to get a reading
LJ.IntervalConfig(1, 7500)
LJ.IntervalConfig(0, 8500)

--Power the sensor
ljWrite(ljnameToAddress("DAC0"), 0)

--Begin loop
while true do
	ljWrite(ljnameToAddress("DAC0"), 0)
	if LJ.CheckInterval(1) then
		ljWrite(ljnameToAddress("DAC0"), vsupply)
	end
	if LJ.CheckInterval(0) then
		--Measures ToF of sonar in seconds
		pwm = ljRead(ljnameToAddress("DIO0_EF_READ_A_F_AND_RESET"))
		print(pwm, " seconds")
		--Converts to distance
		pwmf = math.floor(pwm*1000*3.28084*1000+0.5)/1000
		pwmm = math.floor((pwm*1000)*1000+0.5)/1000
		print("The PWM output measured a distance of: ", pwmf, " feet and ", pwmm, " meters.")

		--Measures the ain output
		ain = ljRead(ljnameToAddress("AIN3"))
		--Converts to distance
		ainf = math.floor((ain*((5.120*3.28084)/vsupply)*1000)+0.5)/1000
		ainm = math.floor(ain*(5.120/vsupply)*1000+0.5)/1000
		print("The AIN output measured a distance of: "m ainf, " feet and ", ainm, " meters.")
	end
end