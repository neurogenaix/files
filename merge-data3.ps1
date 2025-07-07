# Set file paths
$fileA = "A.txt"
$fileB = "B.txt"
$fileC = "C.txt"

# Remove output file if it exists
if (Test-Path $fileC) { Remove-Item $fileC }

# Build inverted index for file A (any field value => list of lines)
$index = @{}

Write-Host "Indexing file A..."
$aLines = Get-Content $fileA
foreach ($aLine in $aLines) {
    $aFields = $aLine -split ":", 6
    foreach ($field in $aFields) {
        $key = $field.Trim()
        if ($key -ne "") {
            if (-not $index.ContainsKey($key)) {
                $index[$key] = @()
            }
            $index[$key] += $aLine
        }
    }
}

Write-Host ("Indexed {0} unique keys from A" -f $index.Count)

# Prepare output array for batched file writing
$output = @()
$count = 0

# Process each line in file B
Write-Host "Processing file B..."
$bLines = Get-Content $fileB
foreach ($bLine in $bLines) {
    $bFields = $bLine -split ":", 2
    $bKey = $bFields[0].Trim()
    if ($bKey -ne "" -and $index.ContainsKey($bKey)) {
        foreach ($aLine in $index[$bKey]) {
            $output += "$aLine:$bLine"
            $count++
        }
    }
}

Write-Host ("Matched and combined {0} lines. Writing to C..." -f $count)
# Write to C in one go for speed
$output | Out-File -FilePath $fileC -Encoding UTF8

Write-Host "Done! Output in $fileC"
