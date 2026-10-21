# 2026-10-21 write-data diff

## 질문
데이터를 쓰면 데이터 파일이 Polaris를 거치나?

## 예측 / 결과
- 결과: 거치지 않는다. 데이터 파일은 엔진(pyiceberg)이 저장소에 직접 쓴다.
  manifest, manifest list도 엔진이 쓴다. Polaris는 새 metadata.json을 쓰고 포인터만 옮긴다.
- 근거: 커밋 요청의 manifest-list 칸에 이미 파일 경로가 들어 있다 = 커밋 전에 이미 써져 있음

| 누가 | 쓰는 파일 |
|---|---|
| 엔진 (pyiceberg) | data(.parquet), manifest(-m0.avro), manifest list(snap-*.avro) |
| Polaris | metadata.json + 장부 포인터 교체 |

## 엔진은 어떻게 쓰나 (sync)
1. loadTable: Polaris가 현재 metadata.json 위치, 테이블 위치를 알려줌
2. 엔진이 저장소에 직접 씀: parquet → manifest → manifest list
3. commit: "base(내가 본 버전) 위에 이 스냅샷 추가"
4. Polaris: base가 아직 최신이면 새 metadata.json + 포인터 교체, 아니면 실패 → 엔진이 재시도
- 미리 허락받지 않고, 커밋 순간에 최신인지 검사 (낙관적 동시성)

## 1회차 새 파일 (diff before.txt after.txt)
data/00000-0-db65...parquet               데이터 3줄
metadata/db65...-m0.avro                  manifest
metadata/snap-6468...-0-db65....avro      manifest list
metadata/00001-eb04...metadata.json       새 테이블 설명서
metadata/.00001-eb04...metadata.json.crc  체크섬
→ 의미 있는 파일 4개 + 체크섬 1개

## 파일 관계
metadata.json → snapshot (1:1) manifest list (1:N) manifest (1:N) data

## 2회차에서 달라진 것
- 새 파일 수: 4개 + 체크섬 1개 (1회차와 같음)
- 스냅샷 수: 2 (jq '.snapshots | length'). 커밋마다 1개씩 쌓임, 이전 것 안 지움
- sequence-number: 1, 2 (커밋 순서 번호), last-sequence-number: 2
- manifest 재사용: 새 manifest list가 이전 manifest + 새 manifest 2개를 가리킴 (이론, 직접 확인은 아직)

## 헷갈렸던 것
- 00002가 2개: 서버 재시작마다 장부가 비워지고 같은 위치에 테이블을 새로 만들어서,
  이전 테이블 파일이 아무도 안 가리키는 고아 파일로 남음
  (오늘 테이블: 00000-80e6 → 00001-eb04 → 00002-c98f)
- jq: .snapshot(단수)은 없는 필드라 null. 정확한 이름은 .snapshots