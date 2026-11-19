# Data sources for research on Central Asia

A practical guide to where data on Kazakhstan, the Kyrgyz Republic, Tajikistan, Turkmenistan and Uzbekistan can be found, what each source is good for, and how to access it.

*Last checked: November 2026. Websites and access rules change; please open an issue if a link breaks.*

---

## 1. Cross-country macro data (open, easy to download)

| Source | Good for | Access from code |
|---|---|---|
| **World Bank – World Development Indicators** (data.worldbank.org) | GDP, remittances, trade, population, education, health; long annual series | R: `WDI`; Stata: `wbopendata` (both used in this repo) |
| **IMF – World Economic Outlook / IFS** (data.imf.org) | Macroeconomic forecasts, balance of payments, exchange rates | R: `imfr`; manual download |
| **ILOSTAT** (ilostat.ilo.org) | Labour-market indicators | R: `Rilostat` |
| **UN Comtrade** (comtradeplus.un.org) | Bilateral trade flows | R: `comtradr` (API key) |
| **Penn World Table** (Groningen Growth and Development Centre) | Growth accounting, PPP comparisons | Direct download (.dta / .xlsx) |

**Tip:** for Turkmenistan, many indicators are missing or stop early. Always report missing data by country.

## 2. National statistics agencies

| Country | Agency | Website |
|---|---|---|
| Kazakhstan | Bureau of National Statistics (Agency for Strategic Planning and Reforms) | stat.gov.kz |
| Kyrgyz Republic | National Statistical Committee | stat.gov.kg |
| Tajikistan | Agency on Statistics under the President | stat.tj |
| Turkmenistan | State Committee of Turkmenistan on Statistics | stat.gov.tm |
| Uzbekistan | Statistics Agency under the President | stat.uz |

These agencies publish **regional (oblast / viloyat) data**, which give much more variation than country-level panels. Most tables are in Excel; English versions are often less complete than the Russian or national-language pages.

Uzbekistan also runs an open-data portal; the statistics agency lists the **national open data portal (data.egov.uz)** among its links, and its site includes a **survey microdata** section.

## 3. Household and individual surveys (microdata)

| Survey | Country / years | Notes | Access |
|---|---|---|---|
| **Listening to the Citizens of Uzbekistan (L2CU)** | Uzbekistan, 2018–2025 | World Bank monthly phone panel of about 1,500 households: migration, prices, employment, public services, attitudes | World Bank Microdata Library (free registration) |
| **Life in Kyrgyzstan (LiK)** | Kyrgyz Republic, 2010 onwards (several waves) | Nationally representative individual panel: migration, labour, agriculture, well-being | Publicly available for non-profit research and teaching; see lifeinkyrgyzstan.org and the IZA International Data Service Center |
| **UNICEF MICS** | All five countries, various rounds | Child and maternal health, education, early childhood development | mics.unicef.org (free registration) |
| **Demographic and Health Surveys (DHS)** | Selected countries and years | Fertility, child health, nutrition | dhsprogram.com (free registration) |
| **EBRD Life in Transition Survey (LiTS)** | Post-communist countries, several rounds | Attitudes, trust, life satisfaction, corruption | EBRD website |
| **World Bank Enterprise Surveys / BEEPS** | All five countries, various years | Firm-level data: constraints, finance, corruption | enterprisesurveys.org (free registration) |
| **World Bank Microdata Library** | Many surveys | Search by country for LSMS, labour-force and other surveys | microdata.worldbank.org |

### Working with survey data: checklist

- Use the **survey weights** (`svyset` in Stata, `survey` package in R).
- Cluster standard errors at the **primary sampling unit**.
- Read the **questionnaire** and **sampling report** before using any variable.
- For panels, check **attrition**: who drops out between waves, and why.
- Respect the **terms of use**; most microdata cannot be redistributed, so do not commit them to this repository.

## 4. Citation and licences

- World Bank data (WDI, Microdata Library public-use files) are generally **CC BY 4.0**: cite the source.
- MICS, DHS and LiK require registration and have their own terms; cite the survey as specified on its website.
- When you publish, record the **download date** and **data version** (our scripts write a download log automatically).

---

*Know a useful source that is missing? Please open an issue or a pull request; see [CONTRIBUTING.md](../CONTRIBUTING.md).*
