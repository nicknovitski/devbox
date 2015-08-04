ghman() {
  curl -sS -H "Accept: application/vnd.github.drax-preview.raw" https://api.github.com/repos/$1/readme | pandoc -s -f markdown -t man | groff -T utf8 -man | less
}
