# -*- coding: utf-8 -*-
"""
1D Plotting script for Microprocessors project
Do %matplotlib qt in IPython terminal prior to execution

"""
import serial
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime
import keyboard
#%matplotlib qt
import sys

MSG_LEN = 4*2
PAD_LEN = 6
#distances = np.zeros((64,64))
distances = np.zeros(64)
directions = (-np.arange(0,64)+ 32)/32 * 90

with serial.Serial() as ser:
    # Initialise serial read from UART
    ser.baudrate=9600
    ser.port='COM4'
    if not ser.isOpen():
        ser.open()
    now = datetime.now() 
    current_time = now.strftime("%H%M%S")
    while True: 
        # Read 14 bytes
        s=ser.read(14).hex()
        for i in range(len(s) -2):
            # Find start byte and store message after it 
            if (s[i:i+PAD_LEN] == 'abcdef'):
                msg_idx = i+ PAD_LEN
                pack = s[msg_idx:msg_idx+MSG_LEN]
                print(s)
                print(pack)
                try: 
                    # unpack message
                    dist = int(pack[0:4])
                    p1 = int(int(pack[4:6],16)/4) 
                    p2 =  int(int(pack[6:8],16)/4) 
                    print(dist, p1, p2)
                    
                    #store in array
                    if dist < 4000:
                        distances[p1] = dist
                    else:
                        distances[p1] = 0
                except ValueError:
                    print('ValueError')

                break
        # plot if p pressed, quit if q pressed
        if keyboard.is_pressed('p'):
            plt.clf()
            plt.scatter(directions, distances*np.cos(directions/90*np.pi/2))
            plt.pause(0.02)
        if keyboard.is_pressed('q'):
            sys.exit()
            
#%% Save message
np.savetxt('run_1D_boxcorner.txt', distances)

    