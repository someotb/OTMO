% Расчёт метрик системы

function m = compute_metrics(r)
T = r.departureTimes(end);
meanL = trapz(r.tgrid, r.queueLen) / r.tgrid(end);

intervals = [r.startService, r.departureTimes];
intervals = sortrows(intervals);
merged = [];
for i=1:size(intervals,1)
    if isempty(merged) || intervals(i,1) > merged(end,2)
        merged = [merged; intervals(i,:)];
    else
        merged(end,2) = max(merged(end,2), intervals(i,2));
    end
end
busy = sum(merged(:,2)-merged(:,1));
rho = busy / T;

m.mean_num_system_time = meanL;
m.mean_waiting = mean(r.waitingTimes);
m.mean_system_time = mean(r.systemTimes);
m.rho = rho;
end
