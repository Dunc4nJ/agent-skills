# Search Strategies

Query templates, source-specific mining strategies, and research depth guidelines for product research.

## Table of Contents

1. [Query Templates by Category](#query-templates-by-category)
2. [Source-Specific Mining](#source-specific-mining)
3. [Research Depth Guidelines](#research-depth-guidelines)
4. [Data Organization During Research](#data-organization-during-research)

---

## Query Templates by Category

### 1. Market Landscape

```
"{product category}" market size 2024
"{product category}" industry trends
"{product category}" market growth
"{product category}" consumer trends report
"{product category}" market analysis
"state of {product category}" report
```

### 2. Competitor Discovery

```
best {product category} {current year}
{product category} comparison
"{product category}" vs
top {product category} brands
{product name} alternatives
{product name} vs {competitor}
site:reddit.com "best {product category}"
"{product category}" "better than"
```

### 3. Voice of Customer — Amazon

```
site:amazon.com "{product name}" reviews
"{product name}" amazon review
{product category} amazon best seller
```

Then use `web_fetch` on Amazon product pages to extract reviews. Focus on:
- 5-star reviews: what delights
- 3-star reviews: balanced perspective (most useful for positioning)
- 1-star reviews: objections and complaints

### 4. Voice of Customer — Reddit

```
site:reddit.com "{product name}"
site:reddit.com "{product category}" recommendation
site:reddit.com "{product category}" worth it
site:reddit.com "{product name}" review
site:reddit.com "{product category}" regret
site:reddit.com "{brand name}" experience
```

### 5. Voice of Customer — TikTok/YouTube

```
"{product name}" tiktok review
"{product name}" youtube review
"{product name}" unboxing
"{product name}" honest review
"{product category}" haul tiktok
"{product name}" "is it worth it"
```

### 6. Objection Mining

```
"{product name}" complaints
"{product name}" problems
"{product name}" "not worth"
"{product name}" return
"{product name}" disappointed
"{product name}" "waste of money"
site:reddit.com "{product name}" "don't buy"
"{product category}" scam
```

### 7. Pricing & Business Intelligence

```
"{product name}" price
"{product category}" pricing comparison
"{product name}" coupon OR discount OR sale
"{brand name}" revenue OR funding OR valuation
"{brand name}" shopify OR "direct to consumer"
```

---

## Source-Specific Mining

### Amazon

**What to extract:**
- Star distribution (% at each rating)
- "Most helpful" positive and negative reviews
- Frequently mentioned features (positive and negative)
- Questions section (reveals pre-purchase objections)
- "Customers also bought" (competitive intelligence)
- Listing copy (how the brand positions itself)

**Technique:**
1. Search for the product on Amazon
2. `web_fetch` the product page
3. Sort reviews by "Most helpful" — read top 10
4. Sort by "Most recent" — read top 10
5. Filter to 1-star and 3-star reviews specifically
6. Check the Q&A section

### Reddit

**What to extract:**
- Authentic opinions (no incentivized reviews)
- Comparative discussions ("X vs Y")
- Purchase decision factors
- Long-term ownership experiences
- Gift recommendation context

**Key subreddits to check (varies by category):**
- r/BuyItForLife — quality/durability focused
- r/shutupandtakemymoney — impulse/novelty
- Category-specific subreddits (r/skincare, r/coffee, r/cooking, etc.)
- r/gifts, r/GiftIdeas — gifting context

**Technique:**
1. Search across Reddit for the product and category
2. Read full threads (not just top comments)
3. Look for detailed comparison posts
4. Note the language people use naturally

### TikTok

**What to extract:**
- Viral angles (what hooks work)
- Creator perspectives vs consumer perspectives
- Comment section gold (real reactions)
- Trending sounds/formats used with the product
- UGC content patterns

**Technique:**
1. Search for TikTok reviews via web search
2. Look for viral videos and note their hook/angle
3. Check comment sections for authentic reactions
4. Note which content formats get engagement

### YouTube

**What to extract:**
- Professional reviewer consensus
- Detailed product demonstrations
- Long-term review perspectives
- Comment section objections and praise
- Competitor comparisons

**Technique:**
1. Search for YouTube reviews and unboxings
2. Focus on videos with high view counts
3. Read comment sections (often more useful than the video)
4. Look for "X months later" follow-up reviews

### Meta Ad Library

**What to extract:**
- Competitor ad creatives and copy
- How competitors position themselves
- Which ads have run longest (likely winners)
- Ad formats being used (UGC, polished, comparison)

**Technique:**
1. Search `web_search` for "{brand} Meta Ad Library" or go directly
2. Check active ads for the brand and competitors
3. Longest-running ads = likely best performers
4. Note hooks, angles, and CTAs

---

## Research Depth Guidelines

### Minimum (Quick Research)
- 15+ sources consulted
- 15+ customer quotes
- 5+ competitors
- 8+ objections
- 2-3 personas
- 5-8 ad angles

Use for: low-priority products, quick-turn requests, supplemental research.

### Standard (Default)
- 30+ sources consulted
- 25+ customer quotes
- 8-12 competitors
- 12-15 objections
- 3-5 personas
- 10-15 ad angles

Use for: most product research requests.

### Deep (Premium)
- 50+ sources consulted
- 40+ customer quotes
- 12-15 competitors
- 15-20 objections
- 5-7 personas
- 15-20 ad angles
- Additional: influencer analysis, ad spend estimates, seasonal trend data

Use for: hero products, high-budget launches, competitive markets.

---

## Data Organization During Research

### As You Research, Track:

**Quotes file (mental or scratch):**
```
[QUOTE] "exact words" — Source: Amazon 5-star review
[QUOTE] "exact words" — Source: Reddit r/subreddit
```

**Competitor table:**
```
[COMP] Brand | Price | Key claim | Unique mechanism | Weakness
```

**Objection log:**
```
[OBJ] "customer's words" — Source | Frequency: high/med/low
```

**Insight log:**
```
[INSIGHT] Category: {type} | Finding: {what you learned} | Source: {url}
```

### Research Sequence

Optimal order for research phases:

1. **Market landscape first** — understand the category before diving into specifics
2. **Competitor scan** — identify the competitive frame
3. **VoC mining** — the richest source of insights (spend most time here)
4. **Objection deep dive** — focused mining of negative sentiment
5. **Pricing intelligence** — with competitive context established
6. **Persona synthesis** — after you have VoC data to ground personas in reality

This sequence ensures each phase builds on the previous one.
