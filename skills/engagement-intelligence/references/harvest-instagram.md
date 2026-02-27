# Instagram Harvest Workflow

## Prerequisites
- Chrome running on CDP port 9222 (`agent-browser connect 9222`)
- Logged into @table.clay Instagram account
- `data/watermarks.json` exists (create with `{}` on first run)

## Navigation

1. Connect: `agent-browser connect 9222`
2. Navigate: `agent-browser navigate "https://www.instagram.com/notifications/"`
3. Wait 3 seconds for page load
4. Verify via eval: `document.title` should contain "Instagram" and URL should be `/notifications/`

## Parsing Notifications

Use `agent-browser snapshot` (NOT screenshot) — the accessibility tree gives structured text.

### Snapshot Command
```bash
agent-browser connect 9222 && agent-browser snapshot 2>/dev/null | sed -n '/main:/,/footer/p'
```

### Notification Patterns

Instagram notifications follow predictable text patterns. Parse each by matching:

**Comment Like (single):**
```
text: "(Display Name) liked your comment: [truncated comment text] [time]"
```
→ event_type: `comment_like`, from_account: link URL before text, our_comment_snippet: text after "liked your comment: "

**Comment Like (multiple):**
```
link: "account1"
text: ","
link: "account2"  
text: "and N others liked your comment: [text] [time]"
```
→ One `comment_like` event per named account. Ignore "N others" (we only track named accounts).

**Comment Reply / Mention:**
```
text: "(Display Name) mentioned you in a comment:"
link: "@table.clay"
text: [their reply text] [time]
```
→ event_type: `comment_reply`, their_response: the reply text

**Follow Back:**
```
text: (Display Name) started following you. [time]
button: "Following" or "Follow"
```
→ event_type: `follow_back`. Note: "Following" button means we already follow them back (mutual).

**Post Like:**
```
text: liked your photo. [time]
text: liked your post. [time]
```
→ event_type: `post_like`

### Time Parsing

IG notification timestamps are relative:
- `Xm` → X minutes ago
- `Xh` → X hours ago
- `Xd` → X days ago
- `Xw` → X weeks ago

Convert to approximate ISO date based on current time. Precision to the day is sufficient.

### Section Headers

Notifications are grouped under headings:
- `heading "Today"` 
- `heading "This week"`
- `heading "This month"`
- `heading "Earlier"`

Use these to validate time parsing.

## Scrolling for More

After parsing visible notifications:

1. Scroll down: `agent-browser eval 'window.scrollBy(0, 800); "ok"'`
2. Wait 2 seconds for lazy load
3. Re-snapshot and parse new entries
4. Repeat until:
   - Hitting the watermark timestamp (a notification we've already harvested)
   - OR reaching "Earlier" section on first run (don't go further than 30 days back)
   - OR 3 consecutive scrolls with no new notifications

## Watermark Check

Before starting, read `data/watermarks.json` for the `instagram` watermark timestamp.

While parsing, compare each notification's approximate timestamp against the watermark. When a notification matches or is older than the watermark, stop — everything below has already been harvested.

After harvest completes, update `data/watermarks.json` with the timestamp of the newest notification parsed.

## Account Handle Extraction

The account handle is in the link URL preceding the notification text:
```
link "accountname":
  /url: /accountname/
```

Extract from the URL path. Prepend `@` for consistency with engagement-log.csv.

## Output

Append new events to `data/responses.csv`:
```
harvested_at,platform,event_type,from_account,from_display_name,our_comment_snippet,their_response,post_url,event_age
2026-02-27T07:20:00Z,instagram,comment_like,@forestceramicco,Sean Forest Roberts,the marbling patterns always come out so different,,/p/DVEMJnIDVKP/,14h
2026-02-27T07:20:00Z,instagram,comment_reply,@annashipulina_ceramics,Anna Shipulina,those forms are incredible do you throw everything,this vase was wheel thrown my latest ones are hand built,/p/CqtAJDvvC9i/,9h
2026-02-27T07:20:00Z,instagram,follow_back,@sincerelysydceramics,Sydney | Slow Made Ceramics,,,, 1d
```

Then update affected account profiles in `data/accounts.jsonl`.

## Chrome Stability Notes

- Always chain `agent-browser connect 9222 &&` before every command
- Use `snapshot` not `screenshot` (lighter, gives parseable text)
- If Chrome disconnects, wait 5 seconds and reconnect
- If 3 consecutive SIGKILLs, restart Chrome: `sudo systemctl restart chrome-tableclay.service && sleep 6`
- Keep scrolling gentle — `scrollBy(0, 800)` with 2-second gaps
- Facebook is heavier than Instagram; if doing both, harvest IG first

## First Run

On first run with no watermark:
1. Parse all visible notifications
2. Scroll down through "Today", "This week", "This month"
3. Stop at "Earlier" section or after 5 scrolls (whichever comes first)
4. Set watermark to newest notification's timestamp
5. This establishes the baseline — future runs will be incremental
