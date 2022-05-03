"""
A collection of models we'll use to attempt to classify videos.
"""
from keras.layers import Dense, Flatten, Dropout, ZeroPadding3D
from keras.layers.recurrent import LSTM
from keras.models import Sequential, load_model
from keras.optimizers import Adam, RMSprop
from keras.layers.wrappers import TimeDistributed
from keras.layers.convolutional import (Conv2D, MaxPooling3D, Conv3D,
    MaxPooling2D)
from collections import deque
import sys
import supplement
cg = supplement.Experiment()

class ResearchModels():
    def __init__(self, nb_classes, model, seq_length,learning_rate,learning_decay,features_length=2048,
                 saved_model=None):
        """
        `model` = one of:
            lstm
            lrcn
            mlp
            conv_3d
            c3d
        `nb_classes` = the number of classes to predict
        `seq_length` = the length of our video sequences
        `saved_model` = the path to a saved Keras model to load
        """

        # Set defaults.
        self.seq_length = seq_length
        self.load_model = load_model
        self.saved_model = saved_model
        self.nb_classes = nb_classes
        self.feature_queue = deque()
        self.features_length = features_length

        # Set the metrics. Only use top k if there's a need.
        metrics = ['accuracy']
        if self.nb_classes >= 10:
            metrics.append('top_k_categorical_accuracy')

        # Get the appropriate model.
        if self.saved_model is not None:
            print("Loading model %s" % self.saved_model)
            self.model = load_model(self.saved_model)
        elif model == 'lstm':
            print("Loading LSTM model.")
            self.input_shape = (seq_length, features_length)
            self.model = self.lstm()
        else:
            print("Unknown network.")
            sys.exit()

        # Now compile the network.
        optimizer = Adam(lr=learning_rate, decay=learning_decay)
        
        self.model.compile(loss='categorical_crossentropy', optimizer=optimizer,
                        metrics=metrics)

        print(self.model.summary())

    def lstm(self):
        """Build a simple LSTM network. We pass the extracted features from
        our CNN to this model predomenently."""
        # Model.
        model = Sequential()
        model.add(LSTM(self.features_length, activation='tanh',recurrent_activation='sigmoid',
                    return_sequences=False, # 2048 = the units, which is the diemnsionality of the output space. It should be equal to input dimension since each input gets one corresponding ouput
                    input_shape=self.input_shape,
                    dropout=0.5))
        model.add(Dense(512, activation='relu'))
        model.add(Dropout(0.5, seed = cg.seed))
        model.add(Dense(self.nb_classes, activation='softmax'))
        return model

   
    