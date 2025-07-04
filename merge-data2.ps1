# Set file paths
$fileA = "A.txt"
$fileB = "B.txt"
$fileC = "C.txt"

# Prepare output file
if (Test-Path $fileC) { Remove-Item $fileC }

# Build inverted index for file A
$index = @{}

Get-Content $fileA | ForEach-Object {
    $aLine = $_
    $aFields = $aLine -split ":"
    foreach ($field in $aFields) {
        if (-not $index.ContainsKey($field)) {
            $index[$field] = @()
        }
        $index[$field] += $aLine
    }
}

# Process each line in file B
Get-Content $fileB | ForEach-Object {
    $bLine = $_
    $bKey = ($bLine -split ":")[0]
    if ($index.ContainsKey($bKey)) {
        foreach ($aLine in $index[$bKey]) {
            $combined = "$aLine:$bLine"
            Add-Content -Path $fileC -Value $combined
        }
    }
}
