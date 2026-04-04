# 🏎️ Path Planning for Autonomous Race Cars
SMYD 9th Cohort Project | A Team 

본 프로젝트는 자율주행 레이싱카의 성능을 극대화하기 위해, 차량의 동역학적 한계를 고려하여 최소 랩타임(Minimum Lap Time)을 달성하는 최적 주행 경로를 생성하고 검증하는 것을 목표로 합니다. 

# 📅 Project Overview기간: 2026년 3월 29일 ~ 2026년 8월 7일 
주요 목표: 트랙 형상 및 동역학 모델을 고려한 Racing Line 최적화 실제 F1 트랙 데이터를 활용한 알고리즘 검증 및 성능 평가 최소 5개 이상의 트랙에 대한 랩타임 분석 수행 

# 🛠️ Tech Stack & Models

## Language & Environment: MATLAB 
- Vehicle Model: Bicycle Kinematics Model을 기반으로 한 차량 단순화 및 동역학 모델링 (상태 벡터 $[x, y, \theta]$ 정의) 
- Optimization: MATLAB Optimization Toolbox를 활용한 비선형 최적화(Nonlinear Optimization) 문제 구성
- Key Algorithm: Curvature 기반 Racing Line Optimization Forward/Backward Pass를 통한 Velocity Profile 계산 

# 📈 Methodology
- Track Discretization: 실제 Racetrack Database를 사용하여 트랙 데이터를 추출하고 이산화합니다. 
- Path Optimization: 중앙선(Center Line) 대비 주행 거리를 단축하고 곡률을 최소화하는 최적 경로를 도출합니다. 
- Velocity Profiling: 도출된 경로 위에서 차량이 낼 수 있는 한계 속도를 계산하여 물리적 주행 가능성을 확보합니다. 
- Evaluation: 시뮬레이션을 통해 최종 랩타임을 산출하고 주행 시나리오를 시각화합니다. 

# 👥 Team Information
### 이화여자대학교 휴먼기계바이오공학부
- 옥유진: 
- 조선영: 
- 나원정: 
