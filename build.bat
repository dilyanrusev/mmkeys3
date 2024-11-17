@echo off

setlocal

set root_dir=%~dp0
set src_dir=%root_dir%code\
set build_dir=%root_dir%build
set name=mmkeys3

set LINKER="-extra-linker-flags:/MANIFEST:EMBED /MANIFESTINPUT:%src_dir%manifest.xml"
set FLAGS=-out:%name%.exe -subsystem:windows -error-pos-style:unix -resource:%src_dir%resource.rc %LINKER%
if "%1" == "release" ( 
	echo Release
) else (
	echo Debug
	set FLAGS=-debug %FLAGS%
)

if not exist %build_dir%\ (
	mkdir %build_dir%
)

pushd %build_dir%

odin build %src_dir% %FLAGS%

popd