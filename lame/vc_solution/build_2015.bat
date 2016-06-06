@setlocal

md "%~dp0build\"

call "%VS140COMNTOOLS%vsvars32.bat"
@if %errorlevel% neq 0 goto errorexit

cd "%~dp0"
@if %errorlevel% neq 0 goto errorexit

:: Build all the solution configurations

msbuild /m /p:Configuration=Debug,Platform=x64 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_d_x64_2015.log lame.sln
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Debug,Platform=Win32 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_d_win32_2015.log lame.sln
@if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=x64 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log lame.sln
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_win32_2015.log lame.sln
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=x64 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_s_x64_2015.log lame.sln
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=Win32 /t:Build /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_s_win32_2015.log lame.sln
rem @if %errorlevel% neq 0 goto errorexit

:: http://stackoverflow.com/a/27675253
:: Profile then relink Release/x64

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGInstrument /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log lame.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log libmp3lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

"%~dp0..\output\x64\Release\lame.exe" -q0 -b128 "%~dp0..\testcase.wav" "%~dp0..\output\x64\Release\lame_testcase_128.mp3"
"%~dp0..\output\x64\Release\lame.exe" -q0 -V0 "%~dp0..\testcase.wav" "%~dp0..\output\x64\Release\lame_testcase_V0.mp3"
"%~dp0..\output\x64\Release\lame.exe" -q0 -V6 --resample 22.05 "%~dp0..\testcase.wav" "%~dp0..\output\x64\Release\lame_testcase_V6.mp3"
"%~dp0..\output\x64\Release\lame.exe" -q0 --abr 56 -mm --resample 11.025 "%~dp0..\testcase.wav" "%~dp0..\output\x64\Release\lame_testcase_abr56.mp3"
"%~dp0..\output\x64\Release\lame.exe" --decode "%~dp0..\testcase.wav" "%~dp0..\output\x64\Release\lame_testcase.mp3"
"%~dp0..\output\x64\Release\lame_enc_dll_example.exe" "%~dp0..\testcase.wav"
"%~dp0..\output\x64\Release\lame_test.exe" "%~dp0..\output\x64\Release\lame_test_random_pgo.mp3" 441000

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log lame.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=x64,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log libmp3lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

:: http://stackoverflow.com/a/27675253
:: Profile then relink Release/Win32

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGInstrument /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log lame.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log libmp3lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

"%~dp0..\output\Win32\Release\lame.exe" -q0 -b128 "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Release\lame_testcase_128.mp3"
"%~dp0..\output\Win32\Release\lame.exe" -q0 -V0 "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Release\lame_testcase_V0.mp3"
"%~dp0..\output\Win32\Release\lame.exe" -q0 -V6 --resample 22.05 "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Release\lame_testcase_V6.mp3"
"%~dp0..\output\Win32\Release\lame.exe" -q0 --abr 56 -mm --resample 11.025 "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Release\lame_testcase_abr56.mp3"
"%~dp0..\output\Win32\Release\lame.exe" --decode "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Release\lame_testcase.mp3"
"%~dp0..\output\Win32\Release\lame_enc_dll_example.exe" "%~dp0..\testcase.wav"
"%~dp0..\output\Win32\Release\lame_test.exe" "%~dp0..\output\Win32\Release\lame_test_random_pgo.mp3" 441000

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log lame.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration=Release,Platform=Win32,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log libmp3lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

:: http://stackoverflow.com/a/27675253
:: Profile then relink Static Static Release/x64

msbuild /m /p:Configuration="Static Release",Platform=x64,WholeProgramOptimization=PGInstrument /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log lame.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=x64,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=x64,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log libmp3lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

"%~dp0..\output\x64\Static Release\lame.exe" -q0 -b128 "%~dp0..\testcase.wav" "%~dp0..\output\x64\Static Release\lame_testcase_128.mp3"
"%~dp0..\output\x64\Static Release\lame.exe" -q0 -V0 "%~dp0..\testcase.wav" "%~dp0..\output\x64\Static Release\lame_testcase_V0.mp3"
"%~dp0..\output\x64\Static Release\lame.exe" -q0 -V6 --resample 22.05 "%~dp0..\testcase.wav" "%~dp0..\output\x64\Static Release\lame_testcase_V6.mp3"
"%~dp0..\output\x64\Static Release\lame.exe" -q0 --abr 56 -mm --resample 11.025 "%~dp0..\testcase.wav" "%~dp0..\output\x64\Static Release\lame_testcase_abr56.mp3"
"%~dp0..\output\x64\Static Release\lame.exe" --decode "%~dp0..\testcase.wav" "%~dp0..\output\x64\Static Release\lame_testcase.mp3"
"%~dp0..\output\x64\Static Release\lame_enc_dll_example.exe" "%~dp0..\testcase.wav"
"%~dp0..\output\x64\Static Release\lame_test.exe" "%~dp0..\output\x64\Static Release\lame_test_random_pgo.mp3" 441000

msbuild /m /p:Configuration="Static Release",Platform=x64,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log lame.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=x64,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=x64,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_x64_2015.log libmp3lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

:: http://stackoverflow.com/a/27675253
:: Profile then relink Static Release/Win32

msbuild /m /p:Configuration="Static Release",Platform=Win32,WholeProgramOptimization=PGInstrument /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log lame.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=Win32,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=Win32,WholeProgramOptimization=PGInstrument /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log libmp3lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

"%~dp0..\output\Win32\Static Release\lame.exe" -q0 -b128 "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Static Release\lame_testcase_128.mp3"
"%~dp0..\output\Win32\Static Release\lame.exe" -q0 -V0 "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Static Release\lame_testcase_V0.mp3"
"%~dp0..\output\Win32\Static Release\lame.exe" -q0 -V6 --resample 22.05 "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Static Release\lame_testcase_V6.mp3"
"%~dp0..\output\Win32\Static Release\lame.exe" -q0 --abr 56 -mm --resample 11.025 "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Static Release\lame_testcase_abr56.mp3"
"%~dp0..\output\Win32\Static Release\lame.exe" --decode "%~dp0..\testcase.wav" "%~dp0..\output\Win32\Static Release\lame_testcase.mp3"
"%~dp0..\output\Win32\Static Release\lame_enc_dll_example.exe" "%~dp0..\testcase.wav"
"%~dp0..\output\Win32\Static Release\lame_test.exe" "%~dp0..\output\Win32\Static Release\lame_test_random_pgo.mp3" 441000

msbuild /m /p:Configuration="Static Release",Platform=Win32,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:BuildLink /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log lame.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=Win32,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

msbuild /m /p:Configuration="Static Release",Platform=Win32,WholeProgramOptimization=PGOptimize,LinkTimeCodeGeneration=PGOptimization /t:LibLinkOnly /consoleLoggerParameters:Summary /verbosity:minimal /fileLogger /fileLoggerParameters:Summary;Append;Verbosity=normal;LogFile=%~dp0build\lame_Win32_2015.log libmp3lame_dll.vcxproj
rem @if %errorlevel% neq 0 goto errorexit

@endlocal
@exit /b 0

:errorexit
@endlocal
@exit /b 1
