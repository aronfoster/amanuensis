#!/usr/bin/env python3
"""Check expected-output specimens, not an LLM's semantic reasoning.

Run from any directory with Python 3. No third-party dependencies. The production
validator remains unchanged; this checks fixture counts, witnesses and boundaries
so their documented walk-through does not silently drift.
"""
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
FIXTURE = Path(__file__).resolve().parent
# path relative to fixture -> (Must-Contain, relational, redundant, diagnostic,
#                              review units, expected validator exit)
CASES = {
    'plot/drafts/attempt01': (0, 1, 1, 0, 1, 0),
    'plot/drafts/attempt02': (1, 0, 0, 0, 1, 0),
    'plot/drafts/attempt03': (1, 1, 1, 0, 2, 4),
    'plot/drafts/attempt04': (1, 0, 0, 0, 1, 4),
    'plot/drafts/attempt05': (1, 0, 0, 0, 1, 4),
    'plot/drafts/attempt06': (1, 0, 0, 0, 1, 4),
    'cases/takeaway-only/plot/drafts/attempt01': (0, 0, 0, 1, 0, 0),
    'cases/pre-chapter/plot/book1/chapter02/drafts/attempt01': (0, 3, 1, 0, 3, 0),
    'cases/exceptions/plot/drafts/attempt01': (0, 0, 0, 0, 0, 0),
    'cases/storyboard-defect/plot/drafts/attempt01': (0, 1, 1, 0, 1, 4),
    'cases/storyboard-defect/plot/drafts/attempt02': (1, 0, 0, 0, 1, 4),
}
FIELDS = ('Must-Contain violations', 'Relational violations',
          'Redundant prior-context re-establishments',
          'Unverified prior-reader establishments', 'Review units emitted')


def validate(report, manifest, effective=None):
    command = ['sh', str(ROOT / 'scripts/validate-review-artifact.sh'), str(report),
               str(ROOT / 'agents/review-grammars.yaml'), str(manifest)]
    if effective:
        command.append(effective)
    return subprocess.run(command, text=True, capture_output=True)


def scene_ranges(prose):
    """Validate canonical markers before trusting any specimen's scene locator."""
    pattern = r'<!-- (end )?scene (\w+), beat (\d+) -->'
    active = None
    ranges = {}
    last_end = None
    last_scene = None
    for match in re.finditer(pattern, prose):
        end, scene, beat = match.groups()
        if not end:
            assert active is None, 'nested or unclosed beat'
            if last_scene is not None and scene != last_scene:
                assert re.search(r'^---$', prose[last_end:match.start()], re.M), 'missing scene separator'
                assert scene not in ranges, 'non-contiguous scene'
            active = (scene, beat, match.end())
        else:
            assert active is not None and active[:2] == (scene, beat), 'mismatched end marker'
            ranges.setdefault(scene, []).append(prose[active[2]:match.start()])
            active = None
            last_end, last_scene = match.end(), scene
    assert active is None and ranges, 'missing complete scene markers'
    return {scene: '\n'.join(parts) for scene, parts in ranges.items()}


def check_case(relative, expected):
    attempt = FIXTURE / relative
    project = FIXTURE / relative.split('/plot/')[0] if '/plot/' in relative else FIXTURE
    chapter = attempt.parent.parent.relative_to(project)
    report = attempt / 'reviewer-actions.md'
    text = report.read_text()
    manifest = attempt / 'draft-manifest.md'
    head = re.search(r'^Active-head: (.+)$', manifest.read_text(), re.M)[1]
    assert text.startswith(f'Reviewed-draft: {head}\n'), relative
    scenes = scene_ranges((attempt / head).read_text())
    order = list(scenes)
    for field, count in zip(FIELDS, expected):
        assert re.search(rf'^- {field}: {count}$', text, re.M), (relative, field)
    findings = re.findall(r'^- (?:MISSING|DEGRADED|INCONSISTENT|REDUNDANT) .+$', text, re.M)
    assert len(findings) == expected[4], relative
    assert len(re.findall(r'<!-- review-id:', text)) == expected[4], relative
    assert sum('[defect:' in line for line in findings) == expected[1], relative
    assert sum(line.startswith('- REDUNDANT') for line in findings) == expected[2], relative
    headers = re.findall(r'^## Compliance Report — Scene (\w+),', text, re.M)
    assert headers == order, (relative, 'report/draft scene mismatch')
    clean = len(re.findall(r'^### Block 001 — CLEAN$', text, re.M))
    assert f'- Blocks fully clean: {clean} of {len(order)}' in text
    context = text.split('## Context consulted\n', 1)[1]
    for scene in order:
        for field in ('reader-state-in', 'since-previous-scene'):
            locator = f'{chapter}/storyboards/{scene}-beat01-storyboard.md#{field}'
            assert locator in context, (relative, locator)
    current = None
    for line in text.splitlines():
        if line.startswith('## Compliance Report — Scene '):
            current = re.search(r'Scene (\w+),', line)[1]
        if line.startswith('- ') and '[defect:' in line:
            assert line.count('[ref:') == 1, (relative, 'ref count')
            ref = re.search(r'\[ref: ([^\]]+)\]', line)[1]
            file, anchor = ref.split('#')
            assert (project / file).is_file(), (relative, file)
            assert anchor in ('reader-state-in', 'since-previous-scene')
            assert f'{current}-beat01-storyboard.md' in file
            if '[defect: missing-context]' in line:
                assert not line.startswith('- REDUNDANT'), relative
        if line.startswith('- REDUNDANT'):
            witnesses = re.findall(r'Earlier: (\S+) "([^"]+)"', line)
            assert witnesses, relative
            for locator, quote in witnesses:
                path, earlier = locator.split('#')
                assert (project / path).resolve() == (attempt / head).resolve(), 'wrong draft witness'
                assert earlier in scenes and order.index(earlier) < order.index(current), 'not an earlier scene'
                assert quote in scenes[earlier], (relative, 'quote mismatch')
                assert locator in context, (relative, 'missing context witness')
    result = validate(report, manifest)
    assert result.returncode == expected[5], (relative, result.stdout, result.stderr)
    assert re.search(r'invalid:\s+0\b', result.stdout), result.stdout
    assert re.search(r'stale:\s+0\b', result.stdout), result.stdout
    print(f'PASS {relative}: {expected[4]} units, validator exit {expected[5]}')


def main():
    actual = {str(p.parent.relative_to(FIXTURE)) for p in FIXTURE.rglob('reviewer-actions.md')}
    assert actual == set(CASES), 'unregistered fixture report'
    for path, expected in CASES.items():
        check_case(path, expected)
    # Preserve the deliberately invalid pre-existing grammar specimen.
    result = validate(ROOT / 'examples/review/reviewer-actions.md', '-')
    assert result.returncode == 3, result.stdout
    # Preserve the wider relational-review example and its manifest freshness.
    attempt = ROOT / 'examples/relational-review/plot/book1/chapter03/drafts/attempt01'
    result = validate(attempt / 'reviewer-actions.md', attempt / 'draft-manifest.md')
    assert result.returncode == 0, result.stdout
    # A fully decided report checks freshness against an explicit read-from, not
    # the manifest head. Temporary copies never mutate the checked-in specimens.
    with tempfile.TemporaryDirectory() as temp:
        temp = Path(temp)
        positive = FIXTURE / 'plot/drafts/attempt01'
        report = temp / 'reviewer-actions.md'
        report.write_text((positive / 'reviewer-actions.md').read_text())
        manifest = temp / 'draft-manifest.md'
        manifest.write_text('Active-head: draft-v02.md\n')
        assert validate(report, manifest).returncode == 5
        assert validate(report, manifest, 'draft-v01.md').returncode == 0
    print('PASS invalid grammar, relational fixture, stale stamp and read-from override controls')
    print('These checks validate specimens and provenance, not semantic truth. Perform the README walk-through.')


if __name__ == '__main__':
    main()
