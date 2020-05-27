set -ex
python train.py  --dataset_root <path_to_iHarmony4_dataset> --name experiment_name  --model dovenet --dataset_mode iharmony4 --is_train 1  --gan_mode wgangp  --norm instance --no_flip --preprocess none --netG s2ad
