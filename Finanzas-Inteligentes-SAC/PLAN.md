# PLAN — Ejercicio 1: Agente IA Financiero con Memoria
## Empresa "Finanzas Inteligentes SAC"

> **Objetivo del ejercicio:** construir un agente IA **con memoria** que analice reportes
> financieros mensuales de distintas sucursales y genere automáticamente **resúmenes ejecutivos**.
>
> **Entregable (según guía):** Arquitectura · Código o configuración · Resultados obtenidos.

---

## 1. Decisiones tomadas

| Decisión | Elección | Motivo |
|---|---|---|
| Herramienta | **Flowise (low-code)** ejecutado en Docker | Consistencia con el flujo de trabajo previo; capturas claras; rápido |
| Motor LLM | **Google Gemini** (capa gratuita) | Gratuito, buena calidad en español, un solo proveedor para ambos ejercicios |
| Datos | **3 reportes sintéticos** que genera el equipo | Prototipo completo y reproducible sin depender de datos reales sensibles |
| Memoria | **Buffer Memory** (corto plazo) + resumen acumulado en el prompt | El agente "recuerda" los reportes ya analizados para comparar meses/sucursales |

---

## 2. Arquitectura propuesta (modelo de agente con memoria)

```
                 ┌─────────────────────────────────────────────┐
                 │              AGENTE "FinBot"                 │
  Reporte  ───►  │  Percepción → Razonamiento (Gemini) →        │ ───► Resumen
  mensual        │  Memoria (Buffer) → Acción (salida ejecutiva)│      ejecutivo
                 └─────────────────────────────────────────────┘
                                     ▲
                                     │  contexto acumulado
                                     │  (reportes previos)
                              Buffer Memory
```

**Componentes en Flowise — AGENTE de 6 nodos (Tool Agent):**
1. **Tool Agent** — núcleo agéntico; razona y **decide qué herramienta usar** (tool calling).
2. **ChatGoogleGenerativeAI** (`gemini-2.5-flash`, con function calling) — motor de razonamiento.
3. **Buffer Memory** — memoria de corto plazo; mantiene los reportes de la sesión para comparar.
4. **Calculator** (herramienta) — cálculos aritméticos.
5. **Current Date Time** (herramienta) — fecha/hora.
6. **Custom Tool `analizar_kpis`** (herramienta JS) — calcula margen, eficiencia, morosidad y alerta.

> Diagrama formal a producir en **Draw.io** → `arquitectura/arquitectura-finbot.drawio` + PNG.

---

## 3. Datos: 3 reportes sintéticos a generar

Tres sucursales de una financiera peruana, mismo mes (o meses consecutivos para probar memoria):

| Reporte | Sucursal | Contenido |
|---|---|---|
| `reporte_01_lima.md/.csv` | Lima Centro | Ingresos, gastos, utilidad, cartera, morosidad, N° créditos |
| `reporte_02_arequipa.md/.csv` | Arequipa | Mismos rubros, cifras distintas |
| `reporte_03_trujillo.md/.csv` | Trujillo | Mismos rubros, incluye una alerta (morosidad alta) |

Campos por reporte: **Ingresos financieros, Gastos operativos, Utilidad neta, Cartera de
colocaciones, Índice de morosidad, N° de créditos otorgados, Depósitos captados, Variación % vs mes anterior.**

Se generarán en `datos/` (formato `.csv` para carga y `.md` legible para pegar en el chat).

---

## 4. Prompt especializado (rol del agente)

Archivo: `prompts/system-prompt-finbot.md`. Debe definir:
- **Rol:** analista financiero ejecutivo de "Finanzas Inteligentes SAC".
- **Tarea:** recibir un reporte, analizarlo y devolver un **resumen ejecutivo estructurado**:
  1. Indicadores clave (con cifras del reporte).
  2. Análisis (fortalezas, riesgos, morosidad).
  3. Comparación con reportes previos de la sesión (uso de memoria).
  4. **Recomendaciones** accionables.
  5. **Alertas** (🔴/🟡/🟢 según morosidad y utilidad).
- **Reglas:** usar solo cifras del reporte (no inventar), tono ejecutivo y breve, español.
- **Formato de salida:** encabezados fijos para que los 3 resúmenes sean comparables.

---

## 5. Pasos de implementación

1. **Levantar Flowise** en Docker (Docker Desktop + WSL2), como en el lab anterior.
2. Crear **Chatflow** "FinBot — Finanzas Inteligentes SAC".
3. Agregar y conectar: `Tool Agent` ← `ChatGoogleGenerativeAI` + `Buffer Memory` + herramientas (`Calculator`, `Current Date Time`, `Custom Tool analizar_kpis`).
4. Configurar credencial de **Google Gemini** (API key gratuita de Google AI Studio).
5. Pegar el **system prompt** especializado en el System Message del Tool Agent.
6. **Exportar** el flujo como `config/FinBot-Chatflow.json` (para reproducibilidad/entrega).
7. Cargar los 3 reportes uno por uno en el chat y capturar los **resúmenes generados**.
8. Guardar salidas en `resultados/resumen_01..03.md` y capturas en `evidencias/`.

---

## 6. Pruebas y evaluación (Actividad 6)

| # | Prueba | Qué evalúa |
|---|---|---|
| 1 | Analizar reporte Lima | Genera resumen ejecutivo correcto con cifras reales |
| 2 | Analizar reporte Arequipa | Estructura consistente + recomendaciones |
| 3 | Analizar reporte Trujillo | Detecta y marca alerta de morosidad 🔴 |
| 4 | "¿Cuál sucursal tuvo mayor utilidad?" | **Memoria**: compara los 3 reportes de la sesión |
| 5 | "Dame un consolidado de las 3 sucursales" | Síntesis multi-reporte usando memoria |
| 6 | Reporte con dato faltante | No inventa; indica la falta |

Métrica: N° de resúmenes correctos / total, uso efectivo de memoria en comparaciones.

---

## 7. Estructura de carpeta (a construir)

```
Finanzas-Inteligentes-SAC/
├── PLAN.md                     ← este documento
├── datos/                      ← 3 reportes sintéticos (.csv + .md)
├── prompts/system-prompt-finbot.md
├── arquitectura/               ← .drawio + PNG
├── config/FinBot-Chatflow.json ← flujo exportado de Flowise
├── resultados/                 ← resúmenes ejecutivos generados
├── evidencias/                 ← capturas de pantalla del agente
└── INFORME.md                  ← informe final (arquitectura + config + resultados)
```

---

## 8. Mapeo con el entregable exigido

| Entregable guía | Dónde queda |
|---|---|
| Arquitectura | `arquitectura/` + sección en `INFORME.md` |
| Código o configuración | `config/FinBot-Chatflow.json` + `prompts/` |
| Resultados obtenidos | `resultados/` + `evidencias/` + tabla de pruebas en `INFORME.md` |

---

## 9. Próximos pasos (al aprobar el plan)

1. Generar los 3 reportes sintéticos en `datos/`.
2. Escribir el system prompt especializado.
3. Redactar el diagrama de arquitectura (Draw.io).
4. Preparar el JSON del Chatflow para importar en Flowise.
5. Redactar `INFORME.md` con la plantilla lista para pegar capturas y resultados.
