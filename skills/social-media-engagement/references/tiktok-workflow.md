# TikTok Workflow

This reference covers the full TikTok engagement workflow: discovery, engagement actions, pacing, and safety. TikTok is video-first, so comments should reference what you saw or heard, not static images.

---

## Pre-Session Setup

Before engaging with any accounts:

1. Read the engagement log (`~/.openclaw/skills/social-media-engagement/engagement-log.csv`) and note all previously engaged TikTok handles
2. Keep that list in memory for the entire session — do NOT re-read the CSV between engagements
3. Navigate to `https://www.tiktok.com/` (For You feed) or TikTok Search if the FYP is still off-niche (see Discovery below)

---

## Discovery

Discovery method depends on how trained the account's FYP algorithm is. A brand-new or lightly-used TikTok account will have a generic FYP full of mainstream content (pranks, sports, ads) that is completely irrelevant to the brand's niche. The algorithm needs engagement signals before it starts surfacing niche content.

### Early Sessions (first ~5 sessions, or whenever the FYP is mostly off-niche)

**Use Search as the primary discovery method.** The FYP won't be useful yet.

1. Navigate to TikTok Search
2. Search for keywords matching the brand's content themes (e.g., "handmade pottery", "ceramic mug", "pour over coffee", "handmade crafts"). **Vary search terms across sessions** -- don't use the same keyword every time.
3. Browse the search results grid. Click into videos that look relevant based on the thumbnail and creator name.
4. When you find relevant content, engage directly from the video -- like, follow, comment
5. Before following, cross-check the creator's handle against the **engagement log** to avoid re-engaging

**Tips for Search-based discovery:**

- Start with broad niche terms ("handmade pottery") and get more specific in later sessions ("pottery kiln haul", "ceramic glaze results")
- Sort by "Top" for popular niche content, or switch to "Videos" for chronological results
- Prioritize smaller creators (under ~10K likes on the video) -- they're more likely to notice and reciprocate engagement
- After engaging with a video from search, use the "Find related content" bar at the top of the video view to discover similar creators organically

### Established Sessions (FYP is surfacing mostly relevant content)

Once the FYP consistently shows niche-relevant content (pottery, crafts, coffee, lifestyle), switch to **FYP as the primary discovery method.**

1. Open TikTok and land on the **For You** feed (default view)
2. Scroll through videos looking for content that matches the brand's audience
3. When you spot relevant content, engage directly -- like, follow, comment right from the video
4. Before following, cross-check the creator's handle against the **engagement log** to avoid re-engaging

Most established sessions should lean on the FYP. Mix in Search and other methods for variety.

### Handling Off-Niche FYP Content

Even on established accounts, the FYP will serve off-niche content. Handle it naturally:

- **Watch for 5-10 seconds** before scrolling past (humans don't instantly skip — they assess first)
- **Don't engage with anything off-niche** — no likes, follows, or comments on irrelevant content, as this trains the algorithm wrong
- **Occasionally let an off-niche video play longer** (10-15 seconds) before skipping — this mimics natural curiosity
- **Never rapid-scroll** through a streak of irrelevant videos — skip at a natural pace (5-12 seconds each)
- **If 5+ consecutive videos are off-niche**, switch to Search-based discovery for the rest of the session rather than continuing to scroll a dead feed
- **Keep going until you hit session targets** — cycle through discovery methods (FYP → Search with different keywords → Discover tab → suggested accounts) until you reach your randomized session goals. Never end a session early due to a bad feed — switch methods instead

### Additional Discovery Methods (mix in any time)

- **Discover tab:** Browse trending hashtags and sounds in the brand's niche
- **Suggested accounts:** When on a relevant creator's profile, check suggested accounts (arrow icon near Follow button)
- **Comment sections:** People leaving substantive comments on niche videos are often good engagement targets

---

## What to Engage With

Engage with videos that feel like they belong in the brand's world. Load the brand's audience file (`Projects/Ecommerce/Business/{Brand}/Brand/audience.md`) to understand what content themes and communities are relevant.

**The bar is vibes, not metrics.** If the video feels like something the brand's audience would enjoy, engage with it.

### What to Skip

- Obvious bot/spam/repost-only accounts
- Content in completely unrelated niches
- Big brand ads or massive creator promo content
- Private accounts
- Accounts already in the engagement log for TikTok

### Soft Guideline on Size

Don't waste time checking follower counts. But if it's obviously a massive creator (100K+ followers visible at a glance, or a well-known name), skip it -- they won't notice the engagement. If you can't tell, don't worry about it.

---

## Engagement Actions

Engage **directly from the video in the FYP** -- no need to visit the creator's profile to evaluate them first. If the content vibes, engage.

### Action Types

**Follow** -- click Follow right from the video. This is the primary growth action -- follow on most videos you engage with.

**Like (heart)** -- tap the heart. Likes support the follow and signal genuine interest.

**Comment** -- leave a genuine comment referencing what you saw or heard in the video (see `references/comment-guide.md`). About 5 comments per session, spread naturally. Don't bunch them.

**Save/Bookmark** -- if a video is genuinely exceptional (a technique tutorial, a stunning piece, a process you'd want to revisit), bookmark it. Rare -- 0-2 per session at most, and only if it actually stands out. Don't force it.

No shares, duets, or stitches -- those are content creation, not engagement.

---

## Engagement Pattern Variation

Not every video gets the same treatment. Vary your pattern to look natural:

- **Follow most videos you engage with** -- follows are the primary growth action. Skip a follow on maybe 1-2 videos per session for organic variation, but the default is to follow.
- **Like most videos** -- likes support the follow and signal genuine interest
- **Comment on about 5 videos per session** -- spread naturally, not bunched
- **Save 0-2 videos per session** -- only when something genuinely stands out

Mix it up:

- Most videos: follow + like (the standard combo)
- Sometimes follow, like, and comment all three
- Sometimes follow + like + save (rare, for exceptional content)
- Occasionally like only, skip the follow (1-2 times per session max)
- Occasionally follow only, no like
- Occasionally just watch and scroll past -- not every relevant video needs an action
- Sometimes like 2-3 of a creator's videos instead of just 1

The point is that no two consecutive engagements should look identical. A human scrolling through TikTok doesn't mechanically do the exact same thing on every video.

---

## Session Limits

Conservative per-session limits. TikTok is aggressive about bot detection.

| Action | Per Session (randomize within range) |
|--------|----------------------------------------|
| Follows | 7-12 |
| Likes | 6-10 |
| Comments | 3-5 |
| Saves | 0-2 |

**Pick a random target** within each range at the start of each session. Never hit the same combo twice in a row.

No daily session cap — run as many sessions as needed. Space sessions at least 6 hours apart to stay safe.

For accounts running TikTok engagement for 2+ weeks without flags, the user could consider gradually increasing per-session limits. But this should be a manual user decision, not automatic.

---

## Pacing & Anti-Detection Intervals

Consistent timing is a bot signal. Every interval below should be **randomized within the stated range** — never use the same delay twice in a row.

### Watch Time (Critical)

**Always watch at least 10-15 seconds** of a video before engaging. TikTok tracks watch time as a primary bot-detection signal. An account that follows/likes/comments without watching gets flagged fast.

Let the video play, then engage. Sometimes watch the **full video** (especially shorter ones under 30s) before acting — humans often do.

### Between Individual Actions (on the same video)

| Action Pair | Interval |
|-------------|----------|
| Like → Follow (same video) | **3-8 seconds** |
| Follow → Comment (same video) | **6-15 seconds** |
| Like → Save (same video) | **4-10 seconds** |

### Between Videos

| Transition | Interval |
|------------|----------|
| Scroll to next video (no comment) | **10-20 seconds** (includes watch time) |
| After posting a comment → next video | **25-50 seconds** |
| Skip a video (scroll past without engaging) | **5-12 seconds** (still watch briefly) |

### Session-Level Pacing

- **Skip 1-3 videos between engagements** — don't engage with every consecutive video
- **Watch some videos fully without engaging** — this trains the FYP and looks natural
- **Take a 60-120 second "scroll break"** after every 4-5 engagements (just watch without acting)
- **If anything feels "off"** (slow loading, repeated errors, unusual prompts), stop and tell the user

### Anti-Detection Best Practices

- **Never repeat the same action sequence** on consecutive videos (e.g. like→follow, like→follow, like→follow)
- **Randomize all delays** — TikTok's bot detection is the most aggressive of the three platforms
- **Watch time > action speed** — a 15-second watch + instant like looks more human than a 2-second watch + 5-second delayed like
- **Don't follow 5 accounts in a row** — mix in like-only and skip-only videos to break the pattern
- **Occasional full-video watches** without any engagement signal genuine browsing behavior

---

## Safety and Stop Triggers

If you encounter **ANY** of these, **stop immediately** and inform the user:

- "You're tapping too fast" or any rate-limiting message
- CAPTCHA or verification request
- Phone number verification
- "This account was banned" or any restriction notice
- "Your comment couldn't be posted" on repeated attempts
- Unusual loading times or repeated errors
- Being logged out unexpectedly
- Any message about suspicious activity or community guidelines

### Shadowban Awareness

TikTok may shadowban without notification -- videos get near-zero views, content doesn't appear in searches. If the user reports this: pause all TikTok engagement for **48-72 hours**.

### Cool-Down Protocols

- **After being flagged:** 6-12 hours minimum
- **Flagged twice in one day:** Skip the rest of the day
- **Suspected shadowban:** 48-72 hours
- **After a temp ban lifts:** Half limits for first 2 sessions back

TikTok penalties escalate fast: rate-limit → temp block → temp ban → permanent ban. Conservative limits matter.

---

## URL Structure

- **Creator profiles:** `https://www.tiktok.com/@username`
- **Videos:** `https://www.tiktok.com/@username/video/[video_id]`

Log clean URLs without tracking parameters.

---

## TikTok-Specific Browser Quirks

These are known TikTok UI behaviors that cause friction during browser-automated sessions. Handle them proactively.

### "Leave page?" Popup After Commenting

After posting a comment, TikTok keeps the comment input in a "dirty" state. If you navigate away (click X, click the down arrow, or scroll), TikTok shows a "Leave page?" modal asking "You haven't finished your comment yet. Do you want to leave without finishing?"

**This happens even after the comment was successfully posted.** It's a false positive.

**How to handle:**

1. After posting a comment, **click outside the comment input area** (anywhere on the video) or **press Escape** to blur the input
2. Verify focus is cleared before navigating away
3. If the popup still appears, click **"Leave"** -- the comment is already posted and won't be lost
4. Do NOT click "Keep editing" unless the comment genuinely failed to post (check the comments list to confirm)

### Post Button Visibility

On narrower browser windows (under ~1200px wide), TikTok's "Post" button for comments can be partially off-screen or unclickable via coordinate-based clicks.

**How to handle:**

1. First try clicking the Post button using the `find` tool (`find` query: "Post button")
2. If that fails, use `javascript_tool` as a fallback: find the button with `document.querySelectorAll('button')`, match on `textContent === 'Post'`, and call `.click()`
3. Always take a screenshot after posting to confirm the comment appeared in the comments list
4. For best results, ensure the browser window is at least 1300px wide before starting a TikTok session

---

## Time Per Session

15-25 minutes. Pacing + watch-time requirements spread actions naturally. Don't rush.
