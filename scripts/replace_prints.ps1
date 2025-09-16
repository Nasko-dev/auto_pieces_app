# Script PowerShell pour remplacer les prints par le système de logging

# Fonction pour remplacer dans les fichiers
function Replace-InFiles {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Replacement
    )

    Get-ChildItem -Path $Path -Filter "*.dart" -File | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $newContent = $content -replace [regex]::Escape($Pattern), $Replacement
        if ($content -ne $newContent) {
            Set-Content -Path $_.FullName -Value $newContent -NoNewline
            Write-Host "Updated: $($_.Name)"
        }
    }
}

# Controllers
$controllersPath = "lib\src\features\parts\presentation\controllers"
Replace-InFiles -Path $controllersPath -Pattern "print('❌" -Replacement "Logger.error('"
Replace-InFiles -Path $controllersPath -Pattern "print('⚠️" -Replacement "Logger.warning('"
Replace-InFiles -Path $controllersPath -Pattern "print('📡" -Replacement "Logger.realtime('"
Replace-InFiles -Path $controllersPath -Pattern "print('🔔" -Replacement "Logger.realtime('"
Replace-InFiles -Path $controllersPath -Pattern "print('🌍" -Replacement "Logger.realtime('"
Replace-InFiles -Path $controllersPath -Pattern "print('📨" -Replacement "Logger.conversations('"
Replace-InFiles -Path $controllersPath -Pattern "print('📤" -Replacement "Logger.conversations('"
Replace-InFiles -Path $controllersPath -Pattern "print('✅" -Replacement "Logger.info('"
Replace-InFiles -Path $controllersPath -Pattern "print('🎉" -Replacement "Logger.info('"
Replace-InFiles -Path $controllersPath -Pattern "print('💬" -Replacement "Logger.conversations('"
Replace-InFiles -Path $controllersPath -Pattern "print('🔍" -Replacement "Logger.conversations('"
Replace-InFiles -Path $controllersPath -Pattern "print('🔄" -Replacement "Logger.conversations('"
Replace-InFiles -Path $controllersPath -Pattern "print('⏰" -Replacement "Logger.info('"
Replace-InFiles -Path $controllersPath -Pattern "print('👀" -Replacement "Logger.info('"
Replace-InFiles -Path $controllersPath -Pattern "print('🔥" -Replacement "Logger.info('"
Replace-InFiles -Path $controllersPath -Pattern "print('🚫" -Replacement "Logger.warning('"
Replace-InFiles -Path $controllersPath -Pattern "print('📊" -Replacement "Logger.info('"

# Providers
$providersPath = "lib\src\core\providers"
Replace-InFiles -Path $providersPath -Pattern "print('❌" -Replacement "Logger.error('"
Replace-InFiles -Path $providersPath -Pattern "print('⚠️" -Replacement "Logger.warning('"
Replace-InFiles -Path $providersPath -Pattern "print('🔔" -Replacement "Logger.realtime('"
Replace-InFiles -Path $providersPath -Pattern "print('📡" -Replacement "Logger.realtime('"
Replace-InFiles -Path $providersPath -Pattern "print('✅" -Replacement "Logger.info('"
Replace-InFiles -Path $providersPath -Pattern "print('💬" -Replacement "Logger.conversations('"
Replace-InFiles -Path $providersPath -Pattern "print('🎉" -Replacement "Logger.info('"
Replace-InFiles -Path $providersPath -Pattern "print('🔍" -Replacement "Logger.conversations('"
Replace-InFiles -Path $providersPath -Pattern "print('👀" -Replacement "Logger.info('"
Replace-InFiles -Path $providersPath -Pattern "print('🔥" -Replacement "Logger.info('"
Replace-InFiles -Path $providersPath -Pattern "print('🚫" -Replacement "Logger.warning('"
Replace-InFiles -Path $providersPath -Pattern "print('⏰" -Replacement "Logger.info('"
Replace-InFiles -Path $providersPath -Pattern "print('📊" -Replacement "Logger.info('"
Replace-InFiles -Path $providersPath -Pattern "print('🚪" -Replacement "Logger.info('"
Replace-InFiles -Path $providersPath -Pattern "print('🗑️" -Replacement "Logger.info('"
Replace-InFiles -Path $providersPath -Pattern "print('📤" -Replacement "Logger.conversations('"

# DataSources
$dataSourcesPath = "lib\src\features\parts\data\datasources"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('❌" -Replacement "Logger.error('"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('⚠️" -Replacement "Logger.warning('"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('✅" -Replacement "Logger.dataSource('"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('💥" -Replacement "Logger.error('"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('📈" -Replacement "Logger.dataSource('"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('🔄" -Replacement "Logger.dataSource('"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('💾" -Replacement "Logger.dataSource('"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('🔍" -Replacement "Logger.dataSource('"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('📊" -Replacement "Logger.dataSource('"
Replace-InFiles -Path $dataSourcesPath -Pattern "print('✓" -Replacement "Logger.dataSource('"

Write-Host "Remplacement terminé !" -ForegroundColor Green