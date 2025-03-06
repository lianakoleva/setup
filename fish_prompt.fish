function fish_prompt
    set -l current_time (date "+%H:%M:%S")
    set_color brblack
    echo -n "$current_time "
    set_color green
    echo -n (prompt_pwd)
    set_color normal
    set -l branch (git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if test -n "$branch"
        if test (string length -- $branch) -gt 20
            set start 13
            set len 20
            set branch (string sub $branch -s $start -l $len)
        end
	echo -n " ($branch)"
    end
    echo -n "> "
end
