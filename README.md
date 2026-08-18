# SimBar - 펍/바 경영 시뮬레이션 게임

2D 도트 스타일의 cozy 펍 경영 시뮬레이션. 인디 밴드 라이브 공연 섭외와 운영을 다룹니다.

## 실행 방법

1. **Godot Engine 4.4+** 설치
2. 프로젝트 폴더를 Godot에서 열기
   - Godot 실행 → "Import" → `E:\simbar\project.godot` 선택
3. 실행: F5

## 게임 개요

- **펍 운영**: 손님 주문 처리, 음료 제조, 매출 관리
- **밴드 섭외**: 인디 밴드 라이브 공연 기획 및 계약
- **콘서트 이벤트**: 공연 일정 관리, 관객 동원, 수익 발생
- **데스크톱 위젯**: 오른쪽 하단에 작게 띄워두고 틱택톡처럼 사용 가능
- **모바일 지원**: 화면 비율 유지, 터치 인터페이스

## 프로젝트 구조

```
E:\simbar/
├── project.godot
├── scenes/
│   ├── main/
│   │   └── main.tscn          # 메인 게임 씬
│   ├── ui/
│   │   └── ui.tscn            # UI 씬
│   └── entities/
│       └── customer.tscn      # 손님 엔티티
├── scripts/
│   ├── main.gd                # 메인 컨트롤러
│   ├── ui.gd                  # UI 관리
│   ├── pub_manager.gd         # 펍 운영 로직
│   ├── band_manager.gd        # 밴드 관리
│   ├── concert_manager.gd     # 콘서트 관리
│   ├── systems/
│   │   ├── time_system.gd     # 시간 시스템
│   │   └── game_state.gd      # 게임 상태/세이브
│   ├── data/
│   │   ├── game_time.gd       # 시간 구조체
│   │   ├── drink.gd           # 음료 데이터
│   │   ├── drink_database.gd  # 음료 DB
│   │   ├── band.gd            # 밴드 데이터
│   │   └── band_database.gd   # 밴드 DB
│   └── entities/
│       └── customer.gd        # 손님 스크립트
└── assets/
    ├── pixel_font/            # 픽셀 폰트
    └── sprites/               # 도트 스프라이트
```

## 핵심 시스템

### 시간 시스템
- 게임 내 하루 24시간, 분 단위 진행
- 개장 시간: 14:00 ~ 02:00
- 시간 가속 조절 가능

### 펍 운영
- 손님 생성 및 주문 처리
- 음료 판매 및 수익
- 평판(reputation) 시스템

### 밴드 & 콘서트
- 10종류의 인디 밴드 데이터
- 스킬/인기도/출연료/예상 수익
- 공연 성공률 = 밴드 스킬 + 인기도 + 시설 레벨

## 조작

- **마우스 왼쪽 클릭**: 손님 선택/서빙
- **ESC**: 저장 및 종료
- **Book Band**: 밴드 섭외 UI
- **Menu**: 저장/새 게임

## 개발 상태

기본 로직 구조 완성. 추후 추가 예정:
- 픽셀 아트 스프라이트 교체
- 사운드 시스템
- 업그레이드 메뉴 (시설/인테리어)
- 다양한 손님 타입
- 날씨/계절 시스템
