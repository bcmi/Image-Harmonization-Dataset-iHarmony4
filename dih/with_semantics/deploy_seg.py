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
                           """Number of steps to run trainer.""")
tf.app.flags.DEFINE_float('init_lr', 1e-4,
                           """Number of steps to run trainer.""")
tf.app.flags.DEFINE_string('data_dir','/home/cwy/disk/IHD/',
                          """Path to the composite images""")
tf.app.flags.DEFINE_boolean('pretrain',1,
                          """Path to the composite images""")


MOVING_AVERAGE_DECAY = 0.9999
IMAGE_SIZE = 256
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

def _get_label_path_(path):
  split_slash=path.split("/")
  split_underline=split_slash[-1].split("_")
  label_path=split_slash[0]+"/object_segmentations/"+split_underline[0]+".png"
  return label_path

def _get_image_id_(image_path):
  split_slash=image_path.split("/")
  return split_slash[-1]

def inputs(train=1):
  path_img = []
  path_mask = []
  path_truth = []
  path_label = []
  if train and FLAGS.pretrain:
    filename=os.path.join(FLAGS.data_dir,'HCOCO_train.txt')
  elif train and not FLAGS.pretrain:
    filename=os.path.join(FLAGS.data_dir,'IHD_train.txt')
  else:
    filename=os.path.join(FLAGS.data_dir,'IHD_test.txt')
  with open(filename,'r') as f:
    for line in f.readlines():
      path_img.append(line.rstrip())
      path_mask.append(_get_mask_path_(line.rstrip()))
      path_truth.append(_get_truth_path_(line.rstrip()))
      if FLAGS.pretrain:
        path_label.append(_get_label_path_(line.rstrip()))
  if FLAGS.pretrain:
    return path_img, path_mask, path_truth, path_label
  return path_img, path_mask, path_truth

def read_images(filename_queue,ismask = 0, islabel = 0):
  value = tf.read_file(tf.string_join([tf.convert_to_tensor(FLAGS.data_dir, tf.string),filename_queue]))
  record_bytes = tf.image.decode_jpeg(value,channels =max((1-max(ismask,islabel))*3,1))
  image = tf.image.resize_images(record_bytes, [IMAGE_SIZE, IMAGE_SIZE])
  #print(image)
  if islabel==0:
    image = image*1.0/127.5 - 1.0
  if ismask==0 and islabel==0:
    image = tf.reverse(image,[-1])
  if islabel==0:
    image.set_shape([IMAGE_SIZE,IMAGE_SIZE,max((1-max(ismask,islabel))*3,1)])
  else:
    image=tf.reshape(image,[IMAGE_SIZE,IMAGE_SIZE])
  image = tf.convert_to_tensor(image, tf.float32)
  return image


def get_batch_pre(image_path, mask_path, truth_path, label_path):
  imagepath,maskpath,truthpath,labelpath = tf.train.slice_input_producer([image_path, mask_path, truth_path, label_path], num_epochs=FLAGS.epoch, shuffle=True)
  truth = read_images(truthpath)
  image = read_images(imagepath)
  mask = read_images(maskpath, ismask = 1)
  label = read_images(labelpath, ismask = 0, islabel = 1)
  [image_batch, mask_batch, truth_batch, label_batch] = tf.train.batch([image, mask, truth, label], batch_size=FLAGS.batch_size, num_threads=10, capacity=200, allow_smaller_final_batch=False)
  return image_batch, mask_batch, truth_batch, label_batch

def get_batch(image_path, mask_path, truth_path):
  imagepath,maskpath,truthpath = tf.train.slice_input_producer([image_path, mask_path, truth_path], num_epochs=FLAGS.epoch, shuffle=True)
  truth = read_images(truthpath)
  image = read_images(imagepath)
  mask = read_images(maskpath, ismask = 1)
  [image_batch, mask_batch, truth_batch] = tf.train.batch([image, mask, truth], batch_size=FLAGS.batch_size, num_threads=10, capacity=200, allow_smaller_final_batch=False)
  return image_batch, mask_batch, truth_batch


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
    #_activation_summary(deconv0_h)
  return deconv0_h

def inference(images, masks):

  ################## Context Encoder #####################
  #concat image and mask to a 4D tensor of [1, IMAGE_SIZE, IMAGE_SIZE, 4] size
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
    kernel=_variable_with_weight_decay_('weights',
                      shape=[4,4,256,512],
                      stddev=0.005,
                      wd=None)
    biases=tf.Variable(tf.zeros([512]),name='biases')
    fc7=tf.nn.conv2d(conv5, kernel, [1,1,1,1], padding='VALID')
    fc7 = tf.nn.bias_add(fc7, biases)
  #reshape1
  reshape1=tf.reshape(fc7,[FLAGS.batch_size,1,1,512])

  ################## Scene Parsing Decoder #####################

  deconv5 = deconv_layer(reshape1, [4,4,256,512],conv5.get_shape().as_list(), name='deconv5',padding='VALID')
  #eltwise-sum-h
  skip5=tf.add(deconv5,conv5)
  deconv4 = deconv_layer(skip5, [4,4,256,256],conv4.get_shape().as_list(), name='deconv4')
  #eltwise-sum4-h
  skip4=tf.add(deconv4,conv4)
  deconv3 = deconv_layer(skip4, [4,4,128,256],conv3.get_shape().as_list(), name='deconv3')
  #eltwise-sum3-h
  skip3=tf.add(deconv3,conv3)
  deconv2 = deconv_layer(skip3, [4,4,128,128],conv2.get_shape().as_list(), name='deconv2')
  #eltwise-sum2-h
  skip2=tf.add(deconv2,conv2)
  deconv1 = deconv_layer(skip2, [4,4,64,128],conv1.get_shape().as_list(), name='deconv1')
  #eltwise-sum1-h
  skip1=tf.add(deconv1,conv1)
  deconv0 = deconv_layer(skip1, [4,4,64,64],conv0.get_shape().as_list(), name='deconv0')
  #eltwise-sum0-h
  skip0=tf.add(deconv0,conv0)
  deconv_output_seg = deconv_layer(skip0, [4,4,64,64],[FLAGS.batch_size,256,256,64], name='deconv_output_seg')

  with tf.variable_scope('output_final') as scope:
    kernel=_variable_with_weight_decay_('weights',
                      shape=[1,1,64,92],
                      stddev=0.01,
                      wd=None)
    seg_output_final=tf.nn.conv2d(deconv_output_seg, kernel, [1,1,1,1], padding='VALID')
    pred_label=seg_output_final

  ################## Harmonizaiton Decoder #####################
  deconv5_h = deconv_layer(reshape1, [4,4,256,512],conv5.get_shape().as_list(), name='deconv5-h',padding='VALID')
  #eltwise-sum-h
  skip5_h=tf.add(deconv5_h,conv5)
  concat5 = tf.concat([skip5_h, skip5],3, name='concat5')

  deconv4_h = deconv_layer(concat5, [4,4,256,512],conv4.get_shape().as_list(), name='deconv4-h')
  #eltwise-sum4-h
  skip4_h=tf.add(deconv4_h,conv4)
  concat4 = tf.concat([skip4_h, skip4],3, name='concat4')

  deconv3_h = deconv_layer(concat4, [4,4,128,512],conv3.get_shape().as_list(), name='deconv3-h')
  #eltwise-sum3-h
  skip3_h=tf.add(deconv3_h,conv3)
  concat3 = tf.concat([skip3_h, skip3],3, name='concat3')

  deconv2_h = deconv_layer(concat3, [4,4,128,256],conv2.get_shape().as_list(), name='deconv2-h')
  #eltwise-sum2-h
  skip2_h=tf.add(deconv2_h,conv2)
  concat2 = tf.concat([skip2_h, skip2],3, name='concat2')

  deconv1_h = deconv_layer(concat2, [4,4,64,256],conv1.get_shape().as_list(), name='deconv1-h')
  #eltwise-sum1-h
  skip1_h=tf.add(deconv1_h,conv1)
  concat1 = tf.concat([skip1_h, skip1],3, name='concat1')

  deconv0_h = deconv_layer(concat1, [4,4,64,128],conv0.get_shape().as_list(), name='deconv0-h')
  #eltwise-sum0-h
  skip0_h=tf.add(deconv0_h,conv0)
  #output-h
  with tf.variable_scope('output-h') as scope:
    kernel=_variable_with_weight_decay_('weights',
                      shape=[4,4,3,64],
                      stddev=0.01,
                      wd=None)
    deconv=tf.nn.conv2d_transpose(skip0_h, kernel,[FLAGS.batch_size,256,256,3], [1,2,2,1], padding='SAME')
    composite = deconv
  composite = tf.clip_by_value(composite,-1,1,name='com')

  return pred_label,composite


def loss_pre(pred_label, composite, label_map, groundtruth):
  mse_loss = tf.losses.mean_squared_error(composite,groundtruth)
  label_map = tf.cast(label_map,dtype=np.int32)
  cro_loss = tf.reduce_mean(tf.nn.sparse_softmax_cross_entropy_with_logits(labels=label_map,logits=pred_label))
  combined_loss = mse_loss + 0.0001*cro_loss

  tf.add_to_collection('losses',combined_loss)

  total_loss = tf.add_n(tf.get_collection('losses'),name='total_loss')
  return total_loss

def loss(composite, groundtruth):
  mse_loss = tf.losses.mean_squared_error(composite,groundtruth)
  combined_loss = mse_loss 
  tf.add_to_collection('losses',combined_loss)

  total_loss = tf.add_n(tf.get_collection('losses'),name='total_loss')
  return total_loss


def train(total_loss, global_step):
  tf.summary.scalar('loss',total_loss)
  optimizer = tf.train.AdamOptimizer(FLAGS.init_lr)
  learning_rate = optimizer._lr
  train_op = optimizer.minimize(total_loss,global_step,name='train_op')
  return train_op

def _parse_eval_(image):
  image = (image*1.0+1.0)*127.5
  image = tf.reverse(image,[-1])
  image = tf.clip_by_value(image,0,255)
  return image

def _parse_label_(pred_label):
  parse_label = tf.argmax(pred_label,axis=3)
  parse_label = tf.cast(parse_label,dtype=tf.uint8)
  parse_label=tf.reshape(parse_label,[FLAGS.batch_size,IMAGE_SIZE,IMAGE_SIZE,1])
  return parse_label