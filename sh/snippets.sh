# to prevent any accidental foot-shooting
echo "Do NOT run this file as a shell script!"
exit 1


# get an available nvidia GPU ID
gpu=$(nvidia-smi -L | cut -d' ' -f2 | tr -d :)
echo "$gpu"


# replace the extensions of all files in current dir with $new_ext
new_ext=
for f in *.*; do
  mv "$f" "${f%.*}$new_ext"
done


# do $move_cmd (e.g. mv, ln, ln -s, cp) to 25 random files from $img_dir to $new_img_dir
# then do the same for their basename counterparts (ending in $annot_ext) - from $annot_dir to $new_annot_dir
num_files=25
export move_cmd="ln"
export annot_ext=
export img_dir=
export annot_dir=
export new_img_dir=
export new_annot_dir=
ls "$img_dir" | shuf | head -n $num_files | xargs -I{} -n1 sh -c 'name="$1"; base="${name%.*}"; \
"$move_cmd" "$img_dir/$name" "$new_img_dir" && "$move_cmd" "$annot_dir/${base}${annot_ext}" "$new_annot_dir"' -- {}