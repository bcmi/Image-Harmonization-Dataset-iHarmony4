from PIL import Image
import numpy as np
import os
from skimage import data, img_as_float
from skimage.measure import compare_mse as mse
from skimage.measure import compare_psnr as psnr

IMAGE_SIZE = np.array([256,256])
comp_name='data/a0002_1_4.jpg'

def real_name(name):
	name_parts=name.split('_')
	real_name = name.replace(('_'+name_parts[-2]+'_'+name_parts[-1]),'.jpg')
	return real_name

def mask_name(name):
	name_parts=name.split('_')
	mask_name = name.replace(('_'+name_parts[-1]),'.png')
	return mask_name

comp = Image.open(comp_name)
comp = comp.resize(IMAGE_SIZE, Image.BICUBIC)
comp = np.array(comp, dtype=np.float32)

real = Image.open(real_name(comp_name))
real = real.resize(IMAGE_SIZE, Image.BICUBIC)
real = np.array(real, dtype=np.float32)

mask = Image.open(mask_name(comp_name))
mask = mask.convert('1')
mask = mask.resize(IMAGE_SIZE, Image.BICUBIC)
mask=np.array(mask,dtype=np.uint8)
fore_area = np.sum(np.sum(mask,axis=0),axis=0)
mask = mask[...,np.newaxis]

mse_score = mse(comp,real)
psnr_score = psnr(real,comp,data_range=comp.max() - comp.min())
fmse_score= mse(comp*mask,real*mask)*256*256/fore_area

print("%s MSE %0.2f | PSNR %0.2f | fMSE %0.2f" % (comp_name,mse_score,psnr_score,fmse_score))
