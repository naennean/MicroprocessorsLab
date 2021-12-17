# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import serial
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime
import time
#%matplotlib qt


MSG_LEN = 4*2
PAD_LEN = 6
#distances = np.zeros((64,64))
distances = np.zeros(64)
params=[]
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
            if (s[i:i+PAD_LEN] == 'abcdef'):
                msg_idx = i+ PAD_LEN
                pack = s[msg_idx:msg_idx+MSG_LEN]
                print(s)
                print(pack)
                
                try: 
                   
                    dist = int(pack[0:4])
                    p1 = int(int(pack[4:6],16)/4) 
                    p2 =  int(int(pack[6:8],16)/4) 
                    print(dist, p1, p2)
    #                    if dist < 2000:
#                    distances[p2][p1] = dist
                    distances[p1] = dist
                    params.append([dist,p1,p2])
                    
                    
                    
                except ValueError:
                    print('ValueError')
                break
#%%
np.savetxt(str(f'./dec17/run_2Daccuracytestd=89cm.txt'), params)

#%%
import matplotlib.pyplot as plt
from mpl_toolkits import mplot3d
file = np.loadtxt('./dec17/run_2Dboxes.txt')
#plt.imshow(image)
distancevalues=[]
azimuth=[]
polar=[]
for i in params:
    distancevalues.append(i[0])
    azimuth.append(i[1])
    polar.append(i[2])
    #ax.scatter(i[2],i[1],i[0],c='b')
def sphericalpolar(r,az,pol):
    azimuth=np.array(az)
    polar=np.array(pol)
    azimuthal=np.cos(az)
    polars=np.sin(pol)
    return r,azimuthal,polars

'''
rval,azimuthval,polarval=sphericalpolar(distancevalues,azimuth,polar)
fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
ax.scatter(azimuthval,rval,azimuthval)
'''
def cartesian(r,az,pol):
    r=np.array(r)
    az=np.array(az)
    pol=np.array(pol)
    x=r*np.cos(az/20)*np.sin(pol/20)      
    y=r*np.sin(az/20)*np.sin(pol/20)
    z=r*np.cos(pol/20)
    return x,y,z
fig = plt.figure()
ax = plt.axes(projection='3d')
x,y,z=cartesian(distancevalues,azimuth,polar)
ax.scatter(y,x,z,marker="x",s=5)
ax.set_zlim(-250, 1000)
ax.set_ylim(-250, 1000)
ax.set_xlim(-250, 1000)

#        dist = int(s[0:4])
#        counter = s[4:]
#        
#        counter = int(int(counter, 16) /4)
#        print(dist, counter)
#        if dist < 2000:
#            distances[counter] = dist
#  
#        plt.clf()
#        plt.scatter(directions, distances)
#        plt.pause(0.1)

#        ser.close()
#        data.append([counter, dist])
#        counter2+=1
#        name="1"
#       
#    
#        np.savetxt("2.txt",data,fmt='%s')

   #print(dist, counter)
   # print(s)
    #tring = str(s)[4:]
        #string.replace("'","")
    #distance.append(string.replace("\\",','))
    