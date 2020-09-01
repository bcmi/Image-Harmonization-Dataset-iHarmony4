from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
import time

import os
from options.test_options import TestOptions
from data import create_dataset
from models import create_model
from util.visualizer import save_images
from util import html,util

from skimage import data, img_as_float
from skimage.measure import compare_mse as mse
from skimage.measure import compare_psnr as psnr

if __name__ == '__main__':
    opt = TestOptions().parse()  # get test options
    # hard-code some parameters for test
    opt.num_threads = 0   # test code only supports num_threads = 1
    opt.batch_size = 1    # test code only supports batch_size = 1
    opt.serial_batches = True  # disable data shuffling; comment this line if results on randomly chosen images are needed.
    opt.no_flip = True    # no flip; comment this line if results on flipped images are needed.
    opt.display_id = -1   # no visdom display; the test code saves the results to a HTML file.
    dataset = create_dataset(opt)  # create a dataset given opt.dataset_mode and other options
    model = create_model(opt)      # create a model given opt.model and other options
    model.setup(opt)               # regular setup: load and print networks; create schedulers
    
    # create a website
    web_dir = os.path.join(opt.results_dir, opt.name, '%s_%s' % (opt.phase, opt.epoch))  # define the website directory
    webpage = html.HTML(web_dir, 'Experiment = %s, Phase = %s, Epoch = %s' % (opt.name, opt.phase, opt.epoch))
    if opt.eval:
        model.eval()
    for i, data in enumerate(dataset):
        if i >= opt.num_test:  # only apply our model to opt.num_test images.
            break
        model.set_input(data)  # unpack data from data loader
        model.test()           # run inference
        visuals = model.get_current_visuals()  # get image results
        img_path = str(data['img_path'])
        raw_name = img_path.replace(('[\''),'')
        raw_name = raw_name.replace(('.jpg\']'),'.jpg')
        raw_name = raw_name.split('/')[-1]
        image_name = '%s' % raw_name
        save_path = os.path.join(web_dir,'images/',image_name)
        for label, im_data in visuals.items():
            if label=='output':
                output = util.tensor2im(im_data)
                util.save_image(output, save_path, aspect_ratio=opt.aspect_ratio)
                output =np.array(output, dtype=np.float32)
            if label=='real':
                real=util.tensor2im(im_data)
                real=np.array(real, dtype=np.float32)
            if label=='comp':
                comp=util.tensor2im(im_data)
                comp=np.array(comp, dtype=np.float32)
        mse_score_op = mse(output,real)
        psnr_score_op = psnr(real,output,data_range=output.max() - output.min())
        print('%s | mse %0.2f | psnr %0.2f' % (image_name,mse_score_op,psnr_score_op))

    webpage.save()  # save the HTML
