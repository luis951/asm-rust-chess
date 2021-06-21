call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"

@echo off
IF %1.==. GOTO PERROR

echo Starting assembling %1 
nasm -f win64 -o output.obj %1
if NOT %errorlevel% == 0 GOTO CERROR
echo Finished assembling!

echo Starting linking %1 
link output.obj /subsystem:console /entry:main /out:output.exe "legacy_stdio_definitions.lib" "kernel32.lib" "msvcrt.lib" "Ws2_32.lib" "Advapi32.lib" "Userenv.lib" "asm_rust_chess.lib"
if NOT %errorlevel% == 0 GOTO CERROR
echo Finishing linking!

goto END

:CERROR
	ECHO Compiling error
	GOTO pause

:PERROR
	ECHO Missing Parameter

:END
	pause