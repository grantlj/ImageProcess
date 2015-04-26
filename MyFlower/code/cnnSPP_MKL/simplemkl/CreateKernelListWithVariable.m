%CreateKernelListWithVariable：根据核函数setting来构造kernel list
%kenneloptioncell就是最后那个很诡异的4个vector
%keneralcell里面放的是kernel的类型
%variablecell：all single之类的
function [kernelcellaux,kerneloptioncellaux,variablecellaux]=CreateKernelListWithVariable(variablecell,dim,kernelcell,kerneloptioncell)


j=1;
for i=1:length(variablecell)
    switch variablecell{i}
        case 'all'
            kernelcellaux{j}=kernelcell{i};  %存类型
            kerneloptioncellaux{j}=kerneloptioncell{i}; %存辅助变量
            variablecellaux{j}=1:dim;  %存维度
            j=j+1;    
        case 'single'
            for k=1:dim
            kernelcellaux{j}=kernelcell{i};
            kerneloptioncellaux{j}=kerneloptioncell{i}; %存整个vecto？
            variablecellaux{j}=k;  %存维度
            j=j+1;
            end;    
	case 'random'
		kernelcellaux{j}=kernelcell{i};
        kerneloptioncellaux{j}=kerneloptioncell{i};
		indicerand=randperm(dim);
		nbvarrand=floor(rand*dim)+1;         
   		variablecellaux{j}=indicerand(1:nbvarrand);
        j=j+1;
        end;
end; %end of for

end %end of func
