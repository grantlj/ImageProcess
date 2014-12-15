function [featureVector] = extract_feature_fromfile(fileinfo)
  %For OBBench use only. extract feature from specific file.
  A=load(fileinfo);
  featureVector=A.feature;
end

