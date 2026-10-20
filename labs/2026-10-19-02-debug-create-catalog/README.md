# lab02: 카탈로그 생성을 코드에서 따라가기

## 입구 찾기
grep -rn '/api/management/v1/catalogs' --include='*.java' . | grep -v test
→ api/management-service/build/generated-openapi/.../PolarisCatalogsApi.java:66
- 밖에서 본 URL로 넓게 찾고, 보내는 쪽(test, 문서)을 빼면서 좁힘
- 입구는 src/가 아니라 build/generated-openapi (빌드 때 spec에서 자동 생성)

## 지나간 길
PolarisCatalogsApi          문지기 (로그 찍고 넘김)
Delegator                   포장지 (앞뒤 이벤트)
PolarisServiceImpl          검사관 (입력 검증)
PolarisAdminService         일꾼 (엔티티 만들고 저장 요청)
metaStoreManager            창고 (persistence)
- 문지기 앞에는 Quarkus 인터셉터 4겹 (@RolesAllowed, @Timed, @Timeout, @Valid 하나씩)
- 전체 스택: 문지기 breakpoint → Frames 깔때기로 펼침 → Copy Stack

## 디버거 세팅
- IntelliJ: Run > Edit Configurations > + > Remote JVM Debug
- Attach to remote JVM / Socket / localhost:5005 / classpath 기본값
- 서버: ./gradlew run 이 5005에서 대기 (로그: Listening for transport dt_socket at address: 5005)

## 예측 vs 결과
- 클래스 몇 개? 예측 5개 이상 → 스택 약 56줄, Polaris 코드는 몇 줄뿐이고 대부분 Quarkus
- 누가 먼저? 예측 → 결과: Delegator(포장지)가 일꾼보다 먼저
- return에 breakpoint가 왜 안 멈췄나: 예외가 터지면 남은 줄을 건너뛰고
  catch(IcebergExceptionMapper)로 바로 감 → return 실행 안 됨 → 409