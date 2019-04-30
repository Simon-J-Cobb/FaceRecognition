function [gam] = DynamicProgrammingQ(q1,q2,lam,Disp)

[n,N] = size(q1);
M = 5*N;
for i=1:n
    q2L(i,:) = spline([1:N]/N,q2(i,:),[1:M]/M);
end
%q2L(2,:) = spline([1:N]/N,q2(2,:),[1:M]/M);

Nbrs = [1 1; 1 2; 2 1; 2 3; 3 2; 1 3; 3 1; 1 4; 3 4; 4 3; 4 1; 1 5; 2 5; 3 5; 4 5; 5 4; 5 3; 5 2; 5 1; 1 6; 5 6; 6 5; 6 1];


E = zeros(N,N);
E(1,:) = 5000;
E(:,1) = 5000;
E(1,1) = 0;
for i=2:N
    for j=2:N
        for Num = 1:size(Nbrs,1)
            k = i - Nbrs(Num,1);
            l = j - Nbrs(Num,2);
            if (k > 0 & l > 0)
                CandE(Num) = E(k,l) + CostFn2(q1,q2,q2L,k,l,i,j,N,lam);
            else
                CandE(Num) = 100000;
            end
            [E(i,j),idx] = min(CandE);
            Path(i,j,1) = i - Nbrs(idx,1);
            Path(i,j,2) = j - Nbrs(idx,2);
        end
    end
end


% Displaying the energies and the minimum path
    clear x; clear y;
    x(1) = N; y(1) = N;
    cnt = 1;
    while x > 1
        y(cnt+1) = Path(y(cnt),x(cnt),1);
        x(cnt+1) = Path(y(cnt),x(cnt),2);
        cnt = cnt + 1;
    end

[x,idx] = sort(x);
y = y(idx);

for i=1:N
    F = abs(i - x);
    [tmp,idx] = min(F);
    if x(idx) == i
        yy(i) = y(idx);
    else
        if x(idx) > i
            a = x(idx) -i;      
            b = i - x(idx-1);
            yy(i) = (a*y(idx-1) + b*y(idx))/(a+b);
        else
            a = i - x(idx);
            b = x(idx+1) - i;
            yy(i) = (a*y(idx+1) + b*y(idx))/(a+b);
        end
    end
end
gam = yy/N;

if(Disp)
    figure(2); clf;
    axes('FontSize',20,'FontWeight','bold');
    %clf; hold on;
    %imagesc(E);
    %colormap(gray);
    z = plot([1:N]/N,yy/N,'r');
    set(z,'LineWidth',3);
    %title('Optimal Registration Function Between the Two Curves');
    grid;axis equal;
    axis([0 1 0 1]);
    
    
    
    figure(5); clf;
    image(E*2000);
    hold on;
    z = plot([1:N],yy,'w');
    set(z,'LineWidth',3);
    axis xy;
    axis equal off;
    colormap(gray);
    
    for i=1:N/4
        z  = plot([4*i 4*i],[1,N],'b');
    end
    
     for i=1:N/4
        z  = plot([1,N],[4*i 4*i],'b');
    end
end
