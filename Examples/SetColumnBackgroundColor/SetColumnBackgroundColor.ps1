﻿try {. $PSScriptRoot\..\..\LoadPSD1.ps1} catch {}

$p = Get-Process | Select-Object Company, Handles | Export-Excel c:\temp\testBackgroundColor.xlsx -ClearSheet -KillExcel -PassThru

$ws        = $p.Workbook.WorkSheets[1]
$totalRows = $ws.Dimension.Rows

Set-Format -Address $ws.Cells["B2:B$($totalRows)"] -BackgroundColor LightBlue

Export-Excel -ExcelPackage $p -show -AutoSize