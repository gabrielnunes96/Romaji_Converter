Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Força os controles a usarem o estilo visual moderno do Windows
[System.Windows.Forms.Application]::EnableVisualStyles()

function Convert-RomajiToKana {
    param(
        [string]$text,
        [bool]$ToKatakana = $false
    )

    if ([string]::IsNullOrEmpty($text)) { return "" }

    $map = @{
        "kya"="きゃ"; "kyu"="きゅ"; "kyo"="きょ";
        "gya"="ぎゃ"; "gyu"="ぎゅ"; "gyo"="ぎょ";
        "sha"="しゃ"; "shu"="しゅ"; "sho"="しょ";
        "sya"="しゃ"; "syu"="しゅ"; "syo"="しょ";
        "ja"="じゃ"; "ju"="じゅ"; "jo"="じょ";
        "jya"="じゃ"; "jyu"="じゅ"; "jyo"="じょ";
        "cha"="ちゃ"; "chu"="ちゅ"; "cho"="ちょ";
        "tya"="ちゃ"; "tyu"="ちゅ"; "tyo"="ちょ";
        "nya"="にゃ"; "nyu"="にゅ"; "nyo"="にょ";
        "hya"="ひゃ"; "hyu"="ひゅ"; "hyo"="ひょ";
        "bya"="びゃ"; "byu"="びゅ"; "byo"="びょ";
        "pya"="ぴゃ"; "pyu"="ぴゅ"; "pyo"="ぴょ";
        "mya"="みゃ"; "myu"="みゅ"; "myo"="みょ";
        "rya"="りゃ"; "ryu"="りゅ"; "ryo"="りょ";
        "fa"="ふぁ"; "fi"="ふぃ"; "fe"="ふぇ"; "fo"="ふぉ";
        "va"="ゔぁ"; "vi"="ゔぃ"; "vu"="ゔ"; "ve"="ゔぇ"; "vo"="ゔぉ";
        "tsa"="つぁ"; "tsi"="つぃ"; "tse"="つぇ"; "tso"="つぉ";
        "wi"="うぃ"; "we"="うぇ"; "wo"="を";

        "shi"="し"; "chi"="ち"; "tsu"="つ"; "fu"="ふ";
        "ji"="じ"; "dji"="ぢ"; "dzu"="づ";

        "ka"="か"; "ki"="き"; "ku"="く"; "ke"="け"; "ko"="こ";
        "ga"="が"; "gi"="ぎ"; "gu"="ぐ"; "ge"="げ"; "go"="ご";
        "sa"="さ"; "su"="す"; "se"="せ"; "so"="そ";
        "za"="ざ"; "zu"="ず"; "ze"="ぜ"; "zo"="ぞ";
        "ta"="た"; "ti"="てぃ"; "tu"="とぅ"; "te"="て"; "to"="と";
        "da"="だ"; "de"="で"; "do"="ど";
        "na"="な"; "ni"="に"; "nu"="ぬ"; "ne"="ね"; "no"="の";
        "ha"="は"; "hi"="ひ"; "hu"="ふ"; "he"="へ"; "ho"="ほ";
        "ba"="ば"; "bi"="び"; "bu"="ぶ"; "be"="べ"; "bo"="ぼ";
        "pa"="ぱ"; "pi"="ぴ"; "pu"="ぷ"; "pe"="ぺ"; "po"="ぽ";
        "ma"="ま"; "mi"="み"; "mu"="む"; "me"="め"; "mo"="も";
        "ya"="や"; "yu"="ゆ"; "yo"="よ";
        "ra"="ら"; "ri"="り"; "ru"="る"; "re"="れ"; "ro"="ろ";
        "la"="ら"; "li"="り"; "lu"="る"; "le"="れ"; "lo"="ろ";
        "wa"="わ"; "n'"="ん"; "nn"="ん"; "n " ="ん ";
        "a"="あ"; "i"="い"; "u"="う"; "e"="え"; "o"="お";
        "xya"="ゃ"; "xyu"="ゅ"; "xyo"="ょ";
        "xa"="ぁ"; "xi"="ぃ"; "xu"="ぅ"; "xe"="ぇ"; "xo"="ぉ";
    }

    $i = 0
    $out = New-Object System.Text.StringBuilder
    $lower = $text.ToLower()

    while ($i -lt $lower.Length) {
        if ($i + 1 -lt $lower.Length) {
            $c1 = $lower[$i]
            $c2 = $lower[$i + 1]
            if ($c1 -match "[bcdfghjklmpqrstvwxyz]" -and $c1 -eq $c2 -and $c1 -ne 'n') {
                [void]$out.Append("っ")
                $i += 1
                continue
            }
        }

        if ($lower[$i] -eq 'n') {
            $next = if ($i + 1 -lt $lower.Length) { $lower[$i+1] } else { "" }
            if ($next -eq "" -or $next -match "[^aiueoy]") {
                [void]$out.Append("ん")
                $i += 1
                continue
            }
        }

        $matched = $false
        foreach ($len in 3,2,1) {
            if ($i + $len -le $lower.Length) {
                $chunk = $lower.Substring($i, $len)
                if ($map.ContainsKey($chunk)) {
                    [void]$out.Append($map[$chunk])
                    $i += $len
                    $matched = $true
                    break
                }
            }
        }

        if (-not $matched) {
            [void]$out.Append($lower[$i])
            $i += 1
        }
    }

    $kana = $out.ToString()

    if ($ToKatakana) {
        $converted = New-Object System.Text.StringBuilder
        foreach ($ch in $kana.ToCharArray()) {
            $code = [int][char]$ch
            if ($code -ge 0x3041 -and $code -le 0x3096) {
                $kat = [char]($code + 0x60)
                [void]$converted.Append($kat)
            }
            elseif ($ch -eq 'ー') { [void]$converted.Append('ー') }
            elseif ($ch -eq 'っ') { [void]$converted.Append([char]0x30C3) }
            else { [void]$converted.Append($ch) }
        }
        $kana = $converted.ToString()
        $kana = $kana -replace "-", "ー"
    }

    return $kana
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Romaji → 日本語 (PowerShell IME)"
$form.Size = New-Object System.Drawing.Size(720, 420)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

$lblInput = New-Object System.Windows.Forms.Label
$lblInput.Text = "Digite em romaji:"
$lblInput.Location = New-Object System.Drawing.Point(12, 12)
$lblInput.AutoSize = $true
$form.Controls.Add($lblInput)

$txtInput = New-Object System.Windows.Forms.TextBox
$txtInput.Multiline = $true
$txtInput.ScrollBars = "Vertical"
$txtInput.Font = New-Object System.Drawing.Font("Consolas", 14)
$txtInput.Location = New-Object System.Drawing.Point(12, 32)
$txtInput.Size = New-Object System.Drawing.Size(680, 140)
$form.Controls.Add($txtInput)

$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Text = "Saída (Hiragana/Katakana):"
$lblOutput.Location = New-Object System.Drawing.Point(12, 182)
$lblOutput.AutoSize = $true
$form.Controls.Add($lblOutput)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Multiline = $true
$txtOutput.ScrollBars = "Vertical"
$txtOutput.Font = New-Object System.Drawing.Font("Yu Gothic UI", 16)
$txtOutput.Location = New-Object System.Drawing.Point(12, 202)
$txtOutput.Size = New-Object System.Drawing.Size(680, 140)
$txtOutput.ReadOnly = $true
$form.Controls.Add($txtOutput)

$rbHira = New-Object System.Windows.Forms.RadioButton
$rbHira.Text = "Hiragana"
$rbHira.Location = New-Object System.Drawing.Point(12, 350)
$rbHira.Checked = $true
$rbHira.AutoSize = $true
$rbHira.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
$form.Controls.Add($rbHira)

$rbKata = New-Object System.Windows.Forms.RadioButton
$rbKata.Text = "Katakana"
$rbKata.Location = New-Object System.Drawing.Point(100, 350)
$rbKata.AutoSize = $true
$rbKata.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
$form.Controls.Add($rbKata)

$btnCopy = New-Object System.Windows.Forms.Button
$btnCopy.Text = "Copiar"
$btnCopy.Location = New-Object System.Drawing.Point(200, 346)
$form.Controls.Add($btnCopy)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Limpar"
$btnClear.Location = New-Object System.Drawing.Point(280, 346)
$form.Controls.Add($btnClear)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "Fechar"
$btnClose.Location = New-Object System.Drawing.Point(360, 346)
$form.Controls.Add($btnClose)

$updateOutput = {
    $txtOutput.Text = Convert-RomajiToKana -text $txtInput.Text -ToKatakana:$rbKata.Checked
}

$txtInput.Add_TextChanged($updateOutput)
$rbHira.Add_CheckedChanged($updateOutput)
$rbKata.Add_CheckedChanged($updateOutput)

$btnCopy.Add_Click({ [System.Windows.Forms.Clipboard]::SetText($txtOutput.Text) })
$btnClear.Add_Click({ $txtInput.Clear(); $txtInput.Focus() })
$btnClose.Add_Click({ $form.Close() })

$txtInput.Text = ""
$txtInput.SelectionStart = $txtInput.Text.Length

[void]$form.ShowDialog()
