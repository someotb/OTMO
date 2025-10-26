% Лабораторная №6. Вариант 16 — равномерное распределение.
% Модель: M/M/1, M/G/1, G/M/1, G/G/1

clear; clc; close all;

%% Исходные данные
variant = 16;     % равномерное распределение
N = 1000;         % длина последовательностей
lambda = 100;     % интенсивность потока
mu = 150;         % интенсивность обслуживания

fprintf('Лабораторная №6 — Вариант %d (равномерное распределение)\n', variant);
fprintf('λ = %.2f, μ = %.2f, N = %d\n', lambda, mu, N);

mean_tau = 1/lambda;  % мат. ожидание интервалов прихода
var_tau  = 1/(lambda^2);
mean_nu  = 1/mu;      % мат. ожидание времени обслуживания
var_nu   = 1/(mu^2);

%% Генерация последовательностей
rng(12345);

% Параметры равномерного распределения для τ и ν
[a_tau,b_tau] = solve_params_uniform(mean_tau, var_tau);
[a_nu,b_nu]   = solve_params_uniform(mean_nu, var_nu);

% M/M/1
tau_MM = exprnd(mean_tau, N, 1);
nu_MM  = exprnd(mean_nu, N, 1);

% M/G/1 (обслуживание — равномерное)
tau_MG = tau_MM;
nu_MG  = gen_uniform_seq(a_nu, b_nu, N);

% G/M/1 (поток — равномерный)
tau_GM = gen_uniform_seq(a_tau, b_tau, N);
nu_GM  = nu_MM;

% G/G/1 (оба — равномерные)
tau_GG = gen_uniform_seq(a_tau, b_tau, N);
nu_GG  = gen_uniform_seq(a_nu, b_nu, N);

%% Симуляция
fprintf('Симуляция систем...\n');
res_MM = sim_GG1_eventdriven(tau_MM, nu_MM);
res_MG = sim_GG1_eventdriven(tau_MG, nu_MG);
res_GM = sim_GG1_eventdriven(tau_GM, nu_GM);
res_GG = sim_GG1_eventdriven(tau_GG, nu_GG);

%% Вычисление характеристик
metrics_MM = compute_metrics(res_MM);
metrics_MG = compute_metrics(res_MG);
metrics_GM = compute_metrics(res_GM);
metrics_GG = compute_metrics(res_GG);

%% Отображение результатов
disp('Характеристики систем');
fprintf(' %-6s | rho = %.3f | Lср = %.3f | Wож = %.3f | Wсист = %.3f\n', ...
    'M/M/1', metrics_MM.rho, metrics_MM.mean_num_system_time, metrics_MM.mean_waiting, metrics_MM.mean_system_time);
fprintf(' %-6s | rho = %.3f | Lср = %.3f | Wож = %.3f | Wсист = %.3f\n', ...
    'M/G/1', metrics_MG.rho, metrics_MG.mean_num_system_time, metrics_MG.mean_waiting, metrics_MG.mean_system_time);
fprintf(' %-6s | rho = %.3f | Lср = %.3f | Wож = %.3f | Wсист = %.3f\n', ...
    'G/M/1', metrics_GM.rho, metrics_GM.mean_num_system_time, metrics_GM.mean_waiting, metrics_GM.mean_system_time);
fprintf(' %-6s | rho = %.3f | Lср = %.3f | Wож = %.3f | Wсист = %.3f\n', ...
    'G/G/1', metrics_GG.rho, metrics_GG.mean_num_system_time, metrics_GG.mean_waiting, metrics_GG.mean_system_time);

%  rho   - коэффициент загрузки системы (доля времени, когда прибор занят).
%  Lср   - среднее число заявок в системе (очередь + обслуживание).
%  Wож   - среднее время ожидания заявки в очереди.
%  Wсист - среднее время пребывания заявки в системе (ожидание + обслуживание).
%
%  Интерпретация:
%   • Чем больше rho, тем выше загруженность прибора; при rho ≥ 1 система перегружена.
%   • Lср показывает среднее количество заявок, находящихся одновременно в системе.
%   • Wож — сколько в среднем заявка ждёт начала обслуживания.
%   • Wсист = Wож + среднее время обслуживания — полный цикл пребывания заявки.
%
%  Все характеристики связаны законом Литтла: Среднее число заявок в системе равно произведению интенсивности поступления на среднее время пребывания заявки в системе.
%      Lср ≈ λ * Wсист
%

%% Графики
plot_results(res_MM, metrics_MM, 'M/M/1');
plot_results(res_MG, metrics_MG, 'M/G/1');
plot_results(res_GM, metrics_GM, 'G/M/1');
plot_results(res_GG, metrics_GG, 'G/G/1');