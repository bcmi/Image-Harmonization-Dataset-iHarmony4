"""Dataset class template

This module provides a template for users to implement custom datasets.
You can specify '--dataset_mode template' to use this dataset.
The class name should be consistent with both the filename and its dataset_mode option.
The filename should be <dataset_mode>_dataset.py
The class name should be <Dataset_mode>Dataset.py
You need to implement the following functions:
    -- <modify_commandline_options>:　Add dataset-specific options and rewrite default values for existing options.
    -- <__init__>: Initialize this dataset class.
    -- <__getitem__>: Return a data point and its metadata information.
    -- <__len__>: Return the number of images.
"""
import os.path
import torch
import torchvision.transforms.functional as tf
from data.base_dataset import BaseDataset, get_transform
from data.image_folder import make_dataset
from PIL import Image
import numpy as np
import torchvision.transforms as transforms

class IhdDataset(BaseDataset):
    """A template dataset class for you to implement custom datasets."""
    @staticmethod
    def modify_commandline_options(parser, is_train):
        """Add new dataset-specific options, and rewrite default values for existing options.

        Parameters:
            parser          -- original option parser
            is_train (bool) -- whether training phase or test phase. You can use this flag to add training-specific or test-specific options.

        Returns:
            the modified parser.
        """
        parser.add_argument('--is_train', type=bool, default=True, help='whether in the training phase')
        parser.set_defaults(max_dataset_size=float("inf"), new_dataset_option=2.0)  # specify dataset-specific default values
        return parser

    def __init__(self, opt):
        """Initialize this dataset class.

        Parameters:
            opt (Option class) -- stores all the experiment flags; needs to be a subclass of BaseOptions

        A few things can be done here.
        - save the options (have been done in BaseDataset)
        - get image paths and meta information of the dataset.
        - define the image transformation.
        """
        # save the option and dataset root
        BaseDataset.__init__(self, opt)
        self.image_paths = []
        self.isTrain = opt.isTrain
        if opt.isTrain==True:
            #self.real_ext='.jpg'
            print('loading training file')
            self.trainfile = opt.dataset_root+'IHD_train.txt'
            with open(self.trainfile,'r') as f:
                    for line in f.readlines():
                        self.image_paths.append(os.path.join(opt.dataset_root,line.rstrip()))
        elif opt.isTrain==False:
            #self.real_ext='.jpg'
            print('loading test file')
            self.trainfile = opt.dataset_root+'IHD_test.txt'
            with open(self.trainfile,'r') as f:
                    for line in f.readlines():
                        self.image_paths.append(os.path.join(opt.dataset_root,line.rstrip()))
        # get the image paths of your dataset;
          # You can call sorted(make_dataset(self.root, opt.max_dataset_size)) to get all the image paths under the directory self.root
        # define the default transform function. You can use <base_dataset.get_transform>; You can also define your custom transform function
        self.transform = get_transform(opt)

    def __getitem__(self, index):
        """Return a data point and its metadata information.

        Parameters:
            index -- a random integer for data indexing

        Returns:
            a dictionary of data with their names. It usually contains the data itself and its metadata information.

        Step 1: get a random image path: e.g., path = self.image_paths[index]
        Step 2: load your data from the disk: e.g., image = Image.open(path).convert('RGB').
        Step 3: convert your data to a PyTorch tensor. You can use helpder functions such as self.transform. e.g., data = self.transform(image)
        Step 4: return a data point as a dictionary.
        """
        path = self.image_paths[index]
        name_parts=path.split('_')
        mask_path = self.image_paths[index].replace('composite_images','masks')
        mask_path = mask_path.replace(('_'+name_parts[-1]),'.png')
        target_path = self.image_paths[index].replace('composite_images','real_images')
        target_path = target_path.replace(('_'+name_parts[-2]+'_'+name_parts[-1]),'.jpg')

        #print(path)
        comp = Image.open(path).convert('RGB')
        #print(target_path)
        real = Image.open(target_path).convert('RGB')
        #print(mask_path)
        mask = Image.open(mask_path).convert('1')

        if np.random.rand() > 0.5 and self.isTrain:
            comp, mask, real = tf.hflip(comp), tf.hflip(mask), tf.hflip(real)

        comp = tf.resize(comp, [256, 256])
        mask = tf.resize(mask, [256, 256])
        real = tf.resize(real,[256,256])
        
        comp = self.transform(comp)
        mask = tf.to_tensor(mask)
        real = self.transform(real)

        inputs=torch.cat([comp,mask],0)
        
        return {'inputs': inputs, 'comp': comp, 'real': real,'img_path':path}

    def __len__(self):
        """Return the total number of images."""
        return len(self.image_paths)
