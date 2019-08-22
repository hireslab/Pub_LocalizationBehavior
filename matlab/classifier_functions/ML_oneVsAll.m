function [all_theta,cost,iter] = ML_oneVsAll(X, y, num_labels, lambda, regMethod)
%ONEVSALL trains multiple logistic regression classifiers and returns all
%the classifiers in a matrix all_theta, where the i-th row of all_theta 
%corresponds to the classifier for label i
%   [all_theta] = ONEVSALL(X, y, num_labels, lambda) trains num_labels
%   logistic regression classifiers and returns each of these classifiers
%   in a matrix all_theta, where the i-th row of all_theta corresponds 
%   to the classifier for label i

% Some useful variables
m = size(X, 1);
n = size(X, 2);

% You need to return the following variables correctly 
all_theta = zeros(num_labels, n + 1);

% Add ones to the X data matrix
X = [ones(m, 1) X];

for c = 1:num_labels
    
initial_theta = zeros(n + 1 ,1);
options = optimset('GradObj', 'on', 'MaxIter', 50);
[theta,cost,iter] = ...
         fmincg (@(t)(ML_lrCostFunction(t, X, (y == c), lambda, regMethod)), ...
                 initial_theta, options);

             % all you do is set y for the class you're not working on to 0
             % and the one you are to 1. That way logistic regression
             % optimizes thetas to that current class you are working on. 
all_theta(c,:) = theta';
        % fmincg works similarly to fminunc, but is more more efficient for dealing with
        %a large number of parameters.
end






% =========================================================================


end
