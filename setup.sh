#!/bin/bash

# Script para configurar o ambiente do projeto Agroxeque
# Deve ser executado com sudo no Ubuntu 20.04

# Definir variáveis
DIR_PRINCIPAL="/home/processamento_ortomosaicos"
DIR_ASSETS="${DIR_PRINCIPAL}/assets"
DIR_LOGS="${DIR_PRINCIPAL}/logs"
DIR_TMP="${DIR_PRINCIPAL}/tmp"

# Função para verificar erro
check_error() {
    if [ $? -ne 0 ]; then
        echo "Erro: $1"
        exit 1
    fi
}

echo "=== Iniciando configuração do ambiente ==="

# 1. Atualizar pacotes do sistema
echo "Atualizando pacotes do sistema..."
apt-get update -y
check_error "Falha ao atualizar pacotes"

# 2. Instalar R
echo "Instalando R..."
apt-get install -y r-base
check_error "Falha ao instalar R"

# 3. Instalar GDAL
echo "Instalando GDAL..."
apt-get install -y gdal-bin libgdal-dev
check_error "Falha ao instalar GDAL"

# 4. Instalar dependências adicionais para bibliotecas R
echo "Instalando dependências para bibliotecas R..."
apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev
check_error "Falha ao instalar dependências do R"

# 5. Instalar bibliotecas R necessárias
echo "Instalando bibliotecas R..."
Rscript -e "install.packages(c('terra', 'sf', 'httr', 'jsonlite', 'rmarkdown', 'dotenv'), repos='https://cloud.r-project.org')"
check_error "Falha ao instalar bibliotecas R"

# 6. Criar estrutura de diretórios
echo "Criando diretórios do projeto..."
mkdir -p "$DIR_PRINCIPAL" "$DIR_ASSETS" "$DIR_LOGS" "$DIR_TMP"
check_error "Falha ao criar diretórios"

# 7. Configurar permissões
echo "Configurando permissões..."
chown -R $(whoami):$(whoami) "$DIR_PRINCIPAL"
chmod -R 755 "$DIR_PRINCIPAL"
check_error "Falha ao configurar permissões"

# 8. Criar arquivo .env de exemplo (usuário deve preencher)
echo "Criando arquivo .env de exemplo..."
cat > "$DIR_PRINCIPAL/.env" << EOL
SUPABASE_URL=insira_sua_url_aqui
SUPABASE_KEY=insira_sua_chave_aqui
WEBHOOK_URL=insira_sua_url_webhook_aqui
EOL
check_error "Falha ao criar arquivo .env"

echo "=== Configuração concluída com sucesso! ==="
echo "Por favor, edite o arquivo $DIR_PRINCIPAL/.env com suas credenciais do Supabase e webhook."
echo "Os scripts R podem ser colocados em $DIR_PRINCIPAL e executados com o comando 'Rscript main.R <id_projeto>'."