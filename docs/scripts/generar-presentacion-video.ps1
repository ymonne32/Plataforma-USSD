# Genera Presentacion_Video_USSD_QA.pptx en docs/
# Requiere: Microsoft PowerPoint instalado (Windows)

$ErrorActionPreference = "Stop"
$docsDir = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "docs"
$outFile = Join-Path $docsDir "Presentacion_Video_USSD_QA.pptx"

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

    Add-TitleSlide $pres 'Aseguramiento de Calidad' "Plataforma USSD (gRPC) - Reto Hakom`nYamileidy Monne Clemente | Karate + Java | Junio 2026"

    Add-BulletSlide $pres 'Contexto de negocio' @(
        'USSD = menu al marcar *999# (sin app ni datos)',
        'Alto volumen: saldo, recarga, movimientos, salir',
        'Un fallo = el operador no me deja usar el servicio',
        'Backend gRPC (UssdCmd) con sesiones stateful',
        'Validar que el cliente complete su intencion sin perder sesion'
    )

    Add-BulletSlide $pres 'Objetivo del reto' @(
        'Validar navegacion del menu - suite Karate @grpc',
        'Integridad sesiones stateful - 06-reglas-sesion.feature',
        'Reglas sessionId / msisdn - UssdPayloads + @contract',
        'Reporte ejecutivo para direccion',
        'Ambiente: 181.224.248.52:9898'
    )

    Add-BulletSlide $pres 'Piramide de pruebas' @(
        'Nivel 3 - E2E @e2e: Happy Path completo (07-flujo-completo)',
        'Nivel 2 - Integracion @grpc: smoke + opciones 1 a 4',
        'Nivel 1 - Contrato @contract: payloads sin red (2 tests)',
        'Principio: proteger sesion y contrato antes de exploracion'
    )

    Add-BulletSlide $pres 'Framework: Java + Karate + gRPC' @(
        'Karate 1.5: features legibles y reportes HTML',
        'Java 17 / Maven: CI/CD enterprise',
        'UssdGrpcClient + UssdPayloads: initial() vs subsequent()',
        'Postman descartado (exploracion) | JMeter fase 2 (carga)',
        'Primero protegemos sesion y linea; luego recorrido completo'
    )

    Add-BulletSlide $pres 'Suite automatizada (12 escenarios)' @(
        '00-contracto-payload - @contract (sin servidor)',
        '00-smoke-conexion - menu *999#',
        '01-inicio-sesion - obtencion de sessionId',
        '02 a 05 - opciones 1, 2, 3 y 4 del menu',
        '06-reglas-sesion - reglas stateful criticas',
        '07-flujo-completo - Happy Path E2E'
    )

    Add-BulletSlide $pres 'Reglas de sesion stateful' @(
        'Llamada inicial: solo msisdn y ussdString (*999#)',
        'Llamadas posteriores: solo cambia ussdString + sessionId en request',
        'Inmutables: sessionId (respuesta), msisdn, gwTransId, ussdGwId, type',
        'Feature clave: 06-reglas-sesion.feature'
    )

    Add-BulletSlide $pres 'Happy Path (E2E)' @(
        '*999# - menu principal + sessionId',
        'Opcion 1 - consultar saldo (mismo sessionId)',
        'Opcion 3 - estado de cuenta (mismo sessionId)',
        'Opcion 4 - salir (cierre limpio)',
        'Feature: 07-flujo-completo.feature'
    )

    Add-BulletSlide $pres 'Demo y evidencia' @(
        'Sin VPN: mvn test -Poffline (2/2 OK contrato)',
        'Con VPN: mvn test -Dtest=UssdTestRunner (10 integracion)',
        'Reporte: target/karate-reports/karate-summary.html',
        'Integracion lista; certificacion pendiente acceso red'
    )

    Add-BulletSlide $pres 'Riesgos identificados' @(
        'Perdida de sessionId - abandono del canal - asserts en cada paso',
        'MSISDN distinto - datos de otro usuario - validacion en flujos',
        'Payload incorrecto - rechazo gateway - 00-contracto-payload',
        'Ambiente no accesible - retraso certificacion - P0 VPN/red'
    )

    Add-BulletSlide $pres 'Semaforo de calidad' @(
        'VERDE: diseno de pruebas y cobertura funcional',
        'VERDE: reglas de sesion (sessionId, campos fijos)',
        'AMBAR: ejecucion contra simulador (VPN/red)',
        'PENDIENTE: pruebas de carga y seguridad negativa (fase 2)'
    )

    Add-BulletSlide $pres 'Escalabilidad' @(
        'Hoy: regresion funcional automatica (< 3 min)',
        'Fase 2: JMeter/Gatling - p95, sesiones concurrentes',
        'Produccion: monitoreo sintetico *999# cada 5 min',
        'Funcional = cinturon | Carga = crash test | Monitor = airbag',
        'Arquitectura: TTL sessionId, limites por MSISDN'
    )

    Add-BulletSlide $pres 'Entregables y proximo paso' @(
        'Repo: github.com/ymonne32/Plataforma-USSD',
        'docs/ESTRATEGIA_QA.md + REPORTE_EJECUTIVO_CEO.md',
        'Evidencia: target/karate-reports/',
        'P0: habilitar 181.224.248.52:9898 y certificar integracion'
    )

    Add-TitleSlide $pres 'Gracias' 'Preguntas`nRepo: github.com/ymonne32/Plataforma-USSD'

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
