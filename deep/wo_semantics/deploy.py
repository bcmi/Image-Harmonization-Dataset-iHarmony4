from __future__ import print_function
import tensorflow as tf
import numpy as np
from PIL import Image
import math
import os
from six.moves import cPickle as pickle
from six.moves import range

FLAGS = tf.app.flags.FLAGS


tf.app.flags.DEFINE_integer('batch_size',32,
                           """Batch size.""")
tf.app.flags.DEFINE_float('init_lr', 1e-4,
                           """Initial learning rate.""")
tf.app.flags.DEFINE_string('data_dir','/home/cwy/disk/IHD/',
                           """Path to the dataset images""")

IMAGE_SIZE = 256
MOVING_AVERAGE_DECAY =0.9999
INITIAL_WEIGHT_DECAY=0


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

def _get_image_id_(image_path):
  split_slash=image_path.split("/")
  return split_slash[-1]

def inputs():
  path_img = []
  path_mask = []
  path_truth = []
  if train：
    filename=os.path.join(FLAGS.data_dir,'IHD_train.txt')
  else:
    filename=os.path.join(FLAGS.data_dir,'IHD_test.txt')
  with open(filename,'r') as f:
    for line in f.readlines():
      path_img.append(line.rstrip())
      path_mask.append(_get_mask_path_(line.rstrip()))
      path_truth.append(_get_truth_path_(line.rstrip()))
  return path_img, path_mask, path_truth

def read_images(filename_queue,ismask = 0):
  value = tf.read_file(tf.string_join([tf.convert_to_tensor(FLAGS.data_dir, tf.string),filename_queue]))
  record_bytes = tf.image.decode_jpeg(value,channels =max((1-ismask)*3,1))
  image = tf.image.resize_images(record_bytes, [IMAGE_SIZE, IMAGE_SIZE])
  if ismask==0:
    image = image*1.0/127.5 - 1.0
    image = tf.reverse(image,[-1])
  else:
    image = image*1.0/255.0
  image.set_shape([IMAGE_SIZE,IMAGE_SIZE,max((1-ismask)*3,1)])
  image = tf.convert_to_tensor(image, tf.float32)
  return image


def get_batch(image_path, mask_path, truth_path):
  imagepath,maskpath,truthpath = tf.train.slice_input_producer([image_path, mask_path, truth_path], num_epochs=FLAGS.epoch, shuffle=True)
  truth = read_images(truthpath)
  image = read_images(imagepath)
  mask = read_images(maskpath,ismask = 1)
  [image_batch, mask_batch, truth_batch] = tf.train.batch([image, mask, truth], batch_size=FLAGS.batch_size, num_threads=10, capacity=200, allow_smaller_final_batch=False)
  return image_batch, mask_batch, truth_batch


def _activation_summary(x):
  tf.summary.histogram(x.op.name + '/activations', x)
  tf.summary.scalar(x.op.name + '/sparsity', tf.nn.zero_fraction(x))

def _variable_with_weight_decay_(name, shape, stddev, wd):
  var=tf.Variable(tf.random_normal(shape=shape, stddev=stddev), name=name)
  if wd is not None:
    weight_decay = tf.multiply(tf.nn.l2_loss(var),wd,name='weight_loss')
    tf.add_to_collection('losses',weight_decay)
  return var


def conv_layer(bottom, filter_shape, bias_init = 1, activation=tf.nn.elu, padding='SAME', stride=2, name=None):
  with tf.variable_scope(name) as scope:
    #conv
    kernel=_variable_with_weight_decay_('weights',
                      shape=filter_shape,
                      stddev=0.01,
                      wd=None)
    conv=tf.nn.conv2d(bottom, kernel, [1,stride,stride,1], padding=padding)

    #bn & scale
    pre_activation=tf.layers.batch_normalization(conv, training=False,
                      name='bn' )
    #elu
    conv=activation(pre_activation, name='elu')
    _activation_summary(conv)
  return conv

def deconv_layer(bottom, filter_shape, output_shape, activation=tf.nn.elu, padding='SAME', stride=2, name=None):
  #deconv-h
  with tf.variable_scope(name) as scope:
    kernel=_variable_with_weight_decay_('weights',
                      shape=filter_shape,
                      stddev=0.01,
                      wd=None)
    deconv=tf.nn.conv2d_transpose(bottom, kernel,output_shape, [1,stride,stride,1], padding=padding) #data_format='NCHW'

    #deconv-bn-h & deconv-scale-h
    deconv0_h=tf.layers.batch_normalization(deconv, training=False,
                      name='deconv-bn-h' )
    #elu
    deconv0_h=activation(deconv0_h, name='deconv-elu-h')
    _activation_summary(deconv0_h)
  return deconv0_h

def inference(images, masks):

  ################## Context Encoder #####################
  #concate image and mask to a 4D tensor of [1, IMAGE_SIZE, IMAGE_SIZE, 4] size
  data_all = tf.concat([images, masks],3, name='concat')

  conv0 = conv_layer(data_all, [4,4,4,64], bias_init = 0, name='conv0')
  conv1 = conv_layer(conv0, [4,4,64,64], bias_init = 0, name='conv1')
  conv2 = conv_layer(conv1, [4,4,64,128], bias_init = 0, name='conv2')
  conv3 = conv_layer(conv2, [4,4,128,128], bias_init = 0, name='conv3')
  conv4 = conv_layer(conv3, [4,4,128,256], bias_init = 0, name='conv4')
  conv5 = conv_layer(conv4, [4,4,256,256], bias_init = 0, name='conv5')
  #fc7
  with tf.variable_scope('fc7') as scope:
    conv5=tf.reshape(conv5,[-1,4,4,256])
    print(conv5.shape)
    kernel=_variable_with_weight_decay_('weights',
                      shape=[4,4,256,512],
                      stddev=0.005,
                      wd=None)
    biases=tf.Variable(tf.zeros([512]),name='biases')
    fc7=tf.nn.conv2d(conv5, kernel, [1,1,1,1], padding='VALID')
    fc7 = tf.nn.bias_add(fc7, biases)
  #reshape1
  reshape1=tf.reshape(fc7,[FLAGS.batch_size,1,1,512])
  _activation_summary(reshape1)
  ################## Harmonizaiton Decoder #####################
  deconv5_h = deconv_layer(reshape1, [4,4,256,512],conv5.get_shape().as_list(), name='deconv5-h',padding = 'VALID')
  #eltwise-sum-h
  skip5_h=tf.add(deconv5_h,conv5)
  deconv4_h = deconv_layer(skip5_h, [4,4,256,256],conv4.get_shape().as_list(), name='deconv4-h')
  #eltwise-sum4-h
  skip4_h=tf.add(deconv4_h,conv4)
  deconv3_h = deconv_layer(skip4_h, [4,4,128,256],conv3.get_shape().as_list(), name='deconv3-h')
  #eltwise-sum3-h
  skip3_h=tf.add(deconv3_h,conv3)
  deconv2_h = deconv_layer(skip3_h, [4,4,128,128],conv2.get_shape().as_list(), name='deconv2-h')
  #eltwise-sum2-h
  skip2_h=tf.add(deconv2_h,conv2)
  deconv1_h = deconv_layer(skip2_h, [4,4,64,128],conv1.get_shape().as_list(), name='deconv1-h')
  #eltwise-sum1-h
  skip1_h=tf.add(deconv1_h,conv1)
  deconv0_h = deconv_layer(skip1_h, [4,4,64,64],conv0.get_shape().as_list(), name='deconv0-h')
  #eltwise-sum0-h
  skip0_h=tf.add(deconv0_h,conv0)
  #output-h
  with tf.variable_scope('output-h') as scope:
    kernel=_variable_with_weight_decay_('weights',
                      shape=[4,4,3,64],
                      stddev=0.01,
                      wd=None)
    deconv=tf.nn.conv2d_transpose(skip0_h, kernel,[FLAGS.batch_size,256,256,3], [1,2,2,1], padding='SAME')
    _activation_summary(deconv)
    composite = deconv
  composite = tf.clip_by_value(composite,-1,1,name='comp')
  return composite


def loss(composite, groundtruth):
  mse_loss = tf.losses.mean_squared_error(composite,groundtruth)
  tf.add_to_collection('losses',mse_loss)

  total_loss = tf.add_n(tf.get_collection('losses'),name='total_loss')
  return total_loss

def train(total_loss, global_step):
  tf.summary.scalar('loss',total_loss)
  optimizer = tf.train.AdamOptimizer(FLAGS.init_lr)
  train_op = optimizer.minimize(total_loss,global_step,name='train_op')
  return train_op

def _parse_comp_(image):
  image = (image*1.0+1.0)*127.5
  image = tf.reverse(image,[-1])
  image = tf.clip_by_value(image,0,255)
  return image
