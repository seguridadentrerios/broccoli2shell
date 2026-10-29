#!/usr/bin/env bash

echo "=================================================="
echo "  Auditoría Integral: Broccoli2Shell (CVE-2026-111497)"
echo "=================================================="

# ==========================================
# 1. VERIFICACIÓN DE ENTORNO Y VERSIONES
# ==========================================
echo -e "\n[+] 1. Verificando versión de Node.js y entorno..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "  -> Versión de Node.js actual: $NODE_VERSION"
    
    BROTLI_VERSION=$(node -p "process.versions.brotli" 2>/dev/null || echo "Desconocida")
    echo "  -> Versión de Brotli integrada: $BROTLI_VERSION"
    
    echo -e "\n  [i] Versiones de Node.js con parches de seguridad oficiales:"
    echo "      - Node.js 22: >= 22.23.4"
    echo "      - Node.js 24: >= 24.22.1"
    echo "      - Node.js 26: >= 26.12.1"
    echo "      *(Nota: Las versiones 20, 23 y 25 están EOL y no recibirán parche)*"
else
    echo "  [!] Node.js no está instalado o no se encuentra en el PATH."
fi

# ==========================================
# 2. VERIFICACIÓN DE DEPENDENCIAS (Configuraciones)
# ==========================================
echo -e "\n[+] 2. Buscando referencias a 'brotli' en archivos de configuración..."
if [ -f "package.json" ]; then
    if grep -qi "brotli" package.json; then
        echo "  -> ¡Encontrado 'brotli' en package.json!"
    else
        echo "  -> No se encontró 'brotli' explícitamente en package.json."
    fi
else
    echo "  [!] No se encontró package.json en el directorio actual."
fi

for lockfile in package-lock.json yarn.lock pnpm-lock.yaml; do
    if [ -f "$lockfile" ]; then
        if grep -qi "brotli" "$lockfile"; then
            echo "  -> Coincidencia detectada en el archivo de bloqueo: $lockfile"
        fi
    fi
done

# ==========================================
# 3. ANÁLISIS ESTÁTICO DEL CÓDIGO FUENTE
# ==========================================
echo -e "\n[+] 3. Buscando APIs de descompresión en el código fuente..."
SEARCH_PATTERNS=("brotliDecompress" "createBrotliDecompress" "brotli.decompress" "zlib.brotliDecompress" "zlib.createBrotliDecompress")

MATCH_COUNT=0

if command -v rg &> /dev/null; then
    echo "  (Herramienta utilizada: ripgrep / rg)"
    for term in "${SEARCH_PATTERNS[@]}"; do
        # Buscar en archivos js, ts, mjs, cjs excluyendo carpetas comunes
        RESULTS=$(rg -n "$term" --glob '*.{js,ts,mjs,cjs}' --glob '!node_modules' --glob '!.git' --glob '!dist' --glob '!build' 2>/dev/null)
        if [ -n "$RESULTS" ]; then
            echo -e "\n  -> Patrón encontrado: '$term'"
            echo "$RESULTS" | while read -r line; do
                MATCH_COUNT=$((MATCH_COUNT + 1))
                echo "      [!] $line"
            done
        fi
    done
else
    echo "  (Herramienta utilizada: grep recursivo)"
    for term in "${SEARCH_PATTERNS[@]}"; do
        RESULTS=$(grep -rnwi --include="*.js" --include="*.ts" --include="*.mjs" --include="*.cjs" . -e "$term" --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build 2>/dev/null)
        if [ -n "$RESULTS" ]; then
            echo -e "\n  -> Patrón encontrado: '$term'"
            echo "$RESULTS" | while read -r line; do
                MATCH_COUNT=$((MATCH_COUNT + 1))
                echo "      [!] $line"
            done
        fi
    done
fi

if [ $MATCH_COUNT -eq 0 ]; then
    echo "  -> No se encontraron llamadas a las APIs vulnerables en el código analizado."
fi

echo -e "\n=================================================="
echo "  Auditoría finalizada."
echo "=================================================="
