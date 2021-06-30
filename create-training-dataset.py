# This code is used for generating text files equal to the number of classes
# Each text file will contain the names of images belonging to that class fllowed by 1 (for example, Bhadra_BMR0dot8_20060407_181600_L 1)
# Each text file will also contain names of rest of the images followed by -1 (for example, Nagarahole_BZR1dot9_20111223_235900_R -1)
# This output will be used in create-image-mapping.R script for generating image labels
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

os.chdir("D:/WSDDN New")
print(os.getcwd())

root = fd.Tk()
root.withdraw() #use to hide tkinter window

pres_dir = os.getcwd()
main_list = os.listdir("D:/WSDDN New/Tiger/")
for folder in main_list:
    new_list = os.listdir("D:/WSDDN New/Tiger/" + folder + "/")
    list = []
    for i in new_list:
        if ".jpg" in i:
            new_i = i.replace(".jpg", " 1")
            list.append(new_i)
        else:
            new_i = i.replace(".JPG", " 1")
            list.append(new_i) 
    f = open(folder + ".txt","w+")
    for i in list:
            f.write( i + "\n")
    f.close()


file_list = os.listdir("D:/WSDDN New/")
for ele in  file_list:
    if ele.endswith('.txt') :
        text_res = []
        for dump in file_list:
            if dump.endswith('.txt') :
                if ele != dump:
                    # new_dump = dump.copy()
                    new_dump = dump.replace(".txt", "")
                    new_bel = os.listdir("D:/WSDDN New/Tiger/" + new_dump + "/")
                    for j in new_bel:
                        if ".jpg" in j:
                            newer_i = j.replace(".jpg", " -1")
                            print(newer_i)
                            text_res.append(newer_i)
                        else:
                            newer_i = j.replace(".JPG", " -1")
                            print(newer_i)
                            text_res.append(newer_i) 
        with open(ele, "a") as f:
            for i in text_res:
                f.write( i + "\n")
        f.close()
                    