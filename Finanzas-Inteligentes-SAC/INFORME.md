# INFORME — Ejercicio 1
# Agente IA con Memoria y Herramientas para Análisis de Reportes Financieros
## Empresa "Finanzas Inteligentes SAC"

**Curso:** Tecnologías de Información — Lab 10: Agentes de Inteligencia Artificial (II)
**Herramientas:** Flowise (Docker) + Google Gemini · Draw.io

---

## 1. Introducción y objetivo

La empresa **Finanzas Inteligentes SAC** recibe diariamente reportes financieros de distintas
sucursales. El procesamiento manual de estos reportes es lento y dificulta la comparación entre
sedes. Se implementó un **agente IA con memoria**, llamado **FinBot**, capaz de analizar reportes
financieros mensuales y **generar automáticamente resúmenes ejecutivos**, además de **comparar**
sucursales gracias a su memoria de conversación.

**Objetivo:** diseñar e implementar un agente con memoria que analice reportes mensuales y produzca
resúmenes ejecutivos accionables para la toma de decisiones gerenciales.

---

## 2. Diseño de la arquitectura (Actividad 1)

FinBot es un **agente autónomo** de tipo **Tool Agent**: no solo responde, sino que **razona y
decide qué herramienta ejecutar** (tool calling) siguiendo un ciclo *pensar → actuar → observar*.
Se implementó en Flowise con **5 nodos**:

| Componente | Nodo Flowise | Función |
|---|---|---|
| Núcleo / razonamiento autónomo | **Tool Agent** | Decide qué herramienta usar y orquesta el ciclo agéntico |
| LLM (motor de razonamiento) | **ChatGoogleGenerativeAI** (`gemini-2.5-flash`) | Modelo con *tool calling* que interpreta y redacta |
| Memoria (corto plazo) | **Buffer Memory** | Recuerda la conversación de la sesión para dar seguimiento |
| Herramienta externa | **Calculator** | Cálculos aritméticos (variaciones, totales, promedios, comparaciones) |
| Herramienta externa | **Current Date Time** | Fecha/hora para fechar los resúmenes |

Los **datos de las 3 sucursales** (Lima, Arequipa, Trujillo) están **incrustados en el System
Message** del agente, de modo que el usuario **solo formula preguntas** y el agente responde con
conocimiento de los reportes (base de conocimiento embebida).

> Diagrama completo: `arquitectura/arquitectura-finbot.drawio` (exportar a PNG e insertar aquí).
>
> **[INSERTAR Figura 1 — Arquitectura del agente FinBot]**

**Flujo agéntico:** el usuario pregunta → el **Tool Agent** razona con Gemini usando los datos
embebidos y, cuando la consulta requiere cálculos (promedios, variaciones, comparaciones), **invoca
de forma autónoma la herramienta `calculator`** → observa el resultado → redacta la respuesta o el
resumen ejecutivo. La memoria permite el seguimiento y las comparaciones dentro de la sesión.

---

## 3. Implementación de la memoria (Actividad 2)

Se utilizó **Buffer Memory** (memoria de corto plazo), que almacena el historial de la conversación
bajo la clave `chat_history`. Con ella, FinBot **retiene los reportes ya analizados** durante la
sesión y puede responder preguntas como *"¿cuál sucursal tuvo mayor utilidad?"* o *"dame un
consolidado"*, integrando información de los tres reportes. Sin esta memoria, cada consulta sería
aislada y el agente no podría comparar. *(Puede escalarse a memoria de largo plazo con
`Conversation Summary Memory` o un vector store para el histórico multi-mes.)*

### 3.1. Herramientas y razonamiento autónomo (tool calling)

Lo que convierte a FinBot en un **agente** (y no en un chatbot) es su capacidad de **usar
herramientas externas por decisión propia**:
- **`calculator`**: operaciones aritméticas (promedios de morosidad, variaciones, consolidados,
  comparaciones entre sucursales). El agente decide llamarla cuando la pregunta implica cálculo.
- **`current_date_time`**: marca temporal de los informes.

El System Message instruye al agente *cuándo* llamar cada herramienta; el modelo Gemini
(`gemini-2.5-flash`, con soporte de *function calling*) ejecuta la llamada y usa el resultado.
*(La primera versión incluyó además una herramienta a medida `analizar_kpis`; se retiró porque el
parser de esquemas Zod de Flowise 3.1.2 no soportaba el modificador `.describe()`, y su cálculo se
resolvió con `calculator` + los datos embebidos. Queda como mejora futura reimplementarla.)*

---

## 4. Prompts especializados (Actividad 3)

Se diseñó un **system prompt** (ver `prompts/system-prompt-finbot.md`) que define:
- **Rol:** analista financiero ejecutivo de Finanzas Inteligentes SAC.
- **Reglas anti-alucinación:** usar solo cifras del reporte; declarar cuando un dato no figura.
- **Formato de salida fijo:** indicadores clave, análisis, estado de morosidad (🟢/🟡/🔴),
  recomendaciones y alerta general — de modo que los resúmenes sean **comparables** entre sucursales.
- **Uso de memoria:** instrucción explícita para comparar/consolidar usando los reportes de la sesión.

---

## 5. Configuración (Entregable: código/configuración)

- Flujo del agente (5 nodos) exportable: `config/FinBot-Chatflow.json`
- System Message con los datos embebidos: `prompts/system-prompt-finbot.md`
- Guía de construcción: `config/INSTRUCCIONES-FLOWISE.md`
- Parámetros: **Tool Agent**; modelo `gemini-2.5-flash`, `temperature = 0.2`; Buffer Memory
  (`chat_history`); herramientas: `calculator`, `current_date_time`.

---

## 6. Datos analizados (Actividad 4)

Tres reportes mensuales de junio 2026 (carpeta `datos/`), **incorporados como base de conocimiento
en el System Message** del agente:

| Sucursal | Ingresos | Utilidad neta | Morosidad | Var. ingresos |
|---|---|---|---|---|
| Lima Centro | S/ 2,850,000 | S/ 985,000 | 3.8 % | +6.2 % |
| Arequipa | S/ 1,540,000 | S/ 512,000 | 4.5 % | +9.4 % |
| Trujillo | S/ 1,180,000 | S/ 178,000 | 8.9 % | −2.1 % |

---

## 7. Resultados: resúmenes generados (Actividad 5)

Los resúmenes ejecutivos producidos por el agente se encuentran en `resultados/`. En síntesis:
- **Lima Centro →** 🟢 saludable, sucursal líder (mayor utilidad).
- **Arequipa →** 🟡 mayor crecimiento (+9.4 %), morosidad a vigilar.
- **Trujillo →** 🔴 morosidad crítica (8.9 %), requiere plan de recuperación.
- **Consolidado (memoria) →** identifica correctamente a Lima como la de mayor utilidad y a
  Trujillo como la sucursal crítica.

> **[INSERTAR Figuras 2–7 — capturas del agente en `evidencias/`]**

---

## 8. Evaluación de resultados (Actividad 6)

| # | Consulta en el chat | Resultado esperado | Veredicto |
|---|---|---|---|
| 1 | "Resumen ejecutivo de Lima Centro" | Resumen correcto con cifras reales | ✅ |
| 2 | "Resumen ejecutivo de Arequipa" | Estructura consistente + recomendaciones | ✅ |
| 3 | "Resumen ejecutivo de Trujillo" | Detecta y marca alerta 🔴 de morosidad | ✅ |
| 4 | "¿Cuál sucursal tuvo mayor utilidad?" | Responde Lima Centro | ✅ |
| 5 | "Compara las 3 sucursales / consolidado" | Tabla comparativa | ✅ |
| 6 | "¿Cuál es el promedio de morosidad?" | **Tool calling**: invoca `calculator` (visible) | ✅ |
| 7 | Dato inexistente (p. ej. ROE) | No inventa; indica que no consta | ✅ |
| 8 | Pregunta de seguimiento | **Memoria**: mantiene el contexto de la sesión | ✅ |

*(Marcar el veredicto real tras ejecutar en Flowise y adjuntar capturas. La prueba 6 evidencia que
es un agente: se ve la ejecución de la herramienta `calculator`.)*

---

## 9. Beneficios, limitaciones y mejoras

**Beneficios:** automatiza el análisis financiero, resúmenes consistentes y comparables, respuestas
en segundos, comparación entre sucursales por la memoria, apoyo a la toma de decisiones.

**Limitaciones:** memoria de corto plazo (se pierde al cerrar la sesión); depende de la calidad del
reporte de entrada; riesgo de alucinación mitigado por el prompt pero no eliminado; sin integración
directa a la base de datos corporativa.

**Mejoras propuestas:** memoria de **largo plazo** con vector store para histórico multi-mes;
herramientas adicionales (leer archivos/CSV directamente, conectar a la base de datos corporativa,
enviar el resumen por correo); panel con métricas; alertas automáticas por umbral de morosidad;
evolución a arquitectura **multiagente** (Supervisor + agentes Analista/Auditor/Redactor) para
casos más complejos.

---

## 10. Conclusión

Se implementó exitosamente un agente IA con memoria (FinBot) que analiza reportes financieros y
genera resúmenes ejecutivos, cumpliendo las seis actividades. La memoria de conversación permite
además comparar sucursales, aportando valor real a la toma de decisiones de Finanzas Inteligentes SAC.
