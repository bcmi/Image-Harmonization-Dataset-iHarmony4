set -ex
python test.py --dataset_root <path_to_iHarmony4_dataset> --name experiment_name --model dovenet --dataset_mode iharmony4 --netG s2ad --is_train 0  --norm instance --no_flip --preprocess none --num_test 7404


