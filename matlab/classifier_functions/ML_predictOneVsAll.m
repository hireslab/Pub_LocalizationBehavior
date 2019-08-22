function [p,opt_thresh,h] = ML_predictOneVsAll(all_theta, X,varargin)
%PREDICT Predict the label for a trained one-vs-all classifier. The labels 
%are in the range 1..K, where K = size(all_theta, 1). 
%  p = PREDICTONEVSALL(all_theta, X) will return a vector of predictions
%  for each example in the matrix X. Note that X contains the examples in
%  rows. all_theta is a matrix where the i-th row is a trained logistic
%  regression theta vector for the i-th class. You should set p to a vector
%  of values from 1..K (e.g., p = [1; 3; 1; 2] predicts classes 1, 3, 1, 2
%  for 4 examples) 

m = size(X, 1);
num_labels = size(all_theta, 1);

% You need to return the following variables correctly 
p = zeros(size(X, 1), 1);

% Add ones to the X data matrix
X = [ones(m, 1) X];

metho = varargin{2} ;

h=sigmoid(X*all_theta');


switch metho
    case 'F1'
        real=varargin{1};
        pred_vals = h(:,1); %only looking in refernece to go trials
        [opt_thresh] = ML_F1score(pred_vals,real);
        p = (h(:,1)>=opt_thresh);
        p=double(p);
        x=find(p==0);
        p(x)=2;
        
    case 'Max'
        [Z , p] =max(h,[],2);
        opt_thresh = min(Z);
end
        


end
