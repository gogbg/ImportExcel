$data1 = ConvertFrom-Csv -InputObject @"
ID,Product,Quantity,Price,Total
12001,Nails,37,3.99,147.63
12002,Hammer,5,12.10,60.5
12003,Saw,12,15.37,184.44
12010,Drill,20,8,160
12011,Crowbar,7,23.48,164.36
"@
$data2 = ConvertFrom-Csv -InputObject @"
ID,Product,Quantity,Price,Total
12001,Nails,53,3.99,211.47
12002,Hammer,6,12.10,72.60
12003,Saw,10,15.37,153.70
12010,Drill,10,8,80
12012,Pliers,2,14.99,29.98
"@
$data3 = ConvertFrom-Csv -InputObject @"
ID,Product,Quantity,Price,Total
12001,Nails,20,3.99,79.80
12002,Hammer,2,12.10,24.20
12010,Drill,11,8,88
12012,Pliers,3,14.99,44.97
"@

Describe "Join Worksheet" {
    BeforeAll {
        $path = "$Env:TEMP\test.xlsx"
        Remove-Item -Path $path -ErrorAction SilentlyContinue
        $data1 | Export-Excel -Path $path -WorkSheetname Oxford
        $data2 | Export-Excel -Path $path -WorkSheetname Abingdon
        $data3 | Export-Excel -Path $path -WorkSheetname Banbury
        $ptdef = New-PivotTableDefinition -PivotTableName "Summary" -PivotRows "Store" -PivotColumns "Product" -PivotData @{"Total"="SUM"} -IncludePivotChart -ChartTitle "Sales Breakdown" -ChartType ColumnStacked -ChartColumn 10
        Join-Worksheet -Path $path -WorkSheetName "Total" -Clearsheet -FromLabel "Store" -TableName "Summary" -TableStyle Light1 -AutoSize -BoldTopRow -FreezePane 2,1 -Title "Store Sales Summary" -TitleBold -TitleSize 14  -PivotTableDefinition $ptdef
        $excel = Open-ExcelPackage -Path $path
        $ws    = $excel.Workbook.Worksheets["Total"]
        $pt    = $excel.Workbook.Worksheets["Summary"].pivottables[0]
        $pc    = $excel.Workbook.Worksheets["Summary"].Drawings[0]
    }
    Context "Merge 3 blocks" {
        it "Created sheet of the right size with a title and a table                               " {
            $ws.Dimension.Address                                         | Should     be "A1:F16"
            $ws.Tables[0].Address.Address                                 | Should     be "A2:F16"
            $ws.cells["A1"].Value                                         | Should     be "Store Sales Summary"
            $ws.cells["A1"].Style.Font.Size                               | Should     be 14
            $ws.Tables[0].StyleName                                       | Should     be "TableStyleLight1"
            $ws.cells["A2:F2"].Style.Font.Bold                            | Should     be $True
        }
        it "Added a from column with the right heading                                             " {
            $ws.cells["F2" ].Value                                        | Should     be "Store"
            $ws.cells["F3" ].Value                                        | Should     be "Oxford"
            $ws.cells["F8" ].Value                                        | Should     be "Abingdon"
            $ws.cells["F13"].Value                                        | Should     be "Banbury"
        }
        it "Filled in the data                                                                     " {
            $ws.cells["C3" ].Value                                        | Should     be $data1[0].quantity
            $ws.cells["C8" ].Value                                        | Should     be $data2[0].quantity
            $ws.cells["C13"].Value                                        | Should     be $data3[0].quantity
        }
        it "Created the pivot table                                                                " {
            $pt                                                           | Should not beNullOrEmpty
            $pt.StyleName                                                 | Should     be "PivotStyleMedium9"
            $pt.RowFields[0].Name                                         | Should     be "Store"
            $pt.ColumnFields[0].name                                      | Should     be "Product"
            $pt.DataFields[0].name                                        | Should     be "Sum of Total"
            $pc.ChartType                                                 | Should     be "ColumnStacked"
            $pc.Title.text                                                | Should     be "Sales Breakdown"
        }
    }
    $path = "$env:TEMP\Test.xlsx"
    Remove-item -Path $path -ErrorAction SilentlyContinue
     Get-WmiObject -Class win32_logicaldisk |
        Select-Object -Property DeviceId,VolumeName, Size,Freespace |
            Export-Excel -Path $path -WorkSheetname Volumes -NumberFormat "0,000"
    Get-NetAdapter  |
        Select-Object -Property Name,InterfaceDescription,MacAddress,LinkSpeed |
            Export-Excel -Path $path -WorkSheetname NetAdapters

    Join-Worksheet -Path $path -HideSource -WorkSheetName Summary -NoHeader -LabelBlocks  -AutoSize -Title "Summary" -TitleBold -TitleSize 22
    $excel = Open-ExcelPackage -Path $path
    $ws    = $excel.Workbook.Worksheets["Summary"]
    Context "3 Unlinked blocks" {
        it "Hid the source worksheets                                                              " {
            $excel.Workbook.Worksheets[1].Hidden.tostring()               | should     be "Hidden"
            $excel.Workbook.Worksheets[2].Hidden.tostring()               | should     be "Hidden"
        }
        it "Created the Summary sheet with title, and block labels, and copied the correct data    " {
            $ws.Cells["A1"].Value                                         | should     be "Summary"
            $ws.Cells["A2"].Value                                         | should     be $excel.Workbook.Worksheets[1].name
            $ws.Cells["A3"].Value                                         | should     be $excel.Workbook.Worksheets[1].Cells["A1"].value
            $ws.Cells["A4"].Value                                         | should     be $excel.Workbook.Worksheets[1].Cells["A2"].value
            $ws.Cells["B4"].Value                                         | should     be $excel.Workbook.Worksheets[1].Cells["B2"].value
            $nextRow = $excel.Workbook.Worksheets[1].Dimension.Rows + 3
            $ws.Cells["A$NextRow"].Value                                  | should     be $excel.Workbook.Worksheets[2].name
            $nextRow ++
            $ws.Cells["A$NextRow"].Value                                  | should     be $excel.Workbook.Worksheets[2].Cells["A1"].value
            $nextRow ++
            $ws.Cells["A$NextRow"].Value                                  | should     be $excel.Workbook.Worksheets[2].Cells["A2"].value
            $ws.Cells["B$NextRow"].Value                                  | should     be $excel.Workbook.Worksheets[2].Cells["B2"].value
        }
    }

}

