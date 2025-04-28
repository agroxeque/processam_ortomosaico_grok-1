# Carregar bibliotecas necessárias
library(rmarkdown)
library(sf)

# Função para gerar o relatório em PDF
gerar_relatorio <- function(dir_temp) {
  # Definir caminhos
  caminho_ortomosaico_png <- file.path(dir_temp, "ortomosaico_recortado.png")
  caminho_vari_png <- file.path(dir_temp, "vari.png")
  caminho_classificacao_png <- file.path(dir_temp, "classificacao.png")
  caminho_grade_saida <- file.path(dir_temp, "grade_saida.geojson")
  caminho_relatorio <- file.path(dir_temp, "relatorio.pdf")
  
  # Carregar grade de saída
  grade <- st_read(caminho_grade_saida, quiet = TRUE)
  
  # Calcular estatísticas de área (assumindo área em hectares)
  area_total <- sum(st_area(grade)) / 10000 # Convertendo m² para ha
  area_cultura <- sum(grade$prop_cultura * st_area(grade)) / 10000
  area_invasoras <- sum(grade$prop_invasoras * st_area(grade)) / 10000
  area_solo <- sum(grade$prop_solo * st_area(grade)) / 10000
  
  # Criar template RMarkdown
  rmd_content <- '
---
title: "Relatório do Projeto"
date: "`r format(Sys.Date(), "%d/%m/%Y")`"
output: pdf_document
---

## Informações do Projeto
- **Cliente**: Jonas Rocha
- **Fazenda**: São João 10
- **Talhão**: Pivô 10
- **Data do Levantamento**: 10/03/2025
- **Data de Processamento**: `r format(Sys.Date(), "%d/%m/%Y")`

## Ortomosaico
![Ortomosaico Recortado](`r caminho_ortomosaico_png`)

## Índice de Vegetação (VARI)
![VARI](`r caminho_vari_png`)

## Composição do Talhão
![Classificação](`r caminho_classificacao_png`)

### Estatísticas de Área
- **Cultura**: `r round(area_cultura, 2)` ha (`r round(area_cultura/area_total*100, 2)`%)
- **Plantas invasoras**: `r round(area_invasoras, 2)` ha (`r round(area_invasoras/area_total*100, 2)`%)
- **Solo exposto**: `r round(area_solo, 2)` ha (`r round(area_solo/area_total*100, 2)`%)
- **Total**: `r round(area_total, 2)` ha (100%)

## Ranking de Células
- **Total de Células**: `r nrow(grade)`
- **Área das Células**: `r round(st_area(grade)[1]/10000, 4)` hectares
- **Área Total**: `r round(area_total, 2)` hectares
- **Sistema de Coordenadas**: WGS 84 (EPSG:4326)
'

  # Salvar RMarkdown temporário
  rmd_file <- file.path(dir_temp, "relatorio.Rmd")
  writeLines(rmd_content, rmd_file)
  
  # Renderizar PDF
  render(rmd_file, output_file = caminho_relatorio, quiet = TRUE)
  cat("Relatório salvo como PDF\n")
}