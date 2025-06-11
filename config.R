# 1. Načtení balíčků
library(dplyr)
library(sf)
library(readr)
library(nngeo)    # pro nearest neighbor
library(dbscan)   # pro identifikaci shluků
library(leaflet) # pro interaktivní mapu

# 2. Načtení dat
data_raw <- read_csv2(
  "beskydy_solidago.csv",
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    ID_ND_NALEZ = col_character(),
    .default = col_guess()
    )
  )

# 3. Převod na sf a reprojekce do metrického CRS (S-JTSK)
data_sf <- data_raw %>%
  st_as_sf(
    coords = c("X", "Y"), 
    crs = 5514
    )               # S-JTSK / Krovak East North
