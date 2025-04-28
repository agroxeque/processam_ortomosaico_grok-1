# Caminhos de diretórios
DIR_PRINCIPAL <- "/home/processamento_ortomosaicos"
DIR_ASSETS <- file.path(DIR_PRINCIPAL, "assets")
DIR_LOGS <- file.path(DIR_PRINCIPAL, "logs")
DIR_TMP <- file.path(DIR_PRINCIPAL, "tmp")

# Parâmetros gerais
RESOLUCAO_IMAGEM <- 1200  # Resolução para imagens PNG no relatório

# Carregar credenciais do .env
library(dotenv)
dotenv::load_dot_env(file.path(DIR_PRINCIPAL, ".env"))
SUPABASE_URL <- Sys.getenv("SUPABASE_URL")
SUPABASE_KEY <- Sys.getenv("SUPABASE_KEY")