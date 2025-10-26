function plot_results(res, metrics, label)
figure('Name',label,'NumberTitle','off','Position',[100 100 1200 700]);

subplot(2,2,1);
stairs(res.arrivalTimes,1:numel(res.arrivalTimes),'b'); hold on;
stairs(res.departureTimes,1:numel(res.departureTimes),'r');
xlabel('Время'); ylabel('Количество заявок');
title([label ': поступления (синим) и уходы (красным)']);
legend('Приходы','Уходы');

subplot(2,2,2);
plot(res.tgrid, res.queueLen,'LineWidth',1.2);
xlabel('Время'); ylabel('Число заявок в системе');
title([label ': динамика длины очереди']);

subplot(2,2,3);
histogram(res.waitingTimes,30);
xlabel('Время ожидания'); ylabel('Частота');
title([label ': гистограмма ожиданий']);

subplot(2,2,4);
histogram(res.systemTimes,30);
xlabel('Время в системе'); ylabel('Частота');
title([label ': гистограмма времени пребывания']);

sgtitle([label sprintf(' — ρ=%.3f, Lср=%.3f, Wож=%.3f, Wсист=%.3f', ...
    metrics.rho, metrics.mean_num_system_time, metrics.mean_waiting, metrics.mean_system_time)]);
end
