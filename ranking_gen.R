# Carregar bibliotecas necessárias
library(terra)
library(sf)

# Função para classificar pixels, calcular scores e gerar ranking
gerar_ranking <- function(dir_temp) {
  # Definir caminhos
  caminho_ortomosaico_recortado <- file.path(dir_temp, "ortomosaico_recortado.tif")
  caminho_vari <- file.path(dir_temp, "vari.tif")
  caminho_grade_entrada <- file.path(dir_temp, "grade_entrada.geojson")
  caminho_grade_saida <- file.path(dir_temp, "grade_saida.geojson")
  caminho_png <- file.path(dir_temp, "classificacao.png")
  
  # Carregar arquivos
  ortomosaico <- rast(caminho_ortomosaico_recortado)
  vari <- rast(caminho_vari)
  grade <- st_read(caminho_grade_entrada, quiet = TRUE)
  
  # Classificação simples baseada em thresholds no VARI
  # (Valores fictícios, ajustar conforme necessário)
  cultura <- vari > 0.2
  invasoras <- vari < -0.2
  solo <- vari >= -0.2 & vari <= 0.2
  
  # Calcular proporções por célula
  proporcoes <- data.frame(id = grade$id, cultura = NA, invasoras = NA, solo = NA, vari_medio = NA)
  for (i in 1:nrow(grade)) {
    celula <- vect(grade[i, ])
    # Extrair pixels da célula
    pixels_cultura <- extract(cultura, celula, fun = mean, na.rm = TRUE)[1, 2]
    pixels_invasoras <- extract(invasoras, celula, fun = mean, na.rm = TRUE)[1, 2]
    pixels_solo <- extract(solo, celula, fun = mean, na.rm = TRUE)[1, 2]
    vari_celula <- extract(vari, celula, fun = mean, na.rm = TRUE)[1, 2]
    
    proporcoes$cultura[i] <- pixels_cultura
    proporcoes$invasoras[i] <- pixels_invasoras
    proporcoes$solo[i] <- pixels_solo
    proporcoes$vari_medio[i] <- vari_celula
  }
  
  # Normalizar VARI médio para vigor vegetativo
  vari_min <- min(proporcoes$vari_medio, na.rm = TRUE)
  vari_max <- max(proporcoes$vari_medio, na.rm = TRUE)
  proporcoes$vigor_normalizado <- (proporcoes$vari_medio - vari_min) / (vari_max - vari_min)
  
  # Calcular score: Cultura positiva, Invasoras negativa, Solo neutro, ponderado por vigor
  proporcoes$score <- (1 * proporcoes$cultura * proporcoes$vigor_normalizado) +
                      (-1 * proporcoes$invasoras) +
                      (0 * proporcoes$solo)
  
  # Gerar ranking (1 = melhor)
  proporcoes$ranking <- rank(-proporcoes$score, ties.method = "min")
  
  # Adicionar resultados à grade
  grade$score <- proporcoes$score
  grade$ranking <- proporcoes$ranking
  grade$prop_cultura <- proporcoes$cultura
  grade$prop_invasoras <- proporcoes$invasoras
  grade$prop_solo <- proporcoes$solo
  
  # Salvar grade de saída
  st_write(grade, caminho_grade_saida, delete_dsn = TRUE, quiet = TRUE)
  cat("Grade de saída salva como GeoJSON\n")
  
  # Gerar mapa de classificação para o relatório
  png(caminho_png, width = 800, height = 600)
  plot(ortomosaico, main = "Classificação do Talhão")
  plot(cultura, col = "green", add = TRUE, alpha = 0.5)
  plot(invasoras, col = "red", add = TRUE, alpha = 0.5)
  plot(solo, col = "brown", add = TRUE, alpha = 0.5)
  dev.off()
  cat("Mapa de classificação salvo como PNG\n")
}