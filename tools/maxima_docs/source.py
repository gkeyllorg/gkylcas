"""Locate matching local documentation or acquire the official HTML manual."""

from __future__ import annotations

from dataclasses import dataclass
import hashlib
import os
from pathlib import Path
import re
import shutil
import subprocess
from urllib.error import URLError
from urllib.request import Request, urlopen


ONLINE_URL = "https://maxima.sourceforge.io/docs/manual/maxima_singlepage.html"
MAX_DOWNLOAD_BYTES = 64 * 1024 * 1024


def cache_dir() -> Path:
    override = os.environ.get("MAXIMA_DOCS_CACHE_DIR")
    if override:
        return Path(override).expanduser()
    return Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "gkylcas" / "maxima-docs"


def installed_version() -> str | None:
    if shutil.which("maxima") is None:
        return None
    try:
        result = subprocess.run(
            ["maxima", "--version"], capture_output=True, text=True, timeout=10, check=True
        )
    except (OSError, subprocess.SubprocessError):
        return None
    match = re.search(r"\b(\d+\.\d+(?:\.\d+)?)\b", result.stdout)
    return match.group(1) if match else None


def installed_html(version: str | None) -> Path | None:
    if version is None:
        return None
    prefixes = [Path("/usr"), Path("/usr/local"), Path("/opt/homebrew")]
    executable = shutil.which("maxima")
    if executable:
        binary = Path(executable).resolve()
        prefixes.extend([binary.parent.parent, Path(executable).parent.parent])
    for prefix in prefixes:
        folder = prefix / "share" / "maxima" / version / "doc" / "html"
        if (folder / "maxima_toc.html").is_file() and list(folder.glob("maxima_[0-9]*.html")):
            return folder
    return None


@dataclass(frozen=True)
class Source:
    files: tuple[Path, ...]
    online: bool = False

    def url(self, file: Path) -> str:
        return ONLINE_URL if self.online else file.resolve().as_uri()

    def checksum(self) -> str:
        digest = hashlib.sha256()
        for file in self.files:
            digest.update(file.name.encode("utf-8"))
            digest.update(file.read_bytes())
        return digest.hexdigest()


def _files(path: Path) -> tuple[Path, ...]:
    if path.is_file():
        if path.suffix.lower() not in {".html", ".htm"}:
            raise ValueError("--source must be an HTML file or directory")
        return (path,)
    if not path.is_dir():
        raise FileNotFoundError(f"Documentation source not found: {path}")
    files = sorted(path.glob("maxima_[0-9]*.html"))
    if not files:
        files = sorted(path.glob("*.html"))
    if not files:
        raise ValueError(f"No HTML files found in {path}")
    return tuple(files)


def _download(destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    request = Request(ONLINE_URL, headers={"User-Agent": "gkylcas-maxima-docs/1"})
    try:
        with urlopen(request, timeout=60) as response:
            data = response.read(MAX_DOWNLOAD_BYTES + 1)
    except URLError:
        if shutil.which("curl") is None:
            raise
        result = subprocess.run(
            ["curl", "-fLsS", "--max-time", "60", ONLINE_URL],
            capture_output=True, check=True,
        )
        data = result.stdout
    if len(data) > MAX_DOWNLOAD_BYTES:
        raise ValueError("Online Maxima manual exceeds the download size limit")
    if b"Maxima" not in data[:100_000] or b"<html" not in data[:100_000].lower():
        raise ValueError("Downloaded content is not the Maxima HTML manual")
    temporary = destination.with_suffix(".tmp")
    temporary.write_bytes(data)
    temporary.replace(destination)


def choose_source(explicit: str | None = None) -> Source:
    if explicit:
        return Source(_files(Path(explicit).expanduser()))
    local = installed_html(installed_version())
    if local is not None:
        return Source(_files(local))
    online_file = cache_dir() / "sources" / "maxima_singlepage.html"
    if not online_file.is_file():
        try:
            _download(online_file)
        except (OSError, subprocess.CalledProcessError) as error:
            raise RuntimeError(
                "Cannot download the Maxima manual. Check network access or use "
                "build --source PATH with a local HTML manual."
            ) from error
    return Source((online_file,), online=True)
