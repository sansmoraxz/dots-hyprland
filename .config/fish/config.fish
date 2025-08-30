function is_embedded_terminal
    set pid $fish_pid
    while test $pid -ne 1
        set pinfo (ps -p $pid -o comm=)
        if string match -q -r 'code|jetbrains|idea|atom|emacs|nvim' $pinfo
            return 0
        end
        set pid (ps -p $pid -o ppid= | string trim)
    end
    return 1
end

function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

end

starship init fish | source
if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    if not is_embedded_terminal
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end
end

alias pamcan pacman
alias ls 'eza --icons'
alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias q 'qs -c ii'
    

alias ansi 'echo -ne "\033]104\007"'
alias theme 'cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt'

# function fish_prompt
#   set_color cyan; echo (pwd)
#   set_color green; echo '> '
# end
