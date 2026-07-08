# PLAN — Ejercicio 2: Sistema RAG sobre Reglamentos de la UNSA
## Consultas en lenguaje natural sobre normativa universitaria

> **Objetivo:** implementar un sistema **RAG en Flowise** que responda consultas en lenguaje
> natural sobre documentos oficiales de la UNSA, fundamentando las respuestas en su contenido.
>
> **Requisitos de la guía:** mínimo **3 documentos** oficiales de la UNSA · al menos **20 páginas** ·
> al menos **10 consultas** de prueba.
>
> **Entregable:** Informe ejecutivo de **5–6 páginas** (arquitectura completa, flujos
> conversacionales, evidencias de pruebas, recomendaciones).

---

## 1. Decisiones tomadas

| Decisión | Elección | Motivo |
|---|---|---|
| Herramienta | **Flowise** (Docker) | Exigido por la guía; desarrollo visual |
| LLM (chat) | **Google Gemini** (`gemini-2.5-flash`) | Gratuito, buen español |
| Embeddings | **Google Gemini Embeddings** (`gemini-embedding-001`) | Mismo proveedor, gratuito, integrado en Flowise |
| Vector Store | **In-Memory** (o Faiss) | Suficiente para pocos documentos; sin infraestructura extra |
| Documentos | **3 PDFs oficiales UNSA** (los consigo yo) | Estatuto + Reglamentos ≥ 20 páginas combinadas |

---

## 2. Documentos a utilizar (objetivo de descarga)

**Documentos finalmente utilizados** (descargados en `documentos/`, todos con texto seleccionable
y verificados — ver `documentos/fuentes.md`):

1. **Reglamento de Grados y Títulos** (RCU 0255-2021) — 24 págs.
2. **Reglamento del Régimen Académico** (Diplomados/Maestro/Doctor, RCU 0104-2022) — 31 págs.
3. **Reglamento de Auspicios de la UNSA** (RCU 0516-2020) — 8 págs.

**Total: 63 páginas · 3 documentos** (cumple ≥3 docs y ≥20 págs).

> Nota: el **Estatuto 2015** se descartó por estar **escaneado** (sin texto extraíble para RAG).
> Se priorizaron reglamentos oficiales de la UNSA con texto real.

---

## 3. Arquitectura RAG (pipeline Flowise)

```
  FASE DE INDEXACIÓN (una vez)
  ┌───────────────┐   ┌──────────────┐   ┌────────────────────┐   ┌──────────────┐
  │ PDF Document  │──►│ Text Splitter│──►│ Gemini Embeddings  │──►│ Vector Store │
  │ Loader (x3)   │   │ (chunks)     │   │ (gemini-embedding-001│   │ (In-Memory)  │
  └───────────────┘   └──────────────┘   └────────────────────┘   └──────┬───────┘
                                                                          │
  FASE DE CONSULTA (por pregunta)                                         │
  ┌──────┐   ┌───────────┐   ┌──────────────────┐   ┌─────────────┐       │
  │ Chat │──►│ Retriever │◄──┤ Vector Store      │◄──────────────────────┘
  │ User │   └─────┬─────┘   └──────────────────┘
  └──────┘         ▼
             ┌──────────────────────┐   ┌────────────────────┐
             │ Retrieval QA Chain   │──►│ Gemini (LLM) genera│──► Respuesta
             │ (contexto + pregunta)│   │ respuesta fundada  │    fundamentada
             └──────────────────────┘   └────────────────────┘
```

**Nodos Flowise a conectar (Pasos 3–4 de la guía):**
- **PDF File / Document Loader** (uno por documento, o Folder loader).
- **Recursive Character Text Splitter** — `chunkSize ≈ 1000`, `overlap ≈ 150`.
- **Google Generative AI Embeddings** — `gemini-embedding-001`.
- **In-Memory Vector Store** (o Faiss).
- **Retriever** conectado al Vector Store (top-k ≈ 4).
- **Conversational Retrieval QA Chain** — conecta Retriever + Gemini + Chat.
- **Chat** (entrada del usuario).

> Diagrama formal en **Draw.io** → `arquitectura/arquitectura-rag-unsa.drawio` + PNG.

---

## 4. Configuración clave a documentar

| Parámetro | Valor propuesto | Nota |
|---|---|---|
| Chunk size | 1500 caracteres | Balance contexto/precisión |
| Chunk overlap | 200 | Evita cortar ideas jurídicas |
| Embeddings | `gemini-embedding-001` (Google) | Gratuito |
| top-k retriever | 4 | Fragmentos recuperados por consulta |
| Prompt de sistema | "Responde solo con base en los reglamentos; cita el documento; si no está, dilo" | Reduce alucinación |

---

## 5. Batería de pruebas (≥10 consultas — Paso 5)

Se ejecutaron **12 consultas** (11 de contenido + 1 de control), con respuestas verificadas contra
los artículos de los reglamentos. La lista completa con respuestas esperadas y la tabla de resultados
está en **`pruebas/consultas-respuestas.md`**. Ejemplos: requisitos de bachiller (Art. 6), modalidades
de titulación (Art. 26), integrantes del jurado (Art. 14), créditos de diplomado/maestría/doctorado,
finalidad y definición de auspicio, y una pregunta de control fuera de alcance.

> Cada respuesta se evalúa por **precisión** y **coherencia**, y se anota si citó bien el documento.
> Se guardan en `pruebas/consultas-respuestas.md` + capturas en `evidencias/`.

---

## 6. Estructura de carpeta (a construir)

```
RAG-Reglamentos-UNSA/
├── PLAN.md                       ← este documento
├── documentos/                   ← 3 PDFs oficiales UNSA (+ fuentes.md con URLs)
├── arquitectura/                 ← .drawio + PNG del pipeline RAG
├── config/RAG-UNSA-Chatflow.json ← flujo exportado de Flowise
├── prompts/system-prompt-rag.md  ← prompt anti-alucinación con citación
├── pruebas/consultas-respuestas.md ← las ≥10 consultas y respuestas
├── evidencias/                   ← capturas del flujo y de las respuestas
└── INFORME.md                    ← informe ejecutivo 5–6 págs
```

---

## 7. Estructura del informe ejecutivo (5–6 páginas)

1. **Introducción y problema** (desconocimiento de la normativa UNSA).
2. **Arquitectura completa** (diagrama + explicación de cada nodo y parámetros).
3. **Documentos indexados** (los 3, con páginas y fuente).
4. **Flujos conversacionales** (cómo consulta el usuario; ejemplos).
5. **Evidencias de pruebas** (tabla de las ≥10 consultas con veredicto + capturas).
6. **Análisis de resultados, limitaciones y recomendaciones**.

---

## 8. Mapeo con el entregable exigido

| Entregable guía | Dónde queda |
|---|---|
| Arquitectura completa | `arquitectura/` + `INFORME.md` §2 |
| Flujos conversacionales | `INFORME.md` §4 + `config/` |
| Evidencias de pruebas | `pruebas/` + `evidencias/` + `INFORME.md` §5 |
| Recomendaciones | `INFORME.md` §6 |

---

## 9. Próximos pasos (al aprobar el plan)

1. Buscar y descargar los 3 PDFs oficiales de la UNSA → `documentos/` (verificar ≥20 pág. y texto seleccionable).
2. Redactar el prompt de sistema anti-alucinación con citación.
3. Preparar el diagrama de arquitectura RAG (Draw.io).
4. Preparar el JSON del Chatflow RAG para importar en Flowise.
5. Redactar la batería de ≥10 consultas y la plantilla del informe ejecutivo.
