function []=run_lsvm_test_engine_1v1()
    clear all;
    clc;
    acc=[];

    t=dir('lsvm_model/');
    modelcount=size(t,1)-3;

    % datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'};
      datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'...
                 'dataset/brush_hair/','dataset/catch/','dataset/clap/','dataset/climb_stairs/'};
    %             'dataset/golf/','dataset/jump/','dataset/kick_ball/','dataset/pour/','dataset/pullup/'...
    %             'dataset/push/','dataset/shoot_ball/','dataset/shoot_bow/','dataset/shoot_gun/','dataset/sit/'...
    %             'dataset/stand/','dataset/swing_baseball/'}; %search path;
    % row_dim=44604;

    % load('lsvm_rand_row.mat');    %load rand row info.
     load('1v1_lsvm_test_set.mat');     %load test set.

    fvals=[];
    for i=0:modelcount
      [acc(i+1),fval]=lsvm_test_engine_1v1(i,datapath,test_set);
      if (i~=0)
         % if (isempty(fval))
             % fvals(i,:)=fvals(i-1,:)
         % else
            fvals(i,:)=fval;
         % end
      end
    end

    plot([1:modelcount],acc(2:modelcount+1));
    grid on;
    hold on;
    %axis([1,modelcount,0,1]);
    %plot([1:modelcount],acc(0)*ones(1,2:modelcount+1),'r');
    line([1,modelcount+2],[acc(1),acc(1)],'Color','r','LineWidth',2);

    figure;
    grid on;
    hold on;
    for i=1:size(fvals,2)
        target=fvals(:,i)';
        plot([1:modelcount],target-target(1,1),'Color',rand(1,3));
        hold on;
    end
end