# `setup_data.R`

Source: [`1_Data_Cleaning/setup_data.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/setup_data.R)

The script you run to download the datasets. It finds the repo, loads every helper in `1_Functions/`, defines [`setup_data`](setup_data) and runs it.

## How to run

**RStudio:** open `ai_learning.Rproj`, open `1_Data_Cleaning/setup_data.R` and click **Source**
(running it line by line also works).

**Terminal** (from any folder):

```bash
Rscript 1_Data_Cleaning/setup_data.R
```

## Command-line options

| Option | Effect |
|---|---|
| *(none)* | Interactive Amazon menu, then IMDB. Without a terminal, downloads `All_Beauty` instead of showing the menu. |
| `--amazon-categories CAT ...` | Download these Amazon categories without the menu. `all` = every category. |
| `--no-amazon-meta` | With `--amazon-categories`, skip item metadata. |
| `--skip-amazon` | Don't download Amazon data. |
| `--skip-imdb` | Don't download IMDB data. |
| `--overwrite` | Re-download files that already exist. |
| `--list-amazon` | Print the Amazon table (sizes, what you have) and exit. |
| `--help`, `-h` | Print usage and exit. |

Examples:

```bash
Rscript 1_Data_Cleaning/setup_data.R --amazon-categories Software Video_Games --skip-imdb
```

```bash
Rscript 1_Data_Cleaning/setup_data.R --list-amazon
```

## How it finds the repo

The script needs to know where it is saved to load `1_Functions/`. It tries, in order:

1. the file path given to `Rscript`;
2. the file being read by `source()` (also RStudio's **Source** button);
3. the file open in the RStudio editor (when running line by line; needs the `rstudioapi` package);
4. the working directory.

From each candidate it walks up the folders until it finds one containing
`1_Data_Cleaning/1_Functions`. If none matches, it stops and asks you to open `ai_learning.Rproj`
or `setwd()` to the repo.

## Sections of the script

1. **Find this repo and load the helper functions**: described above.
2. **Setup**: defines [`setup_data`](setup_data).
3. **Run**: parses command-line options with [`parse_args`](parse_args) and calls
   [`setup_data`](setup_data) (or [`print_status_table`](print_status_table) for `--list-amazon`).
   Under `Rscript`, the exit status is `0` on success and `1` on failure.

## Functions

| Function | Description |
|---|---|
| [`setup_data`](setup_data) | Downloads every dataset into `0_Data/`. This is what runs when you source or `Rscript` the setup script. |
