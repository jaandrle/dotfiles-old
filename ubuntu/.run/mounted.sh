ls -m -Q /media/jaandrle/ | grep -o '"' | awk 'END { printf "𐝕"; while(i++ < NR/2) printf "𐝓"; printf " "; }'
