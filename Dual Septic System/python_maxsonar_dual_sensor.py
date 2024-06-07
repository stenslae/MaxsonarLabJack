#The following only works for T7/T7-Pro and is most effective when no condensation is expected on the sensor.
#The sensor has a range of 300mm to 5000mm
#Expected Connections: Sensor 1 - FIO1, OBA(DAC0), GND, AIN3     Sensor 2 - FIO0, OBA(DAC0), GND, AIN2
import math
import time
from labjack import ljm

#The following value can be set to a range of 2.7 V to 5.0 V.
vsupply = 3.3

#Find LabJack device
handle = ljm.openS("ANY", "USB", "ANY")
#Powers sensor and makes sure all settings are default.
nameName = ["DIO_EF_CLOCK0_ENABLE", "DIO_EF_CLOCK1_ENABLE", "DIO_EF_CLOCK2_ENABLE", "DIO_EF_CLOCK0_DIVISOR",
            "DIO_EF_CLOCK0_OPTIONS", "DIO_EF_CLOCK0_ROLL_VALUE", "DIO0_EF_ENABLE", "DIO1_EF_ENABLE", "DAC0"]
nameNum = [0, 0, 0, 1,
           0, 0, 0, 0, vsupply]
numFrames = len(nameName)
ljm.eWriteNames(handle, numFrames, nameName, nameNum)
print('Measuring...')

#Update the DIO# for the functions depending on what # DIO/FIO you have the pwm output wired to.
#The following sets up DIO_EF
clockName = ["DIO0_EF_INDEX", "DIO1_EF_INDEX", "DIO_EF_CLOCK0_ENABLE", "DIO0_EF_ENABLE", "DIO1_EF_ENABLE"]
clockNum = [5, 5, 1, 1, 1]
numFrames = len(clockName)
ljm.eWriteNames(handle, numFrames, clockName, clockNum)

#Give time to ensure sensor can get a reading.
time.sleep(17)

access = ["DIO1_EF_READ_A_F_AND_RESET", "AIN3", "DIO0_EF_READ_A_F_AND_RESET", "AIN2"]
x = 0
results = [0, 0, 0, 0, 0, 0, 0, 0]
while x < 2:

    #Measures ToF of sonar in seconds.
    pwm = ljm.eReadName(handle, access[x*2])
    #1 micro second per mm, conversion and truncate due to a +/-5mm accuracy.
    results[0+x] = math.trunc(pwm*1000*3.28084*1000)/1000
    results[2+x] = math.trunc((pwm*1000)*1000)/1000
    #Print results for viewer
    print('The PWM for Sensor ', x+1, ' measured a distance of: ', results[0+x], ' feet and ', results[2+x], ' meters.')

    #Measures the ain output.
    ain1 = ljm.eReadName(handle, access[(x*2)+1])
    #vcc/5120 volts per mm, conversion and truncate due to a +/-5mm accuracy.
    results[4+x] = math.trunc((ain1*((5.120*3.28084)/vsupply))*1000)/1000
    results[6+x] = math.trunc((ain1*(5.120/vsupply))*1000)/1000
    #Print results for viewer
    print('The Analog for Sensor ', x+1, ' measured a distance of: ', results[4+x], ' feet and ', results[6+x], ' meters.')

    x = x+1
    print('\n')


#The program ends.
ljm.close(handle)