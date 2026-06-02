# Reporte Ejecutivo de Calidad — Plataforma USSD (gRPC)

**Para:** Dirección / CEO  
**De:** Aseguramiento de Calidad — Reto Plataforma USSD Hakom  
**Fecha:** Junio 2026  
**Clasificación:** Resumen ejecutivo (1 página clave + anexos)

---

## Resumen en 30 segundos

Se diseñó e implementó una **estrategia de pruebas automatizadas** sobre el canal USSD (*999#) que valida el recorrido del cliente (consulta de saldo, recarga, movimientos y cierre) y las **reglas críticas de sesión** exigidas por la plataforma gRPC.

| Indicador | Estado |
|-----------|--------|
| Automatización del flujo principal (Happy Path) | Implementada |
| Reglas de sesión (`sessionId`, datos inmutables) | Implementadas y automatizadas |
| Validación en servidor de simulación (`181.224.248.52:9898`) | **Pendiente de acceso de red** |
| Pruebas de contrato (sin servidor) | **Ejecutadas correctamente** |

**Mensaje para dirección:** la solución de pruebas está lista; el riesgo inmediato no es la herramienta, sino **confirmar disponibilidad del ambiente** y ejecutar la suite de integración antes de considerar el canal “listo para exposición”.

---

## 1. ¿Qué se probó y por qué importa al negocio?

El USSD es un canal de **bajo ancho de banda pero alto volumen**: millones de usuarios marcan códigos cortos para consultar saldo o recargar. Un fallo no se percibe como “error técnico”, sino como **“el operador no me deja ver mi plata”** o, peor, como **operación sobre la línea equivocada**.

| Función probada | Valor para el negocio |
|-----------------|----------------------|
| Acceso al menú `*999#` | Primera impresión del servicio; si falla, no hay ingresos por recarga ni autoservicio |
| Consultar saldo (opción 1) | Reduce llamadas al call center |
| Recargar (opción 2) | Impacto directo en **ingresos** |
| Estado de cuenta (opción 3) | Transparencia y confianza |
| Salir (opción 4) | Cierre correcto de sesión; evita estados colgados y costos de infraestructura |

---

## 2. Semáforo de calidad (visión negocio)

| Área | Estado | Comentario |
|------|--------|------------|
| Diseño de pruebas y cobertura funcional | 🟢 Verde | Flujo principal y 4 opciones del menú automatizados |
| Reglas de sesión (integridad) | 🟢 Verde | Validación automatizada de `sessionId` y campos fijos |
| Ejecución contra servidor del reto | 🟡 Ámbar | Requiere conectividad a `181.224.248.52:9898` (VPN/red) |
| Pruebas de estrés / escala | ⚪ No iniciado | Recomendado en fase 2 |
| Seguridad (sesión cruzada entre usuarios) | 🟡 Ámbar | Reglas cubiertas; faltan pruebas negativas maliciosas |

---

## 3. Métricas técnicas traducidas a riesgo

| Métrica (QA) | Valor actual | Qué significa para el negocio |
|--------------|--------------|-------------------------------|
| Escenarios de contrato (`@contract`) | **2 / 2 OK** | Los mensajes que envía la pasarela cumplen el formato acordado; menor riesgo de despliegues rotos |
| Escenarios de integración (`@grpc`) | **0 / 10 ejecutados en verde** | No se pudo validar el comportamiento real del simulador (bloqueo de red, no de diseño de pruebas) |
| Cobertura del Happy Path | **1 flujo E2E automatizado** | Camino feliz del cliente reproducible en minutos |
| Tiempo de regresión (estimado) | **&lt; 1 min** (contrato) + **&lt; 2 min** (integración) | Permite validar antes de cada release si el ambiente está accesible |
| Hallazgos críticos en producto | **N/D** | Sin acceso al servidor no se certifica el simulador; ver sección 5 |

---

## 4. Riesgos identificados (lenguaje de negocio)

### Riesgo 1 — Pérdida de sesión durante la navegación  
**Probabilidad si no se controla:** Media · **Impacto:** Alto  

El usuario elige “Consultar saldo” y el sistema “olvida” en qué paso estaba. **Experiencia:** menú que se reinicia o mensaje de error. **Consecuencia:** abandono del canal y pérdida de recargas.

**Control QA implementado:** cada respuesta debe devolver el mismo `sessionId` hasta cerrar con “Salir”.

---

### Riesgo 2 — Inconsistencia del identificador de línea (MSISDN)  
**Probabilidad:** Baja si el backend es sólido · **Impacto:** Muy alto (reputación / regulación)  

Si en mitad de la sesión se mezclan datos de dos números, un cliente podría ver **saldo o movimientos de otro**.

**Control QA implementado:** el número de teléfono no puede cambiar entre pasos de la misma sesión.

---

### Riesgo 3 — Indisponibilidad del ambiente de simulación  
**Probabilidad:** Observada en validación local · **Impacto:** Medio (retraso en certificación)  

Sin acceso de red al puerto **9898**, no es posible firmar que el simulador responde según el documento técnico.

**Acción recomendada:** habilitar VPN o whitelist de IP para el equipo de QA / candidatos.

---

### Riesgo 4 — Escalabilidad bajo picos (no evaluado aún)  
**Probabilidad:** Desconocida · **Impacto:** Alto en campañas o fechas pico  

USSD suele concentrar muchas sesiones simultáneas. Las pruebas actuales validan **correctitud funcional**, no **capacidad**.

**Recomendación fase 2:** pruebas de carga (p. ej. JMeter/Gatling) sobre `UssdCmd` con métricas de latencia p95/p99 y tasa de error.

---

## 5. Hallazgos y evidencias

| # | Hallazgo | Severidad | Evidencia |
|---|----------|-----------|-----------|
| H1 | Suite de automatización completa según especificación del reto | Informativo | Repositorio + features Karate |
| H2 | Pruebas de contrato ejecutadas con éxito sin dependencia de red | Positivo | `mvn test -Poffline` → 2/2 escenarios OK |
| H3 | Integración gRPC no ejecutable desde el entorno de validación actual | Bloqueante operativo | `TcpTestSucceeded: False` hacia `181.224.248.52:9898` |
| H4 | Reportes HTML generados para auditoría y demo | Positivo | `target/karate-reports/karate-summary.html` |

**Nota:** H3 no implica defecto del producto; indica **gap de acceso al ambiente**. Debe resolverse antes de una certificación formal “lista para demo”.

---

## 6. Recomendaciones priorizadas

| Prioridad | Acción | Responsable sugerido | Plazo |
|-----------|--------|----------------------|-------|
| P0 | Habilitar acceso de red (VPN/IP) al simulador `181.224.248.52:9898` | Infra / Hakom IT | Inmediato |
| P0 | Ejecutar suite `@grpc` y archivar reporte HTML | QA | Tras P0 |
| P1 | Incorporar pruebas negativas (sessionId inválido, MSISDN alterado) | QA | 1 sprint |
| P1 | Pipeline CI: contrato en cada commit; integración nightly | DevOps + QA | 1–2 sprints |
| P2 | Pruebas de carga y monitoreo sintético del menú *999# | QA + SRE | Pre-producción |

---

## 7. Cómo asegurar que el servicio escale (respuesta ejecutiva)

1. **Separar pruebas de corrección y de capacidad:** lo implementado garantiza que cada sesión se comporte bien; la escala requiere inyección de miles de sesiones concurrentes y medir degradación.
2. **Monitoreo sintético en producción:** un robot que marque `*999#` cada 5 minutos detecta caídas antes que el usuario masivo.
3. **Stateless en capa de entrada, stateful controlado:** el `sessionId` debe tener TTL y límites por MSISDN para evitar fugas de memoria en picos.
4. **Regresión automática pre-release:** el mismo Happy Path que hoy tarda minutos debe bloquear despliegues si falla.

---

## 8. Conclusión para la toma de decisiones

| Pregunta del CEO | Respuesta |
|------------------|-----------|
| ¿Tenemos pruebas del flujo del cliente? | **Sí**, automatizadas. |
| ¿Protegemos la integridad de la sesión? | **Sí**, con reglas explícitas en la suite. |
| ¿Podemos decir hoy que el simulador está 100 % validado? | **No**, hasta completar pruebas contra el servidor con red habilitada. |
| ¿Cuál es el siguiente paso? | Desbloquear ambiente → ejecutar integración → revisar reporte HTML → planificar carga. |

---

## Anexo A — Inventario de automatización

| Módulo | Escenarios | Tag |
|--------|------------|-----|
| Contrato payloads | 2 | `@contract` |
| Smoke conexión | 1 | `@smoke` `@grpc` |
| Inicio sesión | 2 | `@grpc` |
| Consultar saldo | 1 | `@grpc` |
| Recargar | 1 | `@grpc` |
| Estado cuenta | 1 | `@grpc` |
| Salir | 1 | `@grpc` |
| Reglas sesión | 2 | `@grpc` |
| Flujo completo | 1 | `@e2e` `@grpc` |
| **Total integración** | **10** | |
| **Total contrato** | **2** | |

## Anexo B — Glosario breve

| Término | Significado para negocio |
|---------|--------------------------|
| USSD | Menú por celular al marcar códigos como *999# |
| gRPC | Protocolo interno entre sistemas (rápido, estructurado) |
| sessionId | “Ticket” de la conversación; si se pierde, el menú se rompe |
| MSISDN | Número de teléfono del cliente |
| Happy Path | Camino ideal sin errores del usuario |

---

*Documento complementario: [ESTRATEGIA_QA.md](./ESTRATEGIA_QA.md) · Evidencia técnica: [README.md](../README.md)*
