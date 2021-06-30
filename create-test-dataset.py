# This code is used for creating a text file with the list of all mapped image labels
import numpy as np
import pandas as pd
import shutil
import os
from distutils.dir_util import copy_tree
import csv
import re
import tkinter as fd
from tkinter import filedialog
from pathlib import Path

os.chdir("D:/WSDDN New/")
print(os.getcwd())

root = fd.Tk()
root.withdraw() #use to hide tkinter window

pres_dir = os.getcwd()
main_list = os.listdir("D:/WSDDN New/output/")
list =[]
for i in main_list:
        if ".jpg" in i:
            new_i = i.replace(".jpg", "")
            list.append(new_i)
        else:
            new_i = i.replace(".JPG", "")
            list.append(new_i) 
f = open("test.txt","w+")
for j in list:
            f.write( j + "\n")
f.close()