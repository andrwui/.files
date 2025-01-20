cd ~/.files
for dir in */; do
    ln -sfn "$PWD/$dir" ~/.config/
done
