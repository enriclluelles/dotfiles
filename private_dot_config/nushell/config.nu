$env.config.edit_mode = vi
$env.config.show_banner = false
alias nu-open = open
alias open = ^open
alias nu-ps = ps
alias ps = ^ps

def first-of-field [field_name] {
  let _table = ( $in | detect columns )
  let field = ($_table | get $field_name)
  $field | first
}

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
