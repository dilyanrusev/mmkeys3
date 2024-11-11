@echo off

setlocal

set DEBUG="-debug"
if "%1" == "release" ( 
	set DEBUG="" 
	echo Release build
) else (
	echo Debug
)

odin build . %DEBUG% -error-pos-style:unix -subsystem:windows -resource:resource.rc "-extra-linker-flags:/MANIFEST /MANIFESTFILE:manifest.xml"