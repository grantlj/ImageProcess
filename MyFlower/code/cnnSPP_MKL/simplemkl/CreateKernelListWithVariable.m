%CreateKernelListWithVariable�����ݺ˺���setting������kernel list
%kenneloptioncell��������Ǹ��ܹ����4��vector
%keneralcell����ŵ���kernel������
%variablecell��all single֮���
function [kernelcellaux,kerneloptioncellaux,variablecellaux]=CreateKernelListWithVariable(variablecell,dim,kernelcell,kerneloptioncell)


j=1;
for i=1:length(variablecell)
    switch variablecell{i}
        case 'all'
            kernelcellaux{j}=kernelcell{i};  %������
            kerneloptioncellaux{j}=kerneloptioncell{i}; %�渨������
            variablecellaux{j}=1:dim;  %��ά��
            j=j+1;    
        case 'single'
            for k=1:dim
            kernelcellaux{j}=kernelcell{i};
            kerneloptioncellaux{j}=kerneloptioncell{i}; %������vecto��
            variablecellaux{j}=k;  %��ά��
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
