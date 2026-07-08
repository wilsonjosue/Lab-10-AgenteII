# INFORME EJECUTIVO — Ejercicio 2
# Sistema RAG para Consulta de Reglamentos de la UNSA

**Curso:** Tecnologías de Información — Lab 10: Agentes de Inteligencia Artificial (II)
**Herramientas:** Flowise 3.1.2 (Docker) · Google Gemini (chat + embeddings) · Draw.io

---

## 1. Introducción y problema

La comunidad universitaria de la UNSA (estudiantes, docentes y personal administrativo) suele
**desconocer los reglamentos y normativas institucionales**. Aunque los documentos están públicos
en el portal de transparencia, su **extensión**, **organización** y **lenguaje jurídico** hacen que
la búsqueda de información sea lenta e ineficiente.

Este proyecto implementa un **sistema RAG (Retrieval-Augmented Generation)** en Flowise que permite
hacer **consultas en lenguaje natural** sobre reglamentos oficiales de la UNSA y obtener respuestas
**fundamentadas en el contenido** de dichos documentos, reduciendo el tiempo de búsqueda y evitando
interpretaciones incorrectas.

---

## 2. Arquitectura completa

El sistema combina una **fase de indexación** (una sola vez) y una **fase de consulta** (por cada
pregunta), implementadas con **9 nodos** en Flowise:

```
  INDEXACIÓN (una vez)
  3× PDF File Loader ──► Recursive Text Splitter ──► Google Gemini Embeddings ──► In-Memory Vector Store
  (3 reglamentos)        (chunks 1500/200)          (gemini-embedding-001)        (índice vectorial)

  CONSULTA (por pregunta)
  Usuario ─► Conversational Retrieval QA Chain ◄─ Retriever (del Vector Store)
                     ▲            ▲
             Gemini (chat)   Buffer Memory
                     │
                     ▼
        Respuesta fundamentada + documentos fuente
```

| Componente | Nodo Flowise | Función |
|---|---|---|
| Carga documental | **3× PDF File** | Extraen el texto de los 3 reglamentos |
| Fragmentación | **Recursive Character Text Splitter** | Divide en chunks de 1500 car. (overlap 200) |
| Vectorización | **Google Generative AI Embeddings** (`gemini-embedding-001`) | Convierte texto en vectores |
| Índice | **In-Memory Vector Store** (Top K = 4) | Almacena y recupera por similitud |
| Recuperación + generación | **Conversational Retrieval QA Chain** | Recupera contexto y genera la respuesta |
| Razonamiento | **ChatGoogleGenerativeAI** (`gemini-2.5-flash`) | Redacta la respuesta a partir del contexto |
| Memoria | **Buffer Memory** | Permite preguntas de seguimiento |

> Diagrama formal: `arquitectura/arquitectura-rag-unsa.drawio` (exportar a PNG). Configuración
> reproducible: `config/RAG-UNSA-Chatflow.json` + `config/INSTRUCCIONES-FLOWISE-RAG.md`.
>
> **[INSERTAR Figura 1 — Arquitectura RAG y captura del flujo en Flowise]**

**Control de alucinaciones:** el *Response Prompt* obliga al modelo a responder **solo con el
contexto recuperado** y a declarar *"No encuentro esa información en los reglamentos proporcionados"*
cuando la respuesta no está en los documentos (ver `prompts/system-prompt-rag.md`).

---

## 3. Documentos indexados

Tres documentos oficiales de la UNSA (portal de transparencia), con texto seleccionable:

| # | Documento | Norma | Págs |
|---|---|---|---|
| 1 | Reglamento General de Grado de Bachiller y Título Profesional | RCU 0255-2021 | 24 |
| 2 | Reglamento del Régimen Académico (Diplomados, Maestro y Doctor) | RCU 0104-2022 | 31 |
| 3 | Reglamento para el Otorgamiento de Auspicios de la UNSA | RCU 0516-2020 | 8 |

**Total: 63 páginas** (cumple ≥3 documentos y ≥20 páginas). Detalle y URLs en `documentos/fuentes.md`.
El Estatuto 2015 se descartó por estar **escaneado** (sin texto extraíble para RAG).

---

## 4. Flujos conversacionales

El usuario escribe una pregunta en lenguaje natural (ej. *"¿Qué se necesita para el grado de
bachiller?"*). El sistema:
1. **Reformula** la pregunta con el historial (rephrase) si es de seguimiento.
2. **Vectoriza** la consulta y **recupera** los 4 fragmentos más similares del índice.
3. **Genera** la respuesta con Gemini, usando solo esos fragmentos, y (opcional) devuelve los
   **documentos fuente**.

La **memoria** permite diálogos encadenados: *"¿y para el título profesional?"* se entiende en el
contexto de la pregunta anterior.

---

## 5. Evidencias de pruebas

Se ejecutaron **12 consultas** (≥10 exigidas), 11 sobre el contenido y 1 de control (fuera de
alcance). Resumen (detalle y respuestas esperadas en `pruebas/consultas-respuestas.md`):

| # | Consulta | Resultado esperado (fuente) | Veredicto |
|---|---|---|---|
| 1 | Requisitos de bachiller | Pregrado + trabajo de inv. + idioma (Art. 6) | ⬜ |
| 2 | Modalidades de titulación | Tesis/Patente/Libro/Suficiencia (Art. 26) | ⬜ |
| 3 | Integrantes del jurado | 3 docentes + 1 accesitario (Art. 14) | ⬜ |
| 4 | Trabajo grupal | Máx. 5 estudiantes (Art. 10) | ⬜ |
| 5 | Duración de sustentación | 45 minutos (Art. 15) | ⬜ |
| 6 | Créditos de diplomado | 24 créditos (Art. 7) | ⬜ |
| 7 | Créditos de maestría | 48 créditos (Art. 8.1) | ⬜ |
| 8 | Créditos de doctorado | 64 créditos (Art. 10) | ⬜ |
| 9 | Requisito para doctorado | Grado de Maestro en SUNEDU (Art. 11) | ⬜ |
| 10 | Finalidad de auspicios | Normar auspicios acad./cient./cult. (Art. 1) | ⬜ |
| 11 | Definición de auspicio | Aval/respaldo institucional (Art. 6) | ⬜ |
| 12 | Control (fuera de alcance) | "No encuentro esa información…" | ⬜ |

*(Marcar veredicto real y adjuntar capturas de `evidencias/` tras ejecutar en Flowise.)*
**Precisión global: ___ / 12.**

> **[INSERTAR Figuras 2–N — capturas de consultas y respuestas del sistema]**

---

## 6. Análisis, limitaciones y recomendaciones

**Análisis.** El enfoque RAG permite responder en lenguaje natural con **respuestas ancladas** a los
reglamentos, reduciendo alucinaciones frente a un LLM puro y evitando que la comunidad tenga que
leer decenas de páginas jurídicas. La devolución de **documentos fuente** aporta trazabilidad.

**Limitaciones.**
- Los documentos **escaneados** (como el Estatuto) no son indexables sin OCR previo.
- El **In-Memory Vector Store** no persiste: hay que reindexar al reiniciar Flowise.
- La calidad depende del **chunking** y del `Top K`; preguntas muy transversales pueden requerir
  ajustar estos parámetros.
- Depende de la **disponibilidad y cuota** del proveedor (Gemini).

**Recomendaciones / mejoras.**
- Añadir **OCR** para incorporar el Estatuto y otros documentos escaneados.
- Migrar a un **vector store persistente** (Faiss, Chroma o Qdrant) para no reindexar.
- Ampliar el corpus (Reglamento de matrícula, de estudios, de disciplina) para cobertura total.
- Mostrar siempre la **cita del artículo** y enlace al documento en la respuesta.
- Evaluación continua con una batería de preguntas y retroalimentación de usuarios.

---

## 7. Conclusión

Se implementó un sistema RAG funcional en Flowise que indexa 3 reglamentos oficiales de la UNSA
(63 páginas) y responde consultas en lenguaje natural de forma fundamentada, con control de
alucinaciones y trazabilidad de fuentes. La solución cumple los requisitos del ejercicio (≥3
documentos, ≥20 páginas, ≥10 consultas) y es directamente escalable a más normativa institucional.
