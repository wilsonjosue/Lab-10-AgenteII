# ConsultaV2 — Batería de pruebas (2 documentos)

Consultas para el sistema RAG con **dos reglamentos** de temas distintos:
- **Doc 1 — Reglamento Disciplinario de Estudiantes** (RCU 0515-2020)
- **Doc 2 — Reglamento de Auspicios** (RCU 0516-2020)

12 consultas (11 de contenido + 1 de control). Respuestas **verificadas contra el texto real** de los
PDF, con su artículo. Ejecutar cada una en el chat, pegar la respuesta real y marcar el veredicto.

> **Tip:** cada pregunta en una **sesión de chat nueva** (icono 🗑️) para que el historial no reformule
> la consulta. Las preguntas 1 y 9 son la **prueba cruzada**: confirman que cada documento se cita
> correctamente sin confundirse con el otro.

---

## ⚖️ Doc 1 — Reglamento Disciplinario de Estudiantes

```
1. ¿Cuáles son los tipos de sanciones que se pueden imponer a un estudiante?
```
→ *Art. 12:* amonestación escrita · suspensión 1 semestre · separación 2 semestres · separación definitiva

```
2. ¿Cuál es la finalidad del Reglamento del Procedimiento Administrativo Disciplinario?
```
→ *Art. 1:* establecer el procedimiento disciplinario al que se ceñirán las autoridades para sancionar faltas

```
3. ¿A quiénes se aplica el reglamento disciplinario?
```
→ *Art. 4:* a los estudiantes matriculados en las Facultades de la UNSA

```
4. ¿Qué inconductas se consideran faltas leves?
```
→ *Art. 99 inc. a:* inobservancia de normas y directivas, inasistencia injustificada, etc.

```
5. Dame un ejemplo de falta grave según el reglamento.
```
→ *Art. 99 inc. b:* ingresar portando drogas, bebidas alcohólicas o armas de fuego

```
6. ¿Qué órganos intervienen en el procedimiento administrativo disciplinario?
```
→ Órgano Instructor, Órgano Sancionador y Órgano Revisor

```
7. ¿En qué plazo prescribe el procedimiento administrativo disciplinario?
```
→ tres (3) años desde que la autoridad conoce los hechos

```
8. ¿En qué plazo puede el estudiante presentar el recurso de apelación?
```
→ quince (15) días hábiles

## 🤝 Doc 2 — Reglamento de Auspicios

```
9. ¿Cuál es la finalidad del Reglamento de Auspicios de la UNSA?
```
→ *Art. 1:* normar el otorgamiento de auspicios académicos, científicos, culturales y artísticos

```
10. ¿Qué se entiende por "auspicio" según el reglamento?
```
→ *Art. 6:* el aval o respaldo institucional que otorga la Universidad

```
11. ¿Qué tipo de instituciones pueden solicitar un auspicio a la UNSA?
```
→ *Art. 1:* homólogas, colegios profesionales, sociedades científicas, empresas, etc.

## 🚫 Control (fuera de los documentos)

```
12. ¿Cuál es el horario de atención de la biblioteca central de la UNSA?
```
→ debe responder **"No encuentro esa información en los reglamentos proporcionados"**

---

## Tabla de resultados (llenar tras ejecutar)

| # | Consulta | Doc | Respuesta correcta | Citó doc correcto | Veredicto |
|---|---|---|---|---|---|
| 1 | Tipos de sanciones (Art. 12) | Disciplinario | ⬜ | ⬜ | |
| 2 | Finalidad del reglamento (Art. 1) | Disciplinario | ⬜ | ⬜ | |
| 3 | Ámbito de aplicación (Art. 4) | Disciplinario | ⬜ | ⬜ | |
| 4 | Faltas leves (Art. 99.a) | Disciplinario | ⬜ | ⬜ | |
| 5 | Ejemplo de falta grave (Art. 99.b) | Disciplinario | ⬜ | ⬜ | |
| 6 | Órganos del procedimiento | Disciplinario | ⬜ | ⬜ | |
| 7 | Prescripción (3 años) | Disciplinario | ⬜ | ⬜ | |
| 8 | Apelación (15 días hábiles) | Disciplinario | ⬜ | ⬜ | |
| 9 | Finalidad de auspicios (Art. 1) | Auspicios | ⬜ | ⬜ | |
| 10 | Definición de auspicio (Art. 6) | Auspicios | ⬜ | ⬜ | |
| 11 | Instituciones que solicitan auspicio | Auspicios | ⬜ | ⬜ | |
| 12 | Control (fuera de alcance) | — | ⬜ | — | |

**Precisión global: ____ / 12**

> La columna **"Citó doc correcto"** es clave con 2 documentos: verifica que una pregunta de sanciones
> cite el Disciplinario y una de auspicios cite Auspicios (que NO se crucen las fuentes).
