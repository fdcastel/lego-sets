$ErrorActionPreference = 'Stop'

# Set paths
$lego_sets_csv_path = "./lego_sets.csv"
$generated_path = "./generated"

# Clean generated folder
if (Test-Path $generated_path) {
    Remove-Item "$generated_path/*" -Recurse -Force
} else {
    New-Item -ItemType Directory -Path $generated_path
}


# v1: Initial version, based on data up to 2000.
Write-Host "Generating v1..."
$v1_path = "$generated_path/lego_sets_v1.parquet"
$query1 = "COPY (SELECT set_id, name, year, theme, category as product_line, pieces, minifigs, agerange_min, bricksetURL, thumbnailURL, imageURL FROM read_csv_auto('$lego_sets_csv_path') WHERE year <= 2000) TO '$v1_path' (FORMAT PARQUET);"
duckdb -c $query1

# v2: Inserts only. Adds data from 2001 to 2005.
Write-Host "Generating v2..."
$v2_path = "$generated_path/lego_sets_v2.parquet"
$query2 = "COPY (SELECT * FROM read_parquet('$v1_path') UNION ALL SELECT set_id, name, year, theme, category as product_line, pieces, minifigs, agerange_min, bricksetURL, thumbnailURL, imageURL FROM read_csv_auto('$lego_sets_csv_path') WHERE year > 2000 AND year <= 2005) TO '$v2_path' (FORMAT PARQUET);"
duckdb -c $query2

# v3: Deletes only. Deletes all sets from the 'Star Wars' theme from 1999.
Write-Host "Generating v3..."
$v3_path = "$generated_path/lego_sets_v3.parquet"
$query3 = "COPY (SELECT * FROM read_parquet('$v2_path') WHERE NOT (theme = 'Star Wars' AND year = 1999)) TO '$v3_path' (FORMAT PARQUET);"
duckdb -c $query3

# v4: Updates only. Updates all 'LEGOLAND' sets from 1970.
Write-Host "Generating v4..."
$v4_path = "$generated_path/lego_sets_v4.parquet"
$query4 = "COPY (SELECT set_id, CASE WHEN theme = 'LEGOLAND' AND year = 1970 THEN 'UPDATED ' || name ELSE name END as name, year, theme, product_line, pieces, minifigs, agerange_min, bricksetURL, thumbnailURL, imageURL FROM read_parquet('$v3_path')) TO '$v4_path' (FORMAT PARQUET);"
duckdb -c $query4

# v5: Inserts and Deletes.
Write-Host "Generating v5..."
$v5_path = "$generated_path/lego_sets_v5.parquet"
$query5 = "COPY (SELECT * FROM read_parquet('$v4_path') WHERE theme != 'Bionicle' UNION ALL SELECT set_id, name, year, theme, category as product_line, pieces, minifigs, agerange_min, bricksetURL, thumbnailURL, imageURL FROM read_csv_auto('$lego_sets_csv_path') WHERE year > 2005 AND year <= 2010) TO '$v5_path' (FORMAT PARQUET);"
duckdb -c $query5

# v6: Inserts and Updates.
Write-Host "Generating v6..."
$v6_path = "$generated_path/lego_sets_v6.parquet"
$query6 = "COPY (WITH v5_data AS (SELECT * FROM read_parquet('$v5_path')) SELECT set_id, CASE WHEN theme = 'Creator' THEN 'UPDATED ' || name ELSE name END as name, year, theme, product_line, pieces, minifigs, agerange_min, bricksetURL, thumbnailURL, imageURL FROM v5_data UNION ALL SELECT set_id, name, year, theme, category as product_line, pieces, minifigs, agerange_min, bricksetURL, thumbnailURL, imageURL FROM read_csv_auto('$lego_sets_csv_path') WHERE year > 2010 AND year <= 2012) TO '$v6_path' (FORMAT PARQUET);"
duckdb -c $query6

# v7: Deletes and Updates.
Write-Host "Generating v7..."
$v7_path = "$generated_path/lego_sets_v7.parquet"
$query7 = "COPY (SELECT set_id, name, year, theme, product_line, CASE WHEN theme = 'Duplo' THEN pieces * 2 ELSE pieces END as pieces, minifigs, agerange_min, bricksetURL, thumbnailURL, imageURL FROM read_parquet('$v6_path') WHERE year != 2006) TO '$v7_path' (FORMAT PARQUET);"
duckdb -c $query7

# v8: Inserts, Deletes, and Updates.
Write-Host "Generating v8..."
$v8_path = "$generated_path/lego_sets_v8.parquet"
$query8 = "COPY (WITH v7_data AS (SELECT * FROM read_parquet('$v7_path') WHERE theme != 'Friends') SELECT set_id, CASE WHEN theme = 'Technic' THEN 'SUPER ' || name ELSE name END as name, year, theme, product_line, pieces, minifigs, agerange_min, bricksetURL, thumbnailURL, imageURL FROM v7_data UNION ALL SELECT set_id, name, year, theme, category as product_line, pieces, minifigs, agerange_min, bricksetURL, thumbnailURL, imageURL FROM read_csv_auto('$lego_sets_csv_path') WHERE year > 2012 AND year <= 2015) TO '$v8_path' (FORMAT PARQUET);"
duckdb -c $query8

# v9: Column rename and addition.
Write-Host "Generating v9..."
$v9_path = "$generated_path/lego_sets_v9.parquet"
$query9 = "COPY (SELECT l.set_id, l.name, l.year, l.theme, r.subtheme, r.themeGroup, l.product_line as category, l.pieces, l.minifigs, l.agerange_min, l.bricksetURL, l.thumbnailURL, l.imageURL FROM read_parquet('$v8_path') l LEFT JOIN read_csv_auto('$lego_sets_csv_path') r ON l.set_id = r.set_id) TO '$v9_path' (FORMAT PARQUET);"
duckdb -c $query9

# v10: Final version, with all data and columns.
Write-Host "Generating v10..."
$v10_path = "$generated_path/lego_sets_v10.parquet"
$query10 = "COPY (SELECT * FROM read_csv_auto('$lego_sets_csv_path')) TO '$v10_path' (FORMAT PARQUET);"
duckdb -c $query10

Write-Host "All versions generated successfully!"
