#The following is made for the T7/T7-Pro and is most effective when no condensation is expected on the sensor.
#The sensor has a range of 300mm to 5000mm
#Expected connections: Sensor - FIO0, AIN3, OBA(DAC0), GND
import math
import time
from labjack import ljm

#The following value can be set to a range of 2.7 V to 5.0 V.
vsupply = 3.3

#Find LabJack device
handle = ljm.openS("ANY", "USB", "ANY")

#Initialize variables
pwm = 0
ain = 0
name = ["DIO_EF_CLOCK0_ENABLE", "DIO_EF_CLOCK1_ENABLE", "DIO_EF_CLOCK2_ENABLE", "DIO_EF_CLOCK0_DIVISOR",
            "DIO_EF_CLOCK0_OPTIONS", "DIO_EF_CLOCK0_ROLL_VALUE", "DIO0_EF_ENABLE", "DAC0"]
num = [0, 0, 0, 1,
           0, 0, 0, vsupply]
numFrames = len(name)

#Powers sensor and makes sure all settings are default.
ljm.eWriteNames(handle, numFrames, name, num)
print('Measuring...')

#The following sets up the DIO_EF to measure PWM output
clockName = ["DIO0_EF_INDEX", "DIO_EF_CLOCK0_ENABLE", "DIO0_EF_ENABLE"]
clockNum = [5, 1, 1]
numFrames = len(clockName)
ljm.eWriteNames(handle, numFrames, clockName, clockNum)

#Give time to ensure sensor can get a reading.
time.sleep(8)

#Measures ToF of sonar in seconds.
pwm = ljm.eReadName(handle, "DIO0_EF_READ_A_F_AND_RESET")
print(pwm)
#Converts to distance.
pwmf = math.trunc(pwm*1000*3.28084*1000)/1000
pwmm = math.trunc(pwm*1000*1000)/1000
#Print results for viewer
print('The PWM output measured a distance of: ', pwmf, ' feet and ', pwmm, ' meters.')

#Measures the ain output.
ain = ljm.eReadName(handle, "AIN3")
#Converts to distance.
ainf = math.trunc(ain*((5.120*3.28084)/vsupply)*1000)/1000
ainm = math.trun(ain*(5.120/vsupply)*1000)/1000
#Print results for viewer
print('The analog output measured a distance of: ', ainf, ' feet and ', ainm, ' meters.')

#The program ends.
ljm.close(handle)