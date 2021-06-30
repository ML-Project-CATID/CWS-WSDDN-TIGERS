# This code is used for generating labels required for the imdb-eb.mat file 
# The label will be of the shape = no. of classes x no. of images (for example, for 32 classes and 1980 images, you will get a matrix of 32 x 1980)
# The output label comes with column and row names, makse sure to delete it before using it
# The output label will be used in CreateDataset.m script
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
root = fd.Tk()
root.withdraw() #use to hide tkinter window
pres_dir = os.getcwd()
res = np.empty((164, 0))
main_list = os.listdir("D:/WSDDN New/Tiger/")
main_list.sort()
print(main_list)
for folder in main_list:
    new_list = "D:/WSDDN New/Tiger/" + folder + "/"
    total_file = 0
    for base, dirs, files in os.walk(new_list):
        for Files in files:
            total_file += 1
    resNew = pd.DataFrame(np.zeros(( 164, total_file)), index=('1', '10', '100', '101', '102', '103', '104', '105', '106', '107', '108', '109', '11', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '12', '120', '121', '122', '123', '124', '125', '126', '127', '128', '129', '13', '130', '131', '132', '133', '134', '135', '136', '137', '138', '139', '14', '140', '141', '142', '143', '144', '145', '146', '147', '148', '149', '15', '150', '151', '152', '153', '154', '155', '156', '157', '158', '159', '16', '160', '161', '162', '163', '17', '18', '19', '2', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '3', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '4', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '5', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '6', '60', '61', '62', '63', '64', '65', '66', '67', '68', '69', '7', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '8', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '9', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', 'unclassified'))
    resNew = pd.DataFrame(np.where(resNew == 0, -1, resNew), index=('1', '10', '100', '101', '102', '103', '104', '105', '106', '107', '108', '109', '11', '110', '111', '112', '113', '114', '115', '116', '117', '118', '119', '12', '120', '121', '122', '123', '124', '125', '126', '127', '128', '129', '13', '130', '131', '132', '133', '134', '135', '136', '137', '138', '139', '14', '140', '141', '142', '143', '144', '145', '146', '147', '148', '149', '15', '150', '151', '152', '153', '154', '155', '156', '157', '158', '159', '16', '160', '161', '162', '163', '17', '18', '19', '2', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '3', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '4', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '5', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '6', '60', '61', '62', '63', '64', '65', '66', '67', '68', '69', '7', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '8', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '9', '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', 'unclassified'))
    resNew.loc[folder] = 1
    resNew = resNew.values
    res = np.column_stack((res, resNew))
    resNew = np.empty([])
final_shape = pd.DataFrame(res)
final_shape.to_csv("opt_163_bl_new.csv")
