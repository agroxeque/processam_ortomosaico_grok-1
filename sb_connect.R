# Carregar bibliotecas necessárias
library(httr)
library(jsonlite)

# Função para baixar arquivos de entrada do Supabase
baixar_inputs <- function(id_projeto, dir_temp) {
  cat("Baixando arquivos de entrada para id_projeto:", id_projeto, "\n")
  
  # Definir URLs dos buckets
  bucket_ortomosaicos <- paste0(SUPABASE_URL, "/storage/v1/object/public/Ortomosaicos/", id_projeto, "/ortomosaico.tif")
  bucket_talhoes_poligono <- paste0(SUPABASE_URL, "/storage/v1/object/public/talhoes/", id_projeto, "/poligono.geojson")
  bucket_talhoes_grade <- paste0(SUPABASE_URL, "/storage/v1/object/public/talhoes/", id_projeto, "/grade_entrada.geojson")
  
  # Definir caminhos de destino
  caminho_ortomosaico <- file.path(dir_temp, "ortomosaico.tif")
  caminho_poligono <- file.path(dir_temp, "poligono.geojson")
  caminho_grade <- file.path(dir_temp, "grade_entrada.geojson")
  
  # Configurar autenticação
  headers <- add_headers(Authorization = paste("Bearer", SUPABASE_KEY))
  
  # Baixar arquivos
  download_file <- function(url, dest) {
    response <- GET(url, headers)
    if (status_code(response) == 200) {
      writeBin(content(response, "raw"), dest)
      cat("Arquivo baixado:", dest, "\n")
    } else {
      stop("Erro ao baixar arquivo de", url, ": Status", status_code(response))
    }
  }
  
  download_file(bucket_ortomosaicos, caminho_ortomosaico)
  download_file(bucket_talhoes_poligono, caminho_poligono)
  download_file(bucket_talhoes_grade, caminho_grade)
}

# Função para enviar arquivos de saída ao Supabase
enviar_outputs <- function(id_projeto, dir_temp) {
  cat("Enviando arquivos de saída para id_projeto:", id_projeto, "\n")
  
  # Definir caminhos dos arquivos de saída
  arquivos_saida <- list(
    list(local = file.path(dir_temp, "ortomosaico_recortado.tif"), remoto = "ortomosaico_recortado.tif"),
    list(local = file.path(dir_temp, "vari.tif"), remoto = "vari.tif"),
    list(local = file.path(dir_temp, "grade_saida.geojson"), remoto = "grade_saida.geojson"),
    list(local = file.path(dir_temp, "relatorio.pdf"), remoto = "relatorio.pdf")
  )
  
  # Configurar autenticação
  headers <- add_headers(Authorization = paste("Bearer", SUPABASE_KEY), "Content-Type" = "application/octet-stream")
  
  # Enviar arquivos
  for (arq in arquivos_saida) {
    url <- paste0(SUPABASE_URL, "/storage/v1/object/public/produtos_finais/", id_projeto, "/", arq$remoto)
    response <- POST(url, headers, body = upload_file(arq$local))
    if (status_code(response) == 200) {
      cat("Arquivo enviado:", arq$remoto, "\n")
    } else {
      stop("Erro ao enviar arquivo", arq$remoto, ": Status", status_code(response))
    }
  }
}