# LEGO Sets Dataset Versioning

This project simulates the evolution of a dataset over time, including row insertions, deletions, updates, and schema changes (column additions/removals).

It is designed for testing and demonstrating dataset versioning systems.

## Project Structure

- `lego_sets.csv` — The original LEGO sets dataset (CSV format).
- `rebuild.ps1` — PowerShell script that uses DuckDB to generate multiple versioned Parquet files from the original dataset.
- `generated/` — Folder containing the generated versioned datasets as Parquet files (`lego_sets_v1.parquet` to `lego_sets_v10.parquet`).

## How It Works

The `rebuild.ps1` script:
- Cleans and prepares the `generated/` folder.
- Uses DuckDB SQL queries to create 10 different versions of the dataset, each simulating real-world changes:
  - **Row insertions** (adding new LEGO sets for certain years)
  - **Row deletions** (removing sets by theme, year, or other criteria)
  - **Row updates** (modifying set names, piece counts, etc.)
  - **Column changes** (renaming, adding, or removing columns)
- Each version is saved as a Parquet file in the `generated/` directory.

## Versioning Logic

Each version (`lego_sets_v1.parquet` to `lego_sets_v10.parquet`) represents a different stage in the dataset's evolution, with changes such as:
- Filtering by year
- Inserting new rows for specific periods
- Deleting rows by theme or other criteria
- Updating values (e.g., set names, piece counts)
- Adding or renaming columns

See `rebuild.ps1` script for the exact DuckDB SQL queries and logic for each version.

## License

This project is for demonstration and testing purposes only. LEGO® is a trademark of the LEGO Group, which does not sponsor, authorize, or endorse this project.

> Made with GitHub Copilot and GPT-4.1.