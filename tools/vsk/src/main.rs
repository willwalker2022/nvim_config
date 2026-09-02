use std::{
    env,
    io::{self, IsTerminal},
    process,
};

const DATA: &str = include_str!("../keys.tsv");
const RESET: &str = "\x1b[0m";
const MAUVE: &str = "\x1b[1;38;2;203;166;247m";
const BLUE: &str = "\x1b[38;2;137;180;250m";
const YELLOW: &str = "\x1b[38;2;249;226;175m";

struct Entry<'a> {
    key: &'a str,
    mode: &'a str,
    section: &'a str,
    description: &'a str,
    searchable: String,
}

fn entries() -> impl Iterator<Item = Entry<'static>> {
    DATA.lines().filter_map(|line| {
        if line.is_empty() || line.starts_with('#') {
            return None;
        }
        let mut fields = line.split('\t');
        let key = fields.next()?;
        let mode = fields.next()?;
        let section = fields.next()?;
        let description = fields.next()?;
        let tags = fields.next().unwrap_or_default();
        let searchable = format!("{key} {mode} {section} {description} {tags}").to_lowercase();
        Some(Entry {
            key,
            mode,
            section,
            description,
            searchable,
        })
    })
}

fn print_help(color: bool) {
    let (mauve, reset) = if color { (MAUVE, RESET) } else { ("", "") };
    println!("{mauve}vsk{reset} — Vim short key\n");
    println!("Usage: vsk <keywords...> | vsk --all");
    println!("Examples: vsk search   vsk terminal window   vsk '<leader>e'");
    println!("Modes: N=Normal I=Insert V=Visual T=Terminal O=Operator C=Command");
}

fn main() {
    let color = io::stdout().is_terminal() && env::var_os("NO_COLOR").is_none();
    let (mauve, blue, yellow, reset) = if color {
        (MAUVE, BLUE, YELLOW, RESET)
    } else {
        ("", "", "", "")
    };
    let mut args: Vec<String> = env::args().skip(1).collect();
    if args.iter().any(|arg| arg == "-h" || arg == "--help") {
        print_help(color);
        return;
    }

    let show_all = args.as_slice() == ["--all"];
    if args.iter().any(|arg| arg.starts_with('-')) && !show_all {
        eprintln!("vsk: unknown option; run vsk --help for usage");
        process::exit(2);
    }
    if args.is_empty() {
        print_help(color);
        println!("\nCommon shortcuts:");
        args.push("core".into());
    }

    let terms: Vec<String> = args.iter().map(|arg| arg.to_lowercase()).collect();
    let all: Vec<_> = entries().collect();
    let exact_key = args.len() == 1 && all.iter().any(|entry| entry.key == args[0]);
    let matches: Vec<_> = all
        .into_iter()
        .filter(|entry| {
            show_all
                || (exact_key && entry.key == args[0])
                || (!exact_key && terms.iter().all(|term| entry.searchable.contains(term)))
        })
        .collect();

    if matches.is_empty() {
        eprintln!("No matches for: {}", args.join(" "));
        process::exit(1);
    }

    let mut section = "";
    for entry in &matches {
        if entry.section != section {
            section = entry.section;
            println!("\n{mauve}[{section}]{reset}");
        }
        println!(
            "  {blue}{:<18}{reset} {yellow}{:<7}{reset} {}",
            entry.key, entry.mode, entry.description
        );
    }
}
