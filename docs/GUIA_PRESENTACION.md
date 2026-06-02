# Guía para la presentación final — Reto USSD gRPC

**Duración sugerida:** 15–20 minutos (+ 5 min Q&A)  
**Audiencia mixta:** CEO + perfiles técnicos

---

## Estructura recomendada

### 1. Contexto (2 min)

- Qué es el canal USSD para el negocio: autoservicio, recargas, consulta de saldo sin app ni datos móviles.
- Reto: validar simulación gRPC con **sesiones stateful** (el sistema “recuerda” en qué menú está el usuario).

**Mensaje clave:** No probamos solo “si responde el servidor”, probamos **si el cliente puede completar su intención sin perder la sesión**.

---

### 2. Por qué Karate + Java + gRPC (3 min)

| Decisión | Por qué |
|----------|---------|
| **Karate** | Features legibles para negocio y QA; reportes HTML para dirección |
| **Java / Maven** | Estándar en empresas telco; encaja en CI/CD |
| **Cliente gRPC propio** | Control del contrato Protobuf y reutilización de builders (`UssdPayloads`) |
| **Dos capas de prueba** | `@contract` sin red (rápido) + `@grpc` contra simulador (real) |

**Frase para CEO:** “Invertimos primero en reglas que protegen al cliente (sesión y número de línea); luego en el recorrido completo del menú.”

---

### 3. Demo en vivo (5 min)

**Si hay VPN / red al simulador:**

```bash
mvn test -Dtest=UssdTestRunner
# Abrir target/karate-reports/karate-summary.html
```

Mostrar: smoke → opción saldo → verde en `sessionId`.

**Si NO hay red (como en preparación actual):**

```bash
mvn test -Poffline
```

Mostrar contrato OK y explicar: “La automatización está lista; falta certificar contra el ambiente Hakom cuando habiliten el puerto 9898.”

---

### 4. Riesgos en lógica de sesiones (4 min) — slide mental

```
Usuario marca *999#  →  sessionId = ABC
Usuario pulsa "1"     →  debe seguir ABC  (si cambia → menú roto)
Usuario recarga       →  mismo MSISDN     (si cambia → riesgo grave)
Usuario pulsa "4"     →  cierre limpio
```

| Riesgo | Impacto | Cómo lo cubre la suite |
|--------|---------|------------------------|
| sessionId nuevo en cada paso | Cliente perdido en el menú | `06-reglas-sesion` |
| MSISDN distinto en paso 2 | Datos de otro usuario | Asserts en todos los flujos |
| Payload con campos de más en llamada inicial | Rechazo o comportamiento impredecible | `00-contracto-payload` |
| Ambiente caído | Canal USSD “muerto” | Smoke post-deploy |

---

### 5. Escalabilidad (3 min)

**Pregunta esperada:** “¿Cómo asegurarías que escale?”

Respuesta en tres capas:

1. **Hoy (funcional):** regresión automática del Happy Path + reglas de sesión en cada release.
2. **Mañana (carga):** JMeter/Gatling sobre `UssdCmd`, objetivos p95 &lt; X ms, 0 % error bajo N sesiones concurrentes.
3. **Operación (producción):** monitoreo sintético *999# cada N minutos; alertas si falla smoke.

**Analogía para CEO:** “Las pruebas funcionales son el cinturón de seguridad; las de carga son el crash test; el monitoreo es el airbag en carretera.”

---

### 6. Resultados y próximos pasos (2 min)

Usar tabla del [REPORTE_EJECUTIVO_CEO.md](./REPORTE_EJECUTIVO_CEO.md):

- Contrato: OK  
- Integración: pendiente de red  
- Recomendación P0: habilitar `181.224.248.52:9898`

---

## Preguntas frecuentes (preparación)

**¿Por qué no Postman?**  
Postman sirve para explorar; las sesiones USSD son multi-paso y necesitan asserts encadenados. Karate lo hace mantenible en CI.

**¿Qué pasa si cambia el .proto?**  
Los tests de contrato fallan primero → se detecta antes de que el usuario vea errores en el menú.

**¿Cuánto cuesta mantenerlo?**  
Bajo: features por opción de menú; un QA puede añadir caso sin reescribir Java.

**¿Está listo para producción?**  
Listo el **marco de calidad**; la **certificación del simulador** requiere ejecutar `@grpc` con ambiente accesible.

---

## Checklist antes de presentar

- [ ] Repositorio actualizado (código + carpeta `docs/`)
- [ ] `mvn test -Poffline` en verde
- [ ] Captura de `karate-summary.html` (contrato o integración si hay red)
- [ ] Leer semáforo y riesgos del reporte ejecutivo
- [ ] Tener a mano IP/puerto del reto: `181.224.248.52:9898`
