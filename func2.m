function[meanVal, varVal] = myfunc(n,m)
    vc = 10 * rand(n,1); % вектор столбец
    vs = 10 * rand(1,m); % вектор строка
    matrix = vc * vs; % перемножение векторов, для получения матрицы
    meanVal = mean(matrix, 'all'); % считает среднее
    varVal = var(matrix, 0, "all"); % считает дисперсию
end 