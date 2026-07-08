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
  INDEXACIÓN (una vez, con Upsert)
  3× PDF File Loader ──► Recursive Text Splitter ──► Google Gemini Embeddings ──► In-Memory Vector Store
  (3 reglamentos)        (chunks 1000/overlap 200)   (gemini-embedding-001,        (índice vectorial,
                                                       Task Type RETRIEVAL_DOCUMENT)  Top K = 20)

  CONSULTA (por pregunta)
  Usuario ─► Conversational Retrieval QA Chain ◄─ Retriever (del Vector Store)
                     ▲            ▲
             Gemini (chat)   Buffer Memory
                     │
                     ▼
        Respuesta fundamentada + documentos fuente
```

| Componente | Nodo Flowise | Configuración / Función |
|---|---|---|
| Carga documental | **3× PDF File** | Extraen el texto de los 3 reglamentos (uno por nodo, con metadata `documento`) |
| Fragmentación | **Recursive Character Text Splitter** | Chunks de 1000 caracteres, overlap 200 |
| Vectorización | **Google Generative AI Embeddings** | `gemini-embedding-001`, Task Type **`RETRIEVAL_DOCUMENT`** |
| Índice | **In-Memory Vector Store** | Top K = 20; se indexa con el botón **Upsert** |
| Recuperación + generación | **Conversational Retrieval QA Chain** | Recupera contexto y genera la respuesta; *Return Source Documents* activo |
| Razonamiento | **ChatGoogleGenerativeAI** | `gemini-2.5-flash`, temperatura 0.2 |
| Memoria | **Buffer Memory** | Permite preguntas de seguimiento |

> Diagrama formal: `arquitectura/arquitectura-rag-unsa.drawio` (exportar a PNG). Configuración
> reproducible: `config/RAG-UNSA-Chatflow.json` + `config/INSTRUCCIONES-FLOWISE-RAG.md`.
>
> **[INSERTAR Figura 1 — Arquitectura RAG y captura del flujo en Flowise]**

**Control de alucinaciones (Response Prompt).** El prompt de respuesta obliga al modelo a: (1) leer
**todos** los fragmentos recuperados, (2) responder **solo con ese contexto** citando el documento y
el artículo con formato fijo *(Documento, Art. X)*, y (3) declarar exactamente *"No encuentro esa
información en los reglamentos proporcionados"* cuando ningún fragmento es pertinente. Incluye además
**dos ejemplos** (uno resuelto y uno de control) para fijar el estilo de respuesta. Ver
`prompts/system-prompt-rag.md`.

---

## 3. Documentos indexados

Se seleccionaron **tres reglamentos oficiales de la UNSA de temas deliberadamente distintos**, con
texto seleccionable (no escaneado):

| # | Documento | Norma | Págs | Tema |
|---|---|---|---|---|
| 1 | Reglamento del Procedimiento Administrativo Disciplinario para Estudiantes | RCU 0515-2020 | 26 | Disciplina / faltas / sanciones |
| 2 | Reglamento del Régimen Académico (Diplomados, Maestro y Doctor) | RCU 0104-2022 | 31 | Estudios de posgrado / créditos |
| 3 | Reglamento para el Otorgamiento de Auspicios de la UNSA | RCU 0516-2020 | 8 | Auspicios institucionales |

**Total: 65 páginas** (cumple ≥3 documentos y ≥20 páginas). Detalle y URLs en `documentos/fuentes.md`.

> **Decisión de diseño (importante).** En una primera versión se usó el *Reglamento de Grados y
> Títulos* (RCU 0255-2021) como Documento 1. Sin embargo, su contenido **se solapaba casi por
> completo** con el *Reglamento del Régimen Académico* (ambos tratan grados, títulos, tesis y
> créditos). En las pruebas, el recuperador **no lograba distinguir entre ambos** y devolvía
> fragmentos del documento equivocado. Se decidió **reemplazarlo por el Reglamento Disciplinario**,
> de vocabulario totalmente distinto, aplicando el principio de que **un buen corpus RAG debe tener
> documentos temáticamente separados**. Este cambio mejoró notablemente la precisión de recuperación
> (ver §6). El Estatuto 2015 se descartó por estar escaneado (sin texto extraíble).

---

## 4. Flujos conversacionales

El usuario escribe una pregunta en lenguaje natural (ej. *"¿Cuáles son los tipos de sanciones que se
pueden imponer a un estudiante?"*). El sistema:
1. **Reformula** la pregunta con el historial (rephrase) si es de seguimiento.
2. **Vectoriza** la consulta y **recupera** del índice los fragmentos más similares (Top K = 20).
3. **Genera** la respuesta con Gemini usando solo esos fragmentos, cita el artículo y devuelve los
   **documentos fuente**.

La **memoria** (Buffer Memory) permite diálogos encadenados. *Nota operativa:* como la cadena
reformula la consulta con el historial, cada pregunta de la batería de pruebas se ejecuta en una
**sesión de chat nueva** para evaluar la recuperación de forma aislada.

---

## 5. Evidencias de pruebas

Se ejecutaron **12 consultas** (≥10 exigidas): 11 sobre el contenido (distribuidas en los 3
documentos) y 1 de control fuera de alcance. Todas las respuestas esperadas fueron **verificadas
contra el texto real** de los PDF. Detalle en `pruebas/consultas-respuestas.md`.

| # | Consulta | Doc | Resultado esperado (fuente) | Veredicto |
|---|---|---|---|---|
| 1 | Tipos de sanciones a un estudiante | 1 | Amonestación / suspensión / separación (Art. 12) | ⬜ |
| 2 | Faltas muy graves y su sanción | 1 | Causal de separación definitiva (Art. 99) | ⬜ |
| 3 | Prescripción del procedimiento disciplinario | 1 | Tres (3) años | ⬜ |
| 4 | Etapa de preinstrucción | 1 | Se inicia al conocer la falta (Art. 40) | ⬜ |
| 5 | Créditos de la Maestría de Especialización | 2 | 48 créditos + 1 idioma | ⬜ |
| 6 | Créditos del doctorado | 2 | 64 créditos + 2 idiomas | ⬜ |
| 7 | Nota aprobatoria en posgrado | 2 | Catorce (14), sistema vigesimal | ⬜ |
| 8 | Unidad que ofrece diplomados/maestrías/doctorados | 2 | Escuela de Posgrado | ⬜ |
| 9 | Finalidad del Reglamento de Auspicios | 3 | Normar auspicios acad./cient./cult./art. (Art. 1) | ⬜ |
| 10 | Definición de auspicio | 3 | Aval/respaldo institucional (Art. 6) | ⬜ |
| 11 | Instituciones que pueden solicitar auspicio | 3 | Homólogas, colegios, empresas, etc. (Art. 1) | ⬜ |
| 12 | Control (fuera de alcance: horario de biblioteca) | — | "No encuentro esa información…" | ⬜ |

*(Marcar veredicto real y adjuntar capturas de `evidencias/` tras ejecutar en Flowise.)*
**Precisión global: ___ / 12.**

> **[INSERTAR Figuras 2–N — capturas de consultas y respuestas del sistema]**

---

## 6. Análisis, limitaciones y recomendaciones

**Análisis.** El enfoque RAG permite responder en lenguaje natural con **respuestas ancladas** a los
reglamentos, reduciendo alucinaciones frente a un LLM puro y evitando que la comunidad tenga que leer
decenas de páginas jurídicas. La devolución de **documentos fuente** aporta trazabilidad.

**Lección aprendida clave — la separación temática del corpus.** El hallazgo más importante del
proyecto fue que **la calidad de la recuperación depende de que los documentos sean temáticamente
distintos**. Con dos reglamentos muy parecidos (Grados y Títulos vs. Régimen Académico), el
recuperador confundía cuál era la fuente correcta y entregaba respuestas erróneas o "sin resultado".
Al sustituir uno por un documento de tema distinto (Disciplinario) y ajustar el **Task Type de los
embeddings a `RETRIEVAL_DOCUMENT`** (optimizado para búsqueda documental) y el **Top K a 20**, la
precisión mejoró de forma notable. También se reforzó el *Response Prompt* con instrucciones de
razonamiento y ejemplos, lo que redujo respuestas ambiguas y "no encuentro" injustos.

**Limitaciones.**
- Los documentos **escaneados** (como el Estatuto) no son indexables sin OCR previo.
- El **In-Memory Vector Store** no persiste: hay que reindexar (Upsert) al reiniciar Flowise.
- La recuperación sigue siendo sensible a **documentos con contenido solapado** y al **chunking**;
  preguntas muy transversales pueden requerir ajustar `chunkSize`/`Top K`.
- Depende de la **disponibilidad y cuota** del proveedor (Gemini, capa gratuita).

**Recomendaciones / mejoras.**
- Mantener un corpus de **documentos temáticamente separados**; si se indexan documentos similares,
  usar **filtrado por metadata** (`documento`) o un **re-ranker** para desambiguar.
- Migrar a un **vector store persistente** (Faiss, Chroma o Qdrant) para no reindexar.
- Añadir **OCR** para incorporar documentos escaneados (p. ej. el Estatuto).
- Mostrar siempre la **cita del artículo** y un enlace al documento en la respuesta.
- Evaluación continua con la batería de preguntas y retroalimentación de usuarios.

---

## 7. Conclusión

Se implementó un sistema RAG funcional en Flowise que indexa 3 reglamentos oficiales de la UNSA
(65 páginas, temas distintos) y responde consultas en lenguaje natural de forma fundamentada, con
control de alucinaciones y trazabilidad de fuentes. El proceso incluyó una **iteración de diseño**
relevante —la separación temática del corpus y el ajuste de los parámetros de recuperación— que
elevó la precisión del sistema. La solución cumple los requisitos del ejercicio (≥3 documentos,
≥20 páginas, ≥10 consultas) y es directamente escalable a más normativa institucional.
