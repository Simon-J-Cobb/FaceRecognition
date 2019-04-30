function E = CostFn2(q1,q2,q2L,k,l,i,j,N,lam)


M = size(q2L,2);

x = [k:1:i];
m = (j-l)/(i-k);
y = (x-k)*m + l;

idx = round(y*M/N);
vec = sqrt(m)*q2L(:,idx);

E = norm(q1(:,x) - vec,'fro')^2/N;