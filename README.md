# Reto QA Senior – Plataforma USSD (gRPC) con Karate

**Repositorio:** https://github.com/ymonne32/Plataforma-USSD

Suite de automatización en **Java + Karate** para el flujo USSD stateful del reto Hakom, consumiendo el servicio gRPC **UssdCmd/UssdCmd**.

## Documentación de entrega (CEO / presentación)

| Documento | Descripción |
|-----------|-------------|
| [docs/INDICE_ENTREGA.md](docs/INDICE_ENTREGA.md) | Índice de todos los entregables |
| [docs/ESTRATEGIA_QA.md](docs/ESTRATEGIA_QA.md) | Estrategia, framework, matriz de cobertura, CI |
| [docs/REPORTE_EJECUTIVO_CEO.md](docs/REPORTE_EJECUTIVO_CEO.md) | Resumen ejecutivo, riesgos y métricas en lenguaje de negocio |
| [docs/GUIA_PRESENTACION.md](docs/GUIA_PRESENTACION.md) | Guion para la presentación final |

## Requisitos

- **JDK 17+**
- **Maven 3.8+**
- Acceso de red al servidor: `181.224.248.52:9898`

## Estructura

```
src/main/proto/ussd.proto          # Contrato gRPC (ajustar si el servidor usa otro .proto)
src/test/java/
  karate-config.js                 # Host, MSISDN, helpers ussdInitial / ussdContinue
  com/hakom/retoqa/grpc/           # Cliente gRPC + builders de payload
  com/hakom/retoqa/ussd/*.feature  # Escenarios Karate por funcionalidad
```

## Ejecutar tests

```bash
# Suite completa (requiere red al servidor 181.224.248.52:9898)
mvn clean test

# Solo validación de contrato JSON (sin gRPC, útil sin VPN)
mvn test -Poffline

# Solo smoke
mvn test -Dkarate.options="--tags @smoke"

# Solo E2E
mvn test -Dkarate.options="--tags @e2e"

# Otro MSISDN o host
mvn test -Dgrpc.host=181.224.248.52 -Dgrpc.port=9898 -Dmsisdn=541122556664 -Drecharge.amount=50
```

Si ves `Error gRPC UssdCmd [UNAVAILABLE]: io exception`, comprueba VPN/firewall y que el puerto **9898** esté accesible.

Reporte HTML: `target/karate-reports/karate-summary.html`

## Reglas del reto implementadas

| Regla | Implementación |
|-------|----------------|
| Llamada inicial: solo `msisdn` y `ussdString` | `UssdPayloads.initial()` + feature `01-inicio-sesion` |
| Llamadas posteriores: solo `ussdString` (+ `sessionId` del response) | `UssdPayloads.subsequent()` + features `02`–`05` |
| `sessionId` constante en la sesión | `06-reglas-sesion` |
| `msisdn` sin cambios | Asserts en todos los features |
| Menú *999# | `00-smoke-conexion`, `openSession()` |

## Features

| Archivo | Cobertura |
|---------|-----------|
| `00-smoke-conexion.feature` | Conexión y menú principal |
| `01-inicio-sesion.feature` | Llamada inicial y obtención de `sessionId` |
| `02-consultar-saldo.feature` | Opción 1 |
| `03-recargar.feature` | Opción 2 (monto vía `recharge.amount`) |
| `04-estado-cuenta.feature` | Opción 3 |
| `05-salir.feature` | Opción 4 |
| `06-reglas-sesion.feature` | Contrato de request/response stateful |
| `07-flujo-completo.feature` | Recorrido E2E |

## Proto

El archivo `ussd.proto` se infiere del JSON del enunciado. Si el servidor devuelve `UNIMPLEMENTED` o error de método, solicita el `.proto` oficial y sustitúyelo; luego:

```bash
mvn clean compile
```

## Datos de conexión (por defecto)

- **IP:** 181.224.248.52  
- **Puerto:** 9898  
- **Servicio / método:** UssdCmd / UssdCmd  
- **MSISDN ejemplo:** 541122556664  
- **Marcación:** `*999#`
