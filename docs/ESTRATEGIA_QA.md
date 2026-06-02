# Estrategia de Aseguramiento de Calidad — Plataforma USSD (gRPC)

**Proyecto:** Reto QA Senior — Hakom  
**Alcance:** Simulación de plataforma USSD stateful vía gRPC (`UssdCmd`)  
**Versión:** 1.0 | **Fecha:** Junio 2026

---

## 1. Objetivo de negocio

Garantizar que los usuarios puedan navegar el menú USSD (`*999#`), consultar saldo, recargar, ver movimientos y salir **sin pérdida de sesión ni errores de cobro**, y que las integraciones con la pasarela gRPC respeten el contrato técnico (campos inmutables, `sessionId` consistente).

| Pregunta de negocio | Cómo la responde QA |
|---------------------|-------------------|
| ¿El cliente ve el menú correcto al marcar *999#? | Smoke + Happy Path |
| ¿Se pierde la sesión al elegir una opción? | Pruebas stateful + reglas de `sessionId` |
| ¿Puede un error técnico cobrar mal o mostrar datos de otro usuario? | Validación de `msisdn` inmutable y payloads |
| ¿Podemos desplegar sin romper integraciones? | Contrato gRPC + CI |

---

## 2. Enfoque de pruebas (pirámide adaptada a gRPC)

```
                    ┌─────────────────┐
                    │  E2E @e2e       │  Flujo completo menú → opciones → salir
                    │  (pocos, críticos)│
                    └────────┬────────┘
               ┌─────────────┴─────────────┐
               │  Integración @grpc         │  Cada opción 1–4 + smoke
               │  (servicio real)           │
               └─────────────┬─────────────┘
          ┌──────────────────┴──────────────────┐
          │  Contrato @contract (sin red)        │  Payloads inicial / posterior
          │  Reglas sessionId, campos fijos      │
          └─────────────────────────────────────┘
```

**Principio:** validar primero el **contrato y las reglas stateful** (rápido, estable, en CI); luego la **integración contra el servidor** (dependiente de VPN/red).

---

## 3. Framework elegido: Java + Karate + gRPC

| Criterio | Decisión | Beneficio |
|----------|----------|-----------|
| Protocolo | gRPC (Protobuf) | Alineado al sistema bajo prueba |
| Lenguaje | Java 17 | Estándar enterprise, tipado, fácil integración CI |
| Herramienta de prueba | Karate 1.5 | Features legibles (Given/When/Then), reportes HTML para stakeholders |
| Cliente gRPC | `grpc-java` + `UssdGrpcClient` | Control del contrato, reutilizable desde features vía Java interop |
| Build | Maven | Reproducible, perfiles `offline` / integración |

**Alternativas descartadas (resumen):**

- **Postman:** bueno para exploración manual; menos mantenible para sesiones multi-paso y CI.
- **Python + grpcio:** válido; se priorizó Karate por reportes y DSL compartido con equipos QA/Java.
- **JMeter:** orientado a carga; complemento futuro, no sustituto de validación funcional stateful.

---

## 4. Matriz de cobertura

| ID | Requisito (documento técnico) | Tipo | Automatización | Feature |
|----|------------------------------|------|----------------|---------|
| R01 | Llamada inicial: solo `msisdn` y `ussdString` | Regla | Sí | `01-inicio-sesion`, `00-contracto-payload` |
| R02 | Respuesta inicial devuelve `sessionId` | Regla | Sí | `01-inicio-sesion`, `00-smoke` |
| R03 | Llamadas posteriores: solo cambia `ussdString` (+ `sessionId` en request) | Regla | Sí | `06-reglas-sesion`, `UssdPayloads` |
| R04 | `sessionId` constante en toda la sesión | Regla crítica | Sí | `06-reglas-sesion`, todos `@grpc` |
| R05 | `msisdn` inmutable | Regla crítica | Sí | Asserts en features 02–07 |
| R06 | Campos fijos (`gwTransId`, `ussdGwId`, `type`, etc.) | Regla | Sí | `06-reglas-sesion` |
| F01 | Menú principal *999# | Funcional | Sí | `00-smoke-conexion` |
| F02 | Opción 1 — Consultar saldo | Funcional | Sí | `02-consultar-saldo` |
| F03 | Opción 2 — Recargar | Funcional | Sí | `03-recargar` |
| F04 | Opción 3 — Estado de cuenta | Funcional | Sí | `04-estado-cuenta` |
| F05 | Opción 4 — Salir | Funcional | Sí | `05-salir` |
| F06 | Happy Path multi-opción | E2E | Sí | `07-flujo-completo` |

**Cobertura pendiente recomendada (fase 2):** sesiones concurrentes mismo MSISDN, timeouts, `sessionId` inválido, MSISDN alterado en request posterior (test negativo), carga (JMeter/Gatling).

---

## 5. Entornos y datos de prueba

| Entorno | Host:Puerto | Uso |
|---------|-------------|-----|
| Simulación Hakom (reto) | `181.224.248.52:9898` | Integración `@grpc` |
| Local / CI contrato | N/A | `mvn test -Poffline` |

**Datos por defecto:** MSISDN `541122556664`, marcación `*999#`, `ussdGwId` `USSDGWS101`.

---

## 6. Criterios de entrada y salida

**Entrada a ciclo de pruebas integradas**

- Servidor USSD disponible (`TcpTestSucceeded = True` en puerto 9898).
- Contrato `.proto` alineado con producción (o validado por smoke).

**Salida (release / demo)**

- 100 % escenarios `@contract` en verde.
- 100 % escenarios `@grpc` y `@smoke` en verde contra ambiente objetivo.
- Sin hallazgos críticos abiertos en matriz de riesgos.

---

## 7. Integración continua (propuesta)

```yaml
# Ejemplo conceptual — pipeline
stages:
  - contract:  mvn test -Poffline          # Siempre, sin VPN
  - integration: mvn test -Dtest=UssdTestRunner  # Solo si ambiente UP
  - report:    publicar target/karate-reports/
```

**Métricas a publicar por build:** % escenarios passed, duración, fallos por categoría (red / contrato / negocio).

---

## 8. Gestión de riesgos en sesiones stateful (resumen técnico)

Ver detalle en [REPORTE_EJECUTIVO_CEO.md](./REPORTE_EJECUTIVO_CEO.md) y [GUIA_PRESENTACION.md](./GUIA_PRESENTACION.md).

| Riesgo | Impacto negocio | Mitigación QA |
|--------|-----------------|---------------|
| Pérdida de `sessionId` | Usuario ve error o menú incorrecto; abandono | Asserts en cada paso; regresión en CI |
| Cambio de `msisdn` en sesión | Exposición de datos / cobro incorrecto | Validación estricta en payloads |
| Servidor sin alta disponibilidad | Indisponibilidad del canal USSD | Smoke post-deploy; monitoreo sintético |
| Contrato gRPC desalineado | Fallo masivo post-release | Tests `@contract` + smoke |

---

## 9. Artefactos de entrega

| Documento | Audiencia |
|-----------|-----------|
| [README.md](../README.md) | Equipo técnico |
| [ESTRATEGIA_QA.md](./ESTRATEGIA_QA.md) | QA / Tech Lead |
| [REPORTE_EJECUTIVO_CEO.md](./REPORTE_EJECUTIVO_CEO.md) | CEO / Dirección |
| [GUIA_PRESENTACION.md](./GUIA_PRESENTACION.md) | Presentación final |
| `target/karate-reports/karate-summary.html` | Evidencia de ejecución |

---

## 10. Conclusión estratégica

La estrategia prioriza **proteger la integridad de sesión y el contrato gRPC** antes que ampliar casos exploratorios: un fallo en `sessionId` o `msisdn` tiene impacto directo en confianza del cliente y cumplimiento. La automatización con Karate permite explicar calidad en lenguaje de negocio (menú, saldo, recarga) mientras se mantiene trazabilidad técnica para ingeniería.
