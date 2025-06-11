# 1. Načtení balíčků
library(dplyr)
library(sf)
library(readr)
library(nngeo)    # pro nearest neighbor
library(dbscan)   # pro identifikaci shluků
library(leaflet) # pro interaktivní mapu
library(RCzechia)

# 2. Načtení dat
#--------------------------------------------------#
## Stazeni GIS vrstev AOPK CR ---- 
#--------------------------------------------------#
endpoint <- "http://gis.nature.cz/arcgis/services/Aplikace/Opendata/MapServer/WFSServer?"
caps_url <- base::paste0(endpoint, "request=GetCapabilities&service=WFS")

layer_name_evl <- "Opendata:Evropsky_vyznamne_lokality"
layer_name_po <- "Opendata:Ptaci_oblasti"
layer_name_biotopzvld <- "Opendata:Biotop_zvlaste_chranenych_druhu_velkych_savcu"
getfeature_url_evl <- paste0(
  endpoint,
  "service=WFS&version=2.0.0&request=GetFeature&typeName=", layer_name_evl
)
getfeature_url_po <- paste0(
  endpoint,
  "service=WFS&version=2.0.0&request=GetFeature&typeName=", layer_name_po
)
getfeature_url_biotopzvld <- paste0(
  endpoint,
  "service=WFS&version=2.0.0&request=GetFeature&typeName=", layer_name_biotopzvld
)

evl <- sf::st_read(getfeature_url_evl) %>%
  sf::st_transform(., st_crs("+init=epsg:5514"))
po <- sf::st_read(getfeature_url_po) %>%
  sf::st_transform(., st_crs("+init=epsg:5514")) 
biotop_zvld <- sf::st_read(getfeature_url_biotopzvld) %>%
  sf::st_transform(., st_crs("+init=epsg:5514"))

n2k_union <- sf::st_join(
  evl, 
  po
)

rivers_raw <- RCzechia::reky(resolution = "high") %>%
  sf::st_transform(
    .,
    5514)

rivers <-
  sf::st_crop(
    rivers_raw,
    evl %>% 
      dplyr::filter(
        NAZEV == "Beskydy"
      ) %>%
      sf::st_buffer(
        .,
        1000
      )
  )

data_raw <- read_csv2(
  "beskydy_solidago.csv",
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    ID_ND_NALEZ = col_character(),
    X = col_character(),
    Y = col_character(),
    .default = col_guess()
  )
)

# 3. Převod na sf v originálním CRS (S-JTSK / Krovak East North)
# Předpokládáme, že X, Y jsou již v EPSG:5514
data_sf <- data_raw %>%
  st_as_sf(coords = c("X", "Y"), crs = 5514) %>%
  dplyr::mutate(
    PLOCHA_POPULACE = readr::parse_number(
      stringr::str_extract(STRUKT_POZN, "Plocha populace:\\s*[0-9]+([.,][0-9]+)?")
    ),
    MANAGEMENT = stringr::str_trim(
      stringr::str_remove(
        stringr::str_extract(
          STRUKT_POZN,
          "Management:\\s*.+$"
        ),
        "^Management:\\s*"
      )
    )
  )

