$location_list = '_Arkoban Hall', '_The Soulforges', '_The Upper Reaches','Bastion', 'De Other Side', 'Halls Of Attonement', 'Mists of Tirna Scithe', 'Plaguefall', 'Random Location', 'The Necrotic Wake', 'Torghast Start', 'Training Dummy'
$file_list = 'code.lua', 'utils.lua', 'prep.lua', 'instances.lua', 'paladin.lua', 'priest.lua', 'druid.lua', 'shaman.lua', 'mage.lua', 'demon.lua', 'warrior.lua', 'monk.lua', 'hunter.lua', 'warlock.lua'
foreach ($location in $location_list)
{
    foreach ($file in $file_list) {
        Copy-Item -Path $file -Destination "$location\$file"        
    }
}