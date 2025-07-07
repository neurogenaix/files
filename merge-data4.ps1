# File paths
$fileA = "A.txt"
$fileB = "B.txt"
$fileC = "C.txt"

# Remove output file if exists
if (Test-Path $fileC) { Remove-Item $fileC }

# Load B into a hashtable: key is first field, value is whole line
$BTable = @{}
Get-Content $fileB | ForEach-Object {
    $fields = $_ -split ":", 2
    $BTable[$fields[0]] = $_
}

# Open output for fast streaming
$outStream = [System.IO.StreamWriter]::new($fileC, $false, [System.Text.Encoding]::UTF8)

# Process A line by line
$matched = 0
Get-Content $fileA | ForEach-Object {
    $aLine = $_
    $aFields = $aLine -split ":", 6
    foreach ($aField in $aFields) {
        if ($BTable.ContainsKey($aField)) {
            $bLine = $BTable[$aField]
            $outStream.WriteLine($aLine + ":" + $bLine)
            $matched++
            break   # Only match the first field in B (remove if you want multiple matches)
        }
    }
}

$outStream.Close()
Write-Host "Done. $matched matches written to $fileC"
