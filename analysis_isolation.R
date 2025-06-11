# 4. Izolovanost bodů (nejbližší soused)
nn_idx <- 
  st_nn(
    data_sf, 
    data_sf, 
    k = 2, 
    progress = FALSE
    )

dist_to_nn <- 
  st_distance(
    data_sf,
    data_sf[sapply(nn_idx, `[`, 2), ],
    by_element = TRUE
    )
data_sf$iso_bod_m <- as.numeric(dist_to_nn)

# 5. Identifikace ohnisek DBSCAN
eps_val <- 500   # m
min_pts <- 5     # body
coords_mat <- st_coordinates(data_sf)
db <- dbscan(coords_mat, eps = eps_val, minPts = min_pts)
data_sf$cluster_id <- db$cluster

# 6. Izolovanost ohnisek (centroidy)
clusters_sf <- data_sf %>%
  filter(cluster_id != 0) %>%
  group_by(cluster_id) %>%
  summarise(geometry = st_union(geometry)) %>%
  st_centroid()
nn_cl <- st_nn(clusters_sf, clusters_sf, k = 2, progress = FALSE)
dist_cl <- st_distance(
  clusters_sf,
  clusters_sf[sapply(nn_cl, `[`, 2), ],
  by_element = TRUE
)
clusters_sf$iso_cluster_m <- as.numeric(dist_cl)

# 7. Sloučení zpět na body a vrácení do WGS84 pro leaflet
data_final <- data_sf %>%
  left_join(
    clusters_sf %>%
      sf::st_drop_geometry() %>%
      dplyr::select(
        cluster_id, 
        iso_cluster_m
        ),
    by = "cluster_id"
  ) %>%
  mutate(iso_cluster_m = if_else(cluster_id == 0, NA_real_, iso_cluster_m)) %>%
  st_transform(4326)  # WGS84 pro leaflet

# 9. Volitelný export výsledků
data_out <- data_final %>%
  st_drop_geometry() %>%
  select(ID_NALEZ, iso_bod_m, cluster_id, iso_cluster_m)
# write_csv(data_out, "beskydy_solidago_isolation.csv")
