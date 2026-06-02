---
marp: true
theme: default
paginate: true
header: 'Hakom — QA USSD gRPC'
footer: 'Reto QA Senior | Junio 2026'
style: |
  section { font-size: 28px; }
  h1 { color: #1a365d; }
  h2 { color: #2c5282; }
---

<!-- _class: lead -->
# Aseguramiento de Calidad
## Plataforma USSD (gRPC)
**Reto Hakom — Karate + Java**  
**Yamileidy Monne Clemente**

---

## Agenda

1. Contexto de negocio (USSD)
2. Objetivo del reto
3. Estrategia y framework
4. Suite de pruebas
5. Reglas de sesión stateful
6. Resultados y semáforo
7. Riesgos para el negocio
8. Escalabilidad y próximos pasos

---

## ¿Qué es USSD?

- Menú en el celular al marcar **\*999#**
- Sin app ni datos móviles — alto volumen
- **Opción 1:** Consultar saldo → menos call center
- **Opción 2:** Recargar → **impacto en ingresos**
- **Opción 3:** Movimientos → confianza
- **Opción 4:** Salir → cierre de sesión

Integración backend: **gRPC** (`UssdCmd`)

---

## Objetivo del reto

| Meta | Estado |
|------|--------|
| Validar navegación del menú | Automatizado |
| Integridad sesiones stateful | Automatizado |
| Reglas sessionId / msisdn | Automatizado |
| Reporte para dirección | Documentado |

**Ambiente:** `181.224.248.52:9898`

---

## Framework: Java + Karate + gRPC

| Componente | Rol |
|------------|-----|
| **Karate 1.5** | Features legibles, reportes HTML |
| **Java 17 / Maven** | CI/CD enterprise |
| **grpc-java** | Cliente `UssdGrpcClient` |
| **Protobuf** | Contrato `ussd.proto` |

Postman → exploración | JMeter → fase 2 (carga)

---

## Pirámide de pruebas

```
        [ E2E @e2e — Happy Path ]
      [ Integración @grpc — menú 1-4 ]
    [ Contrato @contract — sin red ]
```

- **Contrato:** payloads correctos (CI rápido)
- **Integración:** servidor real (VPN)
- **E2E:** flujo completo del cliente

---

## Flujo Happy Path

1. `*999#` → menú principal + **sessionId**
2. Input `1` → saldo
3. Input `2` → recarga (monto)
4. Input `3` → movimientos
5. Input `4` → salir

**Regla:** mismo `sessionId` y `msisdn` en todo el recorrido

---

## Llamada inicial

Solo modifican:
- `msisdn`
- `ussdString` (`*999#`)

Operación: `USSD_SERVICE_PROCESS_UNSTRUCTURED_SS_REQUEST`

**Respuesta:** `sessionId` → guardar para siguientes pasos

---

## Llamadas posteriores

Solo cambia: **`ussdString`** (input usuario)

**Inmutables:**
- `sessionId`
- `msisdn`
- `gwTransId`, `ussdGwId`, `ussdCoreId`, `type`

Feature: `06-reglas-sesion.feature`

---

## Riesgo #1 — Pérdida de sesión

```
*999#  →  sessionId = ABC
Pulsa 1  →  debe ser ABC
```

| Si falla | Impacto |
|----------|---------|
| Menú reiniciado | Abandono del canal |
| Error confuso | Menos recargas |

**Control QA:** assert `sessionId` en cada paso

---

## Riesgo #2 — MSISDN incorrecto

- **MSISDN** = teléfono del cliente
- Si cambia en la sesión → **datos de otro usuario**
- Impacto: **muy alto** (regulación, reputación)

**Control QA:** validación en todos los features `@grpc`

---

## Suite automatizada

| Feature | Cobertura |
|---------|-----------|
| 00-smoke | Conexión + menú |
| 01-inicio | sessionId |
| 02-05 | Opciones 1-4 |
| 06-reglas | Contrato stateful |
| 07-flujo | E2E |
| 00-contracto | Sin red (2 tests) |

**12 escenarios** en total

---

## Métricas → negocio

| Métrica | Valor | Negocio |
|---------|-------|---------|
| Contrato | **2/2 OK** | Despliegues seguros |
| Integración | 10 listos | Certificación pendiente red |
| Regresión | &lt; 3 min | Release ágil |

**Bloqueo:** puerto 9898 no accesible (VPN)

---

## Semáforo de calidad

| Área | Estado |
|------|--------|
| Diseño y cobertura | Verde |
| Reglas de sesión | Verde |
| Servidor simulación | Ámbar (red) |
| Carga / escala | Fase 2 |
| Seguridad negativa | Fase 2 |

---

## Recomendaciones

| Prioridad | Acción |
|-----------|--------|
| **P0** | VPN / acceso `181.224.248.52:9898` |
| **P0** | Ejecutar suite `@grpc` |
| **P1** | CI: contrato + integración nightly |
| **P2** | JMeter + monitoreo sintético *999# |

---

## Escalabilidad

1. **Hoy:** regresión funcional automática
2. **Fase 2:** pruebas de carga (p95, errores %)
3. **Producción:** smoke sintético cada N minutos
4. **Arquitectura:** TTL `sessionId`, límites por MSISDN

> Funcional = cinturón | Carga = crash test | Monitor = airbag

---

## Cómo ejecutar

```bash
# Sin VPN
mvn test -Poffline

# Con VPN
mvn test -Dtest=UssdTestRunner
```

```powershell
Test-NetConnection 181.224.248.52 -Port 9898
```

Reporte: `target/karate-reports/karate-summary.html`

---

## Entregables

- Repositorio (código + Karate features)
- `docs/ESTRATEGIA_QA.md`
- `docs/REPORTE_EJECUTIVO_CEO.md`
- Presentación PPT / Marp
- Reportes HTML Karate

---

<!-- _class: lead -->
# Gracias
## Preguntas

**Próximo paso:** habilitar ambiente → certificar integración gRPC
