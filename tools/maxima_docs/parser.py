"""Extract documented entries and explanatory sections from Texinfo HTML."""

from __future__ import annotations

from dataclasses import dataclass, field
from html.parser import HTMLParser
import re
from typing import Iterator


VERSION_RE = re.compile(r"Maxima\s+(\d+\.\d+(?:\.\d+)?)\s+Manual", re.I)
KIND_RE = re.compile(
    r"^(Function|Option variable|System variable|Variable|Constant|"
    r"Operator|Special operator|Keyword|Property|Declaration|Package):\s*",
    re.I,
)
HEADING_TAGS = {f"h{i}" for i in range(1, 7)}
VOID_TAGS = {
    "area", "base", "br", "col", "embed", "hr", "img", "input", "link",
    "meta", "param", "source", "track", "wbr",
}
BLOCK_TAGS = {
    "p", "pre", "ul", "ol", "table", "blockquote", "div", "li", "dt", "dd",
}
SKIP_CLASSES = {
    "header", "foot", "menu", "categorybox", "contents", "shortcontents",
    "copiable-anchor", "section-toc", "mini-toc", "footnote",
}
SECTION_CLASSES = {
    "chapter", "section", "subsection", "subsubsection", "appendix",
    "appendixsec", "appendixsubsec", "unnumbered", "unnumberedsec",
}


@dataclass
class Node:
    tag: str
    attrs: dict[str, str] = field(default_factory=dict)
    children: list[Node | str] = field(default_factory=list)

    def elements(self, tag: str) -> Iterator[Node]:
        for child in self.children:
            if isinstance(child, Node):
                if child.tag == tag:
                    yield child
                yield from child.elements(tag)


class TreeParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.root = Node("document")
        self.stack = [self.root]

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        node = Node(tag, {key: value or "" for key, value in attrs})
        self.stack[-1].children.append(node)
        if tag not in VOID_TAGS:
            self.stack.append(node)

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self.handle_starttag(tag, attrs)
        if tag not in VOID_TAGS:
            self.handle_endtag(tag)

    def handle_endtag(self, tag: str) -> None:
        for index in range(len(self.stack) - 1, 0, -1):
            if self.stack[index].tag == tag:
                del self.stack[index:]
                return

    def handle_data(self, data: str) -> None:
        self.stack[-1].children.append(data)


def parse_html(html: str) -> Node:
    parser = TreeParser()
    parser.feed(html)
    return parser.root


def render(node: Node | str, in_pre: bool = False) -> str:
    if isinstance(node, str):
        return node if in_pre else re.sub(r"\s+", " ", node.replace("\xa0", " "))
    if node.tag in {"script", "style", "noscript"} or set(node.attrs.get("class", "").split()) & SKIP_CLASSES:
        return ""
    if node.tag == "br":
        return "\n"
    if node.tag == "img":
        return node.attrs.get("alt", "")
    parts = [render(child, in_pre or node.tag == "pre") for child in node.children]
    content = "".join(parts)
    if node.tag in BLOCK_TAGS:
        return "\n" + content + "\n"
    return content


def clean(text: str) -> str:
    text = text.replace("\r", "")
    text = re.sub(r" *\n *\n(?: *\n)*", "\n\n", text)
    return text.strip()


def first_anchor(node: Node) -> str | None:
    fallback = None
    def walk(current: Node) -> Iterator[Node]:
        for child in current.children:
            if isinstance(child, Node):
                yield child
                yield from walk(child)

    for anchor in walk(node):
        value = anchor.attrs.get("name") or anchor.attrs.get("id")
        if value:
            fallback = fallback or value
            if not value.startswith(("index-", "Item_")):
                return value
    return fallback


@dataclass(frozen=True)
class Document:
    title: str
    kind: str
    symbols: tuple[str, ...]
    section: str
    text: str
    anchor: str | None
    source: str


def _definition(node: Node, section: str, source: str, anchor: str | None) -> Document | None:
    terms = [child for child in node.children if isinstance(child, Node) and child.tag == "dt"]
    if not terms:
        return None
    first = clean(render(terms[0])).replace("\n", " ")
    match = KIND_RE.match(first)
    if not match:
        return None
    symbols: list[str] = []
    for term in terms:
        strong = next(term.elements("strong"), None)
        if strong is not None:
            name = clean(render(strong))
        else:
            plain = clean(render(term)).replace("\n", " ")
            term_match = KIND_RE.match(plain)
            name = re.split(r"[\s(]", plain[term_match.end():], maxsplit=1)[0] if term_match else ""
        if name and name not in symbols:
            symbols.append(name)
    if not symbols:
        return None
    body = clean(render(node))
    if len(body) < 15:
        return None
    return Document(symbols[0], match.group(1), tuple(symbols), section, body, anchor, source)


def extract(html: str, source: str) -> tuple[str, list[Document]]:
    root = parse_html(html)
    title_node = next(root.elements("title"), None)
    title = clean(render(title_node)) if title_node else ""
    match = VERSION_RE.search(title)
    if not match:
        raise ValueError(f"Cannot find Maxima manual version in {source}")
    version = match.group(1)
    if "Index" in title or "Documentation Categories" in title:
        return version, []
    body = next(root.elements("body"), None)
    if body is None:
        raise ValueError(f"No HTML body in {source}")

    documents: list[Document] = []
    headings: list[tuple[int, str]] = []
    intro: list[str] = []
    section_anchor: str | None = None
    pending_anchor: str | None = None

    def section_name() -> str:
        return " > ".join(text for _, text in headings)

    def flush_intro() -> None:
        nonlocal intro
        body_text = clean("\n\n".join(intro))
        if body_text and headings and len(body_text) >= 40:
            documents.append(Document(headings[-1][1], "Section", (), section_name(), body_text, section_anchor, source))
        intro = []

    def visit(node: Node) -> None:
        nonlocal pending_anchor, section_anchor
        if node.tag in {"script", "style", "nav", "footer"}:
            return
        classes = set(node.attrs.get("class", "").split())
        if classes & SKIP_CLASSES or node.attrs.get("id") in {
            "Function-and-Variable-Index", "Documentation-Categories"
        }:
            return
        if node.tag == "div" and classes & SECTION_CLASSES and node.attrs.get("id"):
            pending_anchor = node.attrs["id"]
        if node.tag in {"a", "span"}:
            value = node.attrs.get("name") or node.attrs.get("id")
            if value and pending_anchor is None:
                pending_anchor = value
            if node.tag == "a" or not node.children:
                return
        if node.tag in HEADING_TAGS:
            flush_intro()
            heading = clean(render(node)).replace("\n", " ")
            level = int(node.tag[1])
            while headings and headings[-1][0] >= level:
                headings.pop()
            if heading:
                headings.append((level, heading))
                section_anchor = pending_anchor or node.attrs.get("id")
            pending_anchor = None
            return
        if node.tag == "dl":
            doc = _definition(node, section_name(), source, pending_anchor or first_anchor(node))
            if doc is not None:
                documents.append(doc)
                pending_anchor = None
                return
        if node.tag in {"p", "pre", "ul", "ol", "table", "blockquote"}:
            text = clean(render(node))
            if text:
                intro.append(text)
            return
        for child in node.children:
            if isinstance(child, Node):
                visit(child)

    visit(body)
    flush_intro()
    return version, documents
