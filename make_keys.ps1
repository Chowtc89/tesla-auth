# 1. Generate the Private Key
$key = [System.Security.Cryptography.ECDsa]::Create([System.Security.Cryptography.ECCurve]::NamedCurves.nistP256)
$privateKey = $key.ExportECPrivateKey()
[System.IO.File]::WriteAllBytes("private-key.der", $privateKey)

# 2. Generate the Public Key in the format Tesla needs
$publicKey = $key.ExportSubjectPublicKeyInfo()
$base64Key = [System.Convert]::ToBase64String($publicKey, [System.Base64FormattingOptions]::InsertLineBreaks)
$pemKey = "-----BEGIN PUBLIC KEY-----`n$base64Key`n-----END PUBLIC KEY-----"
[System.IO.File]::WriteAllText("com.tesla.3p.public-key.pem", $pemKey)

Write-Host "Success! Your Tesla keys are created in your folder." -ForegroundColor Green