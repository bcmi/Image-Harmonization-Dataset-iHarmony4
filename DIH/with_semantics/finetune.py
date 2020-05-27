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

import deploy_seg

FLAGS = tf.app.flags.FLAGS
TIMESTAMP = "{0:%Y-%m-%dT%H-%M-%S}".format(datetime.now())

tf.app.flags.DEFINE_integer('epoch', 1000,
                           """Number of epochs to run trainer.""")

TRAIN_DIR = 'logs/'+TIMESTAMP+'_e'+str(FLAGS.epoch)+'_lr'+str(FLAGS.init_lr)+'_b'+str(FLAGS.batch_size)+'_finetune/'

TRAIN_AMOUNT = 65742
STEP_PER_TRAIN_EPOCH = int(TRAIN_AMOUNT / FLAGS.batch_size) #1625

MODEL_NAME = "model.ckpt"
image_size = 256
FLAGS.pretrain = False

if tf.gfile.Exists(TRAIN_DIR):
  tf.gfile.DeleteRecursively(TRAIN_DIR)
tf.gfile.MakeDirs(TRAIN_DIR)

global_step = tf.train.get_or_create_global_step()
image_path, mask_path, truth_path = deploy_seg.inputs()
image_batch, mask_batch, truth_batch = deploy_seg.get_batch(image_path, mask_path, truth_path)

com_placeholder = tf.placeholder(tf.float32,
                                shape=(FLAGS.batch_size,image_size, image_size, 3))
masks_placeholder = tf.placeholder(tf.float32,
                                shape=(FLAGS.batch_size,image_size, image_size, 1))
truths_placeholder = tf.placeholder(tf.float32,
                                shape=(FLAGS.batch_size, image_size, image_size, 3))

pred_label,composite = deploy_seg.inference(com_placeholder, masks_placeholder)
parse_com = deploy_seg._parse_eval_(composite)
tf.summary.image('parsed_composite', parse_com, max_outputs=20)
loss = deploy_seg.loss(composite, truths_placeholder)
train_op = deploy_seg.train(loss,global_step)
summary = tf.summary.merge_all()
with tf.Session() as sess:
  sess.run((tf.global_variables_initializer(), tf.local_variables_initializer()))
  new_saver = tf.train.Saver(max_to_keep=7)
  new_saver = tf.train.import_meta_graph('model/model.ckpt-455301.meta')
  new_saver.restore(sess, 'model/model.ckpt-455301')
  if new_saver:
    print("Restore successfully!")
  coord = tf.train.Coordinator()
  threads = tf.train.start_queue_runners(sess=sess,coord = coord)
  start_time = time.time()
  writer_train = tf.summary.FileWriter(TRAIN_DIR, sess.graph)
  checkpoint_file = os.path.join(TRAIN_DIR, 'model.ckpt')
  for e in range(FLAGS.epoch):
    for step in range(STEP_PER_TRAIN_EPOCH):
      image_batch_v, mask_batch_v, truth_batch_v = sess.run([image_batch, mask_batch, truth_batch])
      feed_dict_t={
              com_placeholder:image_batch_v,
              masks_placeholder:mask_batch_v,
              truths_placeholder:truth_batch_v
              }
      _, loss_value, train_pre = sess.run(
          [[pred_label, composite], loss, train_op], feed_dict=feed_dict_t)
      if((step+1) % 300 ==0):
        duration = time.time() - start_time
        print('Epoch %d step %d: total loss = %.7f (%.3f sec)' %(e, step+1, loss_value, duration))
        summary_str = sess.run(summary,feed_dict=feed_dict_t)
        writer_train.add_summary(summary_str,step)
        writer_train.flush()
    if((e+1) %3 == 0):
        new_saver.save(sess, checkpoint_file, global_step=global_step)
  coord.request_stop()
  coord.join(threads)

  print('Done!')


