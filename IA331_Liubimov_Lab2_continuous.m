% Вариант 7: Непрерывная СВ с f(x) = 1/(2*sqrt(x)) на [1,4]

% Шаг 1: Генерация выборок с помощью метода обратных функций
Ns = [50, 200, 1000];  % Размеры выборок
samples = cell(1, length(Ns));

for i = 1:length(Ns)
    N = Ns(i);
    u = rand(N, 1);  % Равномерная [0,1]
    x = (u + 1).^2;  % Обратная функция
    samples{i} = x;
end

% Шаг 3: Точечные оценки
means = zeros(1, length(Ns));
vars = zeros(1, length(Ns));
stds = zeros(1, length(Ns));

for i = 1:length(Ns)
    means(i) = mean(samples{i});
    vars(i) = var(samples{i});
    stds(i) = std(samples{i});
end

% Шаг 4: Интервальные оценки
alphas = [0.1, 0.05, 0.01];
mean_intervals = cell(length(alphas), length(Ns));
var_intervals = cell(length(alphas), length(Ns));

for i = 1:length(Ns)
    N = Ns(i);
    sample = samples{i};
    mu = mean(sample);
    sigma2 = var(sample);
    s = std(sample);
    
    for j = 1:length(alphas)
        alpha = alphas(j);
        
        % Для среднего (t-распределение, предполагаем нормальность для больших N)
        t_val = tinv(1 - alpha/2, N-1);
        mean_intervals{j, i} = [mu - t_val * s / sqrt(N), mu + t_val * s / sqrt(N)];
        
        % Для дисперсии (хи-квадрат)
        chi_low = chi2inv(alpha/2, N-1);
        chi_high = chi2inv(1 - alpha/2, N-1);
        var_intervals{j, i} = [(N-1)*sigma2 / chi_high, (N-1)*sigma2 / chi_low];
    end
end

% Шаг 5: Таблицы результатов
disp('Точечные оценки:');
table_point = table(Ns', means', vars', stds', ...
    'VariableNames', {'N', 'Mean', 'Variance', 'Std'});
disp(table_point);

disp('Интервальные оценки среднего:');
for j = 1:length(alphas)
    disp(['Alpha = ' num2str(alphas(j))]);
    intervals_mean = zeros(length(Ns), 2);
    for i = 1:length(Ns)
        intervals_mean(i, :) = mean_intervals{j, i};
    end
    disp(table(Ns', intervals_mean(:,1), intervals_mean(:,2), ...
        'VariableNames', {'N', 'Lower', 'Upper'}));
end

disp('Интервальные оценки дисперсии:');
for j = 1:length(alphas)
    disp(['Alpha = ' num2str(alphas(j))]);
    intervals_var = zeros(length(Ns), 2);
    for i = 1:length(Ns)
        intervals_var(i, :) = var_intervals{j, i};
    end
    disp(table(Ns', intervals_var(:,1), intervals_var(:,2), ...
        'VariableNames', {'N', 'Lower', 'Upper'}));
end

% Шаг 6-7: Гистограммы с теоретической плотностью
figure;
for i = 1:length(Ns)
    N = Ns(i);
    sample = samples{i};
    k = floor(1 + 3.2 * log(N));  % Число бинов
    subplot(1, length(Ns), i);
    histogram(sample, k, 'Normalization', 'pdf');
    hold on;
    
    % Теоретическая плотность
    x_th = linspace(1, 4, 1000);
    f_th = 1 ./ (2 * sqrt(x_th));
    plot(x_th, f_th, 'r-', 'LineWidth', 2);
    
    title(['N = ' num2str(N)]);
    xlabel('x');
    ylabel('Density');
    hold off;
end

% Шаг 8: Теоретические CDF и PDF на одном графике
figure;
x_th = linspace(1, 4, 1000);
f_th = 1 ./ (2 * sqrt(x_th));
F_th = sqrt(x_th) - 1;

yyaxis left;
plot(x_th, f_th, 'b-', 'LineWidth', 2);
ylabel('PDF');

yyaxis right;
plot(x_th, F_th, 'g-', 'LineWidth', 2);
ylabel('CDF');

title('Theoretical PDF and CDF');
xlabel('x');