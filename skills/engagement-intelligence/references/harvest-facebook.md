# Facebook Harvest Workflow

## Prerequisites
- Chrome running on CDP port 9222 (`agent-browser connect 9222`)
- Logged into Facebook as Sims Wilson (TableClay page)
- `data/watermarks.json` exists

## Navigation

1. Connect: `agent-browser connect 9222`
2. Navigate: `agent-browser navigate "https://www.facebook.com/notifications/"`
3. Wait 5 seconds (FB loads slower than IG)
4. Verify: `document.title` should contain "Notifications"

## Parsing Notifications

Use `agent-browser snapshot` — the text field contains the full notification.

### Snapshot Command
```bash
agent-browser connect 9222 && agent-browser snapshot 2>/dev/null | grep "text:" | head -30
```

### Notification Patterns

FB notifications are noisier than IG. Only harvest engagement-relevant events.

**Comment Like:**
```
text: "Unread PageName likes your comment: \"[truncated text]...\" [time]1 Reaction"
```
→ event_type: `comment_like`

**Comment Reply / Mention:**
```
text: "Unread PageName mentioned you in a comment. [time]"
```
→ event_type: `comment_reply`. Note: FB doesn't always show the reply text in the notification; may need to click through for full text. If not visible, record event_type but leave `their_response` empty.

**Comment Reaction with Reply count:**
```
text: "Unread PageName reacted to your comment: \"[text]...\" [time]1 Reaction · 1 Reply"
```
→ Both a `comment_like` event AND note that a reply exists (click through if possible).

### Noise Filtering

SKIP these notification types entirely:
- "You approved a login" / "new login" / security alerts
- Birthday notifications
- "You have access to a new message" 
- Group post notifications (unless from a ceramics group)
- Threads cross-posts
- Tagged-in-post notifications from unrelated accounts
- Marketplace notifications

**Keep only:** Notifications where the text contains "your comment", "mentioned you", "your post", "your photo", "started following", or "reacted to".

### Time Parsing

FB notification timestamps:
- `Xm` → minutes
- `Xh` → hours  
- `Xd` → days
- `Xw` → weeks

Same conversion logic as Instagram.

## Scrolling

FB notifications page can be heavy. Limit scrolling:

1. Scroll: `agent-browser eval 'window.scrollBy(0, 600); "ok"'`
2. Wait 3 seconds (FB lazy-loads slower)
3. Re-snapshot and parse
4. Stop when hitting watermark OR after 3 scrolls (FB DOM gets heavy fast)

## Page vs Personal Notifications

FB may show mixed personal + Page notifications. Our engagement is done as the TableClay Business Page (Sims Wilson account).

Engagement-relevant notifications will reference "your comment" — these are comments posted as the Page. Filter by this to avoid capturing personal account interactions.

## Output

Same format as Instagram — append to `data/responses.csv` with `platform` set to `facebook`.

Update affected account profiles in `data/accounts.jsonl`.

## Chrome Stability Notes

Facebook is significantly heavier than Instagram. Extra caution:
- Restart Chrome before FB harvest if it's been running for a while: `sudo systemctl restart chrome-tableclay.service && sleep 6`
- Limit to 3 scrolls maximum
- If page becomes unresponsive (eval timeouts), stop harvest and save what you have
- Never run FB harvest immediately after a long IG session — restart Chrome in between
