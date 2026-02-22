# Facebook Workflow

This reference covers the full Facebook engagement workflow. All actions are performed as a **Business Page** (not a personal profile). Discovery and engagement happen exclusively through **Facebook Reels**.

---

## Pre-Session Setup

Before engaging with any Reels:

1. Read the engagement log (`engagement-log.csv`) and note all previously engaged Facebook Page names
2. Keep that list in memory for the entire session — do NOT re-read the CSV between engagements
3. Navigate to `https://www.facebook.com/reel/`

---

## Discovery: Facebook Reels

### How to Access

1. Navigate to `https://www.facebook.com/reel/` or click the **Reels** icon in the left sidebar / bottom nav
2. Facebook loads a vertical Reels feed with auto-playing short videos
3. Browse through looking for content that matches the brand's audience

### What to Engage With

Engage with Reels that feel like they belong in the brand's world. For Table Clay, that means content like:

- Pottery, ceramics, clay work (throwing, glazing, kiln reveals, handbuilding)
- Coffee culture (pour-overs, latte art, morning routines, cafe visits)
- Cute home finds, aesthetic kitchen/table setups
- DIY and artsy projects (painting, crafting, woodworking, candle making)
- Handmade goods and small business showcases
- Cozy lifestyle and mindful living content

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

| Action | Per Session | Daily Max (2 sessions) |
|--------|-------------|------------------------|
| Page follows | 8 | 16 |
| Reactions | 12 | 24 |
| Comments | 4 | 8 |

**Max 2 sessions per day.** Space sessions at least 4 hours apart.

---

## Pacing

- **No explicit wait between react and follow on the same Reel** -- the time to locate and click both buttons is natural pacing (~5-10 seconds)
- **20-40 seconds between reactions on different Reels** -- use this time to assess the next Reel's niche fit
- **15-30 seconds after posting a comment** before advancing to the next Reel -- comments are high-signal actions and benefit from a brief pause
- **Watch each Reel for at least 3-5 seconds** before engaging or scrolling past

The natural time spent scrolling, finding Reels, and assessing content provides sufficient spacing between engagements. Don't add unnecessary artificial waits beyond what's listed above.

---

## Engagement Log Format

After each session, append to `engagement-log.csv` following these rules:

1. **One row per account per session.** Consolidate all actions on one account into a single row using the `action_taken` field (e.g., "page_follow+react", "page_follow+react+comment"). Do NOT log each action as separate rows for the same account.
2. **Always include time (HH:MM).** Every row must have a timestamp.
3. **Keep format consistent** across all platforms.

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

---

## URL Structure

- **Pages:** `https://www.facebook.com/[pagename]`
- **Reels:** `https://www.facebook.com/reel/[reel_id]`

---

## Time Per Session

12-18 minutes. The pacing rules spread actions naturally. Don't rush.
