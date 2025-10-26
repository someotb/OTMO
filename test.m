clc; clear; close all;

P_raw = [
    1, 1, 1, 1;  % Строка 1, сумма=4
    1, 1, 1, 1;  % Строка 2, сумма=4
    1, 1, 1, 1;  % Строка 3, сумма=4
    0, 0, 1, 1   % Строка 4, сумма=2
];

P = P_raw ./ sum(P_raw, 2);

stateNames = {'Healthy', 'Unwell', 'Sick', 'Very sick'};
MC = dtmc(P, 'StateNames', stateNames);

disp('Нормированная матрица переходов:');
disp(MC.P);

rowSums = sum(MC.P, 2);
disp('Сумма строк (должна быть 1):');
disp(rowSums);

figure;
graphplot(MC, 'ColorEdges', true, 'LabelEdges', true);
title('Граф цепи Маркова');

P_cum = cumsum(MC.P, 2);

iterations = [200, 1000, 10000];
z_all = cell(1, length(iterations));
P_obs_all = cell(1, length(iterations));

for idx = 1:length(iterations)
    N = iterations(idx);
    z = zeros(1, N);
    z(1) = 1;  % Начальное состояние - 1
    
    for t = 1:N-1
        r = rand;
        z(t+1) = sum(r > P_cum(z(t), :)) + 1;
    end
    
    z_all{idx} = z;
    
    numStates = 4;
    counts = zeros(numStates, numStates);
    for t = 1:N-1
        i = z(t);
        j = z(t+1);
        counts(i, j) = counts(i, j) + 1;
    end
    P_obs = counts ./ sum(counts, 2);
    P_obs(isnan(P_obs)) = 0;  % Если нет переходов из состояния, установить 0
    P_obs_all{idx} = P_obs;
    
    disp(['Оцененная матрица для ', num2str(N), ' итераций:']);
    disp(P_obs);
    
    MC_obs = dtmc(P_obs, 'StateNames', stateNames);
    figure;
    graphplot(MC_obs, 'ColorEdges', true, 'LabelEdges', true);
    title(['Граф оцененной цепи Маркова (', num2str(N), ' итераций)']);
    
    figure;
    plot(1:N, z, 'o-');
    xlabel('Итерация');
    ylabel('Состояние');
    yticks(1:4);
    yticklabels(stateNames);
    title(['Изменение состояний для ', num2str(N), ' итераций']);
    grid on;
end


lambda = 35;  % 35 заявок/час - клиенты звонят
mu = 50;      % 50 заявок/час - операторы обрабатывают  
n = 7;        % 7 операторов (каналов)
m = 5;        % 5 мест в очереди ожидания

rho = lambda / mu;  % Коэффициент загрузки если, rho > 1 - система уже не сможет справляться

sum1 = sum((rho.^ (0:n)) ./ factorial(0:n));
sum2 = (rho.^(n+1:n+m)) ./ (factorial(n) * n.^( (1:m) ));
sum2 = sum( sum2 );
p0 = 1 / (sum1 + (rho^n / factorial(n)) * sum2);

p = zeros(1, n+m+1);
for k = 0:n
    p(k+1) = (rho^k / factorial(k)) * p0;
end
for k = n+1:n+m
    p(k+1) = (rho^k / (factorial(n) * n^(k-n))) * p0;
end

P_otk = p(n+m+1);              % Вероятность отказа
Q = 1 - P_otk;                 % Относительная пропускная способность
A = lambda * Q;                % Абсолютная пропускная способность
k_zan = A / mu;                % Среднее число занятых каналов

if rho / n ~= 1
    L_och = (rho^(n+1) / factorial(n)) * ...
            (1 - (rho/n)^m * (m+1 - m*(rho/n)) ) / ...
            (1 - rho/n)^2 * p0;
else
    L_och = (rho^(n+1) / factorial(n)) * (m*(m+1)/2) * p0;
end

T_och = L_och / lambda;        % Среднее время ожидания в очереди
L_sist = L_och + k_zan;        % Среднее число заявок в системе
T_sist = L_sist / lambda;      % Среднее время пребывания в системе

disp('Показатели СМО:');
disp(['P_otk = ', num2str(P_otk)]);
disp(['Q = ', num2str(Q)]);
disp(['A = ', num2str(A)]);
disp(['k_zan = ', num2str(k_zan)]);
disp(['L_och = ', num2str(L_och)]);
disp(['T_och = ', num2str(T_och)]);
disp(['L_sist = ', num2str(L_sist)]);
disp(['T_sist = ', num2str(T_sist)]);

fprintf('\nТаблица показателей СМО:\n');
fprintf('Характеристика\tЗначение\n');
fprintf('lambda\t\t%d\n', lambda);
fprintf('mu\t\t%d\n', mu);
fprintf('n\t\t%d\n', n);
fprintf('m\t\t%d\n', m);
fprintf('rho\t\t%.2f\n', rho);
fprintf('p0\t\t%.4f\n', p0);
fprintf('P_otk\t\t%.4f\n', P_otk);
fprintf('Q\t\t%.4f\n', Q);
fprintf('A\t\t%.4f\n', A);
fprintf('k_zan\t\t%.4f\n', k_zan);
fprintf('L_och\t\t%.4f\n', L_och);
fprintf('T_och\t\t%.4f\n', T_och);
fprintf('L_sist\t\t%.4f\n', L_sist);
fprintf('T_sist\t\t%.4f\n', T_sist);