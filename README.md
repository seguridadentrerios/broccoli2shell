# Auditor Broccoli2Shell (CVE-2026-111497) 🛡️

Script en **Bash** diseñado para auditar rápidamente proyectos de **Node.js** y verificar si están expuestos a la vulnerabilidad crítica **Broccoli2Shell** en el decodificador de Brotli.

El script realiza tres comprobaciones clave de forma automatizada:
1. **Entorno:** Verifica la versión actual de Node.js y la versión del motor Brotli integrado en el runtime.
2. **Dependencias:** Busca referencias a `brotli` en tu `package.json` y archivos de bloqueo (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`).
3. **Código Fuente:** Realiza un análisis estático recursivo buscando llamadas directas a APIs vulnerables de compresión/descompresión (`brotliDecompress`, `createBrotliDecompress`, etc.) en archivos `.js`, `.ts`, `.mjs` y `.cjs`.

---

## 📋 Requisitos Previos

* **Bash** (disponible por defecto en Linux, macOS y Git Bash en Windows).
* **Node.js** instalado en el sistema (para verificar las versiones del runtime).
* *(Opcional)* **`ripgrep` (`rg`)** instalado para acelerar la búsqueda en el código fuente (si no está presente, el script utilizará `grep` automáticamente).

---

## 🚀 Instalación y Uso

1. Descarga o copia el script `audit-broccoli2shell.sh` en la raíz de tu proyecto Node.js.

2. Otórgale permisos de ejecución ejecutando el siguiente comando en tu terminal:
   
   chmod +x audit-broccoli2shell.sh
