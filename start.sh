#!/bin/bash

set -e

echo "=== Script de Inicialização do n8n ==="
echo ""

if ! command -v docker &> /dev/null; then
    echo "Erro: Docker não está instalado!"
    echo "Por favor, instale o Docker primeiro."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Erro: Docker Compose não está instalado!"
    echo "Por favor, instale o Docker Compose primeiro."
    exit 1
fi

echo "1. Verificando Docker e Docker Compose..."
echo "   ✓ Docker instalado: $(docker --version)"
if command -v docker-compose &> /dev/null; then
    echo "   ✓ Docker Compose instalado: $(docker-compose --version)"
else
    echo "   ✓ Docker Compose instalado: $(docker compose version)"
fi

echo ""
echo "2. Criando diretório .n8n se não existir..."
mkdir -p .n8n
echo "   ✓ Diretório .n8n pronto"

echo ""
if [ ! -f ".env" ]; then
    echo "3. Criando arquivo .env a partir de .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "   ✓ Arquivo .env criado"
        echo "   ⚠ Importante: Edite o arquivo .env com suas credenciais antes de continuar!"
        echo "   Pressione Enter para continuar ou Ctrl+C para editar o .env primeiro..."
        read
    else
        echo "   ⚠ .env.example não encontrado. Você precisa criar o arquivo .env manualmente."
        exit 1
    fi
else
    echo "3. Arquivo .env já existe. Pulando criação."
fi

echo ""
echo "4. Verificando se os containers já estão rodando..."
if docker-compose ps 2>/dev/null | grep -q "Up"; then
    echo "   ⚠ Alguns containers já estão rodando."
    echo "   Deseja reiniciar os containers? (s/N)"
    read -r response
    if [[ "$response" =~ ^([sS][iI][mM]|[sS])$ ]]; then
        echo "   Parando containers existentes..."
        docker-compose down
    else
        echo "   Mantendo containers existentes."
        echo ""
        echo "=== Inicialização concluída! ==="
        exit 0
    fi
fi

echo ""
echo "5. Construindo imagens Docker (primeira execução pode demorar)..."
if command -v docker-compose &> /dev/null; then
    docker-compose build
else
    docker compose build
fi

echo ""
echo "6. Iniciando serviços..."
if command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

echo ""
echo "7. Aguardando serviços iniciarem..."
sleep 5

echo ""
echo "8. Status dos containers:"
if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi

echo ""
echo "=== Inicialização concluída com sucesso! ==="
echo ""
echo "n8n está disponível em: http://localhost:${N8N_PORT:-5678}"
echo ""
echo "Comandos úteis:"
echo "  - Ver logs: docker-compose logs -f n8n"
echo "  - Parar: docker-compose down"
echo "  - Atualizar: ./update.sh"
echo ""


