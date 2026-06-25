function plotTrack(track)
% plotTrack
% Plot track centerline and boundaries if available.

figure;
hold on;

% Plot boundaries if they exist
if isfield(track, "leftBoundary")
    plot(track.leftBoundary(:,1), track.leftBoundary(:,2), ...
        'b-', 'LineWidth', 1.2);
end

if isfield(track, "rightBoundary")
    plot(track.rightBoundary(:,1), track.rightBoundary(:,2), ...
        'r-', 'LineWidth', 1.2);
end

% Plot centerline
plot(track.center(:,1), track.center(:,2), ...
    'k--', 'LineWidth', 1.2);

grid on;
axis equal;

xlabel('x [m]');
ylabel('y [m]');

if isfield(track, "name")
    title("Track Plot: " + track.name);
else
    title("Track Plot");
end

if isfield(track, "leftBoundary") && isfield(track, "rightBoundary")
    legend('Left boundary', 'Right boundary', 'Centerline', ...
        'Location', 'best');
else
    legend('Centerline', 'Location', 'best');
end

fprintf('\n=== Track Plot Summary ===\n');

if isfield(track, "name")
    fprintf('Track name: %s\n', track.name);
end

fprintf('Number of points: %d\n', size(track.center, 1));

if isfield(track, "length")
    fprintf('Approx. track length: %.2f m\n', track.length);
end

if isfield(track, "widthLeft") && isfield(track, "widthRight")
    fprintf('Mean left width: %.2f m\n', mean(track.widthLeft));
    fprintf('Mean right width: %.2f m\n', mean(track.widthRight));
    fprintf('Mean total width: %.2f m\n', ...
        mean(track.widthLeft + track.widthRight));
end

end