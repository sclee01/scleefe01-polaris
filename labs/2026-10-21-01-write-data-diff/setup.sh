source /home/ec2-user/next/scleefee01-polaris/labs/2026-10-20-01-pol-v2/pol.sh
pol_login

echo "== 1. catalog"
pol POST /management/v1/catalogs '{"catalog":{
  "name":"lab01","type":"INTERNAL",
  "properties":{"default-base-location":"file:///tmp/polaris/lab01"},
  "storageConfigInfo":{"storageType":"FILE",
    "allowedLocations":["file:///tmp/polaris/lab01"]}}}'

echo "== 2. grant (pyiceberg 403 방지)"
pol PUT /management/v1/catalogs/lab01/catalog-roles/catalog_admin/grants \
  '{"grant":{"type":"catalog","privilege":"CATALOG_MANAGE_CONTENT"}}'

echo "== 3. namespace"
pol POST /catalog/v1/lab01/namespaces '{"namespace":["sales"]}'

echo "== 4. table"
pol POST /catalog/v1/lab01/namespaces/sales/tables '{
  "name":"orders",
  "schema":{"type":"struct","fields":[
    {"id":1,"name":"id","type":"long","required":true},
    {"id":2,"name":"amount","type":"double","required":false}]}}' | tail -3