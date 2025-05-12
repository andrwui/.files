#zoxide sourcing
zoxide init fish | source

# setting pnpm
set -gx PNPM_HOME "/home/andrw/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
