# `utils.R`

Source: [`1_Data_Cleaning/1_Functions/utils.R`](https://github.com/ben-rocheteau/ai_learning/blob/main/1_Data_Cleaning/1_Functions/utils.R)

General helpers: package checks, downloads, size lookups, prompts and command-line parsing. Also defines `REQUIRED_PACKAGES` (`curl`, `jsonlite`).

## Functions

| Function | Description |
|---|---|
| [`%\|\|%`](null-default-operator) *(internal)* | Returns `a`, or `b` when `a` is `NULL`. Base R only has this operator from 4.4, so it is defined here for older versions. |
| [`check_packages`](check_packages) *(internal)* | Stops with a ready-to-paste `install.packages()` command if required packages are missing. |
| [`human_size`](human_size) *(internal)* | Formats a byte count for display. |
| [`remote_sizes`](remote_sizes) *(internal)* | Asks the server how big each file is, without downloading it. |
| [`download_file`](download_file) *(internal)* | Downloads one file with a progress bar, safely. |
| [`can_prompt`](can_prompt) *(internal)* | Tells whether a person can answer questions. |
| [`ask`](ask) *(internal)* | Asks the user a question and returns the typed line. |
| [`parse_args`](parse_args) *(internal)* | Minimal command-line parser for `Rscript` options. |
| [`flag`](flag) *(internal)* | Checks whether a value-less flag was given. |
| [`category_arg`](category_arg) *(internal)* | Turns a category option into a vector of category names. |
