function [dist,X2n,q2n,X1,q1]=my3Dgeod(X1,X2)
 
%input: two curves X1 and X2 as 3xn
%output: dist=distance, also will display when you run the program; X2n:
%optimally registered curve X2; q2n: same as X2n except in q-fun form; X1:
%scaled curve X1; q1: same as X1 except in q-fun form;

% Load some parameters, no need to change this
lam = 0;

% What displays you want to see, set to 1 if you want to see figures
    Disp_geodesic_between_the_curves = 0;
    Disp_registration_between_curves = 0;
    Disp_optimal_reparameterization = 0;
    
% Resample the curves to have N points
    N = 20;
    X1 = ReSampleCurve(X1,N);
    X2 = ReSampleCurve(X2,N);

%Center curves, not really needed but good for display purposes
    X1 = X1 - repmat(mean(X1')',1,size(X1,2));
    X2 = X2 - repmat(mean(X2')',1,size(X2,2));    
    
% Form the q function for representing curves and find best rotation
    [q1] = curve_to_q(X1);
    [q2] = curve_to_q(X2);
    A = q1*q2';
    [U,S,V] = svd(A);
    if det(A)> 0
        Ot = U*V';
    else
        Ot = U*([V(:,1) V(:,2) -V(:,3)])';
    end
    X2 = Ot*X2;
    q2 = Ot*q2;

% Applying optimal re-parameterization to the second curve
    [gam] = DynamicProgrammingQ(q1,q2,lam,0);
    gamI = invertGamma(gam);
    gamI = (gamI-gamI(1))/(gamI(end)-gamI(1));
    X2n = Group_Action_by_Gamma_Coord(X2,gamI);
    q2n = curve_to_q(X2n);
    if Disp_optimal_reparameterization
        figure(100); clf;
        plot(gamI,'LineWidth',2)
    end

% Find optimal rotation
    A = q1*q2n';
    [U,S,V] = svd(A);
    if det(A)> 0
        Ot = U*V';
    else
        Ot = U*([V(:,1) V(:,2) -V(:,3)])';
    end
    X2n = Ot*X2n;
    q2n = Ot*q2n;

% Forming geodesic between the registered curves
N = size(X1,2);
dist = acos(sum(sum(q1.*q2n))/N);
%sprintf('The distance between the two curves is %0.3f',dist)
    if(Disp_geodesic_between_the_curves)
        for t=1:7
            s = dist*(t-1)/6;
            PsiQ(:,:,t) = (sin(dist - s)*q1 + sin(s)*q2n)/sin(dist);
            PsiX(:,:,t) = q_to_curve(PsiQ(:,:,t));
        end
        figure(4); clf; axis equal; hold on;
        for t=1:7
            z = plot3(0.2*t + PsiX(1,:,t), PsiX(2,:,t), PsiX(3,:,t),'r-'); 
            set(z,'LineWidth',[2],'color',[(t-1)/6 (t-1)/12 0]);
        end
        axis off;
    end
    
% Displaying the correspondence
%X1=PsiX(:,:,1);
%X2n=PsiX(:,:,7);
if(Disp_registration_between_curves)
    figure(3); clf;
    z = plot3(X1(1,:), X1(2,:), X1(3,:),'r');
    set(z,'LineWidth',[2]);
    axis off;
    hold on;
    z = plot3(0.2+X2n(1,:), X2n(2,:), X2n(3,:),'b-+');
    set(z,'LineWidth',[3]);
    N = size(X1,2);
    for j=1:N/15
        i = j*15;
        plot3([X1(1,i) 0.2+X2n(1,i)],[X1(2,i) X2n(2,i)], [X1(3,i) X2n(3,i)], 'k');
    end
end