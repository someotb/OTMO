clc; clear; close all;

%% Характеристики СМО
lambda = 5; % Кол-во поступающих заявок
nu = 8; % Кол-во заявок, которые можно обрабатывать одновременно
p = lambda / nu; % Коэффициент загрузки системы
p_MD1_MM1_MG1 = 0.1:0.1:0.9;
x = 1 / nu; % Среднее время обслуживания одной заявки
C_2b = [0 1 10:10:100]; % Нормированная дисперсия, время обслуживания
C_2b_const = 0.5;

%% Расчет характеристик M/G/1 (зависимость от нормированной дисперсии)
N_q_MG1 = p^2 .* (1 + C_2b) ./ (2 * (1 - p)); % Средняя длина очереди
N_MG1   = p + N_q_MG1; % Среднее число заявок в СМО
W_MG1   = p .* x .* (1 + C_2b) ./ (2 * (1 - p)); % Среднее время ожидания
T_MG1   = x + W_MG1; % Среднее время пребывания

% Расчет характеристик M/G/1 (зависимость от загрузки системы)
N_q_MG1_p = p_MD1_MM1_MG1.^2 .* (1 + C_2b_const) ./ (2 * (1 - p_MD1_MM1_MG1)); % Средняя длина очереди
N_MG1_p   = p_MD1_MM1_MG1 + N_q_MG1_p; % Среднее число заявок в СМО
W_MG1_p   = p_MD1_MM1_MG1 .* x .* (1 + C_2b_const) ./ (2 * (1 - p_MD1_MM1_MG1)); % Среднее время ожидания
T_MG1_p   = x + W_MG1_p; % Среднее время пребывания

%% Расчет характеристик M/D/1 (C_b^2 = 0, детерминированное время обслуживания)
N_q_MD1 = p_MD1_MM1_MG1.^2 ./ (2 * (1 - p_MD1_MM1_MG1)); % Средняя длина очереди
N_MD1 = p_MD1_MM1_MG1 + N_q_MD1; % Среднее число заявок в СМО
W_MD1 = p_MD1_MM1_MG1 .* x ./ (2 * (1 - p_MD1_MM1_MG1)); % Среднее время ожидания
T_MD1 = (x * (1 - p_MD1_MM1_MG1)) ./ (2 * (1 - p_MD1_MM1_MG1)); % Среднее время пребывания требования в системе

%% Расчет характеристик M/M/1 (C_b^2 = 1, экспоненциальное время обслуживания)
N_q_MM1 = p_MD1_MM1_MG1.^2 ./ (1 - p_MD1_MM1_MG1); % Средняя длина очереди
N_MM1 = p_MD1_MM1_MG1 ./ (1 - p_MD1_MM1_MG1); % Среднее число заявок в СМО
W_MM1 = p_MD1_MM1_MG1 .* x ./ (1 - p_MD1_MM1_MG1); % Среднее время ожидания
T_MM1 = x ./ (1 - p_MD1_MM1_MG1); % Среднее время пребывания требования в системе

%% Вывод результатов в командное окно
disp('Характеристики M/G/1(от нормированной дисперсии)');
disp(table(C_2b', N_q_MG1', N_MG1', W_MG1', T_MG1', ...
    'VariableNames', {'C_b^2','N_q','N','W','T'}));

disp('Характеристики M/G/1(от загрузки системы)');
disp(table(p_MD1_MM1_MG1', N_q_MG1_p', N_MG1_p', W_MG1_p', T_MG1_p', ...
    'VariableNames', {'p','N_q','N','W','T'}));

disp(' ');
disp('Характеристики M/D/1');
disp(table(p_MD1_MM1_MG1', N_q_MD1', N_MD1', W_MD1', T_MD1', ...
    'VariableNames', {'p','N_q','N','W','T'}));

disp(' ');
disp('Характеристики M/M/1');
disp(table(p_MD1_MM1_MG1', N_q_MM1', N_MM1', W_MM1', T_MM1', ...
    'VariableNames', {'p','N_q','N','W','T'}));

%% Графики характеристик для всех СМО

figure('Name','Характеристики СМО','NumberTitle','off');

%% 1. Средняя длина очереди N_q
subplot(2,2,1); hold on;
plot(p_MD1_MM1_MG1, N_q_MG1_p, '-o','LineWidth',1.5);
plot(p_MD1_MM1_MG1, N_q_MD1, '-s','LineWidth',1.5);
plot(p_MD1_MM1_MG1, N_q_MM1, '-d','LineWidth',1.5);
grid on; xlabel('\rho'); ylabel('N_q');
title('Средняя длина очереди N_q');
legend('M/G/1','M/D/1','M/M/1','Location','northwest');

%% 2. Среднее число заявок N
subplot(2,2,2); hold on;
plot(p_MD1_MM1_MG1, N_MG1_p, '-o','LineWidth',1.5);
plot(p_MD1_MM1_MG1, N_MD1, '-s','LineWidth',1.5);
plot(p_MD1_MM1_MG1, N_MM1, '-d','LineWidth',1.5);
grid on; xlabel('\rho'); ylabel('N');
title('Среднее число заявок N');
legend('M/G/1','M/D/1','M/M/1','Location','northwest');

%% 3. Среднее время ожидания W
subplot(2,2,3); hold on;
plot(p_MD1_MM1_MG1, W_MG1_p, '-o','LineWidth',1.5);
plot(p_MD1_MM1_MG1, W_MD1, '-s','LineWidth',1.5);
plot(p_MD1_MM1_MG1, W_MM1, '-d','LineWidth',1.5);
grid on; xlabel('\rho'); ylabel('W');
title('Среднее время ожидания W');
legend('M/G/1','M/D/1','M/M/1','Location','northwest');

%% 4. Среднее время пребывания T
subplot(2,2,4); hold on;
plot(p_MD1_MM1_MG1, T_MG1_p, '-o','LineWidth',1.5);
plot(p_MD1_MM1_MG1, T_MD1, '-s','LineWidth',1.5);
plot(p_MD1_MM1_MG1, T_MM1, '-d','LineWidth',1.5);
grid on; xlabel('\rho'); ylabel('T');
title('Среднее время пребывания T');
legend('M/G/1','M/D/1','M/M/1','Location','northwest');