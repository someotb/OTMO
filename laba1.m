clc;
clear;

%% 1. Задание функции и построение графиков
x = -2:0.01:2;
f = @(x) abs(1 - exp(2*x));
y = f(x);

% Символьная производная
syms xs
fs = abs(1 - exp(2*xs));
dfs = diff(fs);
df_num = matlabFunction(dfs); % численная форма
y_derivative = df_num(x);

% Интеграл F(x) = ∫₀ˣ f(y) dy
F = zeros(size(x));
for i = 1:length(x)
    F(i) = integral(f, 0, x(i));
end

% Графики
figure;
subplot(3,1,1);
plot(x, y, 'b', 'LineWidth', 1.5);
title('Функция f(x) = |1 - e^{2x}|');
xlabel('x'); ylabel('f(x)');
legend('f(x) = |1 - e^{2x}|', 'Location', 'northwest');
grid on;

subplot(3,1,2);
plot(x, y_derivative, 'r', 'LineWidth', 1.5);
title('Производная f''(x)');
xlabel('x'); ylabel('f''(x)');
legend('f''(x)', 'Location', 'northwest');
grid on;

subplot(3,1,3);
plot(x, F, 'g', 'LineWidth', 1.5);
title('Интеграл F(x) = ∫₀ˣ f(y)dy');
xlabel('x'); ylabel('F(x)');
legend('F(x) = ∫₀ˣ f(y) dy', 'Location', 'northwest');
grid on;

%% 2. Решение уравнения: a*x + b = f(x)
a = 2;
b = 1;
eq_func = @(x) a*x + b - f(x);
x0 = -0.3; % начальное приближение
x_solution = fsolve(eq_func, x0);
fprintf('Решение уравнения 2x + 1 = f(x): x = %.4f\n', x_solution);

%% 3. Функция двух переменных F(x, y) = sin(x)/y - cos(y)/x
[X, Y] = meshgrid(-5:0.25:5, -5:0.25:5);
% Чтобы избежать деления на ноль:
X(X == 0) = eps;
Y(Y == 0) = eps;
Fxy = sin(X)./Y - cos(Y)./X;

% Построение 3D-графика
figure;
surf(X, Y, Fxy);
title('F(x, y) = sin(x)/y - cos(y)/x');
xlabel('x'); ylabel('y'); zlabel('F(x, y)');
legend('F(x, y)', 'Location', 'best');
