import torch
from .base_model import BaseModel
from . import networks
import torch.nn.functional as F
from torch import nn, cuda
from torch.autograd import Variable
import functools
from torch.nn.utils import spectral_norm


class PartialConv2d(nn.Conv2d):
    def __init__(self, *args, **kwargs):

        # whether the mask is multi-channel or not
        if 'multi_channel' in kwargs:
            self.multi_channel = kwargs['multi_channel']
            kwargs.pop('multi_channel')
        else:
            self.multi_channel = False

        self.return_mask = True

        super(PartialConv2d, self).__init__(*args, **kwargs)

        if self.multi_channel:
            self.weight_maskUpdater = torch.ones(self.out_channels, self.in_channels, self.kernel_size[0],
                                                 self.kernel_size[1])
        else:
            self.weight_maskUpdater = torch.ones(1, 1, self.kernel_size[0], self.kernel_size[1])

        self.slide_winsize = self.weight_maskUpdater.shape[1] * self.weight_maskUpdater.shape[2] * \
                             self.weight_maskUpdater.shape[3]

        self.last_size = (None, None, None, None)
        self.update_mask = None
        self.mask_ratio = None

    def forward(self, input, mask_in=None):
        assert len(input.shape) == 4
        if mask_in is not None or self.last_size != tuple(input.shape):
            self.last_size = tuple(input.shape)

            with torch.no_grad():
                if self.weight_maskUpdater.type() != input.type():
                    self.weight_maskUpdater = self.weight_maskUpdater.to(input)

                if mask_in is None:
                    # if mask is not provided, create a mask
                    if self.multi_channel:
                        mask = torch.ones(input.data.shape[0], input.data.shape[1], input.data.shape[2],
                                          input.data.shape[3]).to(input)
                    else:
                        mask = torch.ones(1, 1, input.data.shape[2], input.data.shape[3]).to(input)
                else:
                    mask = mask_in

                self.update_mask = F.conv2d(mask, self.weight_maskUpdater, bias=None, stride=self.stride,
                                            padding=self.padding, dilation=self.dilation, groups=1)

                self.mask_ratio = self.slide_winsize / (self.update_mask + 1e-8)
                self.update_mask = torch.clamp(self.update_mask, 0, 1)
                self.mask_ratio = torch.mul(self.mask_ratio, self.update_mask)


        raw_out = super(PartialConv2d, self).forward(torch.mul(input, mask) if mask_in is not None else input)

        if self.bias is not None:
            bias_view = self.bias.view(1, self.out_channels, 1, 1)
            output = torch.mul(raw_out - bias_view, self.mask_ratio) + bias_view
            output = torch.mul(output, self.update_mask)
        else:
            output = torch.mul(raw_out, self.mask_ratio)

        if self.return_mask:
            return output, self.update_mask
        else:
            return output


class OrgDiscriminator(nn.Module):

    def __init__(self, input_nc, ndf=64, n_layers=6, norm_layer=nn.BatchNorm2d, global_stages=0):
        """Construct a PatchGAN discriminator

        Parameters:
            input_nc (int)  -- the number of channels in input images
            ndf (int)       -- the number of filters in the last conv layer
            n_layers (int)  -- the number of conv layers in the discriminator
            norm_layer      -- normalization layer
        """
        super(OrgDiscriminator, self).__init__()
        if type(norm_layer) == functools.partial:  # no need to use bias as BatchNorm2d has affine parameters
            use_bias = norm_layer.func == nn.InstanceNorm2d
        else:
            use_bias = norm_layer == nn.InstanceNorm2d

        kw = 3
        padw = 0
        self.conv1 = spectral_norm(PartialConv2d(input_nc, ndf, kernel_size=kw, stride=2, padding=padw))
        if global_stages < 1:
            self.conv1f = spectral_norm(PartialConv2d(input_nc, ndf, kernel_size=kw, stride=2, padding=padw))
        else:
            self.conv1f = self.conv1
        self.relu1 = nn.LeakyReLU(0.2, True)
        nf_mult = 1
        nf_mult_prev = 1

        n = 1
        nf_mult_prev = nf_mult
        nf_mult = min(2 ** n, 8)
        self.conv2 = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
        self.norm2 = norm_layer(ndf * nf_mult)
        if global_stages < 2:
            self.conv2f = spectral_norm(
                PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
            self.norm2f = norm_layer(ndf * nf_mult)
        else:
            self.conv2f = self.conv2
            self.norm2f = self.norm2

        self.relu2 = nn.LeakyReLU(0.2, True)

        n = 2
        nf_mult_prev = nf_mult
        nf_mult = min(2 ** n, 8)
        self.conv3 = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
        self.norm3 = norm_layer(ndf * nf_mult)
        if global_stages < 3:
            self.conv3f = spectral_norm(
                PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
            self.norm3f = norm_layer(ndf * nf_mult)
        else:
            self.conv3f = self.conv3
            self.norm3f = self.norm3
        self.relu3 = nn.LeakyReLU(0.2, True)

        n = 3
        nf_mult_prev = nf_mult
        nf_mult = min(2 ** n, 8)
        self.norm4 = norm_layer(ndf * nf_mult)
        self.conv4 = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
        self.conv4f = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
        self.norm4f = norm_layer(ndf * nf_mult)

        self.relu4 = nn.LeakyReLU(0.2, True)

        n = 4
        nf_mult_prev = nf_mult
        nf_mult = min(2 ** n, 8)
        self.conv5 = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
        self.conv5f = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
        self.norm5 = norm_layer(ndf * nf_mult)
        self.norm5f = norm_layer(ndf * nf_mult)
        self.relu5 = nn.LeakyReLU(0.2, True)

        n = 5
        nf_mult_prev = nf_mult
        nf_mult = min(2 ** n, 8)
        self.conv6 = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
        self.conv6f = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=2, padding=padw, bias=use_bias))
        self.norm6 = norm_layer(ndf * nf_mult)
        self.norm6f = norm_layer(ndf * nf_mult)
        self.relu6 = nn.LeakyReLU(0.2, True)

        nf_mult_prev = nf_mult
        nf_mult = min(2 ** n_layers, 8)
        self.conv7 = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=1, padding=padw, bias=use_bias))
        self.conv7f = spectral_norm(
            PartialConv2d(ndf * nf_mult_prev, ndf * nf_mult, kernel_size=kw, stride=1, padding=padw, bias=use_bias))

    def forward(self, input, mask=None):
        x = input
        x, _ = self.conv1(x)
        x = self.relu1(x)
        x, _ = self.conv2(x)
        x = self.norm2(x)
        x = self.relu2(x)
        x, _ = self.conv3(x)
        x = self.norm3(x)
        x = self.relu3(x)
        x, _ = self.conv4(x)
        x = self.norm4(x)
        x = self.relu4(x)
        x, _ = self.conv5(x)
        x = self.norm5(x)
        x = self.relu5(x)
        x, _ = self.conv6(x)
        x = self.norm6(x)
        x = self.relu6(x)
        x, _ = self.conv7(x)

        """Standard forward."""
        xf, xb = input, input
        mf, mb = mask, 1 - mask

        xf, mf = self.conv1f(xf, mf)
        xf = self.relu1(xf)
        xf, mf = self.conv2f(xf, mf)
        xf = self.norm2f(xf)
        xf = self.relu2(xf)
        xf, mf = self.conv3f(xf, mf)
        xf = self.norm3f(xf)
        xf = self.relu3(xf)
        xf, mf = self.conv4f(xf, mf)
        xf = self.norm4f(xf)
        xf = self.relu4(xf)
        xf, mf = self.conv5f(xf, mf)
        xf = self.norm5f(xf)
        xf = self.relu5(xf)
        xf, mf = self.conv6f(xf, mf)
        xf = self.norm6f(xf)
        xf = self.relu6(xf)
        xf, mf = self.conv7f(xf, mf)

        xb, mb = self.conv1f(xb, mb)
        xb = self.relu1(xb)
        xb, mb = self.conv2f(xb, mb)
        xb = self.norm2f(xb)
        xb = self.relu2(xb)
        xb, mb = self.conv3f(xb, mb)
        xb = self.norm3f(xb)
        xb = self.relu3(xb)
        xb, mb = self.conv4f(xb, mb)
        xb = self.norm4f(xb)
        xb = self.relu4(xb)
        xb, mb = self.conv5f(xb, mb)
        xb = self.norm5f(xb)
        xb = self.relu5(xb)
        xb, mb = self.conv6f(xb, mb)
        xb = self.norm6f(xb)
        xb = self.relu6(xb)
        xb, mb = self.conv7f(xb, mb)

        return x, xf, xb


class NLayerDiscriminator(nn.Module):

    def __init__(self, input_nc, ndf=64, n_layers=6, norm_layer=nn.BatchNorm2d):
        """Construct a PatchGAN discriminator

        Parameters:
            input_nc (int)  -- the number of channels in input images
            ndf (int)       -- the number of filters in the last conv layer
            n_layers (int)  -- the number of conv layers in the discriminator
            norm_layer      -- normalization layer
        """
        super(NLayerDiscriminator, self).__init__()
        num_outputs = ndf * min(2 ** n_layers, 8)
        self.D = OrgDiscriminator(input_nc, ndf, n_layers, norm_layer)
        self.convl1 = spectral_norm(nn.Conv2d(num_outputs, num_outputs, kernel_size=1, stride=1))
        self.relul1 = nn.LeakyReLU(0.2)
        self.convl2 = spectral_norm(nn.Conv2d(num_outputs, num_outputs, kernel_size=1, stride=1))
        self.relul2 = nn.LeakyReLU(0.2)
        self.convl3 = nn.Conv2d(num_outputs, 1, kernel_size=1, stride=1)
        self.convg3 = nn.Conv2d(num_outputs, 1, kernel_size=1, stride=1)

    def forward(self, input, mask=None, gp=False, feat_loss=False):

        x, xf, xb = self.D(input, mask)
        feat_l, feat_g = torch.cat([xf, xb]), x
        x = self.convg3(x)

        sim = xf * xb
        sim = self.convl1(sim)
        sim = self.relul1(sim)
        sim = self.convl2(sim)
        sim = self.relul2(sim)
        sim = self.convl3(sim)
        sim_sum = sim
        if not gp:
            if feat_loss:
                return x, sim_sum, feat_g, feat_l
            return x, sim_sum
        return  (x + sim_sum) * 0.5


class DoveNetModel(BaseModel):


    @staticmethod
    def modify_commandline_options(parser, is_train=True):
        """Add new dataset-specific options, and rewrite default values for existing options.

        Parameters:
            parser          -- original option parser
            is_train (bool) -- whether training phase or test phase. You can use this flag to add training-specific or test-specific options.

        Returns:
            the modified parser.

        """
        parser.set_defaults(norm='batch', netG='unet_256', dataset_mode='aligned')
        if is_train:
            parser.set_defaults(pool_size=0, gan_mode='vanilla')
            parser.add_argument('--lambda_L1', type=float, default=100.0, help='weight for L1 loss')
            parser.add_argument('--gp_ratio', type=float, default=1.0, help='weight for gradient_penalty')
            parser.add_argument('--lambda_a', type=float, default=1.0, help='weight for adversarial loss')
            parser.add_argument('--lambda_v', type=float, default=1.0, help='weight for verification loss')

        return parser

    def __init__(self, opt):
        """Initialize the DoveNet class.

        Parameters:
            opt (Option class)-- stores all the experiment flags; needs to be a subclass of BaseOptions
        """
        BaseModel.__init__(self, opt)
        # specify the training losses you want to print out. The training/test scripts will call <BaseModel.get_current_losses>
        self.loss_names = ['G_GAN', 'G_L1', 'D_real', 'D_fake', 'D_gp', 'D_global', 'D_local', 'G_global', 'G_local']
        # specify the images you want to save/display. The training/test scripts will call <BaseModel.get_current_visuals>
        self.visual_names = ['comp', 'real', 'cap', 'output', 'mask', 'real_f', 'fake_f', 'bg']
        # specify the models you want to save to the disk. The training/test scripts will call <BaseModel.save_networks> and <BaseModel.load_networks>
        if self.isTrain:
            self.model_names = ['G', 'D']
        else:  # during test time, only load G
            self.model_names = ['G']
        # define networks (both generator and discriminator)
        self.netG = networks.define_G(opt.input_nc, opt.output_nc, opt.ngf, opt.netG, opt.norm,
                                      not opt.no_dropout, opt.init_type, opt.init_gain, self.gpu_ids)
        self.relu = nn.ReLU()

        if self.isTrain: 
            self.gan_mode = opt.gan_mode
            netD = NLayerDiscriminator(opt.output_nc, opt.ndf, opt.n_layers_D,
                                       networks.get_norm_layer(opt.norm))
            self.netD = networks.init_net(netD, opt.init_type, opt.init_gain, self.gpu_ids)

        if self.isTrain:
            # define loss functions
            self.criterionGAN = networks.GANLoss(opt.gan_mode).to(self.device)
            self.criterionL1 = torch.nn.L1Loss()
            # initialize optimizers; schedulers will be automatically created by function <BaseModel.setup>.
            self.optimizer_G = torch.optim.Adam(self.netG.parameters(), lr=opt.lr*opt.g_lr_ratio,
                                                betas=(opt.beta1, 0.999))
            self.optimizer_D = torch.optim.Adam(self.netD.parameters(), lr=opt.lr*opt.d_lr_ratio, betas=(opt.beta1, 0.999))
            self.optimizers.append(self.optimizer_G)
            self.optimizers.append(self.optimizer_D)
            self.iter_cnt = 0

    def set_input(self, input):
        """Unpack input data from the dataloader and perform necessary pre-processing steps.

        Parameters:
            input (dict): include the data itself and its metadata information.
        """
        self.comp = input['comp'].to(self.device)
        self.real = input['real'].to(self.device)
        self.inputs = input['inputs'].to(self.device)
        self.mask = self.inputs[:, 3:4, :, :]
        self.real_f = self.real * self.mask
        self.bg = self.real * (1 - self.mask)

    def forward(self):
        """Run forward pass; called by both functions <optimize_parameters> and <test>."""
        self.output = self.netG(self.inputs)
        self.fake_f = self.output * self.mask
        self.cap = self.output * self.mask + self.comp * (1 - self.mask)
        self.harmonized = self.output

    def backward_D(self):
        """Calculate GAN loss for the discriminator"""
        # Fake;
        fake_AB = self.harmonized
        pred_fake, ver_fake = self.netD(fake_AB.detach(), self.mask)
        if self.gan_mode == 'wgangp':
            global_fake = self.relu(1 + pred_fake).mean()
            local_fake = self.relu(1 + ver_fake).mean()
        else:
            global_fake = self.criterionGAN(pred_fake, False)
            local_fake = self.criterionGAN(ver_fake, False)
        self.loss_D_fake = global_fake + local_fake

        # Real
        real_AB = self.real
        pred_real, ver_real = self.netD(real_AB, self.mask)
        if self.gan_mode == 'wgangp':
            global_real = self.relu(1 - pred_real).mean()
            local_real = self.relu(1 - ver_real).mean()
        else:
            global_real = self.criterionGAN(pred_real, True)
            local_real = self.criterionGAN(ver_real, True)

        self.loss_D_real = global_real + local_real
        self.loss_D_global = global_fake + global_real
        self.loss_D_local = local_fake + local_real

        gradient_penalty, gradients = networks.cal_gradient_penalty(self.netD, real_AB.detach(), fake_AB.detach(),
                                                                    'cuda', mask=self.mask)
        self.loss_D_gp = gradient_penalty

        # combine loss and calculate gradients
        self.loss_D = (self.loss_D_fake + self.loss_D_real + self.opt.gp_ratio * gradient_penalty)
        self.loss_D.backward(retain_graph=True) 

    def backward_G(self):
        """Calculate GAN and L1 loss for the generator"""
        fake_AB = self.harmonized  
        pred_fake, ver_fake, featg_fake, featl_fake = self.netD(fake_AB, self.mask, feat_loss=True)
        self.loss_G_global = self.criterionGAN(pred_fake, True)
        self.loss_G_local = self.criterionGAN(ver_fake, True)

        real_AB = self.real 
        pred_real, ver_real, featg_real, featl_real = self.netD(real_AB, self.mask, feat_loss=True)
        self.loss_G_GAN =self.opt.lambda_a * self.loss_G_global + self.opt.lambda_v * self.loss_G_local
        
        self.loss_G_L1 = self.criterionL1(self.output, self.real) * self.opt.lambda_L1
        self.loss_G = self.loss_G_GAN + self.loss_G_L1 
        self.loss_G.backward(retain_graph=True)

    def optimize_parameters(self):
        self.forward()  
        # update D
        self.set_requires_grad(self.netD, True)  # enable backprop for D
        self.optimizer_D.zero_grad()  # set D's gradients to zero
        self.backward_D()  # calculate gradients for D
        self.optimizer_D.step()  # update D's weights
         # update G
        self.set_requires_grad(self.netD, False)  # D requires no gradients when optimizing G
        self.optimizer_G.zero_grad()  # set G's gradients to zero
        self.backward_G()  # calculate graidents for G
        self.optimizer_G.step()  # udpate G's weights
