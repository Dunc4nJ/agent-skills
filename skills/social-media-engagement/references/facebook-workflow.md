# Facebook Workflow

This reference covers the full Facebook engagement workflow. All actions are performed as a **Business Page** (not a personal profile). Discovery and engagement happen exclusively through **Facebook Reels**.

---

## Pre-Session Setup

Before engaging with any Reels:

1. Read the engagement log (`engagement-log.csv`) and note all previously engaged Facebook Page names
2. Keep that list in memory for the entire session — do NOT re-read the CSV between engagements
3. **Switch to the correct Page identity** (see Page Switching below)
4. Navigate to `https://www.facebook.com/reel/`

---

## Page Switching

Multiple brands share one Facebook personal profile. Each brand has its own **Facebook Page**. Before engaging, you must switch to act as the correct Page.

### How to Switch

1. Navigate to `https://www.facebook.com/`
2. Click the **profile avatar / account menu** in the top-right corner
3. Look for **"Switch Profile"** or **"See all profiles"** in the dropdown
4. Select the Page that matches the brand you're engaging for (check `references/profile-manifest.yaml` for the Page name)
5. **Verify the switch**: After selecting, the top-right avatar should change to the Page's logo/icon. The name shown when you hover should be the Page name, not the personal profile name.
6. If verification fails (still showing personal profile name), try navigating to `https://www.facebook.com/pages/?category=your_pages`, click the Page, then click **"Use Facebook as [Page Name]"**

### Verification Before Engaging

**Never start engagement without confirming the active identity.** After switching:
- Take a screenshot and verify the Page name in the top-right
- If unsure, navigate to `https://www.facebook.com/me` — it should show the Page, not the personal profile
- If you're acting as the wrong Page or personal profile, **stop and switch** before any engagement

### Fallback: Direct Page Switch URL

If the menu-based switch doesn't work:
1. Navigate to `https://www.facebook.com/{page-username}/`
2. Look for a **"Switch to [Page Name]"** or **"Use Facebook as [Page Name]"** button
3. Click it and verify the switch

**Important:** All reactions, follows, and comments will appear as the active Page identity. Engaging as the wrong Page or personal profile is worse than not engaging at all.

---

## Discovery: Facebook Reels

### How to Access

1. Navigate to `https://www.facebook.com/reel/` or click the **Reels** icon in the left sidebar / bottom nav
2. Facebook loads a vertical Reels feed with auto-playing short videos
3. Browse through looking for content that matches the brand's audience

### What to Engage With

Engage with Reels that feel like they belong in the brand's world. Load the brand's audience file (`Projects/Ecommerce/Business/{Brand}/Brand/audience.md`) to understand what content themes and communities are relevant.

**The bar is vibes, not metrics.** If the content feels like something the brand's audience would enjoy, engage with it.

### What to Skip

- Viral memes, news, celebrity gossip, political content
- Big corporate brand ads
- Beauty tutorials, travel accessories, cooking (unless directly tied to the brand's niche)
- Content with zero connection to the brand's niche
- Accounts you've already engaged with (check the engagement log)

### Niche Assessment

Before engaging with a Reel, visually assess (no need to screenshot):

1. Does this content visually fit the brand's world? (pottery, ceramics, coffee, DIY, cozy lifestyle, handmade, home decor)
2. Is this a personal/small creator or an obvious mega-brand?
3. Is the content positive and safe to engage with?

If the answer to #1 is unclear, lean toward engaging. It's better to cast a slightly wide net than to overthink it. Skip only when the content is clearly outside the niche (beauty tutorials, travel vlogs, gaming, etc.).

### Soft Guideline on Size

Don't waste time checking follower counts. But if it's obviously a massive account (100K+ followers visible at a glance, or a well-known brand), skip it -- they won't notice the engagement. If you can't tell, don't worry about it.

---

## Navigating Between Reels

Facebook Reels navigation can be inconsistent. Use this priority order:

### Primary Method: Down Arrow Button

1. Click the **down arrow** button on the right side of the Reels player (the `⌄` icon)
2. Wait 1-2 seconds for the next Reel to snap into view
3. If the feed only partially advanced, click the down arrow again

This is the most reliable method for fully advancing to the next Reel.

### Secondary Method: "Next Card" Button

1. Use `find` tool with query **"Next Card"**
2. Click the returned reference
3. The feed will begin transitioning — if it only partially advances, press `ArrowDown` to complete the snap

**Known behavior:** Next Card sometimes advances the feed partway without fully snapping. Follow up with ArrowDown if needed, without taking a screenshot to verify.

### Tertiary Method: ArrowDown Key

1. Click on an empty area of the Reel first (not on any interactive element) to ensure the Reel player has focus
2. Press `ArrowDown`
3. Wait 1-2 seconds

**Known issue:** ArrowDown does NOT work when the comment input or any text field has focus. Always clear focus first (click outside or press `Escape`) before attempting ArrowDown.

### Fallback: Fresh Feed Reset

If navigation becomes stuck (same Reels cycling, content not advancing after 2-3 attempts):

1. Navigate directly to `https://www.facebook.com/reel/`
2. This forces Facebook to load a completely fresh Reels feed
3. Resume normal navigation

### Navigation After Commenting

Commenting is the action most likely to break navigation, because the comment input captures keyboard focus. After posting a comment:

1. Press `Escape` to close/defocus the comment input
2. Click on an empty area of the Reel player to restore player focus
3. Use the down arrow button or "Next Card" button to advance -- do NOT rely on ArrowDown immediately after commenting

---

## Engagement Actions

Engage **directly from the Reel** -- no need to visit the creator's profile first. Just react, follow, and (selectively) comment right there.

### 1. React to the Reel

1. Use `find` tool with query **"Like button"** on the current Reel
2. Click the returned reference to apply a simple Like (thumbs up)

**Reaction type guidance:**

| Reaction | When to Use | Frequency |
|----------|-------------|-----------|
| **Like** (thumbs up) | Safe default for any Reel | ~50% of reactions |
| **Love** (heart) | Beautiful visuals, inspiring work, aesthetic content | ~40% of reactions |
| **Care** (hug) | Personal stories, milestones, vulnerable posts | ~10% of reactions |

**Never use:** Haha, Wow, Sad, or Angry -- too easy to misread coming from a brand Page.

**If you want to attempt Love or Care:** Hover the Like button for 2 full seconds. If a reaction picker bar appears above the button, click your choice (Love is typically second from left, Care is typically third). If no picker appears after 2 seconds, click the Like button instead -- don't retry hover. The reaction picker is unreliable on Facebook, and defaulting to Like is fine.

**Important:** Never reuse a Like button reference from a previous Reel. Always re-query with `find` after navigating to a new Reel -- stale references may target the wrong Reel's button.

### 2. Follow the Creator's Page

1. Use `find` tool with query **"Follow button"**
2. Click the returned reference
3. The button text will change to "Following"

If you accidentally click a wrong element (audio link, profile link, etc.), close the popup with `Escape` and re-query with `find`.

If the Follow button isn't visible on the Reel overlay, skip the follow for this Reel -- don't navigate away to the profile page.

If the creator is already followed (button shows "Following"), skip and move on -- do NOT unfollow.

### 3. Comment (Selectively)

**4 comments per session max** (see `references/comment-guide.md` for writing guidelines)

1. Use `find` tool with query **"Comment button"** to open the comment section
2. Wait 1-2 seconds for the comment input to appear
3. Use `find` tool with query **"comment input"** or **"Write a comment"** or **"Comment as [Page Name]"**
4. Click the input to focus it
5. Type your comment
6. Use `find` tool with query **"Send"** or **"Post"** or **"Comment"** button to locate the submit button
7. Click the send button
8. Wait 1-2 seconds to confirm the comment posted
9. Press `Escape` or click outside the comment area to release focus before navigating

**Important: Do NOT press Enter to submit comments.** On Facebook, pressing Enter triggers the keyboard shortcuts overlay instead of submitting. Always use the dedicated send button (typically a small arrow icon to the right of the input field).

Comment on Reels where you have something specific to say about what you SAW in the video. Since these are videos, reference the content -- a technique, a transformation, a satisfying moment, a specific detail. Don't comment on every Reel you react to.

---

## Engagement Pattern Variation

Not every Reel gets the same level of engagement. Vary your pattern to look natural:

- **React to most Reels** -- this is the baseline engagement
- **Follow roughly 60-70% of the Reels you react to** -- skip follows on some Reels to avoid appearing robotic
- **Comment on approximately 4 Reels per session** -- roughly 1 comment per 3-4 engaged Reels

Mix it up:

- Sometimes react only, no follow
- Sometimes react and follow, no comment
- Sometimes react, follow, and comment all three
- Occasionally skip a niche-fit Reel entirely -- this makes your engagement pattern more organic

When doing multiple actions on a single Reel:
1. **React** first
2. **Follow** the Page (no explicit wait needed between react and follow)
3. **Comment** (if warranted) -- wait 15-30 seconds after posting before moving to next Reel

---

## Session Flow

1. **Read engagement log** and note previously engaged Facebook Pages
2. **Navigate** to `https://www.facebook.com/reel/`
3. **Assess niche fit** -- does this content belong in the brand's world?
4. **Engage** if relevant -- react, follow, and selectively comment
5. **Advance** to the next Reel using the down arrow button (primary method)
6. **Repeat** until session limits are reached
7. Track your counts: reactions (target 12), follows (target 8), comments (target 4)

### Handling Non-Niche Content

When you encounter content that doesn't fit the brand's niche, simply advance to the next Reel. No need to wait or interact. If you hit a streak of 5+ non-niche Reels, navigate to `https://www.facebook.com/reel/` for a fresh feed.

---

## Session Limits

| Action | Per Session (randomize within range) |
|--------|----------------------------------------|
| Page follows | 5-8 |
| Reactions | 8-12 |
| Comments | 2-4 |

**Pick a random target** within each range at the start of each session. Never hit the same combo twice in a row.

No daily session cap — run as many sessions as needed. Space sessions at least 6 hours apart to stay safe.

---

## Pacing & Anti-Detection Intervals

Consistent timing is a bot signal. Every interval below should be **randomized within the stated range** — never use the same delay twice in a row.

### Watch Time (Critical)

**Watch each Reel for at least 5-10 seconds** before engaging or scrolling past. Instant reactions are a strong bot signal on Facebook.

### Between Individual Actions (on the same Reel)

| Action Pair | Interval |
|-------------|----------|
| React → Follow (same Reel) | **4-10 seconds** |
| Follow → Comment (same Reel) | **6-15 seconds** |
| React → Comment (no follow) | **5-12 seconds** |

### Between Reels

| Transition | Interval |
|------------|----------|
| Advance to next Reel (no comment) | **8-20 seconds** (includes watch time) |
| After posting a comment → next Reel | **20-45 seconds** |
| Skip a Reel (scroll past without engaging) | **4-8 seconds** |

### Session-Level Pacing

- **Skip 1-2 Reels between engagements** — don't engage with every consecutive Reel
- **Take a 60-90 second "browse break"** after every 4-5 engagements (just watch Reels without acting)
- **Vary reaction types** across the session — don't use Love 5 times in a row
- **If anything feels "off"** (slow loading, repeated errors, unusual prompts), stop and tell the user

### Anti-Detection Best Practices

- **Never repeat the same action sequence** on consecutive Reels
- **Randomize all delays** — consistent 5-second gaps between every action look robotic
- **Watch before acting** — humans watch the Reel first, then decide to react
- **Let some good Reels go** — skipping relevant content occasionally is more human than engaging with every match

---

## Engagement Log Format

After each session, append to `engagement-log.csv` following these rules:

1. **One row per action.** Each follow, react, and comment is a separate row. If you follow + react + comment on one account, that's 3 rows.
2. **Always include time (HH:MM).** Every row must have a timestamp. Never leave blank.
3. **Platform name:** always lowercase `facebook`
4. **Account type:** always lowercase `page`
5. **Action values:** `follow`, `react(like)`, `react(love)`, `react(care)`, `comment`
6. **`comment_text`** only populated on `comment` rows.
7. **`notes`** on first action row for an account, empty on subsequent rows for same account.
8. **Follower count:** use `unknown` if not visible, never leave blank.

**Example (3 rows for one account):**
```
2026-03-01,14:30,facebook,themagnoliamercantile,The Magnolia Mercantile,unknown,page,Reel,react(love),,https://www.facebook.com/reel/1268827865155437,spring gift in a mug
2026-03-01,14:30,facebook,themagnoliamercantile,The Magnolia Mercantile,unknown,page,Reel,follow,,https://www.facebook.com/reel/1268827865155437,
2026-03-01,14:30,facebook,themagnoliamercantile,The Magnolia Mercantile,unknown,page,Reel,comment,"The mug is gorgeous and the ribbon takes it to another level.",https://www.facebook.com/reel/1268827865155437,
```

---

## Safety and Stop Triggers

If you encounter **ANY** of these, **stop immediately** and inform the user:

- "This Feature is Temporarily Unavailable"
- "You're Going Too Fast" or "Slow Down"
- Account checkpoint or identity verification
- CAPTCHA
- "Your Account Has Been Restricted"
- Phone number verification
- "Something Went Wrong" on repeated actions
- Unexpected redirect to a help/support page
- Being logged out unexpectedly

**Cool-down if flagged:** 6-12 hours minimum. Facebook penalties escalate aggressively -- a Business Page restriction can last 7-30 days.

---

## Handling Common Issues

- **Navigation isn't advancing:** Try the down arrow button, then ArrowDown key, then fresh feed reset (`https://www.facebook.com/reel/`)
- **Reaction picker unreliable:** Default to simple Like; hover is optional
- **Follow button not visible:** Skip the follow for this Reel -- no need to profile-visit
- **Comment submission fails:** Ensure you're clicking the send button (not pressing Enter) -- Enter triggers the keyboard shortcuts overlay on Facebook
- **Feed cycles through same Reels:** Navigate directly to `https://www.facebook.com/reel/` for a fresh feed
- **Clicked wrong element:** Close with `Escape`, re-query with `find`, try again
- **Stale reference clicked wrong Reel:** Navigate to `https://www.facebook.com/reel/` and restart

### Off-Niche / Untrained Feed (New Accounts)

New Pages or Pages with little engagement history will get a Reels feed full of generic viral content (pranks, memes, sports highlights, celebrity clips) with zero niche relevance. This is normal — Facebook's algorithm needs signals to learn what content the Page cares about.

**Do NOT engage with off-niche content just to "fill the session."** That trains the algorithm in the wrong direction.

**Strategy for untrained feeds:**

1. **Switch to Search-based discovery.** Use Facebook Search to find niche-relevant Pages and content:
   - Navigate to `https://www.facebook.com/search/pages/?q={niche keyword}` (e.g. "handmade pottery", "ceramic art", "meal prep")
   - Browse the Pages results and follow relevant ones
   - Click into Pages to find their Reels/posts and engage there
   - **Vary search terms across sessions**

2. **Use direct Reel URLs.** If you find a relevant Reel, Facebook's "related Reels" that load after it are usually more on-niche than the generic feed. Use this as a discovery chain — one good Reel leads to more.

3. **Scroll past off-niche Reels naturally.** When the feed serves irrelevant content:
   - Watch for 3-5 seconds (normal browse behavior), then advance
   - Don't react, follow, or comment on anything off-niche
   - **Never rapid-skip through dozens of Reels** — that's a bot signal
   - Occasionally let a Reel play for 8-10 seconds before skipping (humans get momentarily hooked)

4. **Keep going until you hit session targets.** Cycle through discovery methods (Page search → direct Reel URLs → related Reels chains → fresh feed reloads) until you reach your randomized session goals. Never end a session early due to a bad feed — switch methods instead.

5. **Rotate search terms.** If one keyword isn't producing enough Pages or Reels, try another from the brand's audience file. Broaden slightly if needed but stay within the niche.

6. **Signal the niche.** Every Page follow and reaction on niche content teaches Facebook what to surface. After 3-5 sessions of search-based engagement, the Reels feed should start aligning.

---

## URL Structure

- **Pages:** `https://www.facebook.com/[pagename]`
- **Reels:** `https://www.facebook.com/reel/[reel_id]`

---

## Time Per Session

12-18 minutes. The pacing rules spread actions naturally. Don't rush.
