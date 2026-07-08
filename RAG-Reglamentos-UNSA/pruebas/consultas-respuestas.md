# Batería de pruebas — Sistema RAG Reglamentos UNSA

12 consultas en lenguaje natural (≥10 exigidas). Las **respuestas esperadas** están verificadas
contra los documentos oficiales (se cita el artículo). Ejecutar cada una en el chat de Flowise,
pegar la respuesta real del sistema y marcar el veredicto. Capturas en `../evidencias/`.

> Umbral esperado: respuesta correcta y **fundamentada en el documento** (idealmente citando el
> artículo). La pregunta 12 es de control: debe reconocer que la info no está en los reglamentos.

---

### Doc 1 — Reglamento de Grados y Títulos (RCU 0255-2021)

**1. ¿Qué se requiere para obtener el Grado Académico de Bachiller?**
*Esperado (Art. 6):* haber aprobado los estudios de pregrado, la **sustentación de un Trabajo de
Investigación** (o un trabajo acreditado como artículo para publicación en revista indexada Scopus
o Web of Science) y el **conocimiento de un idioma extranjero** (de preferencia inglés) o una
lengua nativa.

**2. ¿Cuáles son las modalidades para obtener el Título Profesional?**
*Esperado (Art. 26):* (1) Tesis o publicación/exposición de Tesis en Formato Artículo en revista
indexada Scopus/WoS; (2) Tesis Formato Patente de Invención; (3) Tesis Formato Libro evaluado por
pares externos; (4) Trabajo de **Suficiencia Profesional** (3 años en un centro de trabajo
calificado); (5) otras autorizadas por ley.

**3. ¿Por cuántos miembros está integrado el jurado calificador del trabajo de investigación?**
*Esperado (Art. 14):* **tres (3) docentes** ordinarios o contratados —el asesor forma parte pero no
puede presidir— más **un (1) accesitario**.

**4. ¿El trabajo de investigación se puede hacer en grupo? ¿De cuántos estudiantes?**
*Esperado (Art. 10):* sí, individual o grupal, **máximo cinco (5) estudiantes**, garantizando la
responsabilidad individual.

**5. ¿Cuánto tiempo dura la sustentación del trabajo de investigación?**
*Esperado (Art. 15):* un máximo de **cuarenta y cinco (45) minutos** para la exposición.

### Doc 2 — Reglamento del Régimen Académico (RCU 0104-2022)

**6. ¿Cuántos créditos mínimos exige un diplomado de posgrado?**
*Esperado (Art. 7):* mínimo de **veinticuatro (24) créditos**.

**7. ¿Cuántos créditos requiere la Maestría de Especialización?**
*Esperado (Art. 8.1):* dos (2) semestres con un mínimo de **cuarenta y ocho (48) créditos** y la
certificación del dominio de un idioma extranjero.

**8. ¿Cuántos créditos mínimos requiere el doctorado?**
*Esperado (Art. 10):* mínimo de **sesenta y cuatro (64) créditos** y el dominio de un idioma
extranjero.

**9. ¿Qué requisito se necesita para postular al doctorado?**
*Esperado (Art. 10/11.1):* tener el **grado académico de Maestro registrado en SUNEDU**.

### Doc 3 — Reglamento de Auspicios (RCU 0516-2020)

**10. ¿Cuál es la finalidad del Reglamento de Auspicios de la UNSA?**
*Esperado (Art. 1):* normar el otorgamiento de **auspicios académicos, científicos, culturales y
artísticos** de la Universidad.

**11. ¿Qué se entiende por "auspicio" según el reglamento?**
*Esperado (Art. 6):* el **aval o respaldo institucional** que otorga la Universidad.

### Control (fuera de los documentos)

**12. ¿Cuál es el horario de atención de la biblioteca central de la UNSA?**
*Esperado:* el sistema debe responder que **no encuentra esa información en los reglamentos
proporcionados** (no debe inventar).

---

## Tabla de resultados (llenar tras ejecutar)

| # | Consulta | Respuesta correcta | Citó documento/artículo | Veredicto |
|---|---|---|---|---|
| 1 | Requisitos de bachiller | ⬜ | ⬜ | |
| 2 | Modalidades de titulación | ⬜ | ⬜ | |
| 3 | Integrantes del jurado | ⬜ | ⬜ | |
| 4 | Trabajo grupal (máx. 5) | ⬜ | ⬜ | |
| 5 | Duración de sustentación | ⬜ | ⬜ | |
| 6 | Créditos de diplomado | ⬜ | ⬜ | |
| 7 | Créditos de maestría | ⬜ | ⬜ | |
| 8 | Créditos de doctorado | ⬜ | ⬜ | |
| 9 | Requisito para doctorado | ⬜ | ⬜ | |
| 10 | Finalidad de auspicios | ⬜ | ⬜ | |
| 11 | Definición de auspicio | ⬜ | ⬜ | |
| 12 | Control (fuera de alcance) | ⬜ | — | |

**Precisión global: ____ / 12**
