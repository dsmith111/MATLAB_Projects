clear
hold off;
clf
clc
hold on;

t = [0:1:10]
t1 = t(1:3)
t2 = t(3:5)
t3 = t(5:7)
t4 = t(7:9)
% t5 = [7 8]
x = stp_fn(t1, 3) % Generate step at t=2
y = stp_fn(t2, 1)
z = stp_fn(t3, 3)
h = rmp_fn(5 - t4)

% y = cat(2, x, y);
% y = cat(2, y, z);
% y = cat(2, y, h)


% subplot(3,1,1)
plot(t1, x)
plot(t2, y)
plot(t3, z)
plot(t4, h)
xline(2)
xline(4)
% axis([-10 10 0 1.5])
xlabel('t')
% ylabel('u(t-2)')

% y = 2 * rmp_fn(-4 - t);
% plot(t, y)



function u = stp_fn(t, height)
    u = 0.5 * (sign(t+eps) + height);
end

function r = rmp_fn(t)
    
    r(1) = 0.5*t(1).*(sign(t(1)) - 3);
    r(2) = 0.5*t(2).*(sign(t(2)) + 0);
    r(3) = 0.5*t(3).*(sign(t(3)) + 1);    
end

function imp = imps_fn(t, delta)
    imp = (stp_fn(t + (delta/2)) - stp_fn(t - (delta/2)))/delta;
end