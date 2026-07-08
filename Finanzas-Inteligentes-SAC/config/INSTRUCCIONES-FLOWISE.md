# Construcción y prueba del AGENTE FinBot en Flowise

> **Es un AGENTE** (Tool Agent): razona, usa **herramientas** (Calculator, Current Date Time) y
> tiene **memoria**. Los **3 reportes ya están incrustados** en su System Message, así que **tú
> solo preguntas en el chat** (no hace falta pegar reportes).
>
> Flowise 3.1.2 corre en Docker, la cuenta está creada y `FinBot-Chatflow.json` (5 nodos) está
> listo para importar.

---

## Arquitectura (5 nodos)
```
        🧠 Google Gemini (gemini-2.5-flash, tool calling)
                     │
  👤 Usuario ──► 🤖 TOOL AGENT ──── 🗂️ Buffer Memory (memoria corto plazo)
   (pregunta)     (FinBot)     │
                     │         └── 🧰 Herramientas: 🧮 Calculator · 📅 Current Date Time
                     ▼
              📄 Respuesta / Resumen ejecutivo
```
Los datos de las 3 sucursales (Lima, Arequipa, Trujillo) viven en el **System Message** del agente.

## Estado ya preparado
- ✅ Flowise **3.1.2** en **http://localhost:3000**
- ✅ Cuenta: **`admin@finbot.local`** / **`Admin123!`**
- ✅ `FinBot-Chatflow.json` (5 nodos, sin Custom Tool)

---

## Paso 1 — Iniciar sesión
Abre **http://localhost:3000** y entra con `admin@finbot.local` / `Admin123!`.

## Paso 2 — Credencial de Google Gemini
1. API key gratuita: **https://aistudio.google.com/apikey**
2. **Credentials → Add Credential → Google GenerativeAI** → pega la key → nómbrala `gemini-key`.

## Paso 3 — Importar el flujo del agente
1. Si tenías un FinBot anterior, **bórralo** (Chatflows → ⋮ → Delete).
2. **Chatflows → Add New → ⋮ → Load Chatflow** → `config/FinBot-Chatflow.json`.
3. Verás 5 nodos: **Tool Agent** ← **Gemini** + **Buffer Memory** + **Calculator** + **Current Date Time**.
4. Nodo **Google Gemini** → *Connect Credential* → `gemini-key`. **Guarda** (💾).

## Paso 4 — Probar (Actividades 4, 5 y 6) — solo preguntas
Abre un **chat nuevo** y escribe directamente (los datos ya los conoce):
1. `Dame el resumen ejecutivo de la sucursal de Lima Centro`
2. `Dame el resumen ejecutivo de Trujillo` (debe marcar 🔴 morosidad crítica)
3. `¿Cuál sucursal tuvo mayor utilidad neta?`
4. `Compara las 3 sucursales en una tabla y dame un consolidado`
5. `¿Cuál es el promedio de morosidad de las 3 sucursales?` → usa la herramienta **Calculator**
6. `¿Cuál fue el ROE de Arequipa?` → debe responder que no consta en los reportes

> **Memoria:** usa la misma sesión de chat; el agente recuerda lo consultado y da seguimiento.
> **Tool calling:** en las preguntas de cálculo verás que invoca `calculator` (evidencia de agente).

Guarda respuestas y capturas en `../resultados/` y `../evidencias/`.

---

## Plan B — Armar el agente manualmente (si el import falla)
1. **Add New** chatflow.
2. **Tool Agent** (Agents).
3. **Google Gemini** (Chat Models): credencial + Model `gemini-2.5-flash` + Temp `0.2` → a *Tool Calling Chat Model*.
4. **Buffer Memory** (Memory): `chat_history` → a *Memory*.
5. **Calculator** y **Current Date Time** (Tools) → a *Tools* del agente.
6. En **System Message** del Tool Agent, pega el contenido de `../prompts/system-prompt-finbot.md`
   (incluye los datos de las 3 sucursales).
7. Guarda y prueba (Paso 4).

---

## Comandos Docker
```powershell
cd docker
docker compose up -d          # arrancar
docker compose down           # detener (conserva cuenta y flujos)
docker compose logs -f
```
