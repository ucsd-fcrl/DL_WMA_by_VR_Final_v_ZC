# System
import os

class Experiment():

  def __init__(self):

    self.nas_main_dir = os.environ['CG_NAS_MAIN_DIR']
  
    self.nas_image_data_dir = os.environ['CG_NAS_IMAGE_DATA_DIR']

    self.save_dir = os.environ['CG_SAVE_DIR']

    self.local_dir = os.environ['CG_LOCAL_DIR']

    self.num_partitions = int(os.environ['CG_NUM_PARTITIONS'])
  
    self.seed = int(os.environ['CG_SEED'])
  
