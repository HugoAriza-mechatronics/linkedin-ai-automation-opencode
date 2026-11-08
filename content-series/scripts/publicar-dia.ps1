param(
  [string]$ProjectRoot = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) { $ProjectRoot = (Get-Location).Path }
$ProjectRoot = (Resolve-Path $ProjectRoot).Path

$contentDir = Join-Path $ProjectRoot "contenido"
$autoDir    = Join-Path $ProjectRoot "automatizacion"
$logsDir    = Join-Path $autoDir "logs"
$pend       = Join-Path $contentDir "pendiente.json"
$task       = "Content Series - Publicar pendiente"

New-Item -ItemType Directory -Force -Path $logsDir | Out-Null

if (-not (Test-Path $pend)) {
  Write-Output "No hay publicacion pendiente."
  Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
  exit 0
}

try {
  $p = Get-Content $pend -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
  Write-Output "pendiente.json invalido: $($_.Exception.Message)"
  exit 1
}

$dia = [int]$p.dia
$log = Join-Path $logsDir ("{0}-publicar-dia-{1:D2}.log" -f (Get-Date -Format "yyyy-MM-dd"), $dia)

$exe = $null
$cmd = Get-Command opencode -ErrorAction SilentlyContinue
if ($cmd) { $exe = $cmd.Source }
if (-not $exe) {
  $candidate = Join-Path $env:LOCALAPPDATA "Programs\ai.opencode.desktop\resources\opencode-cli.exe"
  if (Test-Path $candidate) { $exe = $candidate }
}
if (-not $exe) { throw "No se encontro el CLI de OpenCode." }

$prevEap = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$code = 1

Push-Location $ProjectRoot
try {
  & $exe run --auto --title ("Publicar LinkedIn Dia {0:D2}" -f $dia) "Lee automatizacion\instrucciones-publicar.md y ejecuta la publicacion pendiente. Trabaja en esta carpeta." *> $log
  $code = $LASTEXITCODE
} finally {
  Pop-Location
  $ErrorActionPreference = $prevEap
}

# La tarea es de una sola ejecucion: se elimina siempre.
Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

exit $code
