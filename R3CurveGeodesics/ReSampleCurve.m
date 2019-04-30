function Xn = ReSampleCurve(X,N)

    T = length(X);
    for r = 2:T
        del(r-1) = norm(X(:,r) - X(:,r-1));
    end
    cumdel = cumsum(del)/sum(del);
    
    
    newdel = [1:N]/(N);
    
    Xn(1,:) = spline(cumdel,X(1,2:T),newdel);
    Xn(2,:) = spline(cumdel,X(2,2:T),newdel);
    Xn(3,:) = spline(cumdel,X(3,2:T),newdel);