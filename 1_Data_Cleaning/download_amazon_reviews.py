"""Download Amazon Reviews 2023 (McAuley Lab) into 0_Data/amazon_reviews_2023/.

Files are kept as gzipped JSON Lines (one JSON object per line):
    reviews/<Category>.jsonl.gz       user reviews
    meta/meta_<Category>.jsonl.gz     item metadata (title, price, ...)

Run with no arguments for an interactive menu that shows which files you
already have and how big each download is. Or pass categories directly:

    python download_amazon_reviews.py                          # interactive menu
    python download_amazon_reviews.py -c Software Video_Games  # no prompts
    python download_amazon_reviews.py -c All_Beauty --no-meta
    python download_amazon_reviews.py --list                   # table only
"""

import argparse
import sys
from concurrent.futures import ThreadPoolExecutor

import requests

import config
from download_utils import download_file, human_size, remote_size

PARTS = ("reviews", "meta")


def part_url(category: str, part: str) -> str:
    template = config.AMAZON_REVIEW_URL if part == "reviews" else config.AMAZON_META_URL
    return template.format(category=category)


def part_path(category: str, part: str):
    if part == "reviews":
        return config.AMAZON_DIR / "reviews" / f"{category}.jsonl.gz"
    return config.AMAZON_DIR / "meta" / f"meta_{category}.jsonl.gz"


# ---------------------------------------------------------------------------
# Download
# ---------------------------------------------------------------------------

def download_category(category: str, parts=PARTS, overwrite: bool = False) -> None:
    print(f"\n== Amazon Reviews 2023: {category} ==")
    for part in parts:
        download_file(part_url(category, part), part_path(category, part), overwrite=overwrite)


def download_amazon(categories=None, meta: bool = True, overwrite: bool = False,
                    parts=None) -> bool:
    """Download the given categories. Returns True if all succeeded.

    `parts` overrides `meta`: e.g. ("reviews",), ("meta",) or ("reviews", "meta").
    """
    categories = categories or config.AMAZON_DEFAULT_CATEGORIES
    parts = parts or (PARTS if meta else ("reviews",))
    unknown = [c for c in categories if c not in config.AMAZON_CATEGORIES]
    if unknown:
        print(f"Unknown categories: {unknown}. Use --list to see valid names.")
        return False

    ok = True
    for cat in categories:
        try:
            download_category(cat, parts=parts, overwrite=overwrite)
        except requests.RequestException as e:
            print(f"  [error] {cat}: {e}")
            ok = False
    return ok


# ---------------------------------------------------------------------------
# Status table (what you have + remote sizes)
# ---------------------------------------------------------------------------

def fetch_sizes(categories) -> dict:
    """{(category, part): bytes or None}, looked up in parallel via HEAD requests."""
    keys = [(c, p) for c in categories for p in PARTS]
    print(f"Checking download sizes for {len(keys)} files...", flush=True)
    with ThreadPoolExecutor(max_workers=16) as pool:
        sizes = list(pool.map(lambda k: remote_size(part_url(*k)), keys))
    return dict(zip(keys, sizes))


def print_status_table(categories, sizes: dict) -> None:
    def cell(cat, part):
        have = part_path(cat, part).exists()
        mark = "[have]" if have else "      "
        return f"{human_size(sizes.get((cat, part))):>9} {mark}"

    width = max(len(c) for c in categories)
    print(f"\n  #  {'Category':<{width}}  {'Reviews':>16}  {'Metadata':>16}")
    print("  " + "-" * (width + 40))
    for i, cat in enumerate(categories, 1):
        print(f"{i:>3}  {cat:<{width}}  {cell(cat, 'reviews')}  {cell(cat, 'meta')}")

    have_total = sum(part_path(c, p).stat().st_size
                     for c in categories for p in PARTS if part_path(c, p).exists())
    print(f"\n  [have] = already in {config.AMAZON_DIR}  (total on disk: {human_size(have_total)})")
    print("  Sizes are compressed (.jsonl.gz) download sizes; '?' = server did not report one.")


# ---------------------------------------------------------------------------
# Interactive menu
# ---------------------------------------------------------------------------

def parse_selection(text: str, categories) -> list[str]:
    """Parse '1,3,5-7', 'all', or category names into a list of categories."""
    text = text.strip()
    if text.lower() == "all":
        return list(categories)
    by_lower = {c.lower(): c for c in categories}
    chosen = []
    for token in text.replace(",", " ").split():
        if "-" in token and token.replace("-", "").isdigit():
            a, b = (int(x) for x in token.split("-", 1))
            idxs = range(min(a, b), max(a, b) + 1)
        elif token.isdigit():
            idxs = [int(token)]
        elif token.lower() in by_lower:
            chosen.append(by_lower[token.lower()])
            continue
        else:
            raise ValueError(f"'{token}' is not a number, range or category name")
        for i in idxs:
            if not 1 <= i <= len(categories):
                raise ValueError(f"{i} is out of range (1-{len(categories)})")
            chosen.append(categories[i - 1])
    return list(dict.fromkeys(chosen))  # de-duplicate, keep order


def ask(prompt: str) -> str:
    try:
        return input(prompt)
    except EOFError:
        return ""


def interactive_select(overwrite: bool = False):
    """Show the status table and ask what to download.

    Returns (categories, parts), or None if the user cancels.
    """
    categories = config.AMAZON_CATEGORIES
    sizes = fetch_sizes(categories)
    print_status_table(categories, sizes)

    while True:
        text = ask("\nWhich categories? (e.g. 1,3,5-7 | All_Beauty Software | all | Enter to cancel): ")
        if not text.strip():
            return None
        try:
            chosen = parse_selection(text, categories)
            break
        except ValueError as e:
            print(f"  {e}")

    choice = ask("Which parts? [b]oth reviews + metadata, [r]eviews only, [m]etadata only (default b): ")
    parts = {"r": ("reviews",), "m": ("meta",)}.get(choice.strip().lower()[:1], PARTS)

    # Summarise what will actually be downloaded.
    todo, skipped = [], []
    for cat in chosen:
        for part in parts:
            (todo if overwrite or not part_path(cat, part).exists() else skipped).append((cat, part))

    width = max(len(f"{c} {p}") for c, p in todo + skipped)
    print()
    for cat, part in skipped:
        print(f"  [have] {f'{cat} {part}':<{width}}")
    for cat, part in todo:
        print(f"  [get]  {f'{cat} {part}':<{width}}  {human_size(sizes[(cat, part)]):>9}")
    if not todo:
        print("\nYou already have everything selected. Nothing to download.")
        return None

    known = [sizes[k] for k in todo if sizes[k] is not None]
    unknown = len(todo) - len(known)
    if not known:
        total = "size unknown"
    else:
        total = human_size(sum(known))
        if unknown:
            total += f" + {unknown} file(s) of unknown size"
    if ask(f"\nDownload {len(todo)} file(s), {total}? [y/N]: ").strip().lower() not in ("y", "yes"):
        print("Cancelled.")
        return None
    return chosen, parts


def run_interactive(overwrite: bool = False) -> bool:
    selection = interactive_select(overwrite=overwrite)
    if selection is None:
        return True
    categories, parts = selection
    return download_amazon(categories, parts=parts, overwrite=overwrite)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-c", "--categories", nargs="+",
                   help="Categories to download without prompting. Use 'all' for every category. "
                        "If omitted, an interactive menu is shown.")
    p.add_argument("--no-meta", action="store_true", help="Skip item metadata files (with -c).")
    p.add_argument("--overwrite", action="store_true", help="Re-download files that already exist.")
    p.add_argument("--list", action="store_true",
                   help="Show categories, download sizes and what you already have, then exit.")
    args = p.parse_args()

    if args.list:
        print_status_table(config.AMAZON_CATEGORIES, fetch_sizes(config.AMAZON_CATEGORIES))
        return

    cats = args.categories
    if not cats:
        if sys.stdin.isatty():
            sys.exit(0 if run_interactive(overwrite=args.overwrite) else 1)
        cats = config.AMAZON_DEFAULT_CATEGORIES  # non-interactive fallback (scripts, CI)
    elif [c.lower() for c in cats] == ["all"]:
        cats = config.AMAZON_CATEGORIES
    sys.exit(0 if download_amazon(cats, meta=not args.no_meta, overwrite=args.overwrite) else 1)


if __name__ == "__main__":
    main()
