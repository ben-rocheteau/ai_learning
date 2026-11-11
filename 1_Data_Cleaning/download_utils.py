"""Small helpers for downloading files safely."""

from pathlib import Path

import requests
from tqdm import tqdm

CHUNK_SIZE = 1024 * 1024  # 1 MB


def download_file(url: str, dest: Path, overwrite: bool = False) -> Path:
    """Stream `url` to `dest` with a progress bar.

    Writes to `<dest>.part` first and renames on success, so an interrupted
    download never leaves a half-written file that looks complete.
    """
    dest = Path(dest)
    if dest.exists() and not overwrite:
        print(f"  [skip] {dest.name} already exists")
        return dest

    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_name(dest.name + ".part")

    with requests.get(url, stream=True, timeout=60) as resp:
        resp.raise_for_status()
        total = int(resp.headers.get("content-length", 0)) or None
        with open(tmp, "wb") as f, tqdm(
            total=total, unit="B", unit_scale=True, unit_divisor=1024,
            desc=f"  {dest.name}",
        ) as bar:
            for chunk in resp.iter_content(chunk_size=CHUNK_SIZE):
                f.write(chunk)
                bar.update(len(chunk))

    tmp.replace(dest)
    return dest


def remote_size(url: str, timeout: float = 15) -> int | None:
    """Return the file size in bytes reported by the server, or None if unknown."""
    try:
        resp = requests.head(url, allow_redirects=True, timeout=timeout)
        resp.raise_for_status()
        size = int(resp.headers.get("content-length", 0))
        return size or None
    except (requests.RequestException, ValueError):
        return None


def human_size(n: int | None) -> str:
    """Format a byte count like '1.2 GB'. None -> '?'."""
    if n is None:
        return "?"
    size = float(n)
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if size < 1024 or unit == "TB":
            return f"{size:.0f} {unit}" if unit == "B" else f"{size:.1f} {unit}"
        size /= 1024
