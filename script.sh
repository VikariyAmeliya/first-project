#!/bin/bash
#Проверка пути файла
if [ -z "$1" ]; then
	echo "Задайте путь к файлу"
	exit 1
fi

#Проверка на существование файла
if [ ! -f  "$1" ]; then
	echo "Такого файла не существует"
	exit 1
fi

#Считываем размер файла
filesize=$(stat -c%s "$1")
if [ $filesize -le 1024 ]; then
	echo "OK"
else 
	echo "FAIL"
fi

#Вывод разммера файла
echo "Размер файла '$1'= $filesize байт"
