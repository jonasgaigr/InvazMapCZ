
# Extrakce souřadnic lat/lon
coords_wgs <- st_coordinates(data_final)
data_final$lon <- coords_wgs[,1]
data_final$lat <- coords_wgs[,2]

# 8. Interaktivní mapa pomocí leaflet
tmp_palette <- colorNumeric(palette = "viridis", domain = data_final$iso_bod_m)

leaflet(data_final) %>%
  addTiles() %>%
  addCircleMarkers(
    ~lon, ~lat,
    radius = 6,
    color = ~tmp_palette(iso_cluster_m),
    stroke = FALSE, fillOpacity = 0.8,
    popup = ~paste0(
      "<strong>ID:</strong> ", ID_NALEZ, "<br/>",
      "<strong>Iso bod (m):</strong> ", round(iso_bod_m, 1), "<br/>",
      "<strong>Ohnisko:</strong> ", cluster_id, "<br/>",
      ifelse(!is.na(iso_cluster_m), paste0("<strong>Iso ohnisko (m):</strong> ", round(iso_cluster_m, 1)), "")
    )
  ) %>%
  addLegend(
    position = "bottomright",
    pal = tmp_palette,
    values = ~iso_cluster_m,
    title = "Iso ohnisko (m)",
    na.label = "Noise"
  )
