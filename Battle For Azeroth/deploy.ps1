$location_list = 'Aqir', 'Freehold', 'Nazjatar', 'Panda Assault', 'Random Location', 'Temple of Sethraliss', 'Tol Dagor', 'Training Dummy','Uldum Assault', 'Underrot','Waycrest Manor','White Shark Test'
$file_list = 'code.lua', 'utils.lua', 'paladin.lua', 'priest.lua', 'druid.lua', 'shaman.lua', 'mage.lua'
foreach ($location in $location_list)
{
    foreach ($file in $file_list) {
        Copy-Item -Path $file -Destination "$location\$file"        
    }
}