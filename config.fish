function fish_user_key_bindings
    echo -ne "\e[6 q" # set cursor to line
    bind alt-left backward-word
    bind alt-right forward-word
end
