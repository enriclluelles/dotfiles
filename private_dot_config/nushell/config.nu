$env.config.edit_mode = vi
$env.config.show_banner = false
alias nu-open = open
alias open = ^open
let path = "~/.cache/starship"
let file = "init.nu"
if not ( $path | path exists) { mkdir $path }
if ( not ($path | path join | $file | path exists) ) {
  if (which starship | length) > 0 {
    starship init nu | save -f ($path | path join $file)
    echo "use ~/.cache/starship/init.nu" | save -f "~/.config/nushell/config.nu" --append
  }
}
use ~/.cache/starship/init.nuuse ~/.cache/starship/init.nu