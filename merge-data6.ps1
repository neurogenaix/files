# Define file paths
$fileA = "A.txt"  # 40Kb - Lookup file
$fileB = "B.txt"  # 500Mb - Source data file
$fileC = "C.txt"  # Output file

# Remove output file if it exists
if (Test-Path $fileC) { Remove-Item $fileC }

# Read file sizes for reporting
$aLineCount = (Get-Content $fileA).Count
$bLineCount = (Get-Content $fileB).Count
Write-Host "File A: $aLineCount lines"
Write-Host "File B: $bLineCount lines"

# Read all lines from A into memory (small file)
$aLines = Get-Content $fileA

# Prepare output stream
$outStream = [System.IO.StreamWriter]::new($fileC, $false, [System.Text.Encoding]::UTF8)
$totalMatches = 0

$counter = 0
foreach ($aLine in $aLines) {
    $counter++
    $aFields = $aLine -split ":", 6
    $lookupValue = $aFields[0].Trim()
    Write-Host "Processing line $counter of $aLineCount from File A: '$lookupValue'..."

    # Stream through large File B line-by-line
    $matchCountThisA = 0
    $progressB = 0
    Get-Content $fileB | ForEach-Object {
        $progressB++
        # Progress indicator every 100,000 lines
        if ($progressB % 100000 -eq 0) {
            Write-Host "  ...processed $progressB lines from File B"
        }

        $bFields = $_ -split ":", 6
        # Safeguard: Ensure B line has at least 4 fields
        if ($bFields.Length -ge 4) {
            $compareField = $bFields[3].Trim()
            if ($lookupValue -eq $compareField) {
                $outStream.WriteLine("$_$aLine")  # Concatenate without extra delimiter
                $matchCountThisA++
                $totalMatches++
            }
        }
    }
    Write-Host "  Found $matchCountThisA matches for '$lookupValue'"
}

$outStream.Close()
Write-Host "DONE!"
Write-Host "$totalMatches total matches written to $fileC"
