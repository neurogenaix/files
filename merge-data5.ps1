# Set file paths
$fileA = "A.txt"
$fileB = "B.txt"
$fileC = "C.txt"

# Remove output file if exists
if (Test-Path $fileC) { Remove-Item $fileC }

# Count lines for reporting
$aLineCount = (Get-Content $fileA | Measure-Object).Count
$bLineCount = (Get-Content $fileB | Measure-Object).Count
Write-Host "Lines in File A: $aLineCount"
Write-Host "Lines in File B: $bLineCount"

# Load File B into an array of objects for fast searching
Write-Host "Loading File B into memory for lookup..."
$bArray = @()
Get-Content $fileB | ForEach-Object {
    $fields = $_ -split ":", 5
    # Store the whole line and the 4th field (index 3)
    $bArray += [PSCustomObject]@{ Line = $_; FourthField = if ($fields.Count -ge 4) { $fields[3].Trim() } else { "" } }
}

Write-Host "Starting comparison..."

# Use a stream writer for efficient file output
$outStream = [System.IO.StreamWriter]::new($fileC, $false, [System.Text.Encoding]::UTF8)
$totalMatches = 0
$linesProcessed = 0

Get-Content $fileA | ForEach-Object {
    $aLine = $_
    $aFields = $aLine -split ":", 2
    $firstField = $aFields[0].Trim()
    foreach ($b in $bArray) {
        if ($b.FourthField -eq $firstField -and $b.FourthField -ne "") {
            $outStream.WriteLine("$($b.Line)$aLine")
            $totalMatches++
        }
    }
    $linesProcessed++
    if ($linesProcessed % 10000 -eq 0) {
        Write-Host "$linesProcessed lines of File A processed..."
    }
}

$outStream.Close()
Write-Host "Processing complete."
Write-Host "Total lines from File A processed: $linesProcessed"
Write-Host "Total matches written to $fileC: $totalMatches"
