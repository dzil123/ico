#!/bin/bash

cat << EOF > index.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
  </head>
  <body>
EOF

for page in */index.html; do
    dir=$(dirname $page)
    echo "    <a href=\"$dir/\">$dir</a><br>" >> index.html
done

cat << EOF >> index.html
  </body>
</html>
EOF
