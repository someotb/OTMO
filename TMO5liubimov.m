%% lab1_3_full.m
% Лабораторная работа №1.3 — моделирование цепи Маркова (расширенный вариант)
clear; clc; close all;

%% Параметры
L = 15;                  % количество узлов
startNode = 1;           % начальный узел i
epsilon = 1e-5;          % точность ε
maxM = 2000;             % предел шагов
Ntraj = 200;             % длина траектории для визуализации
saveExcel = true;        % сохранять результаты в Excel
excelFileName = 'lab1_3_results.xlsx';

%% 1. Построение матрицы переходов (15x15)
T = zeros(L);

T(1, [2 3 4 5]) = [0.4, 0.2, 0.2, 0.2];
T(2, [3 6 7 8]) = [0.3, 0.3, 0.2, 0.2];
T(3, [4 9 10]) = [0.4, 0.4, 0.2];
T(4, [5 11 12]) = [0.3, 0.5, 0.2];
T(5, [6 13 14]) = [0.4, 0.3, 0.3];
T(6, [7 8 9 15]) = [0.3, 0.3, 0.2, 0.2];
T(7, [8 10 11]) = [0.4, 0.4, 0.2];
T(8, [9 12 13]) = [0.3, 0.4, 0.3];
T(9, [10 14 15]) = [0.3, 0.4, 0.3];
T(10, [11 12 13]) = [0.3, 0.4, 0.3];
T(11, [12 14]) = [0.5, 0.5];
T(12, [13 14 15]) = [0.4, 0.3, 0.3];
T(13, [1 2 3]) = [0.4, 0.3, 0.3];
T(14, [1 4 5 6]) = [0.3, 0.3, 0.2, 0.2];
T(15, [1 7 8 9]) = [0.3, 0.4, 0.2, 0.1];

% Проверка стохастичности
for i = 1:L
    if abs(sum(T(i,:)) - 1) > 1e-10
        error('Строка %d не стохастична!', i);
    end
end
disp('Матрица переходов T загружена и проверена на стохастичность.');

%% 2. Построение траектории MarkovTrajectory
figure('Name','Траектория пакета по сети','NumberTitle','off');
E = MarkovTrajectory(T, Ntraj, startNode);
plot(1:length(E), E, '-o', 'MarkerFaceColor','auto');
xlabel('Номер коммутации i');
ylabel('Номер узла j');
title(sprintf('Траектория пакета: стартовый узел = %d (N = %d)', startNode, Ntraj));
grid on;
ylim([0.5, L+0.5]); yticks(1:L);

%% 3–4. Расчёты вероятностей и статистик
F_cell = {};
F1 = T;
F1(1:L+1:end) = 0;
F_cell{1} = F1;
max_f_for_i = zeros(1,maxM);

Pstay = zeros(maxM, L);
e_i = zeros(1,L); e_i(startNode) = 1;
Pstay(1,:) = e_i * T; % Формула 5.1

m = 1;
max_f = max(F_cell{1}(startNode,:));
max_f_for_i(1) = max_f;

while m < maxM
    if max_f <= epsilon
        break;
    end
    m = m + 1;
    prevF = F_cell{m-1};
    prevF_zeroDiag = prevF;
    prevF_zeroDiag(1:L+1:end) = 0;
    Fm = T * prevF_zeroDiag; % Формула 5.2
    F_cell{m} = Fm;
    Pstay(m,:) = e_i * (T^m);
    max_f = max(Fm(startNode,:));
    max_f_for_i(m) = max_f;
end

computedM = m;
fprintf('Вычислено F^{(m)} для m = 1..%d (остановка при max f_{i->j}(m) <= ε).\n', computedM);

M = computedM;
F3 = zeros(M, L, L);
for mm = 1:M
    F3(mm,:,:) = F_cell{mm};
end

Pstay = Pstay(1:M,:);
F_for_i = squeeze(F3(:, startNode, :));

d_ij = inf(1, L);
Tpower = eye(L);
for mm = 1:M
    Tpower = Tpower * T;
    row = Tpower(startNode, :);
    for j = 1:L
        if isinf(d_ij(j)) && row(j) > 0
            d_ij(j) = mm; % Формула 5.3
        end
    end
end
d_ij(isinf(d_ij)) = NaN;

m_vec = (1:M)';
E_ij = zeros(1,L);
Var_ij = zeros(1,L);
total_hit_prob = zeros(1,L);
for j = 1:L
    f_m = F_for_i(:, j);
    total_hit_prob(j) = sum(f_m);
    E = sum(m_vec .* f_m); % Формула 5.4
    M2 = sum((m_vec.^2) .* f_m); % Первая часть формулы 5.5
    E_ij(j) = E;
    Var_ij(j) = M2 - E^2; % Вторая часть формулы 5.5
end

%% 5. Графики
nodes = 1:L;
figure('Name','Вероятность пребывания пакета в узле j после m коммутаций, при условии, что пакет поступил в сеть через узел i','NumberTitle','off');
ms_to_plot = unique([1, min(5,M), min(10,M), M]);
hold on;
for mm = ms_to_plot
    plot(nodes, Pstay(mm, :), '-o', 'DisplayName', sprintf('m = %d', mm));
end
xlabel('Номер узла j'); ylabel('P(находиться в j после m коммутаций)');
title(sprintf('P^(m)(i,j) для i = %d', startNode));
legend('Location','best'); grid on; hold off;

figure('Name','Вероятность первого перехода пакета в узел j из узла i после m коммутаций','NumberTitle','off');
ms_to_plot2 = unique([1, min(2,M), min(5,M), M]);
bar_data = zeros(length(ms_to_plot2), L);
for k = 1:length(ms_to_plot2)
    mm = ms_to_plot2(k);
    bar_data(k, :) = F_for_i(mm, :);
end
bar(nodes, bar_data', 'grouped');
xlabel('Номер узла j'); ylabel('f{i->j}(m)');
title(sprintf('f{i->j}(m) для i=%d', startNode));
legend(arrayfun(@(x) sprintf('m=%d',x), ms_to_plot2,'UniformOutput',false), 'Location','best');
grid on;

figure('Name','Длину кратчайшего пути перехода пакета в узел j из узла i','NumberTitle','off');
stem(nodes, d_ij, 'filled');
xlabel('Номер узла j'); ylabel('d_{i->j}');
title(sprintf('Кратчайшие пути от i=%d', startNode));
grid on;

figure('Name','Математическое ожидание длины пути перехода пакета в узел j из узла i','NumberTitle','off');
yyaxis left
plot(nodes, E_ij, '-o', 'DisplayName','Математическое ожидание длины пути');
ylabel('Среднее число шагов(i->j)');
yyaxis right
plot(nodes, Var_ij, '-s', 'DisplayName','Дисперсия длины пути');
ylabel('Мера разброса, насколько сильно число шагов колеблется вокруг среднего'); % Если дисперсия маленькая — пакет обычно доходит до узла j примерно за одинаковое число шагов. Если дисперсия большая — пакет иногда доходит быстро, а иногда долго.
xlabel('Номер узла j');
title(sprintf('Мат. Ожидание и Дисперсия длины пути от i=%d', startNode));
legend('Location','best'); grid on;

%% 6. Таблица и сохранение
T_hit_sum = sum(F_for_i,1);
tbl = table(nodes', d_ij', E_ij', Var_ij', T_hit_sum', ...
    'VariableNames', {'Номер узла','Кратчайший путь(i->j)','Математическое ожидание длины пути','Дисперсия длины пути','Суммарная вероятность попасть в узел j за максимум M коммутаций'});
disp(tbl);

if saveExcel
    writetable(tbl, excelFileName, 'Sheet', 'results');
    fprintf('Таблица сохранена в %s\n', excelFileName);
end

fprintf('\nКлючевые результаты для стартового узла i = %d (до m=%d):\n', startNode, M);
for j = 1:L
    fprintf(' Узел назначения=%2d: Длина кратчайшего пути от стартового узла i = 1 до узла j =%4s, Вероятность, что пакет попадет в узел j(m <=147) = %.4f, Мат.Ожидание=%.4f, Дисперсия=%.4f\n', ...
        j, num2str(d_ij(j)), T_hit_sum(j), E_ij(j), Var_ij(j));
end

%% Функция MarkovTrajectory
function E = MarkovTrajectory(P, N, s)
% Функция для расчета траектории движения пакета по сети
% P - матрица переходов
% N - количество шагов
% s - начальное состояние
% Возвращает E - массив состояний пакета на каждом шаге

% Инициализация
E = zeros(1, N + 1);     % Хранение траектории
E(1) = s;                % Начальное состояние
S = size(P, 1);          % Количество состояний

% Цикл по шагам
for i = 1:N
    r = rand();           % Генерация случайного числа от 0 до 1
    cumulativeProb = 0;   % Кумулятивная вероятность
    % Поиск следующего состояния
    for j = 1:S
        cumulativeProb = cumulativeProb + P(E(i), j); % Обновляем сумму
        if r < cumulativeProb
            E(i + 1) = j; % Переход в состояние j
            break;
        end
    end
end
end
