FOR %%i IN (3D_Faces\*.obj) DO ECHO %%~ni

FOR %%I IN (3D_Faces\*.obj) DO (
        meshlabserver -i 3D_Faces\%%~nI.obj -o 3D_Faces_Processed_Step1\%%~nIOUT.obj -s Face_CleaningPart1.mlx
    )

cmd /k