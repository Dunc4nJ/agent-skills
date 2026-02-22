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

| Action | Per Session | Daily Max (2 sessions) |
|--------|-------------|----------------------|
| Follows | 10-12 | 20-24 |
| Likes | 10 | 20 |
| Comments | 5 | 10 |
| Saves | 0-2 | 0-4 |

**Max 2 sessions per day** (morning + evening).

---

## Pacing

The natural time spent scrolling, finding posts, reading content, and executing browser actions provides sufficient spacing between engagements. Don't add unnecessary artificial waits.

- **Between accounts:** No explicit wait needed. The time to close a modal, scroll, assess the next post, and click it (typically 5-10 seconds) is natural pacing.
- **After posting a comment:** Wait **15-30 seconds** before moving to the next account. Comments are the highest-signal action and benefit from a brief pause.
- **If anything feels "off"** (slow loading, repeated errors, unusual prompts), stop and tell the user.

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

A full session should take **8-12 minutes**. Most time is spent scrolling and identifying relevant content — the engagement actions themselves are fast.
