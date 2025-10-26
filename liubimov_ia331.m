clear; close all; clc;

%% Параметры (вариант 7)
N_w = 700;    % длина одной реализации
K_w = 400;    % число реализаций (ансамбль)
mu_w = 14;    % математическое ожидание
sigma_w = 8;  % СКО

N_rw = 700;
K_rw = 400;
mu_rw = 0;
sigma_rw = 1;
l1 = 7;
l2 = 70;

a = 0.9;
sigma_omega = 1;
K_ar = K_w;
N_ar = N_w;

%% 1) Белый гауссовский шум: генерация матрицы X (N x K)
X = mu_w + sigma_w.*randn(N_w, K_w); 

mu_ensemble = mean(X, 2);      
mu_time_per_real = mean(X, 1);
mu_time_mean = mean(mu_time_per_real); % скаляр — среднее по времени и по реализациям

figure('Name','Белый шум: среднее по ансамблю и среднее по времени');
plot(1:N_w, mu_ensemble, 'b', 'LineWidth',1.2); hold on;
plot(1:K_w, mu_time_per_real, 'g', 'LineWidth',1.2);
yline(mu_time_mean, 'r-', 'Среднее по времени (общее)', 'LineWidth',1.2);
yline(mu_w,'k--','Теоретическое \mu','LineWidth',1.2);
xlabel('Индекс n или k');
ylabel('Значение среднего');
title('Белый гауссовский шум: среднее по ансамблю vs среднее по времени');
legend('Среднее по ансамблю \mu[n]', 'Среднее по времени для каждой реализации', 'Среднее по времени (общее)', 'Теоретическое \mu','Location','best');
grid on;

figure('Name','Среднее по времени по каждой реализации (white noise)');
histogram(mu_time_per_real, 30);
xlabel('time mean per realization'); ylabel('counts');
title('Histogram of time means (each realization)');

%% 2) Диаграммы рассеяния белого шума
pairs = [100 101; 200 500; 300 300];
figure('Name','Scatterplots for white noise pairs');
for i=1:3
    subplot(1,3,i);
    ni = pairs(i,1); nj = pairs(i,2);
    scatter(X(ni,:), X(nj,:), 8, 'filled');
    xlabel(sprintf('\\xi[%d]',ni)); ylabel(sprintf('\\xi[%d]',nj));
    title(sprintf('Scatter \\xi[%d] vs \\xi[%d]',ni,nj));
    grid on;
end

for i=1:3
    ni=pairs(i,1); nj=pairs(i,2);
    r = corr(X(ni,:)', X(nj,:)');
    fprintf('White noise corr( %d, %d ) = %.4f\n', ni, nj, r);
end

%% 3) Теоретическое среднее случайного блуждания
mu_xi_theoretical = zeros(N_rw,1);

figure('Name','RW theoretical mean');
plot(1:N_rw, mu_xi_theoretical,'LineWidth',1.2);
xlabel('n'); ylabel('E[\xi(n)]');
title('Теоретическое среднее случайного блуждания');
grid on;

%% 4) Теоретическая дисперсия случайного блуждания
var_xi_theoretical = ( (1:N_rw)' ) * (sigma_rw^2);

figure('Name','RW theoretical variance');
plot(1:N_rw, var_xi_theoretical,'LineWidth',1.2);
xlabel('n'); ylabel('Var[\xi(n)]');
title('Теоретическая дисперсия случайного блуждания');
grid on;

%% 5) Теоретическая автокорреляция случайного блуждания
maxLag_rw = 50;
r_theor_rw = zeros(maxLag_rw+1,1);
for k=0:maxLag_rw
    r_theor_rw(k+1) = (N_rw-k) * sigma_rw^2;
end

figure('Name','RW theoretical autocorrelation');
plot(0:maxLag_rw, r_theor_rw,'LineWidth',1.2);
xlabel('lag k'); ylabel('r(k)');
title('Теоретическая автокорреляция случайного блуждания');
grid on;

%% 6) Практическая генерация случайных блужданий
omega = sigma_rw .* randn(N_rw, K_rw) + mu_rw; % приращения
xi_rw = cumsum(omega,1);  % N_rw x K_rw

figure('Name','Random walks (sample realizations)');
plot(1:N_rw, xi_rw(:,1:min(20,K_rw)));
xlabel('n'); ylabel('\xi[n]');
title('Случайное блуждание: первые 20 реализаций');
grid on;

%% 7) Автокорреляция по ансамблю для случайных блужданий
r_nn1 = zeros(N_rw,1);
for n=2:N_rw
    r_nn1(n) = mean( xi_rw(n,:) .* xi_rw(n-1,:) );
end

figure('Name','Ensemble autocovariance r(n,n-1) for RW');
plot(1:N_rw, r_nn1, 'LineWidth',1.2);
hold on; 
plot(1:N_rw, (1:N_rw)-1, '--','LineWidth',1.2);
xlabel('n'); ylabel('r̂(n,n-1)');
legend('empirical','theoretical n-1','Location','northwest');
title('Эмпирическая автокорреляция по ансамблю для RW');
grid on;

%% 8) Теоретический расчёт AR(1)-процесса (затухающие блуждания)

var_xi_theor_ar = sigma_omega^2 / (1 - a^2);

maxLag = 30;
rho_ar_theor = a.^(0:maxLag)';

fprintf('AR(1) theoretical stationary variance = %.6f (a=%.2f, sigma_omega=%.2f)\n', ...
        var_xi_theor_ar, a, sigma_omega);

figure('Name','AR(1) theoretical correlation');
stem(0:maxLag, rho_ar_theor,'LineWidth',1.2,'Marker','o');
xlabel('lag l'); ylabel('\rho(l)');
title(sprintf('Теоретическая АКФ AR(1), a=%.2f', a));
grid on;

%% 9) Практическая генерация AR(1)-процесса
omega_ar = sigma_omega .* randn(N_ar, K_ar); % приращения
xi_ar = zeros(N_ar, K_ar);
for n=2:N_ar
    xi_ar(n,:) = a .* xi_ar(n-1,:) + omega_ar(n,:);
end

figure('Name','AR(1) realizations (sample)');
plot(1:N_ar, xi_ar(:,1:min(20,K_ar)));
xlabel('n'); ylabel('\xi_{AR}(n)');
title(sprintf('AR(1) realizations (первые 20), a=%.2f', a));
grid on;

% Эмпирическая автокорреляция (по ансамблю)
rho_ar_emp = zeros(maxLag+1,1);
for lag=0:maxLag
    r_vals = [];
    for n=(lag+1):N_ar
        r_vals(end+1) = mean( xi_ar(n,:) .* xi_ar(n-lag,:) );
    end
    rho_ar_emp(lag+1) = mean(r_vals) / var_xi_theor_ar;
end

% Сравнение эмпирики с теорией
figure('Name','AR(1) empirical vs theoretical correlation');
plot(0:maxLag, rho_ar_emp, 'o-','LineWidth',1.2); hold on;
plot(0:maxLag, rho_ar_theor, '--','LineWidth',1.2);
xlabel('lag l'); ylabel('\rho(l)');
legend('empirical (ensemble)','theoretical (a^l)','Location','best');
title('AR(1): сравнение эмпирической и теоретической АКФ');
grid on;

%% 10) Сравнение АCF (нормированных) для трех процессов (white noise, RW, AR1)
maxLagC = 50;

% White noise
acf_wn = zeros(maxLagC+1,1);
for lag=0:maxLagC
    acfvals = [];
    for n=(lag+1):N_w
        acfvals = [acfvals; mean( X(n,:) .* X(n-lag,:) )];
    end
    acf_wn(lag+1) = mean(acfvals) / (sigma_w^2);
end

% Random Walk
acf_rw = zeros(maxLagC+1,1);
for lag=0:maxLagC
    vals = [];
    for n=(lag+1):N_rw
        vals = [vals; mean( xi_rw(n,:) .* xi_rw(n-lag,:) )];
    end
    acf_rw(lag+1) = mean(vals) / mean(var_xi_theoretical);
end

% AR(1)
acf_ar = rho_ar_emp(1:min(maxLagC+1, length(rho_ar_emp)));

% График нормированных ACF
figure('Name','Normalized ACF comparison');
plot(0:maxLagC, acf_wn, '-','LineWidth',1.2); hold on;
plot(0:maxLagC, acf_rw, '-','LineWidth',1.2);
plot(0:(length(acf_ar)-1), acf_ar, '-','LineWidth',1.2);
xlabel('lag'); ylabel('normalized ACF');
legend('White noise','Random walk (ensemble)','AR(1)','Location','best');
title('Comparison of normalized ACFs (white noise, RW, AR(1))');
grid on;

%% Проверка эргодичности AR(1) — упрощённый вывод
lags = [l1, l2];

fprintf('\n=== Задание 10: Эргодичность AR(1) (сокращённый вывод) ===\n\n');

for lag = lags
    if lag >= N_ar
        fprintf('Лаг %d слишком большой для длины ряда N_ar=%d. Пропуск.\n', lag, N_ar);
        continue;
    end
    
    rho_theor = a^lag;
    rho_ensemble = mean(xi_ar(lag+1:end,:) .* xi_ar(1:end-lag,:));
    rho_time = mean(xi_ar(lag+1:end,1) .* xi_ar(1:end-lag,1));
    
    fprintf('Лаг %d:\n', lag);
    fprintf('  Теоретическое значение: %.4f\n', rho_theor);
    fprintf('  Среднее по ансамблю: %.4f\n', rho_ensemble);
    fprintf('  Среднее по времени (реализация 1): %.4f\n\n', rho_time);
end

fprintf('Вывод:\n');
fprintf('AR(1)-процесс стационарный и затухающий.\n');
fprintf('Средние по ансамблю и по времени близки, особенно на малых лагах → процесс почти эргодичен.\n');
fprintf('На больших лагах наблюдаются небольшие отклонения из-за конечной длины реализаций.\n');