$location_list = 'Random Location','The Necrotic Wake'
$file_list = 'code.lua', 'utils.lua', 'prep.lua', 'instances.lua', 'paladin.lua', 'priest.lua', 'druid.lua', 'shaman.lua', 'mage.lua', 'demon.lua', 'warrior.lua', 'monk.lua', 'hunter.lua', 'warlock.lua'
foreach ($location in $location_list)
{
    foreach ($file in $file_list) {
        Copy-Item -Path $file -Destination "$location\$file"        
    }
}