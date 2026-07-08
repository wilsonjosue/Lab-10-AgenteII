# Batería de pruebas — Sistema RAG Reglamento Disciplinario UNSA

12 consultas en lenguaje natural (11 de contenido + 1 de control; ≥10 exigidas por la guía), todas
sobre el **Reglamento del Procedimiento Administrativo Disciplinario para Estudiantes de la UNSA**
(RCU 0515-2020, 26 páginas). Cada respuesta esperada fue **verificada contra el texto real del PDF**
(con su artículo). Ejecutar cada consulta en el chat, pegar la respuesta real y marcar el veredicto.
Capturas en `../evidencias/`.

> **Tip:** prueba cada pregunta en una **sesión de chat nueva** (icono de bote de basura) para que el
> historial no reformule la consulta. La pregunta 12 es de control: debe reconocer que la info no está.

---

**1. ¿Cuál es la finalidad del Reglamento del Procedimiento Administrativo Disciplinario?**
*Esperado (Art. 1):* establecer el Procedimiento Administrativo Disciplinario al que obligatoriamente
se ceñirán las autoridades para aplicar sanciones a los estudiantes que incurran en faltas.

**2. ¿A quiénes se aplica el reglamento disciplinario?**
*Esperado (Art. 4 — Ámbito de aplicación):* a las inconductas cometidas por los **estudiantes
matriculados** en las diferentes Facultades de la UNSA.

**3. ¿Cuáles son los tipos de sanciones que se pueden imponer a un estudiante?**
*Esperado (Art. 12):* a) **Amonestación escrita**, b) **Suspensión por un (01) semestre académico**,
c) **Separación por dos (02) semestres académicos**, d) **Separación definitiva**.

**4. ¿Qué inconductas se consideran faltas leves?**
*Esperado (Art. 99, inc. a):* p. ej. la inobservancia de las normas y directivas generales de la
Universidad, la inasistencia injustificada a actividades, etc.

**5. Dame un ejemplo de falta grave según el reglamento.**
*Esperado (Art. 99, inc. b):* p. ej. **ingresar a la Universidad portando drogas, bebidas alcohólicas
o armas de fuego**, o consumirlas.

**6. ¿Qué conductas constituyen faltas muy graves y qué sanción pueden acarrear?**
*Esperado (Art. 99, inc. c):* la reiteración de faltas ya suspendidas, la **violencia grave** contra
miembros de la comunidad, apropiación consumada, etc.; pueden ser **causal de separación definitiva**.

**7. ¿Qué órganos intervienen en el procedimiento administrativo disciplinario?**
*Esperado:* el **Órgano Instructor**, el **Órgano Sancionador** y el **Órgano Revisor**.

**8. ¿Qué derechos tiene el estudiante investigado durante el procedimiento?**
*Esperado:* debido procedimiento y **derecho de defensa**: derecho a la **notificación**, de **acceso
al expediente**, entre otros.

**9. ¿En qué plazo prescribe el procedimiento administrativo disciplinario?**
*Esperado:* en el plazo de **tres (3) años** contados a partir de que la autoridad toma conocimiento
de los hechos.

**10. ¿Qué circunstancias atenuantes se consideran al aplicar una sanción?**
*Esperado (Art. 15):* la **carencia de sanciones previas**, la actuación por móviles supuestamente
altruistas, entre otras.

**11. ¿En qué plazo puede el estudiante presentar el recurso de apelación?**
*Esperado:* dentro del plazo legal de **quince (15) días hábiles**.

### Control (fuera del documento)

**12. ¿Cuál es el horario de atención de la biblioteca central de la UNSA?**
*Esperado:* debe responder que **no encuentra esa información en los reglamentos proporcionados**.

---

## Tabla de resultados (llenar tras ejecutar)

| # | Consulta | Respuesta correcta | Citó fuente | Veredicto |
|---|---|---|---|---|
| 1 | Finalidad del reglamento (Art. 1) | bien | ⬜ | |
| 2 | Ámbito de aplicación (Art. 4) | bien | ⬜ | |
| 3 | Tipos de sanciones (Art. 12) | ⬜ | mal | |
| 4 | Faltas leves (Art. 99.a) | ⬜ | mal | |
| 5 | Ejemplo de falta grave (Art. 99.b) | si | ⬜ | |
| 6 | Faltas muy graves → separación definitiva (Art. 99.c) | si | ⬜ | |
| 7 | Órganos: Instructor/Sancionador/Revisor | si | ⬜ | |
| 8 | Derechos del investigado (defensa, notificación) | si | ⬜ | |
| 9 | Prescripción: 3 años | si | ⬜ | |
| 10 | Atenuantes (Art. 15) | ⬜ | no | |
| 11 | Apelación: 15 días hábiles | si | ⬜ | |
| 12 | Control (fuera de alcance) | si | — | |

**Precisión global: ____ / 12**
