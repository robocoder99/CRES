% Set simulation source
src = "const";

% Load data
if exist('oldsrc', 'var') == 0
    [step, track, map] = load_sim(src);
elseif oldsrc ~= src
    [step, track, map] = load_sim(src);
end
oldsrc = src;

% Constants
m_0 = 510.999e3;
ke = 100e3;
c = 3e8;
theta = -90;
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
m = 9.109e-31;
q = 1.602e-19;
E = 200000;
B = 1;
l = 0.3;

v = c*sqrt(1 - 1/((ke/m_0 + 1)^2));
gamma = 1/sqrt(1 - v^2/c^2);

vtan = v.*vecnorm([track.initial_momentum_x track.initial_momentum_y], 2, 2)./... 
    vecnorm([track.initial_momentum_x track.initial_momentum_y track.initial_momentum_z], 2, 2);

larmor = gamma*m*vtan/(q*B);

ic = ([track.initial_momentum_x track.initial_momentum_y]./vecnorm([track.initial_momentum_x track.initial_momentum_y], 2, 2))*R...
    .*larmor...
    + [track.initial_position_x track.initial_position_y];


m = arrayfun(@(x,y,z)  repmat(x + 1, z - y + 1, 1), map.TRACK_INDEX, map.FIRST_STEP_INDEX, map.LAST_STEP_INDEX, 'UniformOutput', false);
m = vertcat(m{:});

l = arrayfun(@(x) larmor(m(x)), (1:1:size(step.momentum_x, 1)).');
c = cell2mat(arrayfun(@(x) ic(m(x),:), (1:1:size(step.momentum_x, 1)).', 'UniformOutput', false));

cp = (([step.momentum_x step.momentum_y]./vecnorm([step.momentum_x step.momentum_y], 2, 2))*R).*l...
    + [step.position_x step.position_y];

err = vecnorm(cp - c, 2, 2);

% Plot histogram of lamar radius errors
%figure; hist(err, 50);

%% Plot Histogram
dat = [m cp c step.time err];
p = dat(dat(:,1) == 100,:);

subplot(1,2,1)
hist(err, 50)
title("Total Observed Deviations from Predicted Center")
xlabel("Distance from Predicted Center (m)")
ylabel("Count (N = 17.2 mil samples)")

subplot(1,2,2)
plot(p(1:100,6), p(1:100,7))
title("Sample Error v. Time")
xlabel("Time (s)")
ylabel("Distance Between Measured and Predicted Center of Rotation (m)")


%% Plot Visual

N = 500000;

dat = [m step.position_x step.position_y];
dat = dat(1:N,:);

scatter(dat(:,2), dat(:,3), 5, dat(:,1), 'Filled')
colormap(jet(size(dat,1)))

title("Sample Electron Path Tracing")
xlabel("X (m)")
ylabel("Y (m)")

hold on;
r = 0.0057785;
ang=0:0.001:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);
plot(xp,yp,'color','black');

