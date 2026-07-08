# Batería de pruebas — Sistema RAG Reglamentos UNSA

12 consultas en lenguaje natural (11 de contenido + 1 de control; ≥10 exigidas). Los **tres
documentos son de temas distintos** (disciplina, posgrado, auspicios) para que la recuperación no
se confunda entre reglamentos que se solapan. Respuestas **verificadas contra el texto real** de los
PDF (número de artículo incluido). Ejecutar cada consulta en el chat, pegar la respuesta real y
marcar el veredicto. Capturas en `../evidencias/`.

> **Tip:** prueba cada pregunta en una **sesión de chat nueva** (icono de bote de basura) para que el
> historial no reformule la consulta. La pregunta 12 es de control: debe reconocer que la info no está.

---

### Doc 1 — Reglamento del Procedimiento Administrativo Disciplinario para Estudiantes (RCU 0515-2020)

**1. ¿Cuáles son los tipos de sanciones que se pueden imponer a un estudiante?**
*Esperado (Art. 12):* a) Amonestación escrita, b) Suspensión por un (01) semestre académico,
c) Separación por dos (02) semestres académicos, d) Separación definitiva.

**2. ¿Qué conductas se consideran faltas muy graves y qué sanción pueden acarrear?**
*Esperado (Art. 99, inc. c):* p. ej. la reiteración de faltas ya sancionadas con suspensión, la
violencia grave contra un miembro de la comunidad universitaria, etc.; **pueden ser causal de
separación definitiva**.

**3. ¿En qué plazo prescribe el procedimiento administrativo disciplinario contra un estudiante?**
*Esperado:* en el plazo de **tres (3) años** contados desde que la autoridad toma conocimiento de los hechos.

**4. ¿En qué consiste la etapa de preinstrucción del procedimiento disciplinario?**
*Esperado (Art. 40):* etapa que **se inicia al tomar conocimiento** de la supuesta comisión de una
falta, de oficio o a pedido de parte.

### Doc 2 — Reglamento del Régimen Académico (RCU 0104-2022) — posgrado

**5. ¿Cuántos créditos mínimos requiere la Maestría de Especialización?**
*Esperado:* dos (2) semestres con un mínimo de **cuarenta y ocho (48) créditos** + dominio de un idioma extranjero.

**6. ¿Cuántos créditos mínimos requiere el doctorado?**
*Esperado:* mínimo **sesenta y cuatro (64) créditos** + dominio de **dos (2) idiomas extranjeros**.

**7. ¿Cuál es la nota aprobatoria en los estudios de posgrado?**
*Esperado:* sistema vigesimal, nota aprobatoria **catorce (14)**.

**8. ¿A través de qué unidad se realizan los diplomados, maestrías y doctorados?**
*Esperado:* a través de la **Escuela de Posgrado** de la Universidad.

### Doc 3 — Reglamento de Auspicios (RCU 0516-2020)

**9. ¿Cuál es la finalidad del Reglamento de Auspicios de la UNSA?**
*Esperado (Art. 1):* normar el otorgamiento de **auspicios académicos, científicos, culturales y artísticos** de la Universidad.

**10. ¿Qué se entiende por "auspicio" según el reglamento?**
*Esperado (Art. 6):* el **aval o respaldo institucional** que otorga la Universidad.

**11. ¿Qué tipo de instituciones pueden solicitar un auspicio a la UNSA?**
*Esperado (Art. 1):* instituciones homólogas, colegios profesionales, sociedades científicas, centros
culturales, instituciones educativas, empresas privadas y públicas y otras con personería jurídica.

### Control (fuera de los documentos)

**12. ¿Cuál es el horario de atención de la biblioteca central de la UNSA?**
*Esperado:* debe responder que **no encuentra esa información en los reglamentos proporcionados**.

---

## Tabla de resultados (llenar tras ejecutar)

| # | Consulta | Doc | Respuesta correcta | Citó fuente | Veredicto |
|---|---|---|---|---|---|
| 1 | Tipos de sanciones (Art. 12) | 1 | ⬜ | ⬜ | |
| 2 | Faltas muy graves → separación definitiva | 1 | ⬜ | ⬜ | |
| 3 | Prescripción del procedimiento (3 años) | 1 | ⬜ | ⬜ | |
| 4 | Etapa de preinstrucción (Art. 40) | 1 | ⬜ | ⬜ | |
| 5 | Créditos de maestría (48) | 2 | ⬜ | ⬜ | |
| 6 | Créditos de doctorado (64 + 2 idiomas) | 2 | ⬜ | ⬜ | |
| 7 | Nota aprobatoria posgrado (14) | 2 | ⬜ | ⬜ | |
| 8 | Diplomados/maestrías/doctorados → Escuela de Posgrado | 2 | ⬜ | ⬜ | |
| 9 | Finalidad de auspicios (Art. 1) | 3 | ⬜ | ⬜ | |
| 10 | Definición de auspicio (Art. 6) | 3 | ⬜ | ⬜ | |
| 11 | Quiénes solicitan auspicio | 3 | ⬜ | ⬜ | |
| 12 | Control (fuera de alcance) | — | ⬜ | — | |

**Precisión global: ____ / 12**
