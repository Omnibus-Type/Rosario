#!/bin/sh
set -e


mkdir -p ../fonts ../fonts/ttf ../fonts/otf
echo "Generating Static fonts"
fontmake -g Rosario.glyphs -i -o ttf --output-dir ../fonts/ttf/
fontmake -g Rosario_Italic.glyphs -i -o ttf --output-dir ../fonts/ttf/
fontmake -g Rosario.glyphs -i -o otf --output-dir ../fonts/otf/
fontmake -g Rosario_Italic.glyphs -i -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
fontmake -g Rosario.glyphs -o variable --output-path ../fonts/ttf/Rosario[wght].ttf
fontmake -g Rosario_Italic.glyphs -o variable --output-path ../fonts/ttf/Rosario-Italic[wght].ttf

rm -rf master_ufo/ instance_ufo/


echo "Post processing"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	./ttfautohint-vf $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
done

echo "Post processing VFs"
vfs=$(ls ../fonts/ttf/*\[*\]*.ttf)
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	./ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";
	mv "$vf.fix" $vf;
	gftools fix-hinting $vf;
	mv "$vf.fix" $vf;
done


echo "Fixing VF Meta"
gftools fix-vf-meta $vfs;
for vf in $vfs
do
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/ttf/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

