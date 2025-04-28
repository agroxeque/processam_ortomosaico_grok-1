# Carregar bibliotecas necessárias
library(plumber)

# Carregar configurações
source("/home/processamento_ortomosaicos/config.R")

# Iniciar a API em HTTP na porta 80
pr <- plumb(file = "/home/processamento_ortomosaicos/API.R")
pr$run(host = "0.0.0.0", port = 80)