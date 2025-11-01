clc; clear; close all;

%% Параметры СМО
lambda = 8; %интенсивность поступления заявок (заявок в единицу времени)
u = 15; % интесивность обслуживаниия (заявок в единицу времени)
p = lambda / u; %коэффициент загруженности СМО

N = 1000; % кол-во заявок


% lambda > u - условие стационарности системы (в ином случае сисетма не
% стабильна, т.к заявок в единицу времени больше, чем СМО может обслужить в единицу времени)
%% Расчет характеристик для системы M/M/1

% распределение обслуживания заявок
MM1_vn = exprnd(1/u, 1, N);

% распределение поступления заявок 
MM1_tn = exprnd(1/lambda, 1, N); %#ok<*NASGU>

%расчет параметров
MM1_params = MM1_param(MM1_vn, p);

%вывод параметров
fprintf("M/M/1:\nrho: \t %f\nAvg queue len(N_q): \t %f\nAvg tasks count in system(N): \t %f\nAvg waiting time(W): \t %f\nAvg time task into system(T): \t %f\n", p, MM1_params.N_q, MM1_params.N, MM1_params.W, MM1_params.T);

%сортируем и накапливаем сумму
MM1_vn = sort(cumsum(exprnd(1/u, 1, N)));
MM1_tn = sort(cumsum(exprnd(1/lambda, 1, N)));

%визуализация
figure;
plot(MM1_tn, 0:1:length(MM1_tn) - 1);
hold on;
plot(MM1_vn, 0:1:length(MM1_vn) - 1);
title("M/M/1: Зависимость числа пришедших/обработанных заявок от времени");
xlabel("Время,с");
ylabel("Кол-во заявок,шт");
hold off;
grid on;
legend("Пришедшие заявки от времени", "Обслуженные заявки от времени");

% кол-во заявок в системе
tasks_in_system = zeros(length(MM1_vn), 1);

for i = 1:length(MM1_vn)
    tasks_in_system(i) = MM1_vn(i) - MM1_tn(i); 
end

figure;
plot(MM1_vn, tasks_in_system);
title("M/M/1: Зависимость кол-ва заявок в системе от времени");
xlabel("Время,с");
ylabel("Кол-во заявок,шт");

tasks_in_system_round = round(tasks_in_system);

figure;
histogram(tasks_in_system_round, 'Normalization', 'probability');
title("Распределение числа заявок в M/M/1")
xlabel('Количество заявок в системе');
ylabel('Вероятность');
title('Распределение числа заявок в M/M/1');
grid on;

% Задание: проделать то же самое для систем M/D/1 и M/G/1, G/M/1, G/G/1.
% Для G/G/1, G/M/1 нет формул для расчета показателей, поэтому можно просто
% построить графики. В случае M/D/1 распределение времени
% обслуживания детерминировано, т.е является константой. Функции для расчета параметров для систем M/D/1 и M/G/1 уже
% написаны. Для удобства можно оформить код выше в одну функцию, куда будут
% подаваться распределения времени обслуживания и времени поступления
% заявок.

%% Расчет характеристик для системы M/D/1

MD1_vn = ones(1, N) * (1/u); % Детерменированное время обслуживание(постоянное)
MD1_tn = exprnd(1/lambda, 1, N); % Поступление заявок

MD1_params = MD1_param(mean(MD1_vn), p);

fprintf("M/D/1:\nrho: \t %f\nAvg queue len(N_q): %f\nAvg tasks count in system(N): %f\nAvg waiting time(W): %f\nAvg time task into system(T): \t %f \n", ...
        p,MD1_params.N_q, MD1_params.N, MD1_params.W, MD1_params.T);

%% Расчет характеристик для системы M/G/1

MG1_vn = exprnd(1/u, 1, N);
c = var(MG1_vn)/mean(MG1_vn)^2;

MG1_params = MG1_param(MG1_vn, c, p);

fprintf("M/G/1:\nrho: \t %f\nAvg queue len(N_q): %f\nAvg tasks count in system(N): %f\nAvg waiting time(W): %f\nAvg time task into system(T): \t %f\n", ...
        p,MG1_params.N_q, MG1_params.N, MG1_params.W, MG1_params.T);

%% G/M/1
GM1_tn = sort(cumsum(normrnd(1/lambda, 0.2, 1, N))); % случайное поступление
GM1_vn = sort(cumsum(exprnd(1/u, 1, N))); % экспоненциальное обслуживание

figure;
plot(GM1_tn, 0:1:length(GM1_tn)-1);
hold on;
plot(GM1_vn, 0:1:length(GM1_vn)-1);
title("G/M/1: Зависимость числа пришедших/обслуженных заявок от времени");
xlabel("Время,с");
ylabel("Кол-во заявок,шт");
legend("Пришедшие заявки", "Обслуженные заявки");
grid on;
hold off;

% кол-во заявок в системе
tasks_in_system = zeros(length(GM1_vn), 1);

for i = 1:length(GM1_vn)
    tasks_in_system(i) = GM1_vn(i) - GM1_tn(i); 
end

figure;
plot(GM1_vn, tasks_in_system);
title("G/M/1: Зависимость кол-ва заявок в системе от времени");
xlabel("Время,с");
ylabel("Кол-во заявок,шт");

tasks_in_system_round = round(tasks_in_system);

figure;
histogram(tasks_in_system_round, 'Normalization', 'probability');
title("Распределение числа заявок в G/M/1")
xlabel('Количество заявок в системе');
ylabel('Вероятность');
title('Распределение числа заявок в G/M/1');
grid on;

%% G/G/1
GG1_tn = sort(cumsum(normrnd(1/lambda, 0.2, 1, N))); % случайное поступление
GG1_vn = sort(cumsum(normrnd(1/u, 0.3, 1, N))); % случайное обслуживание

figure;
plot(GG1_tn, 0:1:length(GG1_tn)-1);
hold on;
plot(GG1_vn, 0:1:length(GG1_vn)-1);
title("G/G/1: Зависимость числа пришедших/обслуженных заявок от времени");
xlabel("Время,с");
ylabel("Кол-во заявок,шт");
legend("Пришедшие заявки", "Обслуженные заявки");
grid on;
hold off;

% кол-во заявок в системе
tasks_in_system = zeros(length(GG1_vn), 1);

for i = 1:length(GG1_vn)
    tasks_in_system(i) = GG1_vn(i) - GG1_tn(i); 
end

figure;
plot(GG1_vn, tasks_in_system);
title("G/G/1: Зависимость кол-ва заявок в системе от времени");
xlabel("Время,с");
ylabel("Кол-во заявок,шт");

tasks_in_system_round = round(tasks_in_system);

figure;
histogram(tasks_in_system_round, 'Normalization', 'probability');
title("Распределение числа заявок в G/G/1")
xlabel('Количество заявок в системе');
ylabel('Вероятность');
title('Распределение числа заявок в G/G/1');
grid on;

function stats = MG1_param(tn, c, p)
    %N_q - avg queue len
    %N - avg tasks count in system
    %W - avg waiting time 
    %T - avg time task into system
    %t_n - set of time serving

    %avg time serving
    avg_tn = mean(tn);

    %compute params
    stats.N_q = p^2 * (1 + c) / (2*(1-p));
    stats.N = p + stats.N_q;
    stats.W = p * avg_tn * (1 + c) / (2*(1-p));
    stats.T = avg_tn + stats.W;

end


function stats = MD1_param(t, p)
    %N_q - avg queue len
    %N - avg tasks count in system
    %W - avg waiting time 
    %T - avg time task into system
    %t - time serving

    %compute params
    stats.N_q = p^2 * 1 / (2*(1-p));
    stats.N = p + stats.N_q;
    stats.W = p * t / (2*(1-p));
    stats.T = t*(1 - p) / (2 * (1 - p));
end

function stats = MM1_param(tn, p)
    %N_q - avg queue len
    %N - avg tasks count in system
    %W - avg waiting time 
    %T - avg time task into system
    %t_n - set of time serving

    %avg time serving
    avg_tn = mean(tn);

    %compute params
    stats.N_q = p^2/(1-p);
    stats.N = p / (1 - p);
    stats.W = stats.N * avg_tn;
    stats.T = avg_tn / (1-p);

end