# Carregar bibliotecas necessárias
library(plumber)
library(httr)
library(jsonlite)

#* @apiTitle Agroxeque API
#* @apiDescription API para processamento de ortomosaicos

#* Processar um projeto
#* @post /processar
#* @param id_projeto:string
function(req) {
  # Extrair id_projeto do corpo da requisição
  id_projeto <- req$body$id_projeto
  if (is.null(id_projeto)) {
    return(list(status = "error", mensagem = "id_projeto não fornecido"))
  }
  
  # Iniciar log
  log_file <- file.path(Sys.getenv("DIR_LOGS"), paste0(format(Sys.Date(), "%Y-%m-%d"), "_", id_projeto, ".log"))
  sink(log_file, append = TRUE)
  cat("API: Recebida requisição para id_projeto:", id_projeto, "\n")
  
  status <- "success"
  mensagem <- "Processamento concluído com sucesso"
  
  tryCatch({
    # Chamar o script main
    source(file.path(Sys.getenv("DIR_PRINCIPAL"), "main.R"))
    main(id_projeto)
  }, error = function(e) {
    status <<- "error"
    mensagem <<- paste("Erro no processamento:", conditionMessage(e))
    cat("API: Erro:", mensagem, "\n")
  }, finally = {
    # Enviar webhook
    webhook_url <- Sys.getenv("WEBHOOK_URL")
    payload <- toJSON(list(
      id_projeto = id_projeto,
      status = status,
      mensagem = mensagem,
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    ), auto_unbox = TRUE)
    
    POST(webhook_url, body = payload, content_type_json())
    cat("API: Webhook enviado com status:", status, "\n")
    sink()
  })
  
  # Retornar resposta
  list(status = status, mensagem = mensagem, id_projeto = id_projeto)
}

# Configurar e executar a API
# Este bloco será usado para testes manuais ou pelo serviço
if (interactive()) {
  pr <- plumb(file = Sys.getenv("DIR_PRINCIPAL") + "/API.R")
  pr$run(host = "0.0.0.0", port = 443)
}