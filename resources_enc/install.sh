#!/bin/bash
for i in *.gpg icons/*.gpg; do
	gpg --decrypt-files $i
done
mkdir -p ../resources/icons/
mv *.png ../resources/
mv icons/*.png ../resources/icons/
