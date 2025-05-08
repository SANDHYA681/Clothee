@echo off
echo Creating directory structure for category images...

set USER_HOME=%USERPROFILE%
set IMAGE_DIR=%USER_HOME%\ClotheeImages\images\categories

echo Creating directory: %IMAGE_DIR%
mkdir "%IMAGE_DIR%"

echo.
echo Directory structure created successfully!
echo.
echo Please upload category images through the admin interface at:
echo http://localhost:8080/Clothee/admin/categories.jsp
echo.
echo Or manually place images in: %IMAGE_DIR%
echo (Use naming convention: category_1.jpg, category_2.jpg, etc.)
echo.
echo Press any key to exit...
pause > nul
