$location_list = '_Arkoban Hall', '_The Fracture Chambers','_The Soulforges', '_Skoldus Hall','_The Upper Reaches','Bastion', 'Maldraxxus','Bastion Dummy','Revendreth', 'De Other Side', '2 Halls Of Attonement', 'Mists of Tirna Scithe', 'Plaguefall', 'Random Location', '7 Spires of Ascension', '8 Theatre Of Pain', 'The Necrotic Wake', 'Torghast Start', 'Training Dummy'
$file_list = 'code.lua', 'utils.lua', 'prep.lua', 'instances.lua', 'paladin.lua', 'priest.lua', 'druid.lua', 'shaman.lua', 'mage.lua', 'demon.lua', 'warrior.lua', 'monk.lua', 'hunter.lua', 'warlock.lua'
foreach ($location in $location_list)
{
    foreach ($file in $file_list) {
        Copy-Item -Path $file -Destination "$location\$file"        
    }
}