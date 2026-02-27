# Instagram Workflow

This reference covers the full Instagram engagement workflow: discovery, engagement actions, pacing, and safety.

---

## Pre-Session Setup

Before engaging with any accounts:

1. Read the engagement log (`~/.openclaw/skills/social-media-engagement/engagement-log.csv`) and note all previously engaged Instagram handles
2. Keep that list in memory for the entire session — do NOT re-read the CSV between engagements
3. Navigate to `https://www.instagram.com/explore/`

---

## Discovery via Explore Tab

**Use the Explore tab**, NOT the Search bar. The Explore page surfaces fresh, algorithmically relevant content every time, which means natural variety across sessions without repeating the same accounts.

1. Scroll through the Explore grid
2. Look for posts related to the brand's content themes
3. When you spot relevant content, click the post image to open the modal
4. Engage directly from the post modal, then close and move to the next

---

## What to Engage With

Engage with posts that feel like they belong in the brand's world. Load the brand's audience file (`Projects/Ecommerce/Business/{Brand}/Brand/audience.md`) to understand what content themes and communities are relevant.

**The bar is vibes, not metrics.** If the content feels like something the brand's audience would enjoy, engage with it.

### What to Skip

- Obvious bot/spam accounts
- Content in completely unrelated niches (finance, fitness, politics, etc.)
- Big corporate brand ads or massive influencer promo posts
- Private accounts (can't see their content)
- Accounts already in the engagement log for Instagram
- Obviously massive accounts (100K+ followers visible at a glance)

---

## Engagement Actions

Everything happens inside the post modal — no profile visits needed.

1. **Click a relevant post** from the Explore grid to open the modal
2. **Check the handle** against your in-memory list of previously engaged accounts. If already engaged, close and move on.
3. **Engage** using whichever combination fits (see Engagement Pattern Variation below)
4. **Close the modal** — press `Escape` (twice if needed) to return to the Explore grid
5. **Scroll** to find the next relevant post and repeat

### Action Types

**Like** — use `find` to locate the heart/Like button and click it. This is the baseline action for most posts.

**Follow** — use `find` to locate the Follow button and click it. Follow is the primary growth action — do this on most posts you engage with. Skip follows occasionally (maybe 1-2 per session) to keep the pattern organic, but follows are the main goal.

**Comment** — click the comment input, type the comment, click Post. See `references/comment-guide.md` for writing guidelines. About 5 comments per session, spread naturally across the session (don't bunch them at the start or end).

**Save** — if something is genuinely exceptional (a technique you'd want to reference, a stunning piece, a tutorial worth revisiting), save it. This is rare — maybe 1-2 per session at most, and only if it actually stands out. Don't force it. Use `find` to locate the save/bookmark icon on the post modal.

### What NOT to do during this flow

- **Don't screenshot between actions on the same post.** Follow, like, and comment happen in the same modal — no need to re-verify between each action.
- **Don't visit the account's profile.** The post content tells you everything you need.
- **Don't re-query element references between actions on the same modal.** Refs stay valid while the modal is open.
- **Don't add artificial wait calls between follow and like on the same post.** They're instant actions in the same UI.

### When to re-query elements

Re-run `find` after closing a modal and opening the next post. The previous post's references are stale once a new modal opens.

---

## Engagement Pattern Variation

Not every post gets the same treatment. Vary your pattern to look natural:

- **Follow most posts you engage with** — follows are the primary growth action. Skip a follow on maybe 1-2 posts per session for organic variation, but the default is to follow.
- **Like most posts** — likes support the follow and signal genuine interest
- **Comment on about 5 posts per session** — spread naturally, not bunched at the start or end
- **Save 0-2 posts per session** — only when something genuinely stands out

Mix it up:

- Most posts: like + follow (the standard combo)
- Sometimes like, follow, and comment all three
- Sometimes like + follow + save (rare, for exceptional content)
- Occasionally like only, skip the follow (1-2 times per session max)
- Occasionally like, comment, but skip the follow
- Occasionally skip a niche-fit post entirely — this makes your engagement pattern more organic

The point is that no two consecutive engagements should look identical. A human scrolling through Explore doesn't mechanically do the exact same thing on every post.

---

## Session Limits

| Action | Per Session (randomize within range) |
|--------|----------------------------------------|
| Follows | 7-12 |
| Likes | 6-10 |
| Comments | 3-5 |
| Saves | 0-2 |

**Pick a random target** within each range at the start of each session. Never hit the same combo twice in a row.

No daily session cap — run as many sessions as needed. Space sessions at least 4 hours apart to stay safe.

---

## Pacing & Anti-Detection Intervals

Consistent timing is a bot signal. Every interval below should be **randomized within the stated range** — never use the same delay twice in a row.

### Between Individual Actions (on the same post)

| Action Pair | Interval |
|-------------|----------|
| Like → Follow (same post) | **3-8 seconds** |
| Follow → Comment (same post) | **5-12 seconds** |
| Like → Save (same post) | **4-9 seconds** |

### Between Posts/Accounts

| Transition | Interval |
|------------|----------|
| Close modal → scroll → open next post | **8-20 seconds** (natural browsing pace) |
| After posting a comment → next post | **20-40 seconds** |
| After a save → next post | **10-20 seconds** |
| Skip a post (scroll past without engaging) | **3-6 seconds** |

### Session-Level Pacing

- **Skip 1-3 posts between engagements** — don't engage with consecutive posts in the grid
- **Vary scroll distance** — sometimes scroll past 2-3 rows, sometimes just 1
- **Take a 60-90 second "browse break"** after every 4-5 engagements (just scroll without acting)
- **If anything feels "off"** (slow loading, repeated errors, unusual prompts), stop and tell the user

### Anti-Detection Best Practices

- **Never repeat the same action sequence** on consecutive posts (e.g. like→follow→comment, like→follow→comment)
- **Randomize all delays** — use `sleep $((RANDOM % (max - min) + min))` or equivalent
- **Don't engage at machine speed** — even 2-second consistent gaps between clicks look robotic
- **Scroll naturally** — humans don't jump straight to the next relevant post, they browse past irrelevant ones

---

## Handling Common Issues

### "Failed to Load" or Explore Page Errors
Navigate directly to `https://www.instagram.com/explore/` to force a fresh grid. This loads new content and resets any stale state. Don't try to refresh or troubleshoot the current page.

### Post Modal Won't Close
Press `Escape` twice. If still stuck, navigate directly to the Explore URL.

### Profile Preview Popup
Sometimes clicking near a username triggers a profile preview instead of the post modal. Dismiss by clicking away from it, then click the **post image** (not the username area) to open the correct modal.

### Stale Follow Buttons
After following, the button changes to "Following". If you see "Following" on a post you haven't engaged with yet, the page may have recycled an element — scroll past and find another post.

### Explore Grid Runs Out of Relevant Content
If you've scrolled far and aren't finding niche-relevant posts, navigate to `https://www.instagram.com/explore/` again for a fresh batch rather than continuing to scroll through irrelevant content.

### Off-Niche / Untrained Feed (New Accounts)

New or lightly-used accounts will have an Explore page full of generic viral content (memes, celebrities, sports) with zero niche relevance. This is normal — the algorithm needs engagement signals to learn.

**Do NOT engage with off-niche content just to "fill the session."** That trains the algorithm in the wrong direction.

**Strategy for untrained feeds:**

1. **Switch to Search-based discovery.** Use Instagram's search to find niche-relevant content directly:
   - Navigate to `https://www.instagram.com/explore/`
   - Use the search bar at the top — search for niche keywords from the brand's audience file (e.g. "handmade pottery", "ceramic mug", "meal prep containers")
   - Browse the search results grid and engage with relevant posts
   - **Vary search terms across sessions** — don't use the same keyword every time

2. **Scroll past off-niche content naturally.** When you encounter irrelevant posts (between search results or on Explore):
   - Scroll past at a normal pace (3-6 seconds per skip)
   - Don't like, follow, or interact with anything off-niche
   - Occasionally pause on a post briefly before scrolling past (humans do this)
   - **Never rapid-scroll through dozens of posts** — that's a bot signal

3. **Use hashtag pages** as an alternative discovery source:
   - Navigate to `https://www.instagram.com/explore/tags/{hashtag}/` with niche-relevant hashtags
   - Browse the grid and engage with relevant posts

4. **Keep going until you hit session targets.** Cycle through discovery methods (search keywords → hashtag pages → fresh Explore loads) until you reach your randomized session goals. Never end a session early due to a bad feed — switch methods instead.

5. **Rotate search terms.** If one keyword isn't producing enough results, try another from the brand's audience file. Broaden slightly if needed (e.g. "handmade" → "artisan", "ceramics" → "pottery studio") but stay within the niche.

6. **Signal the niche.** Every follow, like, and comment on niche content teaches the algorithm. After 3-5 sessions of search-based engagement, the Explore page should start surfacing relevant content naturally.

---

## Safety and Stop Triggers

If you encounter ANY of these, **stop immediately** and inform the user:

- "Action Blocked" message
- CAPTCHA or phone verification
- Unusual loading times or repeated errors
- "Try Again Later" message
- Any warning about suspicious activity
- Being logged out unexpectedly

**Cool-down if flagged:** 4-6 hours minimum. Flagged twice in one day — skip the rest of the day entirely.

---

## Content Observations
While browsing, mentally note 2-5 standout posts (high engagement, trending formats, notable visual techniques). Write observations at session end per Step 4.5.

## Session Target

A full session should take **8-12 minutes**. Most time is spent scrolling and identifying relevant content — the engagement actions themselves are fast.
