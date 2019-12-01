from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import os

from skimage import data, img_as_float
from skimage.measure import compare_ssim as ssim
from skimage.measure import compare_mse as mse
from skimage.measure import compare_psnr as psnr

sub_dataset = 'HCOCO'
real_image_dir = '/home/user/disk/IH/IHD/'+sub_dataset+'_test/'
image_dir = '/home/user/disk/IH/baselines/lalonde/colorStatistics/mycode/demo/data/images/result/'+sub_dataset+'_test/'
test_dirs = ['0to5','5to15','15to90']

def truth_name(name):
	parts = name.split('_')
	return parts[0]+'.jpg'

for ii in range(0,3):
	file_name = '/home/user/disk/IH/IHD/'+sub_dataset+'/'+sub_dataset+'_test_'+test_dirs[ii]+'.txt'
	with open(file_name,'r') as f:
		name_test=[line.rstrip() for line in f.readlines()]

	file = open('/home/user/disk/IH/baselines/lalonde/metrics_result/'+sub_dataset+'_test_'+test_dirs[ii]+'_mps.txt', 'a')
	
	for jj in range(0,len(name_test)):
		comp = Image.open(os.path.join(image_dir,test_dirs[ii],name_test[jj]))
		comp = np.array(comp, dtype=np.float32)
		truth = Image.open(os.path.join(real_image_dir,'real_images/',truth_name(name_test[jj])))
		truth = np.array(truth, dtype=np.float32)
		#mse_sanity = mse(comp,comp)
		mse_score = mse(comp,truth)
		#print('mse_sanity: %f | mse_score: %f' %(mse_sanity,mse_score))
		#psnr_sanity = psnr(comp,comp,data_range=comp.max() - comp.min())
		psnr_score = psnr(truth,comp,data_range=comp.max() - comp.min())
		#print('psnr_score: %f' %psnr_score)
		#ssim_sanity = ssim(comp,comp,data_range=comp.max() - comp.min(),multichannel=True)
		ssim_score = ssim(truth,comp,data_range=comp.max() - comp.min(),multichannel=True)
		#print('ssim_sanity: %f | ssim_score: %f' %(ssim_sanity,ssim_score))
		print('%s | mse %f | psnr %f | ssim %f ' % (name_test[jj],mse_score,psnr_score,ssim_score))
		file.writelines([name_test[jj],'\t',str(mse_score),'\t',str(psnr_score),'\t',str(ssim_score),'\n'])

print('Done!')
file.close()