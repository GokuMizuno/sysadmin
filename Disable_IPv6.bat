:: This disables IPv6 binding on all NICs in the system, as well as removes the 6to4, ISATAP, and Teredo Tunneling software NICs from the system. 
:: - This does not change Windows' default behavior of preferring IPv6 addresses over IPv4 addresses if both are available.
:: - This does not affect IPv4 traffic at all.

netsh interface 6to4 set state disable
netsh interface isatap set state disable
netsh interface teredo set state disable
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters /v DisabledComponents /t REG_DWORD /d 0x11 /f