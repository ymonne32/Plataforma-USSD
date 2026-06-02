---
marp: true
theme: default
paginate: true
header: 'Hakom — QA USSD gRPC'
footer: 'Reto QA Senior | Video presentación | Junio 2026'
style: |
  section { font-size: 26px; }
  h1 { color: #1a365d; font-size: 44px; }
  h2 { color: #2c5282; font-size: 32px; }
  table { font-size: 22px; }
  code { font-size: 20px; }
  blockquote { border-left: 4px solid #2c5282; color: #2d3748; }
---

<!-- _class: lead -->
# Aseguramiento de Calidad
## Plataforma USSD (gRPC)
**Reto Hakom — Karate + Java**

**Yamileidy Monne Clemente** · Junio 2026

---

## Contexto de negocio

- USSD = menú en el celular al marcar **\*999#**
- Sin app ni datos móviles — **alto volumen**
- Opciones: saldo · recarga · movimientos · salir
- Un fallo se percibe como *"el operador no me deja usar el servicio"*
- Backend: **gRPC** (`UssdCmd`) con sesiones **stateful**

> No alcanza con que el servidor responda: hay que validar que el cliente complete su intención **sin perder la sesión**.

---

## Objetivo del reto

| Meta | Entregable |
|------|------------|
| Validar navegación del menú | Suite Karate `@grpc` |
| Integridad sesiones stateful | `06-reglas-sesion.feature` |
| Reglas `sessionId` / `msisdn` | `UssdPayloads` + `@contract` |
| Reporte para dirección | `REPORTE_EJECUTIVO_CEO.md` |
| Escalabilidad y CI | Estrategia + pipeline propuesto |

**Ambiente simulación:** `181.224.248.52:9898`

---

## Pirámide de pruebas

```
              ┌─────────────────────┐
              │  E2E @e2e          │  Happy Path completo
              └──────────┬──────────┘
         ┌─────────────────┴─────────────────┐
         │  Integración @grpc                 │  Smoke + opciones 1–4
         └─────────────────┬─────────────────┘
    ┌──────────────────────┴──────────────────────┐
    │  Contrato @contract (sin red)                │  Payloads correctos
    └─────────────────────────────────────────────┘
```

**Principio:** proteger sesión y contrato **antes** de ampliar casos exploratorios.

---

## Framework: Java + Karate + gRPC

| Decisión | Por qué |
|----------|---------|
| **Karate 1.5** | Features legibles · reportes HTML |
| **Java 17 / Maven** | CI/CD enterprise |
| **UssdGrpcClient** | Control del contrato Protobuf |
| **UssdPayloads** | `initial()` vs `subsequent()` reutilizable |

**Descartado:** Postman (exploración) · **Fase 2:** JMeter (carga)

> *Primero protegemos al cliente (sesión y línea); luego el recorrido completo del menú.*

---

## Suite automatizada

| Feature | Cobertura | Tag |
|---------|-----------|-----|
| `00-contracto-payload` | Payloads sin servidor | `@contract` |
| `00-smoke-conexion` | Menú *999# | `@smoke` |
| `01-inicio-sesion` | Obtención de `sessionId` | `@grpc` |
| `02` – `05` | Opciones 1 a 4 del menú | `@grpc` |
| `06-reglas-sesion` | Reglas stateful críticas | `@grpc` |
| `07-flujo-completo` | Happy Path E2E | `@e2e` |

**Total: 12 escenarios** en 9 features

---

## Reglas de sesión stateful

**Llamada inicial** — solo cambian:
- `msisdn` · `ussdString` (`*999#`)

**Llamadas posteriores** — solo cambia:
- `ussdString` (opción del usuario) + `sessionId` en request

**Inmutables en toda la sesión:**
- `sessionId` (respuesta) · `msisdn` · `gwTransId` · `ussdGwId` · `type`

Feature clave: **`06-reglas-sesion.feature`**

---

## Happy Path (E2E)

```
*999#  →  menú + sessionId
  "1"  →  consultar saldo   (mismo sessionId)
  "3"  →  estado de cuenta  (mismo sessionId)
  "4"  →  salir             (cierre limpio)
```

Feature: **`07-flujo-completo.feature`**

Cada paso incluye assert de `sessionId` y `msisdn`.

---

## Demo y evidencia

```bash
# Contrato (sin VPN) — 2/2 OK
mvn test -Poffline

# Integración (con VPN al simulador)
mvn test -Dtest=UssdTestRunner
```

**Reporte:** `target/karate-reports/karate-summary.html`

| Capa | Estado |
|------|--------|
| Contrato `@contract` | **2 / 2 OK** |
| Integración `@grpc` | Lista · pendiente acceso red |

---

## Riesgos identificados

| Riesgo | Impacto negocio | Control QA |
|--------|-----------------|------------|
| Pérdida de `sessionId` | Abandono del canal | Asserts en cada paso |
| MSISDN distinto | Datos de otro usuario | Validación en todos los flujos |
| Payload incorrecto | Rechazo / comportamiento errático | `00-contracto-payload` |
| Ambiente no accesible | Retraso en certificación | Smoke + documentado P0 |

---

## Semáforo de calidad

| Área | Estado |
|------|--------|
| Diseño de pruebas y cobertura | 🟢 Verde |
| Reglas de sesión (`sessionId`, campos fijos) | 🟢 Verde |
| Ejecución contra simulador | 🟡 Ámbar (VPN/red) |
| Pruebas de carga / escala | ⚪ Fase 2 |
| Seguridad (pruebas negativas) | 🟡 Fase 2 |

---

## Escalabilidad

1. **Hoy:** regresión funcional automática pre-release (&lt; 3 min)
2. **Fase 2:** JMeter/Gatling — p95 latencia, sesiones concurrentes
3. **Producción:** monitoreo sintético *999# cada 5 min

> Funcional = cinturón · Carga = crash test · Monitor = airbag

**Arquitectura:** TTL de `sessionId`, límites por MSISDN

---

## Entregables y próximo paso

| Entregable | Ubicación |
|------------|-----------|
| Código + suite | GitHub: **Plataforma-USSD** |
| Estrategia QA | `docs/ESTRATEGIA_QA.md` |
| Reporte CEO | `docs/REPORTE_EJECUTIVO_CEO.md` |
| Evidencia | `target/karate-reports/` |

**P0:** habilitar `181.224.248.52:9898` → ejecutar suite `@grpc` → certificar

---

<!-- _class: lead -->
# Gracias
## Preguntas

**Repo:** https://github.com/ymonne32/Plataforma-USSD
