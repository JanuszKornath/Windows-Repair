Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Prüfen, ob Adminrechte vorliegen
function Check-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# GUI bauen
$form = New-Object System.Windows.Forms.Form
$form.Text = "Systemüberprüfung mit DISM & SFC"
$form.Size = New-Object System.Drawing.Size(700, 500)
$form.StartPosition = "CenterScreen"

# Textbox für Log-Ausgabe
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.ScrollBars = 'Vertical'
$txtLog.ReadOnly = $true
$txtLog.WordWrap = $true
$txtLog.Font = New-Object System.Drawing.Font("Consolas",10)
$txtLog.Dock = 'Fill'

# Fortschrittsbalken
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Minimum = 0
$progressBar.Maximum = 4
$progressBar.Value = 0
$progressBar.Dock = 'Bottom'
$progressBar.Height = 25

# Statuslabel
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Bereit"
$lblStatus.Dock = 'Bottom'
$lblStatus.Height = 25
$lblStatus.TextAlign = 'MiddleLeft'

# Button starten
$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = "Systemprüfung starten"
$btnStart.Dock = 'Top'
$btnStart.Height = 40
$btnStart.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)

# Layout
$form.Controls.Add($txtLog)
$form.Controls.Add($progressBar)
$form.Controls.Add($lblStatus)
$form.Controls.Add($btnStart)

# Log-Datei Pfad
$logPath = "$PSScriptRoot\SystemCheck.log"

# Funktion zum Loggen in TextBox + Datei
function Write-Log {
    param([string]$text, [string]$color = 'Black')
    $timestamp = Get-Date -Format "HH:mm:ss"
    $line = "[$timestamp] $text"
    # Im Log-File speichern
    Add-Content -Path $logPath -Value $line
    # Im GUI anzeigen
    $txtLog.Invoke([action]{
        $txtLog.AppendText("$line`r`n")
        $txtLog.SelectionStart = $txtLog.Text.Length
        $txtLog.ScrollToCaret()
    })
}

# DISM & SFC Befehle ausführen (in Reihenfolge)
function Run-Check {
    param(
        [string]$desc,
        [string]$cmd
    )
    Write-Log "Starte: $desc"
    $lblStatus.Invoke([action]{ $lblStatus.Text = "Starte: $desc" })
    try {
        $proc = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command $cmd" -NoNewWindow -RedirectStandardOutput "$PSScriptRoot\temp_output.txt" -RedirectStandardError "$PSScriptRoot\temp_error.txt" -Wait -PassThru
        $out = Get-Content "$PSScriptRoot\temp_output.txt" -Raw
        $err = Get-Content "$PSScriptRoot\temp_error.txt" -Raw
        if ($proc.ExitCode -ne 0) {
            Write-Log "FEHLER bei $desc:" 'Red'
            Write-Log $err 'Red'
            return $false
        } else {
            Write-Log "Erfolg: $desc"
            return $true
        }
    }
    catch {
        Write-Log "Exception bei $desc: $_" 'Red'
        return $false
    }
    finally {
        Remove-Item "$PSScriptRoot\temp_output.txt","$PSScriptRoot\temp_error.txt" -ErrorAction SilentlyContinue
    }
}

# Start-Button Eventhandler
$btnStart.Add_Click({
    # Admincheck
    if (-not (Check-Admin)) {
        [System.Windows.Forms.MessageBox]::Show("Bitte das Programm als Administrator starten!","Keine Administratorrechte",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }

    # Logdatei neu anlegen
    if (Test-Path $logPath) { Remove-Item $logPath }
    Add-Content -Path $logPath -Value "=== Systemcheck gestartet: $(Get-Date) ==="

    # Button deaktivieren, Fortschritt zurücksetzen
    $btnStart.Enabled = $false
    $progressBar.Value = 0
    $txtLog.Clear()

    # Befehle + Beschreibungen in Array
    $steps = @(
        @{desc="DISM CheckHealth"; cmd="Dism /Online /Cleanup-Image /CheckHealth"},
        @{desc="DISM ScanHealth"; cmd="Dism /Online /Cleanup-Image /ScanHealth"},
        @{desc="DISM RestoreHealth"; cmd="Dism /Online /Cleanup-Image /RestoreHealth"},
        @{desc="SFC Systemdatei-Überprüfung"; cmd="sfc /scannow"}
    )

    foreach ($i in 0..($steps.Count-1)) {
        $step = $steps[$i]
        $success = Run-Check -desc $step.desc -cmd $step.cmd
        if (-not $success) {
            [System.Windows.Forms.MessageBox]::Show("Fehler bei '$($step.desc)'. Siehe Logdatei: $logPath","Fehler",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null
            break
        }
        $progressBar.Invoke([action]{ $progressBar.Value = $i + 1 })
    }

    $lblStatus.Invoke([action]{ $lblStatus.Text = "Vorgang abgeschlossen." })
    [System.Windows.Forms.MessageBox]::Show("Systemprüfung abgeschlossen.`nDetails siehe Logdatei: $logPath","Fertig",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null

    $btnStart.Enabled = $true
})

# GUI starten
$form.Topmost = $true
[void]$form.ShowDialog()