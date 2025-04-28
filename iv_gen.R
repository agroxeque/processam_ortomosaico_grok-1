# Carregar bibliotecas necessárias
library(terra)

# Função para calcular o índice de vegetação (VARI)
gerar_indices_vegetacao <- function(dir_temp) {
  # Definir caminhos
  caminho_ortomosaico_recortado <- file.path(dir_temp, "ortomosaico_recortado.tif")
  caminho_vari <- file.path(dir_temp, "vari.tif")
  caminho_png <- file.path(dir_temp, "vari.png")
  
  # Carregar ortomosaico recortado
  ortomosaico <- rast(caminho_ortomosaico_recortado)
  
  # Extrair bandas RGB
  r <- ortomosaico[[1]]
  g <- ortomosaico[[2]]
  b <- ortomosaico[[3]]
  
  # Calcular VARI: (Green - Red) / (Green + Red - Blue)
  vari <- (g - r) / (g + r - b)
  
  # Salvar como GeoTIFF
  writeRaster(vari, caminho_vari, overwrite = TRUE)
  cat("VARI salvo como GeoTIFF\n")
  
  # Gerar PNG para o relatório
  png(caminho_png, width = 800, height = 600)
  plot(vari, main = "Índice de Vegetação (VARI)", col = terrain.colors(100))
  dev.off()
  cat("VARI salvo como PNG\n")
}