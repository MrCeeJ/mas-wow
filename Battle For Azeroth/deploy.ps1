$location_list = 'Aqir', 'Freehold', 'Motherlode','Nazjatar', 'Panda Assault', 'Random Location', 'Temple of Sethraliss', 'Tol Dagor', 'Training Dummy','Uldir Raid','Uldum Assault', 'Underrot','Waycrest Manor','White Shark Test'
$file_list = 'code.lua', 'utils.lua', 'instances.lua', 'paladin.lua', 'priest.lua', 'druid.lua', 'shaman.lua', 'mage.lua', 'demon.lua', 'warrior.lua', 'monk.lua', 'hunter.lua', 'warlock.lua'
foreach ($location in $location_list)
{
    foreach ($file in $file_list) {
        Copy-Item -Path $file -Destination "$location\$file"        
    }
}