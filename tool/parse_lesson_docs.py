# -*- coding: utf-8 -*-
"""Parse the lesson-plan .doc files into structured blocks.

Reads textutil's HTML output rather than its plain text, because the HTML keeps
the one signal that reliably separates structure from content: **genuine
headings are bold, list items are not**. (The plain-text output loses that, and
heuristics on the numbering alone mis-promote items like
"6. Bugun uyda qaysi ishni mustaqil bajarasiz?" into section headings.)

Word tables still arrive flattened into a run of paragraphs, so the two known
table shapes are rebuilt from their column counts.
"""
import html as htmllib
import json
import os
import re
import subprocess
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(ROOT, 'assets', 'lessons', 'docs')

APOS = "‘’ʻʼ`´'"


def norm(s):
    s = unicodedata.normalize('NFKC', s).lower()
    for ch in APOS:
        s = s.replace(ch, "'")
    return re.sub(r'\s+', ' ', s).strip()


# Bold lines whose text matches one of these are top-level sections even when
# the document forgot to number them.
SECTION_NAMES = {
    "dars haqida umumiy ma'lumot",
    'dars maqsadlari',
    'kutiladigan natijalar',
    'darsning texnologik xaritasi',
    'darsning batafsil ishlanmasi',
    "qo'shimcha vaziyatlar banki",
    'uyga vazifa',
    'yakuniy xulosa',
    'xulosa',
}

INFO_KEYS = [
    'mavzu', 'dars turi', 'davomiyligi', "asosiy g'oya", 'metodlar',
    'jihozlar', 'shior', 'sinf', 'dars shiori',
]

GOAL_LABELS = ["ta'limiy", 'tarbiyaviy', 'rivojlantiruvchi']

XARITA_HEADER = ['bosqich', 'vaqt', "o'qituvchi faoliyati", "o'quvchi faoliyati"]
BAHO_HEADER = ['mezon', 'ball', "ko'rsatkich"]

ROMAN_RE = re.compile(r'^([IVX]{1,6})\.\s+(.*\S)\s*$')
NUM_RE = re.compile(r'^(\d{1,2})\.\s+(.*\S)\s*$')


def paragraphs(doc_path):
    """(text, is_bold) for every non-empty paragraph, in document order."""
    out = subprocess.run(
        ['textutil', '-convert', 'html', '-stdout', doc_path],
        capture_output=True, check=True,
    ).stdout.decode('utf-8', 'replace')
    body = out[out.index('<body'):]
    result = []
    for m in re.finditer(r'<p[^>]*>(.*?)</p>', body, re.S):
        inner = m.group(1)
        text = htmllib.unescape(re.sub(r'<[^>]+>', '', inner))
        text = text.replace(' ', ' ').replace('\n', ' ').strip()
        if not text:
            continue
        result.append((text, '<b>' in inner))
    return result


def take_table(paras, i, ncols):
    """Consume `ncols` non-bold cells per row until the run stops looking like
    table data (a bold line always ends it — the next heading)."""
    rows, j = [], i
    while j + ncols <= len(paras):
        chunk = paras[j:j + ncols]
        if any(bold for _, bold in chunk):
            break
        rows.append([t for t, _ in chunk])
        j += ncols
    return rows, j


def parse(doc_path, grade):
    paras = paragraphs(doc_path)
    title = paras[0][0].strip('“”"')

    blocks, i, expected = [], 1, 1
    section = None

    while i < len(paras):
        text, bold = paras[i]
        ntext = norm(text)

        # ── Tables: header cells are bold, data cells are not ────────────────
        if [norm(t) for t, _ in paras[i:i + 4]] == XARITA_HEADER:
            header = [t for t, _ in paras[i:i + 4]]
            rows, i = take_table(paras, i + 4, 4)
            blocks.append({'k': 'table', 'h': header, 'r': rows})
            continue
        if [norm(t) for t, _ in paras[i:i + 3]] == BAHO_HEADER:
            header = [t for t, _ in paras[i:i + 3]]
            rows, i = take_table(paras, i + 3, 3)
            blocks.append({'k': 'table', 'h': header, 'r': rows})
            continue

        # ── Roman sub-heading ───────────────────────────────────────────────
        # Checked before the bold branch: a handful of these were left
        # unbolded in the source documents, and nothing else starts with a
        # roman numeral and a period.
        if ROMAN_RE.match(text):
            blocks.append({'k': 'h2', 't': text})
            section = None
            i += 1
            continue

        if bold:
            # ── Info table key: value is the following non-bold run ──────────
            if ntext in INFO_KEYS:
                vals, j = [], i + 1
                while j < len(paras) and not paras[j][1]:
                    vals.append(paras[j][0])
                    j += 1
                blocks.append(
                    {'k': 'kv', 'l': text, 't': ' '.join(vals).strip(' ,;')})
                i = j
                continue

            # ── "Ta'limiy:" / "Ta'limiy: <text>" ─────────────────────────────
            goal = next((g for g in GOAL_LABELS
                         if ntext == g + ':' or ntext.startswith(g + ': ')), None)
            if goal:
                if ntext == goal + ':':
                    vals, j = [], i + 1
                    while j < len(paras) and not paras[j][1]:
                        vals.append(paras[j][0])
                        j += 1
                    blocks.append({'k': 'kv', 'l': text.rstrip(':'),
                                   't': ' '.join(vals)})
                    i = j
                else:
                    cut = text.find(':')
                    blocks.append({'k': 'kv', 'l': text[:cut],
                                   't': text[cut + 1:].strip()})
                    i += 1
                continue

            # ── Numbered section heading ─────────────────────────────────────
            m = NUM_RE.match(text)
            if m and expected <= int(m.group(1)) <= expected + 1:
                n = int(m.group(1))
                expected = n + 1
                section = norm(m.group(2))
                blocks.append({'k': 'h1', 't': m.group(2), 'n': n})
                i += 1
                continue

            # ── Unnumbered section heading ───────────────────────────────────
            if ntext in SECTION_NAMES:
                section = ntext
                blocks.append({'k': 'h1', 't': text, 'n': expected})
                expected += 1
                i += 1
                continue

            # ── Any other bold line is a minor heading ("Yodda tuting",
            #    "1-o'yin: ...", "Taqdimot formulasi") ─────────────────────────
            blocks.append({'k': 'h3', 't': text})
            i += 1
            continue

        # ── Non-bold content ────────────────────────────────────────────────
        m = NUM_RE.match(text)
        if m:
            blocks.append({'k': 'ol', 'n': int(m.group(1)), 't': m.group(2)})
        elif section == 'kutiladigan natijalar' or text.endswith(';'):
            blocks.append({'k': 'li', 't': text})
        else:
            blocks.append({'k': 'p', 't': text})
        i += 1

    return {'grade': grade, 'title': title, 'blocks': blocks}


if __name__ == '__main__':
    # Regenerates assets/lessons/lesson_plans.json from the shipped .doc files.
    # Grade + presentation metadata is keyed by the document's own filename.
    META = {
        'asrab_avaylaymiz':               (1, '\U0001F331', ['0xFF43A047', '0xFF1B5E20']),
        'maktabim_ikkinchi_uyim':         (1, '\U0001F3EB', ['0xFFFF8A65', '0xFFD84315']),
        'men_mustaqil_bolaman':           (1, '\U0001F9D2', ['0xFF7E57C2', '0xFF4527A0']),
        'bizga_telefon_kompyuter_tv':     (2, '\U0001F4F1', ['0xFF29B6F6', '0xFF0277BD']),
        'jamoat_transporti':              (2, '\U0001F68C', ['0xFFFFB300', '0xFFEF6C00']),
        'hamkorlik_ananalari':            (2, '\U0001F91D', ['0xFF26A69A', '0xFF00695C']),
        'mening_odatlarim':               (3, '\u2B50', ['0xFFEC407A', '0xFFAD1457']),
        'volontyorlik':                   (3, '\U0001F49A', ['0xFF66BB6A', '0xFF2E7D32']),
        'ozimni_boshqaraman':             (3, '\U0001F9D8', ['0xFF5C6BC0', '0xFF283593']),
        'baxt_oiladan_boshlanadi':        (4, '\U0001F468\u200D\U0001F469\u200D\U0001F467', ['0xFFFF7043', '0xFFBF360C']),
        'chiqindini_qayta_ishlash':       (4, '\u267B\uFE0F', ['0xFF9CCC65', '0xFF33691E']),
        'qobiliyatlarni_rivojlantiramiz': (4, '\U0001F3A8', ['0xFFAB47BC', '0xFF6A1B9A']),
        'suv_zahiralari':                 (4, '\U0001F4A7', ['0xFF29B6F6', '0xFF01579B']),
    }

    def titlecase(t):
        """Some documents shout their title in caps — normalise to sentence case."""
        letters = [c for c in t if c.isalpha()]
        return t[0] + t[1:].lower() if letters and all(c.isupper() for c in letters) else t

    out = []
    for slug, (grade, emoji, colors) in META.items():
        rec = parse(os.path.join(DOCS, slug + '.doc'), grade)
        title = titlecase(rec['title'])
        subtitle = next((b['t'] for b in rec['blocks']
                         if b['k'] == 'kv' and b['l'].lower().startswith('dars turi')), '')
        out.append({
            'id': slug,
            'grade': grade,
            'title': title,
            'subtitle': subtitle,
            'emoji': emoji,
            'colors': colors,
            'doc': 'assets/lessons/docs/%s.doc' % slug,
            'docName': '%d-sinf \u2014 %s.doc' % (grade, title),
            'blocks': rec['blocks'],
        })
    out.sort(key=lambda r: (r['grade'], list(META).index(r['id'])))

    dest = os.path.join(ROOT, 'assets', 'lessons', 'lesson_plans.json')
    json.dump(out, open(dest, 'w', encoding='utf-8'),
              ensure_ascii=False, separators=(',', ':'))
    print('wrote %s (%d plans, %d blocks)'
          % (dest, len(out), sum(len(r['blocks']) for r in out)))
