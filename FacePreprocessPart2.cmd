FOR %%i IN (3D_Faces_Processed_Step1\*.obj) DO ECHO %%~ni

FOR %%I IN (3D_Faces_Processed_Step1\*.obj) DO (
        meshlabserver -i 3D_Faces_Processed_Step1\%%~nI.obj -o 3D_Faces_Processed_Step2\%%~nI2.obj -s Face_CleaningPart2.mlx
    )

cmd /k