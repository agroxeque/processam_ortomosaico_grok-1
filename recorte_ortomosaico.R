# Carregar bibliotecas necessárias
library(terra)

# Função para recortar o ortomosaico com base no polígono
recortar_ortomosaico <- function(dir_temp) {
  # Definir caminhos dos arquivos de entrada
  caminho_ortomosaico <- file.path(dir_temp, "ortomosaico.tif")
  caminho_poligono <- file.path(dir_temp, "poligono.geojson")
  
  # Definir caminhos dos arquivos de saída
  caminho_ortomosaico_recortado <- file.path(dir_temp, "ortomosaico_recortado.tif")
  caminho_png <- file.path(dir_temp, "ortomosaico_recortado.png")
  
  # Carregar o ortomosaico e o polígono
  ortomosaico <- rast(caminho_ortomosaico)
  poligono <- vect(caminho_poligono)
  
  # Garantir que o sistema de coordenadas seja o mesmo
  if (crs(ortomosaico) != crs(poligono)) {
    poligono <- project(poligono, crs(ortomosaico))
  }
  
  # Recortar o ortomosaico usando o polígono como máscara
  ortomosaico_recortado <- crop(ortomosaico, poligono, mask = TRUE)
  
  # Salvar o ortomosaico recortado como GeoTIFF
  writeRaster(ortomosaico_recortado, caminho_ortomosaico_recortado, overwrite = TRUE)
  cat("Ortomosaico recortado salvo como GeoTIFF\n")
  
  # Converter e salvar como PNG para o relatório
  plotRGB(ortomosaico_recortado, r = 1, g = 2, b = 3, stretch = "lin")
  png(caminho_png, width = 800, height = 600)
  plotRGB(ortomosaico_recortado, r = 1, g = 2, b = 3, stretch = "lin")
  dev.off()
  cat("Ortomosaico recortado salvo como PNG\n")
}