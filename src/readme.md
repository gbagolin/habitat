# Start

## To extract the data:

Requirement:
 - habitat-lab
 - habitat-sim
 - matterport data


Descr:
This code will extract the RGB,DEPTH, and Semantic segmentation from the scene specified in the python source.
The name of the images are in the form of *x_y_z_rx_r_y_rz.[png, npy]*

1. `cd Data_Extraction`
2. `python img_extractor.py <path to the test directory>` 

____
## Reconstruction from rgb-d and semantic segmentation

This will extract a wall.mat file with the points of the extracted walls, using the rbg,depth and semantic information

Requirement:
 - open-3d (this library change a lot from version to version. could work on 0.8.0 or 0.9.0)

Run
1. `cd habitat_reconstruction`
3.`python scene_reconstruction.py <path to the 0.25m directory>` 