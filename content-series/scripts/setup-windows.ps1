param(
  [string]$ProjectRoot = "",
  [string]$TaskName = "Content Series - Diario",
  [switch]$Remove
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) { $ProjectRoot = (Get-Location).Path }
$ProjectRoot = (Resolve-Path $ProjectRoot).Path

$autoDir = Join-Path $ProjectRoot "automatizacion"
$configPath = Join-Path $ProjectRoot "contenido\config.json"

if ($Remove) {
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
  Unregister-ScheduledTask -TaskName "Content Series - Publicar pendiente" -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
  Write-Output "Tareas eliminadas."
  exit 0
}

if (-not (Test-Path $configPath)) { throw "Falta contenido\config.json." }
if (-not (Test-Path (Join-Path $autoDir "run-dia.ps1"))) { throw "Falta automatizacion\run-dia.ps1." }

$cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

$at = "09:00"
if ($cfg.schedule -and $cfg.schedule.generateAt) { $at = [string]$cfg.schedule.generateAt }
if ($at -notmatch '^\d{1,2}:\d{2}$') { throw "schedule.generateAt debe tener formato HH:mm (ej. 09:00)." }

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$autoDir\run-dia.ps1`" -ProjectRoot `"$ProjectRoot`""
$trigger = New-ScheduledTaskTrigger -Daily -At $at
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
$t = Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description "Genera el post diario de la serie de contenido."
$t | Select-Object TaskName, State | Format-Table -AutoSize
Get-ScheduledTaskInfo -TaskName $TaskName | Select-Object NextRunTime | Format-List
