# Genera Presentacion_Reto_USSD_QA.pptx en docs/
# Requiere: Microsoft PowerPoint instalado (Windows)

$ErrorActionPreference = "Stop"
$docsDir = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "docs"
$outFile = Join-Path $docsDir "Presentacion_Reto_USSD_QA.pptx"

function Add-TitleSlide($pres, [string]$title, [string]$subtitle) {
    $layout = $pres.SlideMaster.CustomLayouts.Item(1)
    $slide = $pres.Slides.AddSlide($pres.Slides.Count + 1, $layout)
    $slide.Shapes.Title.TextFrame.TextRange.Text = $title
    if ($slide.Shapes.Count -ge 2) {
        $slide.Shapes.Item(2).TextFrame.TextRange.Text = $subtitle
    }
}

function Add-BulletSlide($pres, [string]$title, [string[]]$bullets) {
    $layout = $pres.SlideMaster.CustomLayouts.Item(2)
    $slide = $pres.Slides.AddSlide($pres.Slides.Count + 1, $layout)
    $slide.Shapes.Title.TextFrame.TextRange.Text = $title
    $body = $slide.Shapes.Item(2).TextFrame.TextRange
    $body.Text = ($bullets -join [char]13)
    $body.ParagraphFormat.Bullet.Type = 1
}

try {
    $ppt = New-Object -ComObject PowerPoint.Application
    $ppt.Visible = 1
    $pres = $ppt.Presentations.Add()

    Add-TitleSlide $pres 'Aseguramiento de Calidad' "Plataforma USSD (gRPC) - Reto Hakom`nKarate + Java | Junio 2026"

    Add-BulletSlide $pres 'Agenda' @(
        'Contexto de negocio: canal USSD',
        'Objetivo del reto y alcance',
        'Estrategia y framework (Karate + gRPC)',
        'Arquitectura de la suite de pruebas',
        'Reglas criticas: sesiones stateful',
        'Resultados, riesgos y semaforo',
        'Escalabilidad y proximos pasos',
        'Demo y entregables'
    )

    Add-BulletSlide $pres 'Que es USSD y por que importa' @(
        'Canal *999#: menu en el celular sin app',
        'Alto volumen: saldo, recargas, movimientos',
        'Un fallo impacta reputacion del operador',
        'Recarga (opcion 2) impacta ingresos',
        'Integracion interna via gRPC (UssdCmd)'
    )

    Add-BulletSlide $pres 'Objetivo del reto' @(
        'Validar flujo de navegacion del menu USSD',
        'Asegurar integridad de sesiones stateful',
        'Cumplir reglas: sessionId, msisdn, campos fijos',
        'Entregar estrategia QA + automatizacion + reporte CEO',
        'Servidor: 181.224.248.52:9898 - UssdCmd/UssdCmd'
    )

    Add-BulletSlide $pres 'Framework: Java + Karate + gRPC' @(
        'Java 17 + Maven: estandar enterprise y CI/CD',
        'Karate 1.5: features legibles, reportes HTML',
        'grpc-java + UssdGrpcClient: contrato Protobuf',
        'Postman: exploracion manual',
        'JMeter: recomendado fase 2 para carga'
    )

    Add-BulletSlide $pres 'Piramide de pruebas' @(
        'Nivel 1 - Contrato (sin red): payloads inicial y posterior',
        'Nivel 2 - Integracion: smoke + opciones 1 a 4',
        'Nivel 3 - E2E: Happy Path completo',
        'Validar contrato y sesion antes de exploracion masiva',
        'CI: contrato en cada build; integracion si ambiente UP'
    )

    Add-BulletSlide $pres 'Flujo del usuario (Happy Path)' @(
        '1. Marca *999# - menu principal (llamada inicial)',
        '2. Opcion 1: Consultar saldo',
        '3. Opcion 2: Recargar (monto)',
        '4. Opcion 3: Estado de cuenta',
        '5. Opcion 4: Salir',
        'Cada paso reutiliza el mismo sessionId y msisdn'
    )

    Add-BulletSlide $pres 'Reglas: llamada inicial' @(
        'Solo se modifican: msisdn y ussdString (*999#)',
        'Operacion: USSD_SERVICE_PROCESS_UNSTRUCTURED_SS_REQUEST',
        'Respuesta devuelve sessionId (guardarlo)',
        'Feature: 01-inicio-sesion + 00-contracto-payload'
    )

    Add-BulletSlide $pres 'Reglas: llamadas posteriores' @(
        'Solo cambia ussdString (input del usuario)',
        'sessionId = el de la primera respuesta',
        'msisdn no puede cambiar en la sesion',
        'gwTransId, ussdGwId, ussdCoreId, type: fijos',
        'Feature: 06-reglas-sesion + features 02-05'
    )

    Add-BulletSlide $pres 'Integridad de sesion (riesgo 1)' @(
        '*999# genera sessionId = ABC',
        'Usuario pulsa 1 - debe seguir ABC',
        'Si sessionId cambia: menu roto',
        'Control QA: assert sessionId en cada respuesta',
        'Impacto: abandono y perdida de recargas'
    )

    Add-BulletSlide $pres 'MSISDN inmutable (riesgo 2)' @(
        'MSISDN = numero de telefono del cliente',
        'Si cambia en mitad de sesion: datos de otro usuario',
        'Impacto muy alto: regulacion y reputacion',
        'Control QA: validacion en todos los flujos grpc'
    )

    Add-BulletSlide $pres 'Suite de pruebas automatizada' @(
        '00-smoke-conexion - menu principal',
        '01-inicio-sesion - sessionId',
        '02 a 05 - opciones menu 1-4',
        '06-reglas-sesion - contrato stateful',
        '07-flujo-completo - E2E',
        '00-contracto-payload - 2 escenarios sin red',
        'Total: 12 escenarios en 9 features Karate'
    )

    Add-BulletSlide $pres 'Metricas y traduccion a negocio' @(
        'Contrato: 2 de 2 OK - formato de mensajes correcto',
        'Integracion: 10 escenarios listos (requiere red)',
        'Regresion estimada: menos de 3 minutos',
        'Reporte HTML: target/karate-reports/karate-summary.html',
        'Bloqueo: puerto 9898 no accesible sin VPN'
    )

    Add-BulletSlide $pres 'Semaforo de calidad' @(
        'VERDE: diseno de pruebas y reglas de sesion',
        'VERDE: automatizacion Happy Path + 4 opciones',
        'AMBAR: ejecucion contra simulador (VPN/red)',
        'AMBAR: pruebas negativas de seguridad (fase 2)',
        'PENDIENTE: pruebas de estres / escala (fase 2)'
    )

    Add-BulletSlide $pres 'Hallazgos principales' @(
        'H1 - Suite alineada al documento tecnico',
        'H2 - Contrato validado sin red (2/2 OK)',
        'H3 - Integracion bloqueada por acceso al servidor',
        'H4 - Reportes Karate listos para auditoria',
        'Conclusion: herramienta lista; certificar ambiente'
    )

    Add-BulletSlide $pres 'Recomendaciones priorizadas' @(
        'P0 - Habilitar VPN o whitelist IP al simulador',
        'P0 - Ejecutar: mvn test -Dtest=UssdTestRunner',
        'P1 - Pipeline CI: contrato + integracion nightly',
        'P1 - Pruebas negativas (sessionId invalido)',
        'P2 - Carga JMeter + monitoreo sintetico *999#'
    )

    Add-BulletSlide $pres 'Como asegurar que el servicio escale' @(
        'Hoy: regresion funcional automatica pre-release',
        'Fase 2: sesiones concurrentes, latencia p95',
        'Produccion: robot *999# cada 5 minutos',
        'Arquitectura: TTL de sessionId, limites por MSISDN',
        'Funcional + carga + monitoreo = defensa en profundidad'
    )

    Add-BulletSlide $pres 'Como ejecutar la suite' @(
        'Sin red: mvn test -Poffline',
        'Con VPN: mvn test -Dtest=UssdTestRunner',
        'Red: Test-NetConnection 181.224.248.52 -Port 9898',
        'Docs: docs/REPORTE_EJECUTIVO_CEO.md',
        'Repo: RetoQA (GitHub/GitLab)'
    )

    Add-BulletSlide $pres 'Entregables del reto' @(
        'Repositorio: codigo + features Karate + proto',
        'ESTRATEGIA_QA.md - estrategia profesional',
        'REPORTE_EJECUTIVO_CEO.md - vision direccion',
        'GUIA_PRESENTACION.md - guion de presentacion',
        'PPT + reportes HTML de evidencia'
    )

    Add-TitleSlide $pres 'Gracias' 'Preguntas`nProximo paso: habilitar ambiente y certificar integracion gRPC'

    if (Test-Path $outFile) { Remove-Item $outFile -Force }
    $pres.SaveAs($outFile)
    $pres.Close()
    $ppt.Quit()
    [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($ppt)
    Write-Host "OK: $outFile"
}
catch {
    Write-Error "Error (requiere PowerPoint instalado): $_"
    exit 1
}
