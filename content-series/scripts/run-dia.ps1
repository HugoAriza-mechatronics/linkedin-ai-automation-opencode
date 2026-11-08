param(
  [int]$Dia = 0,
  [string]$ProjectRoot = "",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) { $ProjectRoot = (Get-Location).Path }
$ProjectRoot = (Resolve-Path $ProjectRoot).Path

$contentDir  = Join-Path $ProjectRoot "contenido"
$postsDir    = Join-Path $contentDir "posts"
$autoDir     = Join-Path $ProjectRoot "automatizacion"
$logsDir     = Join-Path $autoDir "logs"
$configPath  = Join-Path $contentDir "config.json"
$temarioPath = Join-Path $contentDir "temario.md"

New-Item -ItemType Directory -Force -Path $logsDir, $postsDir | Out-Null

if (-not (Test-Path $configPath)) { throw "Falta contenido\config.json. Ejecuta el onboarding de la skill content-series." }
if (-not (Test-Path $temarioPath)) { throw "Falta contenido\temario.md." }

$cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

$total = 30
if ($cfg.series -and $cfg.series.totalDays) { $total = [int]$cfg.series.totalDays }
if ($total -le 0) { $total = 30 }

$mode = "manual"
if ($cfg.publish -and $cfg.publish.mode) { $mode = [string]$cfg.publish.mode }

# Localizar el CLI de OpenCode
$exe = $null
$cmd = Get-Command opencode -ErrorAction SilentlyContinue
if ($cmd) { $exe = $cmd.Source }
if (-not $exe) {
  $candidate = Join-Path $env:LOCALAPPDATA "Programs\ai.opencode.desktop\resources\opencode-cli.exe"
  if (Test-Path $candidate) { $exe = $candidate }
}
if (-not $exe) { throw "No se encontro el CLI de OpenCode. Instala OpenCode o agrega 'opencode' al PATH." }

# Calcular el siguiente dia
$auto = ($Dia -le 0)
if ($Dia -le 0) {
  $nums = Get-ChildItem $postsDir -Filter "dia-*.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.Name -match '^dia-(\d{2})') { [int]$matches[1] }
  }
  $max = 0
  if ($nums) { $max = ($nums | Measure-Object -Maximum).Maximum }
  $Dia = $max + 1
}

if ($Dia -gt $total) {
  Write-Output "Serie completada ($total/$total). No hay nada que generar."
  exit 0
}

# Evitar dos generaciones con la misma fecha
if ($auto) {
  $hoy = (Get-Date).ToString("yyyy-MM-dd")
  $yaHoy = Get-ChildItem $postsDir -Filter "dia-*.md" -File -ErrorAction SilentlyContinue | Where-Object {
    $head = Get-Content $_.FullName -TotalCount 8 -Encoding UTF8
    $head -match ("^\s*-\s*\*\*Fecha:\*\*\s*" + [regex]::Escape($hoy))
  }
  if ($yaHoy) {
    Write-Output ("Ya existe un post con fecha de hoy ({0}). No se genera otro." -f $yaHoy[0].Name)
    exit 0
  }
}

# Fila del temario
$line = (Get-Content $temarioPath -Encoding UTF8) | Where-Object { $_ -match ("^\|\s*" + $Dia + "\s*\|") } | Select-Object -First 1
if (-not $line) { throw "No se encontro el dia $Dia en contenido\temario.md" }

$slugBase = "dia-{0:D2}" -f $Dia

$prompt = @"
# Tarea diaria - Contenido para LinkedIn

Lee y sigue al pie de la letra: automatizacion/instrucciones-dia.md
Lee tambien: contenido/config.json y contenido/temario.md

- Dia a generar: $Dia de $total
- Fila del temario: $line
- Nombre base del archivo: $slugBase-<slug>.md
- Carpeta de salida: contenido/posts
- Modo de publicacion configurado: $mode

Trabaja dentro de: $ProjectRoot
No publiques nada en LinkedIn. Solo guarda el .md.
"@

$promptPath = Join-Path $autoDir "prompt-actual.md"
Set-Content -Path $promptPath -Value $prompt -Encoding UTF8

if ($DryRun) {
  Write-Output "DIA: $Dia de $total"
  Write-Output "MODO: $mode"
  Write-Output "LINEA: $line"
  Write-Output "PROMPT:"
  Get-Content $promptPath
  exit 0
}

$log = Join-Path $logsDir ("{0}-dia-{1:D2}.log" -f (Get-Date -Format "yyyy-MM-dd"), $Dia)

$prevEap = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$code = 1

Push-Location $ProjectRoot
try {
  & $exe run --auto --title ("Contenido Dia {0:D2}" -f $Dia) "Lee automatizacion\prompt-actual.md y ejecuta la tarea diaria. Trabaja en esta carpeta." *> $log
  $code = $LASTEXITCODE
} finally {
  Pop-Location
  $ErrorActionPreference = $prevEap
}

$md = Get-ChildItem $postsDir -Filter ("dia-{0:D2}-*.md" -f $Dia) -File -ErrorAction SilentlyContinue |
      Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $md) {
  Write-Output "No se genero el archivo del dia $Dia. Revisa automatizacion\logs."
  exit 1
}

if ($mode -eq "auto") {
  $offset = 3
  if ($cfg.publish -and $cfg.publish.offsetHours) { $offset = [int]$cfg.publish.offsetHours }
  if ($offset -le 0) { $offset = 3 }

  $pubAt = (Get-Date).AddHours($offset)
  $state = [ordered]@{
    dia         = $Dia
    archivo     = $md.FullName
    generado_en = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    publicar_en = $pubAt.ToString("yyyy-MM-dd HH:mm:ss")
  } | ConvertTo-Json
  Set-Content -Path (Join-Path $contentDir "pendiente.json") -Value $state -Encoding UTF8

  $pubTask = "Content Series - Publicar pendiente"
  $pubAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$autoDir\publicar-dia.ps1`" -ProjectRoot `"$ProjectRoot`""
  $pubTrigger = New-ScheduledTaskTrigger -Once -At $pubAt
  $pubSettings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
  Unregister-ScheduledTask -TaskName $pubTask -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
  Register-ScheduledTask -TaskName $pubTask -Action $pubAction -Trigger $pubTrigger -Settings $pubSettings -Description "Publica en LinkedIn el post pendiente de la serie." | Out-Null
  Write-Output ("Post generado y publicacion programada para {0}" -f $pubAt.ToString("yyyy-MM-dd HH:mm"))
} else {
  Write-Output ("Post generado: {0}" -f $md.FullName)
  Write-Output "Modo manual: copia el texto y publicalo en LinkedIn cuando quieras."
}

exit 0
