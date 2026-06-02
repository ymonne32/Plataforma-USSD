# Índice de entrega — Reto QA USSD gRPC

| # | Entregable | Ubicación | Audiencia |
|---|------------|-----------|-----------|
| 1 | Código y suite automatizada | Raíz del repo (`src/`, `pom.xml`) | QA / Dev |
| 2 | Estrategia y framework | [ESTRATEGIA_QA.md](./ESTRATEGIA_QA.md) | QA / Tech Lead |
| 3 | Reporte ejecutivo | [REPORTE_EJECUTIVO_CEO.md](./REPORTE_EJECUTIVO_CEO.md) | CEO / Dirección |
| 4 | Guía presentación final | [GUIA_PRESENTACION.md](./GUIA_PRESENTACION.md) | Presentación |
| 4b | **Presentación PowerPoint** | [Presentacion_Reto_USSD_QA.pptx](./Presentacion_Reto_USSD_QA.pptx) | CEO / demo |
| 4c | Slides Marp (exportar a PPT/PDF) | [Presentacion_Reto_USSD_QA.md](./Presentacion_Reto_USSD_QA.md) | VS Code Marp |
| 5 | Instrucciones técnicas | [README.md](../README.md) | Implementación |
| 6 | Evidencia de ejecución | `target/karate-reports/` (tras `mvn test`) | Auditoría |

**Comando rápido contrato (sin VPN):** `mvn test -Poffline`  
**Comando integración (con VPN):** `mvn test -Dtest=UssdTestRunner`
