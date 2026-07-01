function candidate = checkCandidateTrackBounds(candidate, track, decision)
% checkCandidateTrackBounds
% candidate trajectory가 track boundary 안에 있는지 검사한다.

arguments
    candidate struct
    track struct
    decision struct
end

if ~candidate.isValid
    return;
end

s = mod(candidate.s(:), track.length);
d = candidate.d(:);

sTrack = track.s(:);

widthLeft = track.widthLeft(:);
widthRight = track.widthRight(:);

% closed track interpolation
sExt = [sTrack; track.length];
wLeftExt = [widthLeft; widthLeft(1)];
wRightExt = [widthRight; widthRight(1)];

leftWidth = interp1(sExt, wLeftExt, s, "linear");
rightWidth = interp1(sExt, wRightExt, s, "linear");

leftLimit = leftWidth - decision.trackMargin;
rightLimit = -rightWidth + decision.trackMargin;

isInside = (d <= leftLimit) & (d >= rightLimit);

candidate.leftLimit = leftLimit;
candidate.rightLimit = rightLimit;

if ~all(isInside)
    firstBadIdx = find(~isInside, 1);

    candidate.isValid = false;
    candidate.reason = string(sprintf( ...
        "track boundary violation at t = %.2f s, d = %.2f m", ...
        candidate.time(firstBadIdx), ...
        candidate.d(firstBadIdx)));
end

end