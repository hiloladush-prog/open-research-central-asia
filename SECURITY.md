# Security policy

## Reporting a problem

If you find a security problem (for example, a script that could expose credentials, download from an unsafe source, or overwrite files outside the project folder), please **do not open a public issue**.

Instead, report it privately through GitHub: go to the **Security** tab of this repository and choose **Report a vulnerability**.

You should receive a reply within 14 days.

## Data protection

- **Never commit personal or restricted data** (survey microdata, student records, API keys, passwords). The `.gitignore` excludes `data/` and `output/` contents and `.Renviron` / `.env` files, but please check before every commit.
- If you accidentally commit sensitive data, report it as above; deleting the file in a new commit does **not** remove it from the history.
- Survey microdata (MICS, DHS, LiK, L2CU and similar) are subject to their providers' terms of use and must not be redistributed through this repository.

## Supported versions

Only the latest version on the `main` branch is maintained.
