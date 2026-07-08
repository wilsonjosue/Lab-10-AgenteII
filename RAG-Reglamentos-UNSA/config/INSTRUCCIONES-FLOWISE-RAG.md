# Construcción y prueba del sistema RAG (Reglamento Disciplinario UNSA) en Flowise

> Sistema RAG que responde consultas en lenguaje natural sobre el **Reglamento del Procedimiento
> Administrativo Disciplinario para Estudiantes de la UNSA** (RCU 0515-2020, 26 págs — cumple el
> mínimo de 20 páginas de la guía). Flowise 3.1.2 en Docker (el mismo del Ejercicio 1).
> Cuenta: `admin@finbot.local` / `Admin123!`. Credencial de Gemini: `gemini-key`.

> **Por qué UN solo documento:** la guía pide "uno o más documentos" con **mínimo 20 páginas**. En una
> primera versión se indexaron 3 reglamentos, pero dos de ellos (Grados y Títulos vs. Régimen
> Académico) se solapaban temáticamente y el recuperador confundía las fuentes. Con un único
> documento la recuperación es precisa y estable (ver INFORME §6 — lección aprendida).

---

## Arquitectura (7 nodos)
```
 PDF File Loader ──► (Recursive Text Splitter 1000/200) ──┐
 (Reglamento                                               ├─► In-Memory Vector Store ─► Retriever ─┐
  Disciplinario)      Google Gemini Embeddings ────────────┘   (Top K 20, botón Upsert)             │
                      (gemini-embedding-001,                                                        ▼
                       RETRIEVAL_DOCUMENT)     👤 Usuario ─► Conversational Retrieval QA Chain ◄── Google
                                                             (Return Sources ON, prompt anti-      Gemini (chat)
                                                              alucinación) ◄── Buffer Memory
                                                                      │
                                                                      ▼  respuesta + artículo citado
```

## Componentes
| Nodo | Config |
|---|---|
| **PDF File** (Document Loader) | subir `../documentos/01_Reglamento_Disciplinario_Estudiantes.pdf`; Metadata `{"documento": "Reglamento Disciplinario de Estudiantes"}` |
| **Recursive Character Text Splitter** | Chunk Size `1000`, Overlap `200` |
| **Google Generative AI Embeddings** | Model `gemini-embedding-001`, **Task Type `RETRIEVAL_DOCUMENT`**, credencial `gemini-key` |
| **In-Memory Vector Store** | Top K `20` |
| **ChatGoogleGenerativeAI** | `gemini-2.5-flash`, Temp `0.2`, credencial `gemini-key` |
| **Buffer Memory** | `chat_history` |
| **Conversational Retrieval QA Chain** | Return Source Documents `ON`; Response Prompt = `../prompts/system-prompt-rag.md` |

---

## Opción A — Importar el flujo
1. **Chatflows → Add New → ⋮ → Load Chatflow** → `config/RAG-UNSA-Chatflow.json`.
2. En **Google Gemini** (chat) y **Google Gemini Embedding** → selecciona la credencial `gemini-key`.
3. En el nodo **PDF File** → sube `../documentos/01_Reglamento_Disciplinario_Estudiantes.pdf`.
4. **Guarda** (💾).
5. **Indexar con Upsert:** pulsa el botón verde **"Upsert Vector Database"** (arriba a la derecha del
   canvas) → debe indicar los chunks añadidos (~100 Added). **Repite el Upsert cada vez que cambies**
   el PDF, el Task Type, el chunk size o el Top K (el prompt NO requiere re-upsert).
6. Pasa a **Probar**.

## Opción B — Construir manualmente (si el import falla)
1. Arrastra **PDF File** y sube el PDF del reglamento disciplinario.
2. Arrastra **Recursive Character Text Splitter** (Chunk 1000 / Overlap 200) → conéctalo a *Text Splitter* del loader.
3. Arrastra **Google Generative AI Embeddings** (`gemini-embedding-001`, **Task Type `RETRIEVAL_DOCUMENT`**, credencial).
   El Task Type es obligatorio (vacío → error 400); `RETRIEVAL_DOCUMENT` es el optimizado para indexar documentos consultables.
4. Arrastra **In-Memory Vector Store**: conecta el loader a *Document* y el embeddings a *Embeddings*. Top K = 20.
5. Arrastra **ChatGoogleGenerativeAI** (`gemini-2.5-flash`) y **Buffer Memory**.
6. Arrastra **Conversational Retrieval QA Chain**: conecta *Vector Store Retriever*, *Chat Model* y
   *Memory*. Activa **Return Source Documents** y pega el **Response Prompt** de `../prompts/system-prompt-rag.md`.
7. **Guarda** → **Upsert** → prueba.

---

## Probar (Paso 5 de la guía)
Ejecuta las **12 consultas** de `../pruebas/consultas-respuestas.md`, **cada una en una sesión de
chat nueva** (icono 🗑️), y verifica que:
- las respuestas sean **correctas** y **citen el artículo** (formato `(Documento, Art. X)`),
- la **pregunta 12** (fuera de alcance) responda que no encuentra la información.

Registra respuestas en la tabla del archivo de pruebas y guarda capturas en `../evidencias/`.

---

## Solución de problemas
- **429 `limit: 0`**: el proyecto de tu API key no tiene cuota para ese modelo → crea una key nueva en
  https://aistudio.google.com/apikey ("Create API key in new project").
- **429 quota exceeded normal**: espera el `retryDelay`, usa `gemini-2.5-flash-lite` y espacia las pruebas.
- **400 TASK_TYPE**: el Task Type de los embeddings no puede quedar vacío.
- **"No encuentro" a datos que sí existen**: (1) verifica que hiciste **Upsert después del último
  cambio** de parámetros; (2) prueba en **chat nuevo** (el historial reformula la consulta); (3) revisa
  los **Source Documents** de la respuesta para ver qué recuperó.
- **El índice se pierde al reiniciar Flowise**: es normal con In-Memory → vuelve a pulsar Upsert
  (mejora futura: Faiss/Chroma persistente).
