@echo off
:# Open RuneScape Classic: Striving for a replica RSC game and more

:# Variable paths:
SET required="Required\"
SET mariadbpath="Required\mariadb-10.5.3-winx64\bin\"

:<------------Begin Start------------>
REM Initial menu displayed to the user
:start
cls
echo:
echo What would you like to do?
echo:
echo Choices:
echo   %RED%1%NC% - Start the game
echo   %RED%2%NC% - Change a player's in-game role
echo   %RED%3%NC% - Backup game database
echo   %RED%4%NC% - Restore game database
echo   %RED%5%NC% - Upgrade the database
echo   %RED%6%NC% - Reset entire game database
echo   %RED%7%NC% - Exit
echo:
SET /P action=Please enter a number choice from above:
echo:

if /i "%action%"=="1" goto run
if /i "%action%"=="2" goto role
if /i "%action%"=="3" goto backup
if /i "%action%"=="4" goto import
if /i "%action%"=="5" goto dbupgrade
if /i "%action%"=="6" goto reset
if /i "%action%"=="7" goto exit

echo Error! %action% is not a valid option. Press enter to try again.
echo:
SET /P action=""
goto start
:<------------End Start------------>


:<------------Begin Exit------------>
:exit
REM Shuts down existing processes
taskkill /F /IM Java*
exit
:<------------End Exit------------>


:<------------Begin Run------------>
:run
cls
echo:
echo Starting Open RSC.
echo:
cd Required && call START "" run.cmd && cd ..
echo:
goto start
:<------------End Run------------>


:<------------Begin Role------------>
:role
cls
echo:
echo What would role should the player be set to?
echo:
echo Choices:
echo   %RED%1%NC% - Admin
echo   %RED%2%NC% - Mod
echo   %RED%3%NC% - Regular Player
echo   %RED%4%NC% - Return
echo:
SET /P role=Please enter a number choice from above:
echo:

if /i "%role%"=="1" goto admin
if /i "%role%"=="2" goto mod
if /i "%role%"=="3" goto regular
if /i "%role%"=="4" goto start

echo Error! %role% is not a valid option. Press enter to try again.
echo:
SET /P role=""
goto start

:admin
echo:
echo Make sure you are logged out first!
echo Type the username of the player you wish to set as an admin and press enter.
echo:
SET /P username=""
call START "" %mariadbpath%mysqld.exe --console
echo Player update will occur in 5 seconds (gives time to start the database server on slow PCs)
PING localhost -n 6 >NUL
call %mariadbpath%mysql.exe -uroot -D openrsc -e "USE openrsc; UPDATE `players` SET `group_id` = '0' WHERE `players`.`username` = '%username%';"
call %mariadbpath%mysql.exe -uroot -D openrsc -e "USE cabbage; UPDATE `players` SET `group_id` = '0' WHERE `players`.`username` = '%username%';"
call %mariadbpath%mysql.exe -uroot -D openrsc -e "USE preservation; UPDATE `players` SET `group_id` = '0' WHERE `players`.`username` = '%username%';"
echo:
echo %username% has been made an admin!
echo:
pause
goto start

:mod
echo:
echo Make sure you are logged out first!
echo Type the username of the player you wish to set as a mod and press enter.
echo:
SET /P username=""
call START "" %mariadbpath%mysqld.exe --console
echo Player update will occur in 5 seconds (gives time to start the database server on slow PCs)
PING localhost -n 6 >NUL
call %mariadbpath%mysql.exe -uroot -D openrsc -e "USE openrsc; UPDATE `players` SET `group_id` = '2' WHERE `players`.`username` = '%username%';"
call %mariadbpath%mysql.exe -uroot -D openrsc -e "USE cabbage; UPDATE `players` SET `group_id` = '2' WHERE `players`.`username` = '%username%';"
call %mariadbpath%mysql.exe -uroot -D openrsc -e "USE preservation; UPDATE `players` SET `group_id` = '2' WHERE `players`.`username` = '%username%';"
echo:
echo %username% has been made a mod!
echo:
pause
goto start

:regular
echo:
echo Make sure you are logged out first!
echo Type the username of the player you wish to set as a regular player and press enter.
echo:
SET /P username=""
call START "" %mariadbpath%mysqld.exe --console
echo Player update will occur in 5 seconds (gives time to start the database server on slow PCs)
PING localhost -n 6 >NUL
call %mariadbpath%mysql.exe -uroot -D openrsc -e "USE openrsc; UPDATE `players` SET `group_id` = '10' WHERE `players`.`username` = '%username%';"
call %mariadbpath%mysql.exe -uroot -D openrsc -e "USE cabbage; UPDATE `players` SET `group_id` = '10' WHERE `players`.`username` = '%username%';"
call %mariadbpath%mysql.exe -uroot -D openrsc -e "USE preservation; UPDATE `players` SET `group_id` = '10' WHERE `players`.`username` = '%username%';"
echo:
echo %username% has been made a regular player!
echo:
pause
goto start
:<------------End Role------------>


:<------------Begin Backup------------>
:backup
REM Shuts down existing processes
taskkill /F /IM Java*

REM Performs a full database export
cls
echo:
echo What do you want to name your player database backup? (Avoid spaces and symbols for the filename or it will not save correctly)
echo:
SET /P filename=""
call START "" %mariadbpath%mysqld.exe --console
call START "" %mariadbpath%mysqldump.exe -uroot --database openrsc --result-file="Backups/%filename%-OpenRSC.sql"
call START "" %mariadbpath%mysqldump.exe -uroot --database cabbage --result-file="Backups/%filename%-RSC-Cabbage.sql"
call START "" %mariadbpath%mysqldump.exe -uroot --database preservation --result-file="Backups/%filename%-RSC-Preservation.sql"
echo:
echo Player database backup complete.
echo:
pause
goto start
:<------------End Backup------------>


:<------------Begin Import------------>
:import
REM Shuts down existing processes
taskkill /F /IM Java*

cls
REM Performs a full database import
echo:
dir /B *.sql
echo:
echo Which player database listed above do you wish to restore? (Just specify the part of the name before the -****.sql part, ex: "mybackup" instead of "mybackup-RSC-Cabbage.sql")
echo:
SET /P filename=""
call START "" %mariadbpath%mysqld.exe --console
call %mariadbpath%mysql.exe -uroot openrsc < "Backups/%filename%-OpenRSC.sql"
call %mariadbpath%mysql.exe -uroot cabbage < "Backups/%filename%-RSC-Cabbage.sql"
call %mariadbpath%mysql.exe -uroot preservation < "Backups/%filename%-RSC-Preservation.sql"
echo:
echo Player database restore complete.
echo:
pause
goto start
:<------------End Import------------>


:<------------Begin DB Upgrade------------>
:dbupgrade
REM Shuts down existing processes
taskkill /F /IM Java*

cls
REM Performs a database upgrade
echo:
dir /B *.sql
echo:
echo Which player database listed above do you wish to upgrade? (Just specify the part of the name before the -****.sql part, ex: "mybackup" instead of "mybackup-RSC-Cabbage.sql")
echo:
SET /P filename=""
call START "" %mariadbpath%mysqld.exe --console
echo Database upgrade will occur in 5 seconds (gives time to start the database server on slow PCs)
PING localhost -n 6 >NUL
call %mariadbpath%mysql.exe -uroot openrsc < Databases\game_server.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases\cabbage_game_server.sql
call %mariadbpath%mysql.exe -uroot preservation < Databases\preservation_game_server.sql
echo:
echo Player database upgrade complete.
echo:
pause
goto start
:<------------End DB Upgrade------------>


:<------------Begin Reset------------>
:reset
REM Shuts down existing processes
taskkill /F /IM Java*

REM Verifies the user wishes to clear existing player data
cls
echo:
echo Are you ABSOLUTELY SURE that you want to reset all game databases?
echo:
echo To confirm the database reset, type yes and press enter.
echo:
SET /P confirmwipe=""
echo:
if /i "%confirmwipe%"=="yes" goto wipe

echo Error! %confirmwipe% is not a valid option.
pause
goto start

:wipe
REM Starts up the database server and imports both server and player database files to replace anything previously existing
cls
echo:
call START "" %mariadbpath%mysqld.exe --console
echo Database wipe will occur in 5 seconds (gives time to start the database server on slow PCs)
PING localhost -n 6 >NUL
call %mariadbpath%mysql.exe -uroot -e "DROP DATABASE IF EXISTS openrsc;"
call %mariadbpath%mysql.exe -uroot -e "DROP DATABASE IF EXISTS cabbage;"
call %mariadbpath%mysql.exe -uroot -e "DROP DATABASE IF EXISTS preservation;"
call %mariadbpath%mysql.exe -uroot -e "CREATE DATABASE `openrsc`;"
call %mariadbpath%mysql.exe -uroot -e "CREATE DATABASE `cabbage`;"
call %mariadbpath%mysql.exe -uroot -e "CREATE DATABASE `preservation`;"
call %mariadbpath%mysql.exe -uroot openrsc < Databases\core.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases\core.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_auctionhouse.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_bank_presets.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_clans.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_custom_items.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_custom_npcs.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_custom_objects.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_equipment_tab.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_harvesting.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_ironman.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_npc_kill_counting.sql
call %mariadbpath%mysql.exe -uroot cabbage < Databases/Addons/add_runecraft.sql
call %mariadbpath%mysql.exe -uroot preservation < Databases\core.sql
echo:
echo The databases have all been reset to the original versions!
echo:
pause
goto start
:<------------End Reset------------>


:<------------Begin Upgrade------------>
:upgrade
REM Shuts down existing processes
taskkill /F /IM Java*
taskkill /F /IM mysqld*

REM Fetches the most recent release version
echo:
call Required\curl -sL https://orsc.dev/api/v4/projects/open-rsc%2Fsingle-player/releases | Required\grep "tag_name" | Required\egrep -o (ORSC-).[0-9].[0-9].[0-9] | Required\head -1 > version.txt
set /P version=<version.txt
echo %version%

REM Downloads the most recent release archive and copies the contents into "Single-Player"
cd ..
call Single-Player\Required\wget https://orsc.dev/open-rsc/Single-Player/-/archive/%version%/Single-Player-%version%.zip
call Single-Player\Required\7za.exe x Single-Player-%version%.zip -aoa
cd Single-Player-%version%
call xcopy "*.*" "../Single-Player\" /K /D /H /Y

REM Cleans up files that are no longer needed
cd ..
call del Single-Player-%version%.zip
call rd /s /q Single-Player
call del Single-Player\version.txt

REM Launches the database server and imports only the server data, leaving player data safely alone
cd Single-Player
call START "" %mariadbpath%mysqld.exe --console
echo Database wipe will occur in 5 seconds (gives time to start the database server on slow PCs)
PING localhost -n 6 >NUL
call %mariadbpath%mysql.exe -uroot -D openrsc < Databases\core.sql
echo:
echo Upgrade complete.
echo:
pause
goto start
:<------------End Upgrade------------>