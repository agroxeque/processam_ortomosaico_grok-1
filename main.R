# Carregar configurações
source("config")

# Função principal
main <- function(id_projeto) {
  # Criar diretório temporário para o projeto
  dir_temp <- file.path(DIR_TMP, id_projeto)
  dir.create(dir_temp, showWarnings = FALSE, recursive = TRUE)
  
  # Iniciar log com a nomenclatura acordada
  log_file <- file.path(DIR_LOGS, paste0(format(Sys.Date(), "%Y-%m-%d"), "_", id_projeto, ".log"))
  sink(log_file, append = TRUE)
  cat("=== INICIANDO PROCESSAMENTO DO PROJETO:", id_projeto, "===\n")
  
  tryCatch({
    # Baixar arquivos de entrada
    source("sb_connect")
    baixar_inputs(id_projeto, dir_temp)
    
    # Recortar ortomosaico
    source("recorte_ortomosaico")
    recortar_ortomosaico(dir_temp)
    
    # Gerar índices de vegetação
    source("iv_gen")
    gerar_indices_vegetacao(dir_temp)
    
    # Gerar ranking
    source("ranking_gen")
    gerar_ranking(dir_temp)
    
    # Gerar relatório
    source("relatorio_gen")
    gerar_relatorio(dir_temp)
    
    # Enviar outputs
    source("sb_connect")
    enviar_outputs(id_projeto, dir_temp)
    
    cat("=== PROCESSAMENTO CONCLUÍDO COM SUCESSO! ===\n")
  }, error = function(e) {
    cat("ERRO FATAL NO PROCESSAMENTO:", conditionMessage(e), "\n")
  }, finally = {
    # Limpar arquivos temporários
    unlink(dir_temp, recursive = TRUE)
    cat("===== LIMPEZA FINALIZADA =====\n")
    sink()
  })
}

# Exemplo de chamada
# main("210_AGXQ")