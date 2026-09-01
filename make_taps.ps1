$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function To-ByteArray {
    param([System.Collections.IEnumerable]$Values)
    $list = New-Object 'System.Collections.Generic.List[byte]'
    foreach ($v in $Values) {
        $list.Add([byte]$v)
    }
    return $list.ToArray()
}

function Concat-Bytes {
    param([object[]]$Parts)
    $ms = New-Object System.IO.MemoryStream
    foreach ($p in $Parts) {
        if ($null -ne $p) {
            $b = [byte[]]$p
            $ms.Write($b, 0, $b.Length)
        }
    }
    $result = $ms.ToArray()
    $ms.Dispose()
    return $result
}

function U16LE {
    param([int]$Value)
    return [byte[]]@(
        [byte]($Value -band 0xFF),
        [byte](($Value -shr 8) -band 0xFF)
    )
}

function U16BE {
    param([int]$Value)
    return [byte[]]@(
        [byte](($Value -shr 8) -band 0xFF),
        [byte]($Value -band 0xFF)
    )
}

function Get-XorChecksum {
    param([byte[]]$Data)
    [int]$x = 0
    foreach ($b in $Data) {
        $x = $x -bxor $b
    }
    return [byte]$x
}

function Make-TapBlock {
    param(
        [byte]$Flag,
        [byte[]]$Payload
    )

    $bodyNoChecksum = Concat-Bytes @([byte[]]@($Flag), $Payload)
    $sum = Get-XorChecksum $bodyNoChecksum
    $body = Concat-Bytes @($bodyNoChecksum, [byte[]]@($sum))
    return Concat-Bytes @((U16LE $body.Length), $body)
}

function Make-Header {
    param(
        [byte]$TypeByte,
        [string]$Name,
        [int]$Length,
        [int]$P1,
        [int]$P2
    )

    $name10 = $Name
    if ($name10.Length -gt 10) {
        $name10 = $name10.Substring(0, 10)
    }
    $name10 = $name10.PadRight(10, " ")
    $nameBytes = [System.Text.Encoding]::ASCII.GetBytes($name10)

    $payload = Concat-Bytes @(
        [byte[]]@($TypeByte),
        $nameBytes,
        (U16LE $Length),
        (U16LE $P1),
        (U16LE $P2)
    )

    return Make-TapBlock 0x00 $payload
}

function Make-CodeFile {
    param(
        [string]$Name,
        [byte[]]$Data,
        [int]$Address
    )
    return Concat-Bytes @(
        (Make-Header 3 $Name $Data.Length $Address 0x8000),
        (Make-TapBlock 0xFF $Data)
    )
}

function Make-ZxNum {
    param([int]$Number)

    $ascii = [System.Text.Encoding]::ASCII.GetBytes($Number.ToString())
    $internal = [byte[]]@(
        0x0E, 0x00, 0x00,
        [byte]($Number -band 0xFF),
        [byte](($Number -shr 8) -band 0xFF),
        0x00
    )

    return Concat-Bytes @($ascii, $internal)
}

function Make-BasicLine {
    param(
        [int]$LineNumber,
        [byte[]]$Content
    )

    $withCR = Concat-Bytes @($Content, [byte[]]@(0x0D))
    return Concat-Bytes @(
        (U16BE $LineNumber),
        (U16LE $withCR.Length),
        $withCR
    )
}

function Validate-Tap {
    param([byte[]]$Tap)

    [int]$i = 0
    [int]$blocks = 0

    while ($i -lt $Tap.Length) {
        if (($i + 2) -gt $Tap.Length) {
            throw "Internal TAP validation failed: truncated block length"
        }

        $len = [int]$Tap[$i] -bor ([int]$Tap[$i + 1] -shl 8)
        $i += 2

        if (($i + $len) -gt $Tap.Length) {
            throw "Internal TAP validation failed: truncated block"
        }

        $body = New-Object byte[] $len
        [Array]::Copy($Tap, $i, $body, 0, $len)

        if ((Get-XorChecksum $body) -ne 0) {
            throw "Internal TAP validation failed: bad checksum"
        }

        $i += $len
        $blocks++
    }

    if ($i -ne $Tap.Length) {
        throw "Internal TAP validation failed: bad total length"
    }

    return $blocks
}

# ZX BASIC tokens
$TOK_CLEAR     = [byte]0xFD
$TOK_LOAD      = [byte]0xEF
$TOK_CODE      = [byte]0xAF
$TOK_RANDOMIZE = [byte]0xF9
$TOK_USR       = [byte]0xC0


# ----------------------------------------------------------------------
# Simple TAP containing EasyCF_MB.bin
#
# BASIC:
# 10 CLEAR 32767: LOAD "" CODE 32768:RANDOMIZE USR 32768
# ----------------------------------------------------------------------

function Make-SimpleEasyTap {
    param(
        [string]$BinName,
        [string]$TapName,
        [string]$SpectrumName
    )

    $binPath = Join-Path $Root $BinName
    $tapPath = Join-Path $Root $TapName

    if (-not (Test-Path $binPath)) {
        throw "Missing file: $BinName"
    }

    $binary = [System.IO.File]::ReadAllBytes($binPath)

    if ($binary.Length -eq 0) {
        throw "$BinName is empty"
    }

    if ((32768 + $binary.Length) -gt 65536) {
        throw "$BinName is too large to load at address 32768"
    }

    $content = Concat-Bytes @(
        [byte[]]@($TOK_CLEAR),
        [System.Text.Encoding]::ASCII.GetBytes(" "),
        (Make-ZxNum 32767),
        [System.Text.Encoding]::ASCII.GetBytes(":"),
        [byte[]]@($TOK_LOAD),
        [System.Text.Encoding]::ASCII.GetBytes(' "" '),
        [byte[]]@($TOK_CODE),
        [System.Text.Encoding]::ASCII.GetBytes(" "),
        (Make-ZxNum 32768),
        [System.Text.Encoding]::ASCII.GetBytes(":"),
        [byte[]]@($TOK_RANDOMIZE),
        [System.Text.Encoding]::ASCII.GetBytes(" "),
        [byte[]]@($TOK_USR),
        [System.Text.Encoding]::ASCII.GetBytes(" "),
        (Make-ZxNum 32768)
    )

    $program = Make-BasicLine 10 $content

    $tap = Concat-Bytes @(
        (Make-Header 0 $SpectrumName $program.Length 10 $program.Length),
        (Make-TapBlock 0xFF $program),
        (Make-CodeFile $SpectrumName $binary 32768)
    )

    $blocks = Validate-Tap $tap
    [System.IO.File]::WriteAllBytes($tapPath, $tap)

    Write-Host "$TapName : OK"
    Write-Host "  source: $BinName ($($binary.Length) bytes)"
    Write-Host '  BASIC: 10 CLEAR 32767: LOAD "" CODE 32768:RANDOMIZE USR 32768'
    Write-Host "  TAP size: $($tap.Length) bytes, blocks: $blocks"
}



try {
    Make-SimpleEasyTap "EasyCF_MB.bin" "EasyCF_MB_BIN.tap" "EASYCF_MB"
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)"
    exit 1
}

exit 0
