% Подбор параметров равномерного распределения
% Возвращает границы a,b равномерного распределения с заданными mean и var.

function [a,b] = solve_params_uniform(meanX, varX)
d = sqrt(12*varX)/2;
a = meanX - d;
b = meanX + d;
end