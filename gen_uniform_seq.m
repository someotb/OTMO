% Генерация N реализаций равномерного распределения U(a,b)

function seq = gen_uniform_seq(a,b,N)
seq = a + (b-a)*rand(N,1);
end