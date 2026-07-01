function candidate = checkCandidateTrackBounds(candidate, track, decisionParams)
% checkCandidateTrackBounds
% 후보 궤적의 모든 waypoint가 트랙 경계 내에 있는지 확인한다.
%
% 각 waypoint의 s 위치에서 widthLeft / widthRight를 보간하고,
% 안전 마진을 적용한 범위를 벗어나면 invalid로 표시한다.
%
% 폐곡선 처리: s=track.length 지점에 첫 번째 포인트를 추가해 연속성 보장.
%
% 입력:
%   candidate     : createCandidateTrajectory 출력 struct
%   track         : 전처리된 트랙 struct
%   decisionParams: decision 파라미터 struct
%
% 출력:
%   candidate : .valid / .invalidReason 업데이트된 struct

arguments
    candidate     struct
    track         struct
    decisionParams struct
end

%% 이미 invalid이면 스킵
if ~candidate.valid
    return;
end

%% closed-track 보간 테이블 구성
sData      = [track.s(:);          track.length       ];
wLeftData  = [track.widthLeft(:);  track.widthLeft(1) ];
wRightData = [track.widthRight(:); track.widthRight(1)];

%% 후보 s를 [0, track.length) 범위로 wrap
sWrapped = mod(candidate.s(:), track.length);

%% 각 waypoint에서 트랙 폭 보간
widthLInterp = interp1(sData, wLeftData,  sWrapped, 'linear')';
widthRInterp = interp1(sData, wRightData, sWrapped, 'linear')';

%% 안전 마진 적용 후 d 허용 범위
dLimitLeft  =  widthLInterp - decisionParams.trackMarginLeft;
dLimitRight = -(widthRInterp - decisionParams.trackMarginRight);

%% 경계 이탈 여부 확인
outLeft  = candidate.d > dLimitLeft;
outRight = candidate.d < dLimitRight;

if any(outLeft)
    candidate.valid         = false;
    candidate.invalidReason = "out_of_track_left";
elseif any(outRight)
    candidate.valid         = false;
    candidate.invalidReason = "out_of_track_right";
end

end
