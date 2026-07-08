# Construcción y prueba del sistema RAG (Reglamentos UNSA) en Flowise

> Sistema RAG que responde consultas en lenguaje natural sobre 3 reglamentos oficiales de la UNSA.
> Flowise 3.1.2 en Docker (el mismo del Ejercicio 1). Misma cuenta: `admin@finbot.local` / `Admin123!`.
> Misma credencial de Gemini (`gemini-key`) — sirve para el chat y para los embeddings.

---

## Arquitectura (9 nodos)
```
 3× PDF File Loader ─┐
 (Disciplinario,      │→ (Recursive Text Splitter) ─┐
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
| **Recursive Character Text Splitter** | Chunk Size `1000`, Overlap `200` |
| **Google Generative AI Embeddings** | Model `gemini-embedding-001`, **Task Type `RETRIEVAL_DOCUMENT`**, credencial `gemini-key` |
| **In-Memory Vector Store** | Top K `20` |
| **ChatGoogleGenerativeAI** | `gemini-2.5-flash` (o `gemini-2.5-flash-lite` si tu proyecto tiene poca cuota), Temp `0.2`, credencial `gemini-key` |
| **Buffer Memory** | `chat_history` |
| **Conversational Retrieval QA Chain** | Return Source Documents `ON`; Response Prompt = `../prompts/system-prompt-rag.md` |

---

## Opción A — Importar el flujo
1. **Chatflows → Add New → ⋮ → Load Chatflow** → `config/RAG-UNSA-Chatflow.json`.
2. En los nodos **Google Gemini** y **Google Generative AI Embeddings** → selecciona la credencial `gemini-key`.
3. **Sube los PDFs**: en cada nodo **PDF File**, campo *Pdf File*, sube el PDF correspondiente de
   `../documentos/` (loader 1 = **Disciplinario de Estudiantes**, loader 2 = Régimen Académico, loader 3 = Auspicios).
   El orden importa para que la metadata `documento` de cada nodo coincida con su archivo.
4. **Guarda** (💾).
5. **Indexar con Upsert:** una vez que los **3 PDF File están conectados** a la entrada *Document*
   del Vector Store y guardaste, aparece el botón **verde "Upsert Vector Database"** arriba a la
   derecha del canvas. Púlsalo → indexa los documentos **una sola vez** (debe decir, p. ej.,
   `225 Added`). Repite el Upsert cada vez que cambies parámetros (Top K, chunk, etc.).
6. Pasa a **Probar**.

## Opción B — Construir manualmente (si el import falla)
1. Arrastra 3× **PDF File** (Document Loaders) y sube un PDF en cada uno.
2. Arrastra **Recursive Character Text Splitter** (Chunk 1000 / Overlap 200) y conéctalo a la
   entrada *Text Splitter* de los 3 loaders.
3. Arrastra **Google Generative AI Embeddings** (`gemini-embedding-001`, **Task Type = `RETRIEVAL_DOCUMENT`**, credencial). El Task Type es obligatorio: si queda vacío, la API responde 400; `RETRIEVAL_DOCUMENT` es el que Google optimiza para **indexar documentos que luego se consultan** (mejor precisión de recuperación que `SEMANTIC_SIMILARITY`). **Reindexa (Upsert) cada vez que cambies el Task Type.**
4. Arrastra **In-Memory Vector Store**: conecta los 3 loaders a *Document* y el embeddings a *Embeddings*. Top K = 20.
5. Arrastra **ChatGoogleGenerativeAI** (`gemini-2.5-flash`) y **Buffer Memory**.
6. Arrastra **Conversational Retrieval QA Chain**: conecta *Vector Store Retriever* (salida Retriever
   del vector store), *Chat Model* (Gemini) y *Memory* (Buffer). Activa **Return Source Documents**.
   Pega el **Response Prompt** de `../prompts/system-prompt-rag.md`.
7. **Guarda** y prueba (con In-Memory se indexa en la primera pregunta; con Faiss usa el botón Upsert).

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

## Solución de problemas de cuota (capa gratuita)
- **Error 429 con `limit: 0`** (p. ej. en `gemini-2.0-flash`): el proyecto de tu API key **no tiene
  cuota gratuita** para ese modelo. Solución: crea una **API key nueva en Google AI Studio**
  (https://aistudio.google.com/apikey → "Create API key in new project") y úsala en la credencial de
  Flowise. Un proyecto nuevo trae el free tier estándar (más generoso).
- **Error 429 «quota exceeded» normal**: agotaste el límite diario/por minuto del modelo. Espera el
  tiempo que indica `retryDelay`, usa un modelo con más cuota (`gemini-2.5-flash-lite`) y **espacia
  las pruebas** (una pregunta a la vez).
- **Respuestas «No encuentro esa información» a datos que sí existen** (recall pobre): dos causas
  frecuentes y su arreglo:
  1. **Task Type inadecuado.** Usa `RETRIEVAL_DOCUMENT` (optimizado para búsqueda documental) en vez de
     `SEMANTIC_SIMILARITY`, y **vuelve a Upsert** para reindexar con ese tipo. Si no reindexas, el índice
     queda con vectores del tipo viejo y la búsqueda falla.
  2. **La cadena reformula la pregunta con el historial.** El *Conversational Retrieval QA Chain* reescribe
     tu pregunta usando el chat previo antes de buscar; si en la misma sesión preguntaste otra cosa, mezcla
     los temas y busca en el documento equivocado. **Prueba cada consulta en una sesión de chat NUEVA**
     (icono de bote de basura / "New chat") para partir con historial vacío.
  - Además: confirma con *Return Source Documents* qué fragmentos se recuperan, y sube el **Top K** si hace falta.
- **Indexar una sola vez** (evita re-embeber en cada consulta): cambia el **In-Memory Vector Store**
  por **Faiss** (Base Path, p. ej. `/root/.flowise/faiss-unsa`), que sí ofrece botón **Upsert** y
  persiste el índice.
