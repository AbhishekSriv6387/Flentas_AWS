# setup_env.ps1

# 1. Generate SSH Key if not exists
$keyPath = "$env:USERPROFILE\.ssh\id_rsa"
if (-not (Test-Path $keyPath)) {
    Write-Host "Generating SSH Key..."
    mkdir "$env:USERPROFILE\.ssh" -ErrorAction SilentlyContinue
    ssh-keygen -t rsa -b 4096 -f $keyPath -N ""
}
$pubKey = Get-Content "$keyPath.pub"

# 2. Get Public IP
Write-Host "Getting Public IP..."
try {
    $publicIp = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
    Write-Host "Public IP: $publicIp"
} catch {
    Write-Warning "Could not get public IP. Using 0.0.0.0/0 as fallback (INSECURE)."
    $publicIp = "0.0.0.0"
}

# 3. Define Variables
$Name = "Krish_Maheshwari"
$Email = "krish.maheshwari@example.com" # Placeholder
$CidrIp = "$publicIp/32"

# 4. Replace in Files
$files = Get-ChildItem -Recurse -Include *.tf, *.sh, *.md

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $newContent = $content -replace "FirstName_Lastname", $Name `
                           -replace "user@example.com", $Email `
                           -replace "0.0.0.0/32", $CidrIp
    
    if ($content -ne $newContent) {
        Write-Host "Updating $($file.Name)..."
        Set-Content -Path $file.FullName -Value $newContent
    }
}

# 5. Write SSH Public Key to task directories
"1_vpc", "2_ec2", "3_ha_asg" | ForEach-Object {
    $path = Join-Path $_ "id_rsa.pub"
    if (Test-Path $_) {
        Write-Host "Writing public key to $path..."
        Set-Content -Path $path -Value $pubKey
    }
}

Write-Host "Setup Complete!"
