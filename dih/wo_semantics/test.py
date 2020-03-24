from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

from datetime import datetime
import time
import tensorflow as tf
import numpy as np
from PIL import Image
import math
import os
from six.moves import cPickle as pickle
from six.moves import range

from skimage import data, img_as_float
from skimage.measure import compare_ssim as ssim
from skimage.measure import compare_mse as mse
from skimage.measure import compare_psnr as psnr

import deploy
FLAGS = tf.app.flags.FLAGS

MODEL_NAME = "model.ckpt"
image_size = 256
n=7404
model_num='117078'
compathfile =FLAGS.data_dir + 'IHD_test.txt'
file = open(model_num+'.txt', 'a')

def _get_mask_path_(path):
  split_slash=path.split("/")
  split_underline=split_slash[-1].split("_")
  mask_path=split_slash[0]+"/masks/"+split_underline[0]+"_"+split_underline[1]+".png"
  return mask_path

def _get_truth_path_(path):
  split_slash=path.split("/")
  split_underline=split_slash[-1].split("_")
  truth_path=split_slash[0]+"/real_images/"+split_underline[0]+".jpg"
  return truth_path


def get_name(path):
  slash = path.split("/")
  return slash[-1]

def _parse_image(image_path):
  im_ori = Image.open(image_path)
  im_ori = im_ori.convert('RGB')
  im = im_ori.resize(np.array([image_size,image_size]), Image.BICUBIC)
  im = np.array(im, dtype=np.float32)
  if im.shape[2] == 4:
    im = im[:,:,0:3]
  im = im[:,:,::-1]
  im -= np.array((127.5, 127.5, 127.5))
  im = np.divide(im, np.array(127.5))
  image = im[np.newaxis, ...]
  return image

def _parse_mask(mask_path):
  mask = Image.open(mask_path)
  mask = mask.resize(np.array([image_size,image_size]), Image.BICUBIC)
  mask = np.array(mask, dtype=np.float32)
  if len(mask.shape) == 3:
    mask = mask[:,:,0]
  mask -= 127.5
  mask = np.divide(mask, np.array(127.5))
  mask = mask[np.newaxis, ...]
  mask = mask[..., np.newaxis]
  return mask


def _parse_truth_eval(truth_path):
  truth = Image.open(truth_path)
  truth = truth.convert('RGB')
  truth = truth.resize(np.array([image_size,image_size]), Image.BICUBIC)
  truth = np.array(truth, dtype=np.float32)
  if truth.ndim == 2:
    truth = truth.reshape(np.array((512,512,3)))
  return truth


path_img = []
path_mask = []
path_truth = []
with open(compathfile,'r') as f:
  for line in f.readlines():
    path_img.append(line.rstrip())
    path_mask.append(_get_mask_path_(line.rstrip()))
    path_truth.append(_get_truth_path_(line.rstrip()))

com_placeholder = tf.placeholder(tf.float32,
                                shape=(1, image_size, image_size, 3))
masks_placeholder = tf.placeholder(tf.float32,
                                shape=(1, image_size, image_size, 1))

harmnization = deploy.inference(com_placeholder, masks_placeholder)

saver = tf.train.Saver()

gpu_options = tf.GPUOptions(allow_growth=True)
sess = tf.Session(config=tf.ConfigProto(gpu_options=gpu_options)) 
sess.run((tf.global_variables_initializer(), tf.local_variables_initializer()))
new_saver = tf.train.import_meta_graph('model/model.ckpt-'+model_num+'.meta')
new_saver.restore(sess, 'model/model.ckpt-'+model_num)
if new_saver:
  print("Restore successfully!")
for i in range(0,len(path_img)):
  com = _parse_image(os.path.join(FLAGS.data_dir,path_img[i]))
  mask = _parse_mask(os.path.join(FLAGS.data_dir,path_mask[i]))
  truth = _parse_truth_eval(os.path.join(FLAGS.data_dir,path_truth[i]))
  feed_dict = {
  com_placeholder: com,
  masks_placeholder: mask,
  }
  harm = sess.run(harmnization, feed_dict=feed_dict)
  harm_rgb=np.squeeze(harm)
  harm_rgb=np.multiply(harm_rgb,np.array(127.5))
  harm_rgb += np.array((127.5, 127.5, 127.5))
  harm_rgb = harm_rgb[:,:,::-1]
  neg_idx = harm_rgb < 0.0
  harm_rgb[neg_idx] = 0.0
  pos_idx = harm_rgb > 255.0
  harm_rgb[pos_idx] = 255.0
  name=get_name(path_img[i])

  truth1 = Image.open(os.path.join(FLAGS.data_dir,path_truth[i]))
  truth1 = truth1.resize([256,256], Image.BICUBIC)
  truth1 = np.array(truth1, dtype=np.float32)

  mse_score = mse(harm_rgb,truth1)
  psnr_score = psnr(truth1,harm_rgb,data_range=harm_rgb.max() - harm_rgb.min())
  ssim_score = ssim(truth1,harm_rgb,data_range=harm_rgb.max() - harm_rgb.min(),multichannel=True)
  
  file.writelines('%s\t%f\t%f\t%f\n' % (name,mse_score,psnr_score,ssim_score))
  print(i,name,mse_score,psnr_score,ssim_score)

sess.close()
print('Done!')