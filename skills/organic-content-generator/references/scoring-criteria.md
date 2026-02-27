# Concept Scoring Criteria

Score each concept 1-5 on five dimensions (max 25 points).

## 1. Trend Alignment (1-5)

How well does the concept match current observation data?

| Score | Meaning |
|---|---|
| 5 | Directly mirrors high-engagement observed content |
| 4 | Matches 2+ observed visual elements or content types |
| 3 | Generally aligned with observed trends |
| 2 | Loosely related to observations |
| 1 | No observation data available or no alignment |

## 2. Brand Fit (1-5)

Does it match brand voice, visual identity, and positioning?

| Score | Meaning |
|---|---|
| 5 | Perfect brand alignment — colors, tone, audience, values |
| 4 | Strong fit with minor stretches |
| 3 | Acceptable but not core brand territory |
| 2 | Borderline — could feel off-brand |
| 1 | Misaligned with brand identity |

## 3. Visual Distinctiveness (1-5)

Is it different from recent outputs?

| Score | Meaning |
|---|---|
| 5 | Completely fresh — new scene, composition, mood |
| 4 | New angle on a familiar theme |
| 3 | Similar category but different execution |
| 2 | Close to a recent output |
| 1 | Near-duplicate of existing content |

## 4. Platform Suitability (1-5)

Would this perform on the target platform?

| Score | Meaning |
|---|---|
| 5 | Optimized for platform format and audience behavior |
| 4 | Strong fit, minor adjustments possible |
| 3 | Works but not platform-native |
| 2 | Better suited to a different platform |
| 1 | Poor platform fit |

## 5. Refiner-Readiness (1-5)

Can the downstream image-refiner cleanly swap in the real product?

| Score | Meaning |
|---|---|
| 5 | Product clearly placed, good lighting info, clean background around product |
| 4 | Product visible, mostly clean swap possible |
| 3 | Product present but partially occluded or complex background |
| 2 | Product placement ambiguous or very small |
| 1 | Product barely visible or impossible to swap |

## Selection Rules

- Rank by total score descending
- Top 3-5 must include ≥2 different content types
- Default to 3 unless rich observation data supports 5
- Tiebreaker: higher refiner-readiness score
