$env.config.edit_mode = vi
$env.config.show_banner = false
alias nu-open = open
alias open = ^open
let path = "~/.cache/starship"
let file = "init.nu"
let full_path = ($path | path join $file)
if not ( $path | path exists ) { mkdir $path }
if ( not ( $full_path | path exists ) ) {
  if (which starship | length) > 0 {
    starship init nu | save -f $full_path
    echo "use ~/.cache/starship/init.nu\n" | save -f "~/.config/nushell/config.nu" --append
  }
}
use ~/.cache/starship/init.nu
