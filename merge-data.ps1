# Set file paths
$fileA = "A.txt"
$fileB = "B.txt"
$fileC = "C.txt"

# Prepare output file
if (Test-Path $fileC) { Remove-Item $fileC }

# Read all lines from A into memory (since we'll be scanning each line)
$aLines = Get-Content $fileA

# For each line in B
Get-Content $fileB | ForEach-Object {
    $bLine = $_
    $bKey = ($bLine -split ":")[0]

    foreach ($aLine in $aLines) {
        $aFields = $aLine -split ":"
        if ($aFields -contains $bKey) {
            $combined = "$aLine:$bLine"
            Add-Content -Path $fileC -Value $combined
        }
    }
}
