---
name: priced-in
description: Find out whether a prediction market knew before the news. Pins the moment news became public, searches for earlier leaks and hints (news sites and X), pulls Polymarket prices and trades around that moment, explains each price move, and gives a verdict - priced in, partly priced in, or a surprise. Use when someone asks "was this priced in", "did the market know beforehand", "why did this market move", or wants a model's forecasts scored against the market.
---

# Priced in

Answer one question with evidence: **did the market move before the news, or after it?**

You need an event ("Iran and the US sign a deal on Hormuz") and, if the user gave it, a market. Work in UTC throughout, and give every time with its source.

## 1. Pin the news moment (T0)

T0 is when the information first became public, not when the headline most people saw came out.

1. **Search the web** for the event. Note the earliest timestamp from each kind of source:
   - official sources (a government, a company, a court);
   - wires (Reuters, AP, Bloomberg, AFP);
   - major outlets.
2. **Find posts on X with your own web search,** for example `site:x.com <words>`. Reporters, officials and local accounts often post before the wires. To read a post you found, fetch it through the mdfromx.com mirror, which is read-only and needs no login: swap `x.com` for `mdfromx.com` in its URL (`https://mdfromx.com/<handle>/status/<id>`). The result includes the exact posting time. For an account's posts since a date, use `https://mdfromx.com/<handle>/posts?since=<YYYY-MM-DD>`. The mirror may ignore date filters, so don't rely on it to find posts. Search for them instead.

   **An X post's ID gives its exact time,** even when no page shows it: `milliseconds since 1970 = (id >> 22) + 1288834974657`. For example, post 2062271057294434770 was posted at 2026-06-03 20:31:49 UTC.
3. **Prefer the original statement.** A post on the speaker's own platform (Truth Social, a government or company site) shows its own time. Fetch it directly, rather than relying on news reports of it, which often give a time with no timezone. For a TV or radio interview, find the segment's air time.
4. **Set T0** as the earliest *credible* public report. Record:
   - the time;
   - the source;
   - the link;
   - whether it's a confirmation or only a report.

   If the verdict would change with a T0 an hour earlier or later, say exactly which time would flip it, and what source would settle it.

   If a rumour came earlier, record it under leaks (step 2), not as T0.
5. **Give a confidence for T0:** high (an official or wire timestamp), medium (a credible reporter) or low (inferred).

## 2. Find leaks and hints before T0

Search the 7 days before T0, or longer if the market started moving earlier. Look for:
- rumours;
- "sources say" reports;
- local-language reports;
- schedule changes (a cancelled trip, an unusual meeting);
- filings, flight or ship tracking, and official calendars;
- posts from people close to the event.

For each one, record the time, source, link, what it said, and how credible it is. Report what was public. Don't speculate about who traded on it.

## 3. Pull the market data

Polymarket's public APIs need no key. Read the docs index at `https://docs.polymarket.com/llms.txt` first, and follow it to the current endpoints. Don't rely on remembered URLs, because the APIs change. You need four things:
- **Find the markets:** search the events and markets for the event's words, then get each market's question, dates, outcome token ids and condition id.
- **Price history:** the YES token's price over the window, at minute or hourly detail.
- **Trades:** time, side, outcome, price, size and wallet. If the API can't filter trades by time, page back from the newest trade until you pass the window start, and say so if you had to stop early.
- **Resolution:** how and when the market settled.

Fetch these with whatever HTTP or fetch tool you have. Use only read endpoints: no orders, no sign-in, no keys.

- **The window:** from T0 minus 7 days (or the first leak, if that's earlier) to T0 plus 1 day.
- **More than one market:** if several markets cover the event (different dates or thresholds), check the most liquid one first, and then any that moved.
- **Report gaps:** if some data is missing, such as trades you couldn't reach or a thin price history, report it.

## 4. Analyse

- **Prices around T0:** the price at T0 − 7d, −24h, −6h, −1h, −10m, at T0, and at T0 + 1h.
- **The share of the move that happened before T0:**

  `pre-news share = (p(T0) − p(start)) / (p(T0 + 1h) − p(start))`

  Here `start` is the price before any leak. If the total move is under 3 points, say there was no real move, and don't compute a share.
- **Volume:** traded size in the 24h before T0, compared with the average day in the week before that. Also flag single trades much larger than usual for this market. List their time, side, size and wallet, which is public on-chain data, and draw no conclusion about who is behind them.
- **Explain each move:** for every price jump of 5 points or more within an hour, find the news, post or leak that landed in the 15 minutes before it. If nothing public explains a move, say so plainly. That's the most interesting finding.

## 5. Verdict

| Pre-news share | Verdict |
|---|---|
| 70% or more | **Priced in.** The market knew before the news. |
| 30–70% | **Partly priced in.** |
| Under 30% | **Surprise.** The market learned it from the news. |

Then say what the early move lines up with: a public leak (name it), nothing public (say so), or general drift with no clear cause.

## 6. Scoring a model (optional)

If the user has a model's forecasts for the same markets, score both on resolved markets:
- **Brier score:** `mean((p − outcome)²)`, for the model and for the market at the same times;
- **calibration:** bucket the forecasts and compare with how often the outcome actually happened;
- **a blend:** the Brier score of `w·model + (1−w)·market` for w from 0 to 1, to show whether the model adds anything to the market.

Report how many markets were scored, and treat small samples with caution.

## Report

```markdown
# Priced in? <event>

**Verdict:** <Priced in | Partly priced in | Surprise>. <pre-news share>% of the move came before the news.

**The news moment (T0):** <time UTC>, <source, link>, <confirmation or report>, confidence <high | medium | low>

**Leaks and hints before T0**
| Time (UTC) | Source | What it said | Credibility |

**Market:** <question> (<slug>)
| Point | Time (UTC) | YES price |
(−7d, −24h, −6h, −1h, −10m, T0, +1h)

**Moves explained**
| Time | Move | What landed just before |

**Unusual trades** (public on-chain data; no claim about who): <list, or "none">

**Caveats:** <data gaps, T0 confidence, thin market, several markets disagree>
```

## Rules

- **Every time and claim needs a source** and a link. If you can't find one, write "unknown", not a guess.
- **Name no one as an insider.** Report public facts: times, prices, trades, posts.
- **Stay read-only.** Never place trades, sign in, or post anything.
