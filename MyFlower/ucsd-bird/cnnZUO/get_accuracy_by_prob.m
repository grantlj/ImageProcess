function [accuracy] = get_accuracy_by_prob(final_prob,test_label,n)
 test_num=size(final_prob,1);
 accuracy=0;
 
 for index=1:test_num
    vote_result=zeros(1,n);
    p=0;
    for i=1:n-1
        for j=i+1:n
            p=p+1;
            if (final_prob(index,p)>0)
                vote_result(1,i)=vote_result(1,i)+1;
            else
                vote_result(1,j)=vote_result(1,j)+1;
            end
        end
    end  %end of vote.
    
    [c ind]=max(vote_result);
    if (any(ind==test_label(index)))
        accuracy=accuracy+1;
    end
 end %end of test.
 accuracy=accuracy/test_num;

end

