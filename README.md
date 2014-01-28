#rdbxml2irkitjson

##概要
リモコンデータベースのxml形式をIRKitのjson形式に変換します。
言語は[Gauche - A Scheme Implementation](http://practical-scheme.net/gauche/index-j.html)を使用。

##使い方

```
$ iconv -f Shift_JIS -t UTF-8 iremo.xml | gosh rdbxml2irkitjson.scm
```

