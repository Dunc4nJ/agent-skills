# Instagram Workflow

This reference covers the full Instagram engagement workflow: discovery, engagement actions, pacing, and safety.

---

## Pre-Session Setup

Before engaging with any accounts:

1. Read the engagement log (`engagement-log.csv`) and note all previously engaged Instagram handles
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

Engage with posts that feel like they belong in the brand's world. For Table Clay, that means:

- Pottery, ceramics, clay work (throwing, glazing, kiln reveals, handbuilding)
- Coffee culture (pour-overs, latte art, morning routines, cafe visits)
- Cute home finds, aesthetic kitchen/table setups
- DIY and artsy projects (painting, crafting, woodworking, candle making)
- Handmade goods and small business showcases
- Cozy lifestyle and mindful living content
- Family/kids doing creative activities

**The bar is vibes, not metrics.** If the content feels like something the brand's audience would enjoy, engage with it.

### What to Skip

- Obvious bot/spam accounts
- Content in completely unrelated niches (finance, fitness, politics, etc.)
- Big corporate brand ads or massive influencer promo posts
- Private accounts (can't see their content)
- Accounts already in the engagement log for Instagram
- Obviously massive accounts (100K+ followers visible at a glance)

---

## Engagement Flow (Per Account)

This is the exact sequence for each account. Everything happens inside the same post modal — no profile visits needed.

1. **Click a relevant post** from the Explore grid to open the modal
2. **Check the handle** against your in-memory list of previously engaged accounts. If already engaged, close and move on.
3. **Follow** — use `find` to locate the Follow button and click it
4. **Like** — use `find` to locate the heart/Like button and click it
5. **Comment** (only if this is a designated comment account) — click the comment input, type the comment, click Post
6. **Close the modal** — press `Escape` (twice if needed) to return to the Explore grid
7. **Scroll** to find the next relevant post and repeat

### What NOT to do during this flow

- **Don't screenshot between actions on the same post.** Follow, like, and comment happen in the same modal — no need to re-verify between each action.
- **Don't visit the account's profile.** The post content tells you everything you need.
- **Don't re-query element references between actions on the same modal.** Refs stay valid while the modal is open.
- **Don't add artificial wait calls between follow and like on the same post.** They're instant actions in the same UI.

### When to re-query elements

Re-run `find` after closing a modal and opening the next post. The previous post's references are stale once a new modal opens.

---

## Session Limits

Non-negotiable. Never exceed these in a single session.

| Action | Per Session | Daily Max (2 sessions) |
|--------|-------------|----------------------|
| Follows | 15 | 30 |
| Likes | 15 | 30 |
| Comments | 5 | 10 |

**Max 2 sessions per day** (morning + evening).

### Comment Distribution

Pre-decide which accounts get comments before starting. Spread them evenly across the session. For 5 comments across 15 accounts, aim to comment on roughly every 3rd account (e.g., accounts #3, #6, #9, #12, #15). Don't bunch comments at the start or end.

---

## Pacing

The natural time spent scrolling, finding posts, reading content, and executing browser actions provides sufficient spacing between engagements. Don't add unnecessary artificial waits.

- **Between accounts:** No explicit wait needed. The time to close a modal, scroll, assess the next post, and click it (typically 5-10 seconds) is natural pacing.
- **After posting a comment:** Wait **15-30 seconds** before moving to the next account. Comments are the highest-signal action and benefit from a brief pause.
- **If anything feels "off"** (slow loading, repeated errors, unusual prompts), stop and tell the user.

### Pattern Variation

Keep it simple:

- Follow + like is the baseline for every account
- Comments are spread evenly per the distribution above
- Vary comment types (compliments, questions, relatable, encouraging) per `references/comment-guide.md`

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

## Session Target

A full session (15 accounts) should take **8-12 minutes**. Most time is spent scrolling and identifying relevant content — the engagement actions themselves are fast.
