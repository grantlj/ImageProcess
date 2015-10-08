Head detector for LAEO release v2.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Head detector by M. Marin-Jimenez, A. Zisserman and V. Ferrari

Introduction
============
This package contains the head detector originally used in [1] and [4]. 
In order to reduce the amount of false positives, it is recommended to be used inside image regions detected by an upper-body detector (e.g. [2] or [3]).
If you use this detector for your research, please cite [1] as a reference.


Contents
========
<head_detector_dir>
   |-- head-gen-on-ub-4laeo.mat         
   |-- demoheaddet.m
   |-- hlayk.jpg
   |-- README.txt
   
   
Quick start
===========   
1. Start Matlab
2. Add to your path the needed detection framework from:
   http://people.cs.uchicago.edu/~pff/latent-release4/
3. cd <head_detector_dir>
4. demoheaddet

If everything works fine, you should get a new Matlab figure with two head detections on a Casablanca's frame.
   
   
Contact
=======
For any query/suggestion/complaint or simply to say you like/use this detector, just drop us an email

mjmarin@uco.es


References
==========

[1] M.J. Marin-Jimenez, A. Zisserman and V. Ferrari
"Here's looking at you, kid." Detecting people looking at each other in videos.
British Machine Vision Conference (BMVC), 2011 

[2] Calvin's Upper-body Detector
http://www.vision.ee.ethz.ch/~calvin/calvin_upperbody_detector/

[3] Upper-body Detector for LibPaBOD
http://www.uco.es/~in1majim/proyectos/libpabod/

[4] M.J. Marin-Jimenez, A. Zisserman, M. Eichner and V. Ferrari
Detecting people looking at each other in videos.
International Journal of Computer Vision (IJCV), 2013

History
=======
- v2.0: this version includes the head detector used in [4]. It includes two new components for back views of heads.
- v1.0: first public release
