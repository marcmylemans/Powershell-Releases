﻿$Path = "HKU:\.DEFAULT\Control Panel\Keyboard"
$Name = "InitialKeyboardIndicators"
$Type = "String"
$Value = 2

Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value 
