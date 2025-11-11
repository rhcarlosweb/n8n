#!/bin/bash

set -e

BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/n8n_backup_${TIMESTAMP}"

echo "=== Script de Atualização do n8n ==="
echo ""

if [ ! -f "docker-compose.yml" ]; then
    echo "Erro: docker-compose.yml não encontrado!"
    exit 1
fi

if [ ! -d ".n8n" ]; then
    echo "Aviso: Diretório .n8n não encontrado. Nenhum backup será criado."
else
    echo "1. Criando backup dos dados do n8n..."
    mkdir -p "${BACKUP_DIR}"
    
    if cp -r .n8n "${BACKUP_PATH}"; then
        echo "   ✓ Backup criado em: ${BACKUP_PATH}"
    else
        echo "   ✗ Erro ao criar backup. Abortando atualização."
        exit 1
    fi
fi

echo ""
echo "2. Fazendo pull das imagens mais recentes..."
if ! docker-compose pull; then
    echo "   ✗ Erro ao fazer pull das imagens."
    exit 1
fi

echo ""
echo "3. Parando os serviços..."
docker-compose down

echo ""
echo "4. Rebuildando os containers..."
if ! docker-compose build --no-cache; then
    echo "   ✗ Erro ao fazer rebuild. Fazendo rollback..."
    docker-compose down
    if [ -d "${BACKUP_PATH}" ] && [ -d ".n8n" ]; then
        rm -rf .n8n
        cp -r "${BACKUP_PATH}" .n8n
        echo "   ✓ Dados restaurados do backup."
    fi
    exit 1
fi

echo ""
echo "5. Iniciando os serviços..."
if ! docker-compose up -d; then
    echo "   ✗ Erro ao iniciar os serviços. Fazendo rollback..."
    docker-compose down
    if [ -d "${BACKUP_PATH}" ] && [ -d ".n8n" ]; then
        rm -rf .n8n
        cp -r "${BACKUP_PATH}" .n8n
        echo "   ✓ Dados restaurados do backup."
        docker-compose up -d
    fi
    exit 1
fi

echo ""
echo "6. Aguardando serviços iniciarem..."
sleep 10

echo ""
echo "7. Verificando status dos containers..."
if docker-compose ps | grep -q "Up"; then
    echo "   ✓ Serviços iniciados com sucesso!"
else
    echo "   ✗ Alguns serviços não estão rodando."
    docker-compose ps
    exit 1
fi

echo ""
echo "=== Atualização concluída com sucesso! ==="
echo "Backup salvo em: ${BACKUP_PATH}"
echo "Para ver os logs: docker-compose logs -f n8n"
echo ""




