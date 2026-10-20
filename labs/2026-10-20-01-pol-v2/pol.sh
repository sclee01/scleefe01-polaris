# 2026-10-19 lab01: 로컬 Polaris REST
# 사용: source pol.sh → pol_login → pol <METHOD> <경로> [JSON]

POL=http://localhost:8181/api

pol_login() {
    TOKEN=$(curl -s "$POL/catalog/v1/oauth/tokens" \
        -d grant_type=client_credentials \
        -d client_id=root \
        -d client_secret=s3cr3t \
        -d scope=PRINCIPAL_ROLE:ALL | jq -r .access_token)
    echo "token: ${TOKEN:0:20}..."
}

pol() {
    curl -s -X "$1" "$POL$2" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        ${3:+-d "$3"} \
        -w "%{http_code}" | jq
}