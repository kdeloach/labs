cython --embed circular.py
gcc -I"C:\Python27\include" -o circular.exe circular.c "C:\Python27\libs\libpython27.a"