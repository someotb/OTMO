% Событийная модель одноканальной СМО (G/G/1)

function res = sim_GG1_eventdriven(tau, nu)
N = numel(tau);
arrival = cumsum(tau);
start = zeros(N,1);
depart = zeros(N,1);

server_free = 0;
for i=1:N
    if arrival(i) >= server_free
        start(i) = arrival(i);
    else
        start(i) = server_free;
    end
    depart(i) = start(i) + nu(i);
    server_free = depart(i);
end

wait = start - arrival;
system_time = depart - arrival;

tgrid = linspace(0, depart(end), 500);
queueLen = zeros(size(tgrid));
for k=1:length(tgrid)
    t = tgrid(k);
    queueLen(k) = sum(arrival <= t) - sum(depart <= t);
end

res.arrivalTimes = arrival;
res.startService = start;
res.departureTimes = depart;
res.waitingTimes = wait;
res.systemTimes = system_time;
res.tgrid = tgrid;
res.queueLen = queueLen;
end
