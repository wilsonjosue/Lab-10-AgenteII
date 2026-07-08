# Construcción y prueba del sistema RAG (Reglamentos UNSA) en Flowise

> Sistema RAG que responde consultas en lenguaje natural sobre 3 reglamentos oficiales de la UNSA.
> Flowise 3.1.2 en Docker (el mismo del Ejercicio 1). Misma cuenta: `admin@finbot.local` / `Admin123!`.
> Misma credencial de Gemini (`gemini-key`) — sirve para el chat y para los embeddings.

---

## Arquitectura (9 nodos)
```
 3× PDF File Loader ─┐
 (Grados/Título,      │→ (Recursive Text Splitter) ─┐
  Régimen Acad.,      │                              ├─► In-Memory Vector Store ──► Retriever ─┐
  Auspicios)          │   Google Gemini Embeddings ──┘        (gemini-embedding-001)           │
                                                                                                 ▼
   👤 Usuario ─► Conversational Retrieval QA Chain ◄── Google Gemini (chat) + Buffer Memory ◄────┘
                          │
                          ▼  respuesta fundamentada + fuentes
```

## Componentes
| Nodo | Config |
|---|---|
| 3× **PDF File** (Document Loaders) | subir cada PDF de `../documentos/` |
| **Recursive Character Text Splitter** | Chunk Size `1500`, Overlap `200` |
| **Google Generative AI Embeddings** | Model `gemini-embedding-001`, credencial `gemini-key` |
| **In-Memory Vector Store** | Top K `4` |
| **ChatGoogleGenerativeAI** | `gemini-2.5-flash`, Temp `0.2`, credencial `gemini-key` |
| **Buffer Memory** | `chat_history` |
| **Conversational Retrieval QA Chain** | Return Source Documents `ON`; Response Prompt = `../prompts/system-prompt-rag.md` |

---

## Opción A — Importar el flujo
1. **Chatflows → Add New → ⋮ → Load Chatflow** → `config/RAG-UNSA-Chatflow.json`.
2. En los nodos **Google Gemini** y **Google Generative AI Embeddings** → selecciona la credencial `gemini-key`.
3. **Sube los PDFs**: en cada nodo **PDF File**, campo *Pdf File*, sube el PDF correspondiente de
   `../documentos/` (loader 1 = Grados y Títulos, loader 2 = Régimen Académico, loader 3 = Auspicios).
4. **Guarda** (💾). En la esquina superior derecha del canvas, pulsa el botón **verde de la base de datos
   / "Upsert Vector Database"** para **indexar** los documentos (esto genera los embeddings una vez).
5. Pasa a **Probar**.

## Opción B — Construir manualmente (si el import falla)
1. Arrastra 3× **PDF File** (Document Loaders) y sube un PDF en cada uno.
2. Arrastra **Recursive Character Text Splitter** (Chunk 1500 / Overlap 200) y conéctalo a la
   entrada *Text Splitter* de los 3 loaders.
3. Arrastra **Google Generative AI Embeddings** (`gemini-embedding-001`, credencial).
4. Arrastra **In-Memory Vector Store**: conecta los 3 loaders a *Document* y el embeddings a *Embeddings*. Top K = 4.
5. Arrastra **ChatGoogleGenerativeAI** (`gemini-2.5-flash`) y **Buffer Memory**.
6. Arrastra **Conversational Retrieval QA Chain**: conecta *Vector Store Retriever* (salida Retriever
   del vector store), *Chat Model* (Gemini) y *Memory* (Buffer). Activa **Return Source Documents**.
   Pega el **Response Prompt** de `../prompts/system-prompt-rag.md`.
7. **Guarda** y pulsa **Upsert** para indexar.

---

## Probar (Paso 5 de la guía)
Abre el chat y ejecuta las **12 consultas** de `../pruebas/consultas-respuestas.md`. Verifica que:
- las respuestas sean **correctas y fundamentadas** (idealmente citando el artículo),
- la **pregunta 12** (fuera de alcance) responda que no encuentra la información,
- si activaste *Return Source Documents*, revisa que **cite el documento** correcto.

Registra respuestas y capturas en `../pruebas/` y `../evidencias/`.

---

## Notas
- Los embeddings y el chat usan la **misma API key de Gemini** (`gemini-key`).
- El **In-Memory Vector Store** se reindexa al reiniciar; para persistencia usa Faiss (mejora futura).
- Si el import no conecta bien los nodos de carga (los loaders usan subida de archivos), usa la
  **Opción B** — es el camino estándar para RAG y solo toma unos minutos.
