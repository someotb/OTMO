% Вариант 7: Дискретная СВ с P(X=k) = 1/2^(k+1), k=0,1,...

% Шаг 1: Генерация выборок (метод обратных функций)
Ns = [50, 200, 1000];
samples = cell(1, length(Ns));

for i = 1:length(Ns)
    N = Ns(i);
    u = rand(N, 1);
    x = zeros(N, 1);
    for j = 1:N
        k = 0;
        cdf = 1 - 1/2^(k+1);
        while u(j) > cdf
            k = k + 1;
            cdf = 1 - 1/2^(k+1);
        end
        x(j) = k;
    end
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

% Шаг 6-7: Гистограммы (для первых 20 значений)
figure;
max_k = 20;  % Ограничение для гистограммы до 20 значений
k_vals = 0:max_k;
p_th = 1 ./ 2.^(k_vals + 1);  % Теоретическая PMF

for i = 1:length(Ns)
    N = Ns(i);
    sample = samples{i};
    sample = sample(sample <= max_k);  % Обрезать для графика
    
    subplot(1, length(Ns), i);
    [counts, edges] = histcounts(sample, 'BinMethod', 'integers', 'BinLimits', [0, max_k]);
    p_exp = counts / N;  % Эмпирическая вероятность
    
    % Подготовка данных для группировки
    x = 1:length(k_vals);
    width = 0.4;  % Ширина каждого столбца
    x_exp = x - width/2;  % Позиции для эмпирических данных
    x_th = x + width/2;   % Позиции для теоретических данных
    
    % Построение столбцов
    bar(x_exp, p_exp, width, 'FaceColor', 'b', 'FaceAlpha', 0.5);
    hold on;
    bar(x_th, p_th, width, 'FaceColor', 'r', 'FaceAlpha', 0.5);
    
    % Настройка осей и меток
    set(gca, 'XTick', x);
    set(gca, 'XTickLabel', k_vals);
    title(['N = ' num2str(N)]);
    xlabel('k');
    ylabel('Probability');
    legend('Experimental', 'Theoretical');
    hold off;
end

% Шаг 8: Теоретические CDF и PMF
figure;
k_th = 0:20;
p_th = 1 ./ 2.^(k_th + 1);
F_th = cumsum(p_th);  % Приближённый CDF (до 20)

yyaxis left;
stem(k_th, p_th, 'b-', 'LineWidth', 2);
ylabel('PMF');

yyaxis right;
stairs(k_th, F_th, 'g-', 'LineWidth', 2);
ylabel('CDF');

title('Theoretical PMF and CDF (approx up to 20)');
xlabel('k');
legend('PMF', 'CDF', 'Location', 'best');  % Добавлена легенда
