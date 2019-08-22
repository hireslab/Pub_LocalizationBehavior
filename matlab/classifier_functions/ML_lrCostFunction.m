function [J, grad] = ML_lrCostFunction(theta, X, y, lambda, regMethod)
%LRCOSTFUNCTION Compute cost and gradient for logistic regression with 
%regularization
%   J = LRCOSTFUNCTION(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));


m=size(X,1);
h=sigmoid(X*theta);

% if strcmp(regMethod,'lasso')
%  reg = (lambda/(2*m)) * abs(sum(theta(2:end))); %L2 (lasso normalization)
% elseif strcmp(regMethod,'ridge')
%  reg = (lambda/(2*m)) * sum(theta(2:end).^2); %L1 (ridge normalization)
% end

if strcmp(regMethod,'lasso')
 reg = (lambda) * abs(sum(theta(2:end))); %L1 (lasso normalization)
elseif strcmp(regMethod,'ridge')
 reg = (lambda) * sum(theta(2:end).^2); %L2 (ridge normalization)
end


J = (1/m) * sum(((-y.*log(h)) - ((1-y).*log(1-h)))) + reg;


grad0 = (1/m) * (h-y)'*X(:,1) ;
gradR = ((1/m) * (h-y)'*X(:,2:end)) + (lambda/m).*theta(2:end)';
grad = [grad0 gradR]';






% =============================================================

grad = grad(:);

end
