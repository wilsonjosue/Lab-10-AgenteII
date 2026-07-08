# Explicación de los nodos del sistema RAG (Flowise)

El chatflow usa **7 nodos** que trabajan en **dos fases**: primero se **indexa** el documento (una
sola vez, con el botón *Upsert*) y luego se **consulta** (cada vez que el usuario pregunta). A
continuación se explica cada nodo: qué es, para qué sirve y su configuración clave.

---

## FASE 1 — Indexación del documento (se ejecuta una sola vez con *Upsert*)

Convierte el PDF en un "índice" de vectores que la máquina puede buscar por significado.

### 1. PDF File — *Document Loader* (Cargador de documentos)
- **Qué es:** el nodo de entrada que **lee el archivo PDF** y extrae su texto.
- **Para qué sirve:** transforma el reglamento (PDF) en texto plano que el resto del flujo puede
  procesar. Sin esto, el sistema no "vería" el contenido del documento.
- **Configuración:**
  - *Pdf File:* `01_Reglamento_Disciplinario_Estudiantes.pdf`.
  - *Usage = perPage* (crea un documento por cada página).
  - *Additional Metadata:* `{"documento": "Reglamento Disciplinario de Estudiantes"}` — etiqueta cada
    fragmento con su origen, útil para citar la fuente.

### 2. Recursive Character Text Splitter — *Fragmentador de texto*
- **Qué es:** parte el texto extraído en **trozos pequeños llamados "chunks"**.
- **Para qué sirve:** un LLM no puede procesar 26 páginas de golpe ni buscar bien en un bloque
  gigante. Al dividir en fragmentos, la búsqueda recupera **solo el pedazo relevante** a la pregunta.
  Es "recursivo" porque intenta cortar respetando párrafos (`\n\n`), luego líneas (`\n`) y luego
  espacios, para no partir ideas a la mitad.
- **Configuración:**
  - *Chunk Size = 1000* caracteres por fragmento.
  - *Chunk Overlap = 200* — cada fragmento repite los últimos 200 caracteres del anterior, para que
    una idea que queda en el borde no se pierda.

### 3. Google Generative AI Embeddings — *Vectorizador*
- **Qué es:** un modelo que convierte cada fragmento de texto en un **vector numérico** (una lista de
  números que representa su *significado*).
- **Para qué sirve:** es el corazón de la "búsqueda por significado". Textos con ideas parecidas
  producen vectores cercanos entre sí, aunque usen distintas palabras. Así el sistema encuentra la
  respuesta aunque la pregunta no use las mismas palabras exactas del reglamento.
- **Configuración:**
  - *Model = `gemini-embedding-001`* (modelo de embeddings de Google).
  - *Task Type = `RETRIEVAL_DOCUMENT`* — le indica que los vectores se usarán para **búsqueda
    documental** (mejora la precisión de la recuperación).
  - Usa la misma credencial de Gemini que el chat.

### 4. In-Memory Vector Store — *Base de datos vectorial*
- **Qué es:** el **almacén** donde se guardan todos los vectores de los fragmentos, en la memoria del
  servidor.
- **Para qué sirve:** cuando llega una pregunta, este nodo compara el vector de la pregunta contra
  todos los vectores guardados y devuelve los **más similares** (los fragmentos más relevantes).
- **Configuración:**
  - *Top K = 20* — devuelve los 20 fragmentos más parecidos a cada consulta.
  - *"In-Memory"* significa rápido y sin instalar nada, pero **el índice se borra si se reinicia
    Flowise** → hay que volver a pulsar *Upsert*.

---

## FASE 2 — Consulta (se ejecuta en cada pregunta del usuario)

Toma la pregunta, recupera los fragmentos relevantes y genera una respuesta fundamentada.

### 5. ChatGoogleGenerativeAI (Google Gemini) — *Modelo de lenguaje (LLM)*
- **Qué es:** el "cerebro" que **redacta la respuesta** en lenguaje natural.
- **Para qué sirve:** recibe la pregunta del usuario junto con los fragmentos recuperados y escribe
  una respuesta clara, citando el artículo. **No inventa**: solo usa el contexto que se le entrega.
- **Configuración:**
  - *Model = `gemini-2.5-flash`* (rápido y con buen español).
  - *Temperature = 0.2* — valor bajo = respuestas **precisas y consistentes**, no creativas (ideal
    para un dominio jurídico donde no queremos que "adorne").

### 6. Buffer Memory — *Memoria conversacional (corto plazo)*
- **Qué es:** guarda el **historial de la conversación** actual (preguntas y respuestas anteriores).
- **Para qué sirve:** permite **preguntas de seguimiento**. Si preguntas *"¿y cuál es la más grave?"*
  después de haber preguntado por las sanciones, el sistema entiende a qué te refieres gracias a la
  memoria. Es la parte de "memoria de corto plazo" que pide la guía.
- **Configuración:** *Memory Key = `chat_history`* (nombre de la variable donde se guarda el diálogo).

### 7. Conversational Retrieval QA Chain — *Orquestador RAG*
- **Qué es:** el nodo **central que conecta todo** y ejecuta la lógica RAG completa.
- **Para qué sirve:** es el director de orquesta. En cada pregunta:
  1. **Reformula** la pregunta usando la memoria (si es de seguimiento).
  2. Pide al **Vector Store** los fragmentos más relevantes (el *contexto*).
  3. Entrega pregunta + contexto al **LLM (Gemini)** con el *Response Prompt* anti-alucinación.
  4. Devuelve la respuesta y los **documentos fuente** (trazabilidad).
- **Configuración:**
  - *Return Source Documents = ON* — muestra de qué fragmentos salió la respuesta.
  - *Response Prompt:* instrucciones que obligan a responder **solo con el contexto**, citar el
    artículo y decir *"No encuentro esa información…"* si no está en el documento.
  - **Conexiones:** recibe el *Retriever* (nodo 4), el *Chat Model* (nodo 5) y la *Memory* (nodo 6).

---

## Resumen visual del flujo

```
  [1] PDF File ──► [2] Text Splitter ──► [3] Embeddings ──► [4] Vector Store
   (lee PDF)        (trocea texto)       (texto→vectores)    (índice buscable)
                                                                    │
   Usuario pregunta                                                 │ (recupera contexto)
        │                                                           ▼
        └────────────────────► [7] Conversational Retrieval QA Chain
                                        ▲                    ▲
                                 [5] Gemini (LLM)     [6] Buffer Memory
                                 (redacta respuesta)  (recuerda el diálogo)
                                        │
                                        ▼
                          Respuesta fundamentada + artículo citado
```

**Idea central del RAG:** en vez de que el LLM responda "de memoria" (y alucine), primero se
**Recupera** (Retrieval) el fragmento correcto del reglamento y luego se **Genera** (Generation) la
respuesta a partir de ese fragmento. Por eso las respuestas quedan ancladas al documento oficial.

---

# Tecnologías aplicadas y para qué sirvieron

En esta actividad se combinaron varias tecnologías. La siguiente tabla resume **qué es cada una** y
**para qué sirvió** concretamente en el desarrollo del sistema RAG.

| Tecnología | Qué es | Para qué sirvió en esta actividad |
|---|---|---|
| **Flowise 3.1.2** | Plataforma *low-code* para construir aplicaciones de IA/LLM conectando nodos de forma visual (sin programar). | Fue el **entorno principal**: en su lienzo se armó todo el flujo RAG arrastrando y conectando los 7–8 nodos, sin escribir código. |
| **Docker (Docker Desktop + WSL2)** | Tecnología de contenedores que empaqueta una aplicación con todo lo que necesita para ejecutarse de forma aislada y reproducible. | Sirvió para **ejecutar Flowise** en el equipo (Windows 10) de manera aislada y estable, con persistencia de datos mediante un volumen. |
| **Google Gemini — `gemini-2.5-flash`** | Modelo de lenguaje grande (LLM) de Google. | Es el **"cerebro" que redacta las respuestas** en lenguaje natural a partir del contexto recuperado (Temperature 0.2 para precisión). |
| **Google Gemini — `gemini-embedding-001`** | Modelo de *embeddings* de Google (texto → vectores). | **Vectorizó** los fragmentos del reglamento y las preguntas, permitiendo la **búsqueda por significado** (Task Type `RETRIEVAL_DOCUMENT`). |
| **RAG (Retrieval-Augmented Generation)** | Técnica que combina un buscador documental con un LLM: primero recupera información y luego genera la respuesta con ella. | Es la **arquitectura central** del proyecto. Permitió responder sobre los reglamentos con respuestas fundamentadas y **menor alucinación**. |
| **Vector Store (In-Memory)** | Base de datos que almacena vectores y busca por similitud. | Guardó el **índice** de los fragmentos y devolvió los más relevantes (Top K) a cada consulta. |
| **LangChain** | Framework de software para construir aplicaciones con LLMs y agentes; Flowise lo usa **por debajo**. | Es el **motor interno** que ejecuta cada nodo (loaders, splitters, cadenas QA). No se programó directamente, pero es la base sobre la que corre Flowise. |
| **Buffer Memory** | Componente de memoria conversacional de corto plazo. | Dio al agente **memoria del diálogo** para entender preguntas de seguimiento (uno de los temas de la guía). |
| **PDF (documentos oficiales UNSA)** | Formato de los reglamentos institucionales. | Fue la **fuente de datos (base de conocimiento)** que alimentó el sistema: el Reglamento Disciplinario y el de Auspicios. |
| **Draw.io** | Herramienta de diagramación. | Se usó para elaborar el **diagrama de arquitectura** del pipeline RAG para el informe. |
| **Python 3.12 + PyPDF2** | Lenguaje de programación y librería de lectura de PDF. | Apoyo puntual: **verificar** que los PDF tuvieran texto extraíble (no escaneado) y **comprobar** los artículos de las respuestas esperadas. |

## Cómo encajan entre sí

- **Docker** aloja a **Flowise**, que es donde se diseña todo visualmente.
- Dentro de Flowise, **LangChain** ejecuta los nodos que implementan la técnica **RAG**.
- El RAG usa a **Google Gemini** en sus dos roles: *embeddings* (para buscar) y *chat* (para
  responder), apoyándose en un **Vector Store** y en la **Buffer Memory**.
- Los **PDF oficiales** son el conocimiento; **Draw.io** y **Python** fueron herramientas de apoyo
  para documentar y verificar.

> En conjunto, estas tecnologías permitieron cumplir el objetivo de la práctica: **implementar un
> agente de IA con memoria y recuperación de información (RAG)** que responde consultas en lenguaje
> natural sobre normativa institucional, de forma fundamentada y con trazabilidad de la fuente.
