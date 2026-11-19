# =============================================================================
# 03_descriptives.R — Summary statistics and figures
# -----------------------------------------------------------------------------
# Input  : data/processed/panel_central_asia.rds
# Output : output/tables/summary_statistics.csv
#          output/tables/means_by_group.csv
#          output/figures/remittances_over_time.png
#          output/figures/gdp_pc_over_time.png
#          output/figures/remittances_vs_growth.png
#
# Look before you regress: graphs reveal outliers, breaks and missing years
# that a regression table will hide.
# -----------------------------------------------------------------------------
# Copyright (c) 2026 Khilola Ruziboeva
# Licence  : PolyForm Noncommercial 1.0.0 (see LICENSE). Free for teaching
#            and non-commercial research; commercial use needs permission.
# Citation : see CITATION.cff
# =============================================================================

source("R/00_setup.R")

panel <- readRDS(file.path(paths$processed, "panel_central_asia.rds"))

# ---- 1. Summary statistics table -------------------------------------------
# One row per variable: N, mean, SD, min, max. This is "Table 1" in most
# empirical papers.
vars <- c("gdp_pc", "gdp_pc_growth", "remit_gdp", "trade_gdp",
          "inflation", "hh_cons_pc", "unemployment")

summary_stats <- panel |>
  select(all_of(vars)) |>
  pivot_longer(everything(), names_to = "variable") |>
  group_by(variable) |>
  summarise(N    = sum(!is.na(value)),
            mean = mean(value, na.rm = TRUE),
            sd   = sd(value, na.rm = TRUE),
            min  = min(value, na.rm = TRUE),
            max  = max(value, na.rm = TRUE),
            .groups = "drop") |>
  mutate(across(mean:max, ~ round(.x, 2))) |>
  # Keep the order defined in `vars`, not alphabetical order.
  arrange(match(variable, vars))

write_csv(summary_stats, file.path(paths$tables, "summary_statistics.csv"))
print(summary_stats)

# Means for Central Asia vs the comparison group.
means_by_group <- panel |>
  mutate(group = ifelse(central_asia == 1, "Central Asia", "Comparison")) |>
  group_by(group) |>
  summarise(across(all_of(vars), ~ round(mean(.x, na.rm = TRUE), 2)),
            .groups = "drop")
write_csv(means_by_group, file.path(paths$tables, "means_by_group.csv"))
print(means_by_group, width = Inf)

# ---- 2. Figures -------------------------------------------------------------
# A consistent, clean theme for all figures (suitable for slides and papers).
theme_set(theme_minimal(base_size = 12) +
            theme(legend.position = "bottom",
                  plot.title.position = "plot"))

ca <- panel |> filter(central_asia == 1)

# Figure 1: remittances over time in Central Asia.
p1 <- ggplot(ca |> filter(!is.na(remit_gdp)),
             aes(year, remit_gdp, colour = country)) +
  geom_line(linewidth = 0.9) +
  # Shade the shocks defined in 02_clean_panel.R.
  annotate("rect", xmin = 2008.5, xmax = 2009.5, ymin = -Inf, ymax = Inf,
           alpha = 0.1) +
  annotate("rect", xmin = 2013.5, xmax = 2015.5, ymin = -Inf, ymax = Inf,
           alpha = 0.1) +
  labs(title = "Personal remittances received, % of GDP",
       subtitle = "Shaded: 2009 crisis, 2014-15 rouble depreciation",
       x = NULL, y = "% of GDP", colour = NULL,
       caption = "Source: World Bank, World Development Indicators.")
ggsave(file.path(paths$figures, "remittances_over_time.png"), p1,
       width = 8, height = 5, dpi = 300, bg = "white")

# Figure 2: GDP per capita (log scale makes growth rates comparable).
p2 <- ggplot(ca |> filter(!is.na(gdp_pc)),
             aes(year, gdp_pc, colour = country)) +
  geom_line(linewidth = 0.9) +
  scale_y_log10(labels = scales::label_comma()) +
  labs(title = "GDP per capita, constant US$ (log scale)",
       x = NULL, y = NULL, colour = NULL,
       caption = "Source: World Bank, World Development Indicators.")
ggsave(file.path(paths$figures, "gdp_pc_over_time.png"), p2,
       width = 8, height = 5, dpi = 300, bg = "white")

# Figure 3: scatter of remittances vs growth, all countries.
# The dashed line is a simple pooled OLS fit — NOT a causal estimate.
p3 <- ggplot(panel |> filter(!is.na(remit_gdp), !is.na(gdp_pc_growth)),
             aes(remit_gdp, gdp_pc_growth)) +
  geom_point(aes(colour = factor(central_asia,
                                 labels = c("Comparison", "Central Asia"))),
             alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, linetype = "dashed",
              colour = "grey30", formula = y ~ x) +
  labs(title = "Remittances and GDP per capita growth",
       x = "Remittances, % of GDP", y = "GDP per capita growth, %",
       colour = NULL,
       caption = "Each point is one country-year. Pooled OLS fit, for illustration only.")
ggsave(file.path(paths$figures, "remittances_vs_growth.png"), p3,
       width = 8, height = 5, dpi = 300, bg = "white")

message("Descriptive tables and figures saved to output/.")
