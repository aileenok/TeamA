function cmd = buildSimulinkDecisionCommand(bestCandidate, decision)
% buildSimulinkDecisionCommand
% 선택된 bestCandidate를 Simulink에서 사용하기 쉬운
% 고정 구조의 numeric command로 변환한다.
%
% 출력:
%   cmd.decisionValid
%   cmd.actionCode
%   cmd.targetD
%   cmd.targetV
%   cmd.sampleTime
%   cmd.numRefPoints
%
%   cmd.timeRef
%   cmd.sRef
%   cmd.dRef
%   cmd.vRef
%   cmd.xRef
%   cmd.yRef
%   cmd.yawRef
%
% actionCode:
%   0 = EMERGENCY_STOP / INVALID
%   1 = MAINTAIN_LINE
%   2 = OVERTAKE_INSIDE
%   3 = OVERTAKE_OUTSIDE
%   4 = RETURN_TO_LINE

arguments
    bestCandidate struct
    decision struct
end

%% 1. 필수 필드 검사
requiredFields = [ ...
    "name", ...
    "time", ...
    "s", ...
    "d", ...
    "v", ...
    "x", ...
    "y", ...
    "yaw", ...
    "targetD", ...
    "targetV", ...
    "isValid" ...
    ];

for i = 1:numel(requiredFields)
    fieldName = requiredFields(i);

    if ~isfield(bestCandidate, fieldName)
        error( ...
            "bestCandidate에 필수 필드 '%s'가 없습니다.", ...
            fieldName);
    end
end

%% 2. Reference vector를 column vector로 정리
timeRef = double(bestCandidate.time(:));
sRef = double(bestCandidate.s(:));
dRef = double(bestCandidate.d(:));
vRef = double(bestCandidate.v(:));

xRef = double(bestCandidate.x(:));
yRef = double(bestCandidate.y(:));
yawRef = double(bestCandidate.yaw(:));

%% 3. Reference point 개수 검사
expectedNumPoints = ...
    round(decision.horizon / decision.dt) + 1;

numRefPoints = numel(timeRef);

if numRefPoints ~= expectedNumPoints
    error( ...
        "Reference point 개수가 예상값과 다릅니다. " + ...
        "Expected: %d, Actual: %d", ...
        expectedNumPoints, ...
        numRefPoints);
end

referenceVectors = { ...
    sRef, ...
    dRef, ...
    vRef, ...
    xRef, ...
    yRef, ...
    yawRef ...
    };

referenceNames = [ ...
    "sRef", ...
    "dRef", ...
    "vRef", ...
    "xRef", ...
    "yRef", ...
    "yawRef" ...
    ];

for i = 1:numel(referenceVectors)
    values = referenceVectors{i};

    if numel(values) ~= numRefPoints
        error( ...
            "%s의 길이가 timeRef와 다릅니다.", ...
            referenceNames(i));
    end

    if any(~isfinite(values))
        error( ...
            "%s에 NaN 또는 Inf가 포함되어 있습니다.", ...
            referenceNames(i));
    end
end

%% 4. Action name을 numeric code로 변환
actionCode = convertActionNameToCode( ...
    string(bestCandidate.name));

%% 5. Simulink command 생성
% Simulink로 넘길 구조체에는 문자열을 넣지 않고
% numeric/logical 데이터만 저장한다.

cmd.decisionValid = logical(bestCandidate.isValid);
cmd.actionCode = actionCode;

cmd.targetD = double(bestCandidate.targetD);
cmd.targetV = double(bestCandidate.targetV);

cmd.sampleTime = double(decision.dt);
cmd.numRefPoints = uint16(numRefPoints);

cmd.timeRef = timeRef;

cmd.sRef = sRef;
cmd.dRef = dRef;
cmd.vRef = vRef;

cmd.xRef = xRef;
cmd.yRef = yRef;
cmd.yawRef = yawRef;

end


function actionCode = convertActionNameToCode(actionName)
% convertActionNameToCode
% action string을 Simulink-friendly uint8 code로 변환한다.

switch actionName
    case "MAINTAIN_LINE"
        actionCode = uint8(1);

    case "OVERTAKE_INSIDE"
        actionCode = uint8(2);

    case "OVERTAKE_OUTSIDE"
        actionCode = uint8(3);

    case "RETURN_TO_LINE"
        actionCode = uint8(4);

    case "EMERGENCY_STOP"
        actionCode = uint8(0);

    otherwise
        error( ...
            "지원하지 않는 actionName입니다: %s", ...
            actionName);
end

end