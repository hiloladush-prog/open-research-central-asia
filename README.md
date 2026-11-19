# Open Research Central Asia

Open-source quantitative research tools, reproducible **R** and **Stata** workflows, and research resources for **Central Asia**: Kazakhstan, the Kyrgyz Republic, Tajikistan, Turkmenistan and Uzbekistan.

The project has two goals:

1. **Research**: give researchers working on the region a clean, documented starting point (data access, cleaning, panel econometrics) that can be extended and cited.
2. **Teaching**: give students and lecturers ready-to-run examples, where every line of code is commented and every modelling choice is explained.

---

## What is here

```
open-research-central-asia/
├── R/                        R workflow (run in order, or use run_all.R)
│   ├── 00_setup.R            packages, paths, countries, indicators
│   ├── 01_download_wdi.R     download World Development Indicators
│   ├── 02_clean_panel.R      build an analysis-ready country-year panel
│   ├── 03_descriptives.R     summary tables and figures
│   ├── 04_panel_regression.R pooled OLS → fixed effects → two-way FE
│   ├── run_all.R             run everything with one command
│   └── utils/
│       └── simulate_panel.R  simulated data for offline teaching/testing
├── stata/                    the same workflow in Stata (.do files)
├── data/
│   ├── raw/                  downloaded data (not tracked by git)
│   └── processed/            cleaned data (not tracked by git)
├── output/
│   ├── figures/              graphs (PNG)
│   └── tables/               tables (CSV / TXT / RTF)
├── docs/
│   └── data-sources.md       guide to data on Central Asia
└── teaching/
    └── exercise-01-remittances-growth.md   student worksheet
```

## The first worked example: remittances and growth

Central Asia includes some of the most remittance-dependent economies in the world, with most migrant earnings coming from Russia. The first workflow asks a simple question:

> Is a higher remittance share of GDP associated with faster GDP per capita growth, once we account for permanent differences between countries and for shocks common to all countries in a given year?

The regression script builds a **model ladder**, where each model fixes a weakness of the one before:

| Model | What it adds | Problem it addresses |
|---|---|---|
| (1) Pooled OLS | – | baseline; ignores that countries differ |
| (2) Country fixed effects | country dummies | time-invariant country differences (geography, institutions) |
| (3) Two-way fixed effects | + year dummies | common shocks (2009 crisis, 2014–15 rouble fall, COVID-19) |
| (4) TWFE with lagged remittances | remittances at *t*–1 | same-year reverse causality (partly) |
| (5) TWFE with interaction | remittances × Central Asia | is the association different in the region? |

Standard errors are **Driscoll–Kraay** (robust to serial and cross-country correlation), with country-clustered errors and a Hausman test reported alongside.

These are **associations, not causal effects**. Natural extensions toward causal identification include instruments based on economic conditions in migrant-host countries (e.g. Russian GDP or the rouble exchange rate interacted with pre-period migration exposure) and difference-in-differences designs around migration-policy changes.

## Quick start

### R (version 4.1 or later)

```r
# From the project root (the folder containing this README):
source("R/run_all.R")              # downloads real WDI data
```

or from a terminal:

```bash
Rscript R/run_all.R                # real data (needs internet)
Rscript R/run_all.R simulate       # simulated data (works offline)
```

Missing packages are installed automatically the first time.

### Stata (version 16 or later)

```stata
cd "path/to/open-research-central-asia"
do stata/run_all.do
```

The setup file installs `wbopendata`, `xtscc` and `estout` from SSC if needed.

### Offline / classroom mode

`R/utils/simulate_panel.R` writes a **simulated** data set with exactly the same structure as the real download. The true effect of remittances is known (0.15), so students can see for themselves that pooled OLS is biased and fixed effects recover the truth. See `teaching/exercise-01-remittances-growth.md`.

## Data

The default data source is the World Bank's **World Development Indicators** (licensed CC BY 4.0). Indicators used:

| Variable | WDI code | Description |
|---|---|---|
| `gdp_pc` | NY.GDP.PCAP.KD | GDP per capita, constant US$ |
| `gdp_pc_growth` | NY.GDP.PCAP.KD.ZG | GDP per capita growth, annual % |
| `remit_gdp` | BX.TRF.PWKR.DT.GD.ZS | Personal remittances received, % of GDP |
| `trade_gdp` | NE.TRD.GNFS.ZS | Trade, % of GDP |
| `inflation` | FP.CPI.TOTL.ZG | Inflation, consumer prices, annual % |
| `hh_cons_pc` | NE.CON.PRVT.PC.KD | Household final consumption per capita, constant US$ |
| `unemployment` | SL.UEM.TOTL.ZS | Unemployment, % of labour force (ILO modelled) |
| `population` | SP.POP.TOTL | Population, total |

The comparison group is Armenia, Azerbaijan, Belarus, Georgia, Moldova, Mongolia, Russia and Ukraine. Change the country list, years or indicators in `R/00_setup.R` or `stata/00_setup.do`.

**Turkmenistan** has many gaps in international databases; check `output/tables/missing_by_country.csv` before drawing conclusions about it.

For household surveys, national statistics and other sources on the region, see **[docs/data-sources.md](docs/data-sources.md)**.

## Reproducibility principles

- Raw data are never edited by hand; every change is in code.
- Each download is saved with a log recording the date and package version.
- One command (`run_all`) goes from raw data to final tables.
- Random seeds are fixed.
- Data and outputs are regenerated, not committed, so the repository stays small and always matches the code.

## Roadmap

Planned next steps (contributions welcome):

- [ ] Household-survey workflow (e.g. L2CU, Life in Kyrgyzstan, MICS): survey weights, clustering, poverty measures
- [ ] Causal-inference examples: instrumental variables, difference-in-differences, event studies
- [ ] Regional (oblast/viloyat-level) data from national statistics agencies
- [ ] Quarto/R Markdown teaching notebooks with exercises and solutions
- [ ] Uzbek and Russian translations of the teaching materials

## Contributing

Issues and pull requests are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md).

## Citation

If you use this material, please cite it using the information in [CITATION.cff](CITATION.cff) (GitHub shows a "Cite this repository" button).

## Licence

Code is released under the [MIT Licence](LICENSE). Data remain under the licences of their original providers.
