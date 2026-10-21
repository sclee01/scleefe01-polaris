from pyiceberg.catalog import load_catalog
import pyarrow as pa


catalog = load_catalog(
    "polaris",
    type="rest",
    uri="http://localhost:8181/api/catalog",
    credential="root:s3cr3t",
    scope="PRINCIPAL_ROLE:ALL",
    warehouse="lab01",
)


table = catalog.load_table("sales.orders")
print("before", table.metadata_location)

schema = pa.schema([
    pa.field("id", pa.int64(), nullable=False),
    pa.field("amount", pa.float64()),
])
rows = pa.table({"id": [1, 2, 3], "amount": [10.0, 20.0, 30.0]}, schema=schema)

table.append(rows)
print("after: ", table.metadata_location)
print(table.scan().to_arrow())