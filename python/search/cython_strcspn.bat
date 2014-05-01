cython --embed strcspn.py
gcc -I"C:\Python27\include" -o strcspn.exe strcspn.c "C:\Python27\libs\libpython27.a"