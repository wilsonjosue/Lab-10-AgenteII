# Fuentes — Documentos oficiales de la UNSA

Los 3 documentos provienen del **Portal de Transparencia de la UNSA**
(`transparencia.unsa.edu.pe`), repositorio oficial de resoluciones y reglamentos.
Todos fueron aprobados por el **Consejo Universitario de la UNSA** y tienen texto
seleccionable (no escaneado), verificado para el pipeline RAG.

| # | Archivo | Documento | Norma | Págs | Fuente |
|---|---|---|---|---|---|
| 1 | `01_Reglamento_Disciplinario_Estudiantes.pdf` | Reglamento del Procedimiento Administrativo Disciplinario para Estudiantes de la UNSA | RCU 0515-2020 | 26 | https://fcnf.unsa.edu.pe/fisica/wp-content/uploads/sites/2/2023/09/3.-Reglamento-del-Procedimiento-Administrativo-Disciplinario-para-Estudiantes-de-la-UNSA.pdf |
| 2 | `02_Reglamento_Regimen_Academico.pdf` | Reglamento del Régimen Académico y Obtención de Diplomados, Grados de Maestro y Doctor | RCU 0104-2022 | 31 | https://transparencia.unsa.edu.pe/handle/123456789/849 |
| 3 | `03_Reglamento_Auspicios_UNSA.pdf` | Reglamento para el Otorgamiento de Auspicios de la UNSA | RCU 0516-2020 | 8 | https://transparencia.unsa.edu.pe/handle/123456789/110 |

**Total: 3 documentos · 65 páginas** (cumple el mínimo de 3 documentos y ≥20 páginas).

## Nota metodológica
- Se eligieron deliberadamente **tres reglamentos de temas distintos** (disciplina estudiantil,
  régimen académico de posgrado y auspicios institucionales) para que el sistema RAG distinga bien
  entre ellos. En una prueba inicial se usó el *Reglamento de Grados y Títulos* (RCU 0255-2021), pero
  se **descartó** porque su contenido se solapa casi por completo con el *Reglamento del Régimen
  Académico* (ambos tratan grados, títulos, tesis y créditos): la recuperación no lograba
  distinguirlos y confundía las respuestas. Se reemplazó por el **Reglamento Disciplinario**, de
  vocabulario totalmente distinto, lo que mejoró notablemente la precisión (ver INFORME §6). El PDF
  descartado se conserva en `documentos/_descartados/`.
- El **Estatuto Universitario de la UNSA** (2015, 136 págs) también se descartó por estar
  **100 % escaneado** (sin texto seleccionable). Se priorizaron documentos con **texto real**.
- Fecha de descarga: 08/07/2026.
