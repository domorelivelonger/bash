Вырезать всё до символа “W”:

1
sed 's|.*W||'
Вырезать всё после символа “W”:

1
sed -r 's/W.+//'
Вырезать всё после “BLABLABLA”, фразу “BLABLABLA” оставить:

1
sed -r 's/(.+BLABLABLA).+/\1/'
Вырезать всё после “BLABLABLA”, фразу “BLABLABLA” удалить:

1
sed -r 's/BLABLABLA.+//'
