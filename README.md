# 🏎️ Cost-Based Overtaking Decision for Autonomous Race Cars

SMYD 9th Cohort Project | Team A

본 프로젝트는 자율주행 레이싱 환경에서 ego 차량이 상대 차량의 위치와 움직임을 고려하여 추월 여부를 판단하는 알고리즘을 구현하는 것을 목표로 합니다.

초기 단계에서는 단일 차량 기준의 `velocity profile`과 `lap time`을 계산하여 baseline을 구축하였고, 이후 `Frenet coordinates`를 기반으로 ego 차량과 opponent 차량을 함께 시뮬레이션하는 구조로 확장하였습니다.

현재 구현 범위는 Monza 트랙 데이터를 기반으로 한 트랙 전처리, 곡률 계산, 속도 프로파일 생성, Frenet 좌표 변환, opponent 차량 시뮬레이션, ego 차량과의 gap 계산, 2D 애니메이션 및 GIF 저장 기능까지입니다.

---

## 📅 프로젝트 개요

* **프로젝트 기간**: 2026.03.29 ~ 2026.08.07
* **사용 트랙**: Monza Circuit
* **개발 환경**: MATLAB
* **최종 목표**: Frenet 좌표계와 cost function을 활용한 자율주행 레이싱 차량의 추월 판단 알고리즘 구현

---

## 🎯 프로젝트 목표

본 프로젝트의 주요 목표는 다음과 같습니다.

1. 실제 레이싱 트랙 데이터를 활용한 자율주행 레이싱 시뮬레이션 환경 구축
2. 단일 차량 기준의 `velocity profile` 및 `lap time` baseline 생성
3. `Frenet coordinates` 기반의 `s`, `d` 위치 표현 구현
4. ego 차량과 opponent 차량의 상대 위치, gap, relative speed 계산
5. 랜덤 opponent 움직임을 포함한 multi-car race simulation 구현
6. candidate action 및 cost function 기반 추월 판단 알고리즘으로 확장

---

## 🛠️ 사용 기술 및 모델

### 개발 환경

* MATLAB
* MATLAB Project
* TUMFTM Racetrack Database

### 차량 모델

차량 모델은 단순화된 `Kinematic Bicycle Model`을 기반으로 구성하였습니다.

상태 벡터는 다음과 같이 정의됩니다.

```text
[x, y, theta]
```

* `x`, `y`: 차량의 전역 좌표 위치
* `theta`: 차량의 heading angle

초기 단계에서는 차량의 기본적인 주행 궤적을 확인하기 위해 bicycle model을 구현하였고, 이후 트랙 기반 시뮬레이션은 Frenet 좌표계를 중심으로 확장하였습니다.

---

## 🧭 전체 구현 흐름

프로젝트는 다음 순서로 구현되었습니다.

```text
1. MATLAB Project 구조 설정
2. Bicycle model 구현 및 테스트
3. Monza 트랙 데이터 로드
4. Track boundary 생성
5. Curvature 계산 및 smoothing
6. Velocity profile 및 lap time 계산
7. Frenet 좌표계 구현
8. Opponent car 시뮬레이션
9. Ego car 추가 및 gap 계산
10. Race animation 및 GIF 저장
11. Candidate action 및 cost-based decision으로 확장 예정
```

---

## 📈 구현 방법

### 1. 트랙 데이터 처리

본 프로젝트에서는 TUMFTM Racetrack Database의 Monza 트랙 데이터를 사용하였습니다.

트랙 데이터에는 다음 정보가 포함됩니다.

```text
x_m, y_m, w_tr_right_m, w_tr_left_m
```

이를 기반으로 다음 과정을 수행합니다.

1. Monza CSV 파일 로드
2. centerline 좌표 추출
3. tangent vector 계산
4. normal vector 계산
5. left boundary 및 right boundary 생성
6. track progress `s` 계산
7. curvature 계산 및 smoothing

---

### 2. 단일 차량 Baseline

multi-car race simulation을 구현하기 전에, 단일 차량 기준의 baseline을 먼저 생성하였습니다.

구현한 항목은 다음과 같습니다.

* curvature profile
* velocity profile
* estimated lap time
* baseline trajectory visualization

`velocity profile`은 곡률 기반 속도 제한과 forward/backward pass를 이용하여 계산하였습니다.

차량 파라미터는 두 가지 모드로 설정할 수 있습니다.

* `conservative`
* `race`

---

### 3. Frenet 좌표계

레이싱 상황에서 차량 간 상대 위치를 쉽게 비교하기 위해 `Frenet coordinates`를 사용하였습니다.

기존 전역 좌표는 다음과 같습니다.

```text
(x, y)
```

Frenet 좌표는 다음과 같습니다.

```text
(s, d)
```

각 변수의 의미는 다음과 같습니다.

* `s`: 트랙 진행 방향을 따라 이동한 거리
* `d`: centerline 기준 lateral offset

본 프로젝트의 부호 기준은 다음과 같습니다.

```text
d = 0  → centerline 위
d > 0  → 트랙 진행 방향 기준 왼쪽
d < 0  → 트랙 진행 방향 기준 오른쪽
```

Frenet 좌표계를 사용하면 ego 차량 기준으로 어떤 차량이 앞에 있는지, 얼마나 떨어져 있는지, 추월 가능한 위치에 있는지를 더 쉽게 판단할 수 있습니다.

---

### 4. Opponent 차량 시뮬레이션

상대 차량은 Frenet 좌표계 기반으로 모델링하였습니다.

각 opponent 차량은 다음 정보를 가집니다.

```text
s
d
v
behaviorType
history
```

* `s`: 트랙 진행 거리
* `d`: lateral offset
* `v`: 차량 속도
* `behaviorType`: 상대 차량의 주행 방식
* `history`: 시각화를 위한 과거 위치 기록

현재 opponent 차량은 실행할 때마다 초기 위치, lateral offset, 속도 일부가 랜덤하게 설정될 수 있습니다. 이를 통해 매 실행마다 다른 주행 상황을 만들 수 있습니다.

---

### 5. Ego 차량 및 Gap 계산

ego 차량 역시 Frenet 좌표계에서 표현됩니다.

매 simulation step마다 ego 차량은 opponent 차량들과의 상대 위치를 비교하여 가장 가까운 앞차를 찾습니다.

계산하는 값은 다음과 같습니다.

* lead opponent
* gap to lead opponent
* relative speed
* look-ahead distance 내 차량 존재 여부

이 단계는 이후 `MAINTAIN_LINE`, `OVERTAKE_INSIDE`, `OVERTAKE_OUTSIDE`, `RETURN_TO_LINE` 등의 candidate action을 평가하기 위한 기반 단계입니다.

---

### 6. Race 종료 조건

초기에는 정해진 시간 `tFinal`까지 시뮬레이션을 실행하는 방식이었지만, 이후 다음과 같은 종료 조건으로 수정하였습니다.

```text
ego 차량과 opponent 차량들이 모두 target lap을 완료하면 race 종료
```

이를 위해 각 차량은 다음 정보를 추가로 관리합니다.

```text
distanceTravelled
completedLaps
hasFinished
finishTime
```

`s` 값은 `mod` 연산으로 인해 트랙 길이 내에서 반복되므로, 실제 완주 여부는 `distanceTravelled`와 `completedLaps`를 별도로 계산하여 판단합니다.

---

### 7. 2D 애니메이션 및 GIF 저장

시뮬레이션 결과는 2D animation으로 확인할 수 있습니다.

구현된 기능은 다음과 같습니다.

* Monza track boundary 표시
* ego 차량 궤적 표시
* opponent 차량 궤적 표시
* 차량 위치 시간 순서대로 animation
* 먼저 완주한 차량은 마지막 위치에 정지
* GIF 파일 저장 가능

생성된 GIF 파일은 용량이 크기 때문에 GitHub에는 포함하지 않습니다.

---

## 📁 프로젝트 구조

```text
SMYD_TeamA/
├── config/
│   ├── vehicleParams.m
│   ├── simParams.m
│   ├── opponentParams.m
│   └── raceParams.m
│
├── data/
│   ├── README.md
│   └── external/
│       └── tum_racetrack_database/
│           └── tracks/
│               └── Monza.csv
│
├── src/
│   ├── vehicle/
│   │   ├── createBicycleModel.m
│   │   ├── bicycleStateDerivative.m
│   │   └── simulateBicycleModel.m
│   │
│   ├── track/
│   │   ├── loadTrack.m
│   │   ├── loadTUMTrack.m
│   │   ├── preprocessTrack.m
│   │   ├── computeTrackNormals.m
│   │   ├── computeTrackBoundaries.m
│   │   ├── findNearestTrackPoint.m
│   │   └── computeTrackProgress.m
│   │
│   ├── velocity/
│   │   ├── computeCurvature.m
│   │   └── velocityProfile.m
│   │
│   ├── evaluation/
│   │   └── computeLapTime.m
│   │
│   ├── frenet/
│   │   ├── globalToFrenetCustom.m
│   │   └── frenetToGlobalCustom.m
│   │
│   ├── opponent/
│   │   ├── createOpponentCar.m
│   │   ├── createOpponentFleet.m
│   │   ├── updateOpponentState.m
│   │   └── updateOpponentFleet.m
│   │
│   └── race/
│       ├── createEgoCar.m
│       ├── updateEgoState.m
│       └── findLeadOpponent.m
│
├── viz/
│   ├── plotTrack.m
│   ├── plotBicycleTrajectory.m
│   ├── plotCurvature.m
│   ├── plotVelocityProfile.m
│   ├── plotOpponentCars.m
│   ├── plotRaceCars.m
│   └── animateRace2D.m
│
├── tests/
├── project_startup.m
└── README.md
```

---

## 📌 GitHub 업로드 관련 안내

다음 파일들은 실행 결과물이므로 GitHub에 포함하지 않습니다.

```text
data/results/
data/processed_tracks/
*.mat
*.gif
*.mp4
```

위 파일들은 MATLAB script를 실행하면 다시 생성할 수 있습니다.

---

## 👥 Team

SMYD 9th Cohort
Team A
