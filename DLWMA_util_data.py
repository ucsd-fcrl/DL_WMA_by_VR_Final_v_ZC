"""
Class for managing our data.
"""
import csv
import pandas as pd
import numpy as np
import random
import glob
import os.path
import sys
import operator
import threading
from DLWMA_util_processor import process_image
from keras.utils import to_categorical
import supplement
import function_list_VR as ff
cg = supplement.Experiment() 

class threadsafe_iterator:
    def __init__(self, iterator):
        self.iterator = iterator
        self.lock = threading.Lock()

    def __iter__(self):
        return self

    def __next__(self):
        with self.lock:
            return next(self.iterator)

def threadsafe_generator(func):
    """Decorator"""
    def gen(*a, **kw):
        return threadsafe_iterator(func(*a, **kw))
    return gen

class DataSet():

    def __init__(self, data_file,validation_batch, seq_length, architecture = 'Inception', class_limit=None, image_shape=(224, 224, 3)):
        """Constructor.
        seq_length = (int) the number of frames to consider
        class_limit = (int) number of classes to limit the data to.
            None = no limit.
        """
        self.data_file = data_file
        self.validation_batch = validation_batch
        self.seq_length = seq_length
        self.class_limit = class_limit
        self.architecture = architecture
        self.sequence_path = os.path.join(cg.local_dir,'sequences_'+architecture)
        self.max_frames = 300  # max number of frames a video can have for us to use it
        
        # Get the data.
        self.data = self.get_data()

        # Get the classes.
        self.classes = self.get_classes()

        # Now do some minor data cleaning.
        self.data = self.clean_data()

        self.image_shape = image_shape

    # @staticmethod (wathc https://www.youtube.com/watch?v=PNpt7cFjGsM to understand @ classmethod and @ staticmethod - no self argument)
    def get_data(self):
        """Load our data from file."""
        data = pd.read_excel(self.data_file)
        
        return data

    def clean_data(self):
        """Limit samples to greater than the sequence length and fewer
        than N frames. Also limit it to classes we want to use."""
        data_clean = []
        D = self.data
        for i in range(0,D.shape[0]):
            item = D.iloc[i]
            # if int(item['nb_frames']) >= self.seq_length and int(item['nb_frames']) <= self.max_frames \
            #         and item['class'] in self.classes:
            data_clean.append(item)
    
        return data_clean

    def get_classes(self):
        """Extract the classes from our data. If we want to limit them,
        only return the classes we need."""
        classes = []
        D = self.data
        for i in range(0,D.shape[0]):
            item = D.iloc[i]
            if item['class'] not in classes:
                classes.append(item['class'])

        # Sort them.
        classes = sorted(classes)

        # Return.
        if self.class_limit is not None:
            return classes[:self.class_limit]
        else:
            return classes

    def get_class_one_hot(self, class_str):
        """Given a class as a string, return its number in the classes
        list. This lets us encode and one-hot it for training."""
        # Encode it first.
        label_encoded = self.classes.index(class_str)

        # Now one-hot it.
        label_hot = to_categorical(label_encoded, len(self.classes))

        assert len(label_hot) == len(self.classes)

        return label_hot

    def split_train_test(self):
        """Split the data into train and test groups based on the batch choice. In the data_file.xlsx, each movie has a column labeling the batch"""
        
        train = []
        test = []
        for item in self.data:
            if item['batch'] != self.validation_batch:
                train.append(item)
            else:
                test.append(item)
        return train, test

    

    @threadsafe_generator
    # Generator is not a collection, it stops with yield and returns to where it was left in the next call. 
    # Thus, it does not requires the use of a lot of memory. 
    # def + yield = generator; generator = def_name(); then use next(generator) to call generator'''
    def frame_generator(self, batch_size, train_test, data_type,regression,shuffle):
        """Return a generator that we can use to train on. There are
        a couple different things we can return:

        data_type: 'features', 'images'
        """
        # Get the right dataset for the generator.
        train, test = self.split_train_test()
        data = train if train_test == 'train' else test
      
        print("Creating %s generator with %d samples." % (train_test, len(data)))

        ###########!!! use index array to do the generator
        N = len(data)
        batch_index = 0
        total_round_seen = 0
        seed = random.randint(0,50)

        while True: # it means next time, we can still start from this while loop which is always correct
            
            if batch_index == 0:
                if shuffle:
                    if seed is not None:
                        np.random.seed(seed + total_round_seen)
                        print('seed is: ', seed+total_round_seen * 3)
                    print('now shuffle')
                    index_array = np.random.permutation(N)
                else:
                    index_array = np.asarray(range(0,N))
                
            current_index = (batch_index * batch_size) % N
            if N >= current_index + batch_size:
                current_batch_size = batch_size
                batch_index += 1
            else:
                current_batch_size = N - current_index
                batch_index = 0
                total_round_seen += 1

            index_array_current_batch = index_array[current_index : current_index + current_batch_size]
            
            # Generate batch_size samples.
            X, y = [], []
            for ii in index_array_current_batch: 
                # Reset to be safe.
                sequence = None
                
                # get the sample
                sample = data[ii]

                # Check to see if we've already saved this sequence.
                if data_type is "images":
                    # Get and resample frames.
                    frames = self.get_frames_for_sample(sample)
                    # frames = self.rescale_list(frames, self.seq_length)  ### change

                    # Build the image sequence
                    sequence = self.build_image_sequence(frames)
                else:
                    # Get the sequence from disk.
                    sequence = self.get_extracted_sequence(data_type, sample)

                    if sequence is None:
                        raise ValueError("Can't find sequence. Did you generate them?")

                if self.seq_length == 4:
                    [ED,interval1,interval2,ES] = [int(sample['ED']), int(sample['interval1']),int(sample['interval2']), int(sample['ES'])]
                    s1 = sequence[ED]
                    s2 = sequence[interval1]
                    s3 = sequence[interval2]
                    s4 = sequence[ES]
                    ss = np.concatenate((s1,s2,s3,s4)).reshape(self.seq_length,s1.shape[0])
                elif self.seq_length == 3:
                    [ED,mid_es,ES] = [int(sample['ED']), int(sample['mid_ES']), int(sample['ES'])]
                    s1 = sequence[ED]
                    s2 = sequence[mid_es]
                    s3 = sequence[ES]
                    ss = np.concatenate((s1,s2,s3)).reshape(self.seq_length,s1.shape[0])
                elif self.seq_length == 2:
                    [ED, ES] = [int(sample['ED']), int(sample['ES'])]
                    s1 = sequence[ED]
                    s2 = sequence[ES]
                    ss = np.concatenate((s1,s2)).reshape(self.seq_length,s1.shape[0])
                

                if regression == 0:
                    X.append(ss)
                    y.append(self.get_class_one_hot(sample['class']))

                elif regression == 1:
                    # s1 = sequence[0];s2 = sequence[(self.seq_length//2) - 1 + 0]
                    # ss = np.concatenate((s1,s2)).reshape(2,s1.shape[0])
                    
                    X.append(ss)
                    #EF = float(sample[’].split('_')[-1])
                    y.append(float(sample['area']) * 100)
                else:
                    print('Error!!!!!')    
        
            yield np.array(X), np.array(y)

    

    def predict_generator(self, sample, data_type,regression):
        """Return a generator that we can use to predict. Every time just load one data needed to be predicted:
        data_type: 'features', 'images'
        """
      
        print("Creating generator for %s as %s." % (sample['video_name_no_ext'], sample['class']))

        while True: # it means next time, we can still start from this while loop which is always correct
            X, y = [], []
            for _ in range(1):
                sequence = None
                if data_type is "images":
                    # Get and resample frames.
                    frames = self.get_frames_for_sample(sample)
                    # frames = self.rescale_list(frames, self.seq_length)  ### change

                    # Build the image sequence
                    sequence = self.build_image_sequence(frames)
                else:
                    # Get the sequence from disk.
                    sequence = self.get_extracted_sequence(data_type, sample)

                    if sequence is None:
                        raise ValueError("Can't find sequence. Did you generate them?")

                if self.seq_length == 4:
                    [ED,interval1,interval2,ES] = [int(sample['ED']), int(sample['interval1']),int(sample['interval2']), int(sample['ES'])]
                    s1 = sequence[ED]
                    s2 = sequence[interval1]
                    s3 = sequence[interval2]
                    s4 = sequence[ES]
                    ss = np.concatenate((s1,s2,s3,s4)).reshape(self.seq_length,s1.shape[0])
                elif self.seq_length == 3:
                    [ED,mid_es,ES] = [int(sample['ED']), int(sample['mid_ES']), int(sample['ES'])]
                    s1 = sequence[ED]
                    s2 = sequence[mid_es]
                    s3 = sequence[ES]
                    ss = np.concatenate((s1,s2,s3)).reshape(self.seq_length,s1.shape[0])
                elif self.seq_length == 2:
                    [ED, ES] = [int(sample['ED']), int(sample['ES'])]
                    s1 = sequence[ED]
                    s2 = sequence[ES]
                    ss = np.concatenate((s1,s2)).reshape(self.seq_length,s1.shape[0])

             

                if regression == 0:
                    X.append(ss)
                    y.append(self.get_class_one_hot(sample['class']))

                elif regression == 1:
                    # s1 = sequence[0];s2 = sequence[9]
                    # ss = np.concatenate((s1,s2)).reshape(2,s1.shape[0])
                    X.append(ss)
                    y.append(float(sample['area'])*100)
                   
                else:
                    print('Error!!!!!')   
            
            yield np.array(X), np.array(y)

            

    def build_image_sequence(self, frames):
        """Given a set of frames (filenames), build our sequence."""
        return [process_image(x, self.image_shape) for x in frames]

    def get_extracted_sequence(self, data_type, sample):
        """Get the saved extracted features."""
        filename = sample['video_name_no_ext']
        path = os.path.join(self.sequence_path, sample['Patient_Class'],sample['Patient_ID'], filename + '-' + data_type + '.npy')
        #print(path)
        if os.path.isfile(path):
            return np.load(path,allow_pickle = True)
        else:
            return None

    def get_frames_by_filename(self, filename, data_type):
        """Given a filename for one of our samples, return the data
        the model needs to make predictions."""
        # First, find the sample row.
        sample = None
        for row in self.data:
            if row[2] == filename:
                sample = row
                break
        if sample is None:
            raise ValueError("Couldn't find sample: %s" % filename)

        if data_type == "images":
            # Get and resample frames.
            frames = self.get_frames_for_sample(sample)
            frames = self.rescale_list(frames, self.seq_length)
            # Build the image sequence
            sequence = self.build_image_sequence(frames)
        else:
            # Get the sequence from disk.
            sequence = self.get_extracted_sequence(data_type, sample)

            if sequence is None:
                raise ValueError("Can't find sequence. Did you generate them?")

        return sequence

    @staticmethod
    def get_frames_for_sample(sample):
        
        path = os.path.join(cg.local_dir, 'images', sample['Patient_Class'],sample['Patient_ID'],sample['video_name_no_ext'])
        
        files = ff.find_all_target_files(['*.jpg'],path)
      
        images = sorted(files)
        
        return images

    @staticmethod
    def get_filename_from_image(filename):
        parts = filename.split(os.path.sep)
        return parts[-1].replace('.jpg', '')

    @staticmethod
    def rescale_list(input_list, size):
        """Given a list and a size, return a rescaled/samples list. For example,
        if we want a list of size 5 and we have a list of size 25, return a new
        list of size five which is every 5th element of the origina list."""
        assert len(input_list) >= size

        # Get the number to skip between iterations.
        skip = len(input_list) // size

        # Build our new output.
        output = [input_list[i] for i in range(0, len(input_list), skip)]

        # Cut off the last one if needed.
        return output[:size]

    def print_class_from_prediction(self, predictions, nb_to_return=5):
        """Given a prediction, print the top classes."""
        # Get the prediction for each label.
        label_predictions = {}
        for i, label in enumerate(self.classes):
            label_predictions[label] = predictions[i]

        # Now sort them.
        sorted_lps = sorted(
            label_predictions.items(),
            key=operator.itemgetter(1),
            reverse=True
        )

        # And return the top N.
        for i, class_prediction in enumerate(sorted_lps):
            if i > nb_to_return - 1 or class_prediction[1] == 0.0:
                break
            print("%s: %.2f" % (class_prediction[0], class_prediction[1]))
