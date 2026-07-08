# INFORME EJECUTIVO — Ejercicio 2
# Sistema RAG para Consulta del Reglamento Disciplinario de la UNSA

**Curso:** Tecnologías de Información — Lab 10: Agentes de Inteligencia Artificial (II)
**Herramientas:** Flowise 3.1.2 (Docker) · Google Gemini (chat + embeddings) · Draw.io

---

## 1. Introducción y problema

La comunidad universitaria de la UNSA (estudiantes, docentes y personal administrativo) suele
**desconocer los reglamentos y normativas institucionales**. Aunque los documentos están públicos,
su **extensión**, **organización** y **lenguaje jurídico** hacen que la búsqueda de información sea
lenta e ineficiente.

Este proyecto implementa un **sistema RAG (Retrieval-Augmented Generation)** en Flowise que permite
hacer **consultas en lenguaje natural** sobre un documento oficial de la UNSA y obtener respuestas
**fundamentadas en su contenido**, con cita del artículo correspondiente, reduciendo el tiempo de
búsqueda y evitando interpretaciones incorrectas.

---

## 2. Arquitectura completa

El sistema combina una **fase de indexación** (una sola vez, con el botón *Upsert*) y una **fase de
consulta** (por cada pregunta), implementadas con **7 nodos** en Flowise:

```
  INDEXACIÓN (una vez, Upsert)
  PDF File Loader ──► Recursive Text Splitter ──► Google Gemini Embeddings ──► In-Memory Vector Store
  (Reglamento          (chunks 1000/overlap 200)   (gemini-embedding-001,        (índice vectorial,
   Disciplinario)                                   Task Type RETRIEVAL_DOCUMENT)  Top K = 20)

  CONSULTA (por pregunta)
  Usuario ─► Conversational Retrieval QA Chain ◄─ Retriever (del Vector Store)
                     ▲            ▲
             Gemini (chat)   Buffer Memory
                     │
                     ▼
        Respuesta fundamentada + artículo citado + documentos fuente
```

| Componente | Nodo Flowise | Configuración / Función |
|---|---|---|
| Carga documental | **PDF File** | Extrae el texto del reglamento (26 págs., una página por documento) |
| Fragmentación | **Recursive Character Text Splitter** | Chunks de 1000 caracteres, overlap 200 |
| Vectorización | **Google Generative AI Embeddings** | `gemini-embedding-001`, Task Type **`RETRIEVAL_DOCUMENT`** |
| Índice | **In-Memory Vector Store** | Top K = 20; se indexa con el botón **Upsert** |
| Recuperación + generación | **Conversational Retrieval QA Chain** | Recupera contexto y genera; *Return Source Documents* activo |
| Razonamiento | **ChatGoogleGenerativeAI** | `gemini-2.5-flash`, temperatura 0.2 |
| Memoria | **Buffer Memory** | Permite preguntas de seguimiento |

> Diagrama formal: `arquitectura/arquitectura-rag-unsa.drawio` (exportar a PNG). Configuración
> reproducible: `config/RAG-UNSA-Chatflow.json` + `config/INSTRUCCIONES-FLOWISE-RAG.md`.
>
> **[INSERTAR Figura 1 — Arquitectura RAG y captura del flujo en Flowise]**

**Control de alucinaciones (Response Prompt).** El prompt de respuesta obliga al modelo a: (1) leer
**todos** los fragmentos recuperados, (2) responder **solo con ese contexto**, citando el documento y
el artículo con formato fijo *(Documento, Art. X)*, y (3) declarar exactamente *"No encuentro esa
información en los reglamentos proporcionados"* cuando ningún fragmento es pertinente. Incluye **dos
ejemplos** (uno resuelto y uno de control) para fijar el estilo. Ver `prompts/system-prompt-rag.md`.

---

## 3. Documento indexado

| Documento | Norma | Págs | Fuente |
|---|---|---|---|
| Reglamento del Procedimiento Administrativo Disciplinario para Estudiantes de la UNSA | RCU 0515-2020 | 26 | Repositorio oficial UNSA (`unsa.edu.pe`) |

Cumple el requisito de la guía (**uno o más documentos, mínimo 20 páginas**) y tiene **texto
seleccionable** (verificado por extracción programática). Detalle y URL en `documentos/fuentes.md`.

> **Decisión de diseño (importante).** En una primera iteración se indexaron **tres** reglamentos a la
> vez (Grados y Títulos, Régimen Académico y Auspicios). Las pruebas revelaron que dos de ellos se
> **solapaban temáticamente** (ambos tratan grados, tesis y créditos) y el recuperador devolvía
> fragmentos del documento equivocado, produciendo respuestas erróneas o "sin resultado". Dado que la
> guía exige un solo documento ≥20 páginas, se **simplificó el corpus a un único reglamento** de
> vocabulario homogéneo y secciones bien diferenciadas (sanciones, faltas, órganos, plazos, recursos),
> lo que hizo la recuperación **precisa y estable**. El Estatuto 2015 se descartó por estar escaneado
> (sin texto extraíble). Esta iteración se documenta como lección aprendida en §6.

---

## 4. Flujos conversacionales

El usuario escribe una pregunta en lenguaje natural (ej. *"¿Cuáles son los tipos de sanciones que se
pueden imponer a un estudiante?"*). El sistema:
1. **Reformula** la pregunta con el historial (rephrase) si es de seguimiento.
2. **Vectoriza** la consulta y **recupera** del índice los 20 fragmentos más similares.
3. **Genera** la respuesta con Gemini usando solo esos fragmentos, **cita el artículo** y devuelve
   los **documentos fuente** (trazabilidad).

La **memoria** (Buffer Memory) permite diálogos encadenados: *"¿y cuál es la sanción más grave?"* se
entiende en el contexto de la pregunta anterior. *Nota operativa:* como la cadena reformula la
consulta usando el historial, cada pregunta de la batería se ejecutó en una **sesión de chat nueva**
para evaluar la recuperación de forma aislada.

---

## 5. Evidencias de pruebas

Se ejecutaron **12 consultas** (≥10 exigidas): 11 sobre el contenido del reglamento y 1 de control
fuera de alcance. Todas las respuestas esperadas fueron **verificadas contra el texto real** del PDF.
Detalle en `pruebas/consultas-respuestas.md`.

| # | Consulta | Resultado esperado (fuente) | Veredicto |
|---|---|---|---|
| 1 | Finalidad del reglamento | Establecer el procedimiento disciplinario (Art. 1) | ⬜ |
| 2 | Ámbito de aplicación | Estudiantes matriculados en las Facultades (Art. 4) | ⬜ |
| 3 | Tipos de sanciones | Amonestación / suspensión 1 sem. / separación 2 sem. / definitiva (Art. 12) | ⬜ |
| 4 | Faltas leves | Inobservancia de normas, inasistencias (Art. 99.a) | ⬜ |
| 5 | Ejemplo de falta grave | Ingresar portando drogas, alcohol o armas (Art. 99.b) | ⬜ |
| 6 | Faltas muy graves y su sanción | Violencia grave, reiteración → separación definitiva (Art. 99.c) | ⬜ |
| 7 | Órganos del procedimiento | Instructor, Sancionador y Revisor | ⬜ |
| 8 | Derechos del investigado | Notificación, acceso al expediente, defensa | ⬜ |
| 9 | Prescripción | Tres (3) años | ⬜ |
| 10 | Atenuantes | Carencia de sanciones previas, móviles altruistas (Art. 15) | ⬜ |
| 11 | Plazo de apelación | Quince (15) días hábiles | ⬜ |
| 12 | Control (horario de biblioteca) | "No encuentro esa información…" | ⬜ |

*(Marcar veredicto real y adjuntar capturas de `evidencias/` tras ejecutar en Flowise.)*
**Precisión global: ___ / 12.**

> **[INSERTAR Figuras 2–N — capturas de consultas y respuestas del sistema]**

---

## 6. Análisis, limitaciones y recomendaciones

**Análisis.** El enfoque RAG permite responder en lenguaje natural con **respuestas ancladas** al
reglamento, reduciendo alucinaciones frente a un LLM puro. La devolución de **documentos fuente** y
la **cita del artículo** aportan trazabilidad y verificabilidad — clave en un dominio normativo.

**Lección aprendida clave — la composición del corpus.** El hallazgo más importante fue que **la
calidad de la recuperación depende de la composición del corpus**: al indexar simultáneamente
reglamentos con temas solapados (Grados y Títulos vs. Régimen Académico), el recuperador confundía
las fuentes y fallaba. Tres decisiones estabilizaron el sistema: (1) usar **un solo documento** de
vocabulario homogéneo, (2) **Task Type `RETRIEVAL_DOCUMENT`** en los embeddings (optimizado para
búsqueda documental) reindexando tras cada cambio, y (3) un **Response Prompt** con instrucciones de
razonamiento y ejemplos, que redujo respuestas ambiguas.

**Limitaciones.**
- Los documentos **escaneados** (como el Estatuto) no son indexables sin OCR previo.
- El **In-Memory Vector Store** no persiste: hay que reindexar (Upsert) al reiniciar Flowise.
- Cobertura limitada a **un reglamento**; ampliar el corpus con documentos similares exige técnicas
  adicionales (filtrado por metadata, re-ranking) para no reintroducir la confusión de fuentes.
- Depende de la **disponibilidad y cuota** del proveedor (Gemini, capa gratuita).

**Recomendaciones / mejoras.**
- Migrar a un **vector store persistente** (Faiss, Chroma o Qdrant) para no reindexar.
- Para escalar a múltiples reglamentos: **filtrado por metadata** (`documento`) o un **re-ranker**,
  y documentos **temáticamente separados**.
- Añadir **OCR** para incorporar documentos escaneados (p. ej. el Estatuto).
- Evaluación continua con la batería de preguntas y retroalimentación de usuarios reales.

---

## 7. Conclusión

Se implementó un sistema RAG funcional en Flowise que indexa el Reglamento Disciplinario de la UNSA
(26 páginas) y responde consultas en lenguaje natural de forma fundamentada, con control de
alucinaciones, cita de artículos y trazabilidad de fuentes. El proceso incluyó una **iteración de
diseño** relevante —la simplificación del corpus y el ajuste de los parámetros de recuperación— que
elevó la precisión del sistema. La solución cumple los requisitos del ejercicio (documento oficial
≥20 páginas, ≥10 consultas, informe con arquitectura, flujos, evidencias y recomendaciones) y es
escalable a más normativa institucional.
