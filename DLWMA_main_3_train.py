#!/usr/bin/env python

# this script train the deep learning (DL) model to do wall motion abnormality classification using the pre-extracted image feature sequence
# To run the script, type commond: ./DLWMA_main_3_train.py --batch N, it means using Nth batch for validation and the rest batches for training.

from keras.callbacks import TensorBoard, ModelCheckpoint, EarlyStopping, CSVLogger
from DLWMA_util_models import ResearchModels
from DLWMA_util_data import DataSet
import argparse
import time
import pandas as pd
import os
import numpy as np
import tensorflow as tf
from sklearn.utils.class_weight import compute_class_weight, compute_sample_weight
import supplement
import function_list_VR as ff
cg = supplement.Experiment() 

tf.set_random_seed(cg.seed)


def train(data_type, data_file, batch, seq_length, model, learning_rate,learning_decay,study_name , saved_model=None,
          class_limit=None, image_shape=None,
        batch_size=32, nb_epoch=100):

    regression = 0
    monitor_par = 'val_acc'
    sequence_len = seq_length

    # Helper: Save the model.
    save_folder = os.path.join(cg.save_dir,'models')
    model_save_folder = os.path.join(save_folder,model+'_'+study_name)
    model_save_folder2 = os.path.join(model_save_folder,'batch_' + str(batch))
    log_save_folder = os.path.join(save_folder,'logs')
    ff.make_folder([save_folder,model_save_folder,model_save_folder2, log_save_folder])

    checkpointer = ModelCheckpoint(
        filepath=os.path.join(model_save_folder2, model+ '-batch'+str(batch)+'-{epoch:03d}.hdf5'),
        monitor=monitor_par,
        verbose=1,
        save_best_only=False)

    # Helper: record results.
    timestamp = time.time()
    csv_logger = CSVLogger(os.path.join(log_save_folder,  model + '_' + study_name + '-batch' + str(batch) + '-training-log' + '.csv'))


    # Get the data
    data = DataSet(
        data_file = data_file,
        validation_batch = batch,
        seq_length=seq_length,
        architecture='InceptionV3',
        class_limit=class_limit)

    # Get generators.
    generator = data.frame_generator(batch_size, 'train', data_type,regression,True)
    val_generator = data.frame_generator(batch_size, 'test', data_type,regression, True)

    # Get the model.
    features_length = 2048 
    rm = ResearchModels(len(data.classes), model, sequence_len, learning_rate,learning_decay,features_length, saved_model)

    # Use fit generator.
    train_data,test_data = data.split_train_test()
    print('training num: ',len(train_data),'testing num: ',len(test_data)) # testing means validation here

    # Get class weights for class imbalance
    D = pd.read_excel(data_file)
    class_weights = compute_class_weight('balanced',np.unique(D['class']), D['class']) 

    # fit generator
    hist = rm.model.fit_generator(
        generator=generator,
        class_weight=class_weights,
        steps_per_epoch=len(train_data) // batch_size, 
        epochs=nb_epoch,
        verbose=1,
        callbacks=[checkpointer, csv_logger], 
        validation_data=val_generator,
        validation_steps=len(test_data) // batch_size,
        workers=1) 


def main(batch):
    """These are the main training settings. Set each before running this file."""

    data_file = os.path.join(cg.save_dir,'Patient_List/data_file_classes_train.xlsx')
    # define the study name
    study_name = 'trial_1'

    # define the model to do video classificiation 
    model = 'lstm'
    saved_model = None  # None or weights file

    # define the number of frames input into the model (default = 4)
    seq_length = 4
    
    # define training epochs and learning rates
    nb_epoch = 500
    learning_rate = 1e-5
    learning_decay = 1e-6
    batch_size = 5 
    

    # define data_type and image_shape 
    data_type = 'features'
    image_shape = None
    class_limit = None  # int, can be 1-101 or None, default = None
    
    
    print('start_to_train')
    hist = train(data_type, data_file, batch, seq_length, model, learning_rate,learning_decay,study_name, 
    saved_model=saved_model,class_limit=class_limit, image_shape=image_shape,batch_size=batch_size, nb_epoch=nb_epoch)
    

if __name__ == '__main__':

  parser = argparse.ArgumentParser()
  parser.add_argument('--batch', type=int)
  args = parser.parse_args()

  if args.batch is not None:
    assert(0 <= args.batch < cg.num_partitions)

  main(args.batch)  # use batch N for the validation and the rest for training (n-fold cross-validation)
