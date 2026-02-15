# My Worship Path — Feature Design Specification

**Hedaya iOS 14+ · SwiftUI · Offline-first · Privacy-first**

A respectful, personalized gamification layer for Islamic worship. This document describes the full UX, flows, copy, and data model. **No existing code is modified**; the feature is a new module launched from a single entry point.

---

## 1. Entry Point / New Screen

### Where to add the entry point

- **Recommended:** Add **one new card** on the existing Home grid (ContentView), in the same `LazyVGrid` as "سبحة عامة" and the Azkar groups. It appears as the first or second card so it’s visible but not overwhelming.
- **Alternative:** A small text link or icon below the header (e.g. "مسيرتي في العبادة" or a leaf/path icon) that opens the new flow. No floating button unless the rest of the app already uses one (to keep UI consistent).

**Rationale:** The app has no Settings yet; the home grid is the only navigation hub. A single card keeps the change minimal and consistent with existing patterns (NavigationLink → destination).

### Intro screen (first screen inside the new flow)

**Purpose:** Introduce the feature in a calm, supportive, non-judgmental way. Set the tone before onboarding.

**Layout (iOS-first):**
- Full-screen with the same soft gradient background as Home (e.g. `F0F7F4` → `E8F5E9`).
- Bismillah or a simple geometric/leaf illustration at top (optional).
- Short, hopeful copy; RTL-friendly.

**UX copy examples:**

- **Headline (Arabic):** "مسيرتك في العبادة"
- **Subhead (Arabic):** "خطوة بخطوة، وفق وقتك ونيتك، بدون ضغط ولا مقارنة."
- **Short paragraph:** "هنا نرتب معاً ما تريد أن تركز عليه من صلاة وذكر وقراءة وصدقة، ونضع خطة بسيطة تتكيف مع أيامك. الهدف أن نثبت لا أن نثقل."
- **Primary CTA:** "ابدأ مسيرتي" (Start My Path)
- **Secondary:** "تخطى الآن" (Skip for now) — dismisses to Home; user can re-enter from the same card later.

**Tone:** Supportive, hopeful, no assumption of “catching up” or guilt. Emphasize: your pace, your intention, adaptation.

---

## 2. Onboarding Questions (Critical)

Progressive, conversational question flow. **All questions skippable.** No religious judgment. Follow-ups adapt to previous answers.

### Question set (order and branching)

| # | Topic | Question (Arabic example) | Type | Follow-up / logic |
|---|--------|----------------------------|------|-------------------|
| 1 | Consistency | "كيف ترى انتظامك حالياً في الصلاة والذكر؟" — خيارات: "منتظم جداً" / "أحياناً أنتظم" / "أبدأ ثم أتوقف" / "أريد أن أبدأ من جديد" | Single choice | If "أريد أن أبدأ من جديد" → lighter daily essentials, more recovery days. |
| 2 | Time | "كم دقيقة تقريباً يمكنك تخصيصها يومياً للعبادة (صلاة، ذكر، قرآن)؟" — "قليل جداً (حوالي ٥–١٠)" / "متوسط (١٥–٣٠)" / "أكثر (٣٠+)" / "يختلف من يوم لآخر" | Single choice | Feeds into daily cap and “optional bonuses” count. |
| 3 | Intention | "ما أبرز ما تريده من هذه المسيرة؟" — "انضباط وترتيب" / "قرب من الله" / "تعلم ووعي" / "بناء عادة مستدامة" | Single choice (or multi if desired) | Shapes wording of reflections and badges (e.g. “قرب” vs “انضباط”). |
| 4 | Worship areas | "ما الذي تريد أن نركّز عليه معك؟" — Checkboxes: الصلاة (فرض وسنة)، القرآن، الذكر، الدعاء، الصدقة، الزكاة، نوايا حسنة/أعمال صالحة | Multi-select | Drives which actions appear in Daily Essentials vs Optional. |
| 5 | Pace | "ما وتيرة تناسبك؟" — "هادئة (خطوات صغيرة ثابتة)" / "متوازنة" / "طموحة (مع مرونة)" | Single choice | Maps to: gentle / balanced / ambitious (target counts, streak mercy). |
| 6 | Tracking feeling | "كيف تشعر حيال متابعة نفسك؟" — "تشجّعني وتنظمني" / "أحياناً تثقل عليّ" / "لا أحب التتبع كثيراً" | Single choice | If “تثقل” or “لا أحب” → minimal numbers, more reflection than stats, softer reminders. |
| 7 | Life context (optional) | "هل تريد أن نأخذ وضعك في الاعتبار؟" — "أم/أب مشغول" / "طالب" / "مسافر أحياناً" / "لا يهم الآن" | Single choice, skippable | Adjusts suggestions (e.g. shorter units for busy parent, travel-friendly goals). |

**Presentation rules:**
- One question per screen (or one topic with sub-choices).
- Conversational tone; optional short sentence before choices (e.g. "لا إجابة صحيحة واحدة—اختر ما يناسبك").
- "تخطى" on every screen.
- Progress indicator: subtle (e.g. dots or "٢ من ٧") so it doesn’t feel like an exam.
- No timers; user can go back and change answers before submitting.

**Data:** Store answers in a **WorshipProfile** (see Data Model). Used to generate the Worship Mix and all personalization.

---

## 3. Personalized Worship Plan ("Worship Mix")

After onboarding, show **one screen** that explains the user’s plan in plain language. No overwhelming lists.

### Sections to show

1. **Daily essentials (الضروريات اليومية)**  
   - Short list of 3–5 concrete actions (e.g. "الصلوات الخمس"، "ورد قرآن قصير"، "ذكر الصباح أو المساء").  
   - Generated from: worship areas selected, time availability, pace.  
   - Copy: "هذه أساس يومك. إن فاتك يوم، الخطة تتكيف ولا نلوم."

2. **Optional bonuses (إضافات اختيارية)**  
   - 2–4 items (e.g. سنة قبل/بعد، صدقة، دعاء معين).  
   - Copy: "إذا تيسر وقت أو نفس، يمكنك إضافتها. ليست إلزاماً."

3. **Weekly focus (تركيز الأسبوع)**  
   - One rotating theme per week (e.g. "هذا الأسبوع: دعاء بعد الصلاة") or a soft weekly intention.  
   - Optional; can be hidden for “gentle” pace.

4. **Recovery & flexibility**  
   - Short explanation: "لديك أيام راحة مضمونة. إذا غبت، نعدّل الهدف ولا نعيد العد من الصفر."  
   - Link or short note: "كيف تتكيف الخطة" (expandable or separate short screen).

### How the plan adapts (explain in-app)

- **Automatic adaptation:** If user consistently logs less than the suggested “daily essentials,” after a few days the plan can suggest a lighter set (e.g. "نرى أن وقتك محدود هذه الفترة—اقترحنا تقليص الأساسيات قليلاً"). User confirms or keeps current.
- **After missed days:** No harsh reset. Streak can use “mercy” (e.g. 1–2 free skips per week for gentle/balanced). Plan text stays the same; only encouragement changes ("غداً فرصة جديدة").
- **Refreshing intentions:** Weekly or on demand, a short prompt: "هل ما زالت نيتك كما هي؟" with option to re-answer one or two questions (intention, pace) and refresh the plan.

**Copy tone:** Reassuring, clear, short. Avoid jargon.

---

## 4. Gamification (Halal & Humane)

### Allowed

- **Levels with spiritual naming (no numbers in labels):**  
  - Seeds (البذور) → Roots (الجذور) → Growth (النمو) → Steadfast (الثبات) → (optional) Blossom (الإيناع).  
  - Progress between levels based on consistency and reflection, not raw counts. Unlock next after e.g. 7–14 days of “on path” (with mercy rules).

- **Progress as “journey”:**  
  - Single visual: a path or tree that fills/advances. Label as "مسيرتك" not "مستواك". No rank, no points against others.

- **Gentle streaks:**  
  - "أيام متتالية على المسيرة" with mercy: 1–2 “grace” days per week (gentle/balanced) so a single miss doesn’t break.  
  - Wording: "٧ أيام على المسيرة" not "Streak: 7."

- **Reflection badges (not performance-based):**  
  - Examples: "أكملت أسبوعاً بنية صادقة"، "راجعت نيتك"، "استخدمت يوم راحة بوعي".  
  - No "Perfect Week" or "Never Missed" badges.

### Not allowed

- Leaderboards, friend comparisons, or any social competition.
- Shame messaging ("لم تصلّ اليوم!"), guilt-based prompts, or harsh streak resets.
- Performance-based badges that punish missing days.

### Implementation note

- All gamification state is local (offline-first). No server-side leaderboard or social graph.

---

## 5. Daily Experience

### When the user opens the feature daily

1. **Today’s view (main screen):**
   - Short greeting: "الخميس، ١٢ فبراير" + optional "مسيرتك اليوم" or "ما خطوتك التالية؟".
   - **Daily essentials** as tappable/checkable items (e.g. "صلاة الفجر"، "ورد القرآن"، "أذكار الصباح"). Tapping opens either:
     - In-app flow (e.g. link to existing Azkar/General Sebha) or
     - Simple "تم" (Done) to log without leaving the Path.
   - **Optional bonuses** listed below, same interaction.
   - At bottom: journey/level progress (path or tree) and optional "تأمل اليوم" (short reflection prompt).

2. **Quick logging:**
   - Each action: one tap to mark done (with optional "تأجيل" or "لاحقاً").  
   - No mandatory fields. Optional: "سجلت [الصلاة / القرآن / …]" with a brief confirmation (e.g. "بارك الله فيك").

3. **Reminders (language + timing):**
   - **Language:** Gentle and supportive. Examples: "وقت أذكارك إذا تيسر"، "لا تنسَ وردك عندما تستطيع." Never: "لم تصلّ بعد!"
   - **Timing:** User chooses time(s); default once (e.g. after Maghrib). No spam; max 1–2 per day unless user opts for more.

4. **End-of-day reflection (optional):**
   - One optional prompt before sleep or at day end: "كلمة واحدة عن يومك في العبادة؟" or "كيف كان قلبك اليوم؟" — free text or emoji. Stored locally for reflection only; not scored.

---

## 6. Failure & Recovery Design

### When the user skips days

- **No punishment.** Next open: "مساء الخير. غداً فرصة جديدة—نفس الخطة بانتظارك."  
- Streak uses mercy days; after mercy is used, streak resets softly (e.g. "ابدأ من جديد عندما تكون مستعداً") with no guilt copy.  
- Plan stays the same unless user has repeatedly logged much less; then offer the lighter plan once.

### When the user disables reminders

- Accept without comment. In-app: "يمكنك تفعيل التذكيرات متى شئت من الإعدادات."  
- No repeated nagging to re-enable. Optional: one gentle card in the Path home: "تذكير واحد عندما تفتح التطبيق؟" (in-app only).

### When the user feels overwhelmed

- **Detect (optional):** e.g. several "لاحقاً" or skips in a row, or answer in onboarding that tracking can feel heavy.  
- **Response:**  
  - Reduce visible goals: show only 1–2 “today essentials” and hide the rest under "المزيد عندما تستطيع."  
  - Offer "أسبوع راحة": plan pauses, no logging expected, copy: "خذ وقتك. المسيرة تنتظرك."  
  - Optional re-onboarding: "هل تريد أن نعدّل خطتك؟" → jump to pace + tracking-feeling questions only.

### Mercy mechanics (Islamic framing)

- **Grace days:** Explained as "رخصة" — "الله يحب أن تؤتى رخصه."  
- **Recovery:** "التوبة تجب ما قبلها" — new day is a fresh start, no dwelling on past misses.  
- **Intention over count:** Badges and messages emphasize sincerity and return, not perfection.

---

## 7. Data Model (High Level)

Conceptual only; no schema enforcement in this doc.

### User worship profile (onboarding output)

- `id`, `createdAt`, `updatedAt`
- `consistencyLevel`: enum (very_regular | sometimes | start_stop | fresh_start)
- `timeAvailability`: enum (very_little_5_10 | medium_15_30 | more_30_plus | varies)
- `primaryIntention`: enum (discipline | closeness | learning | habit)
- `worshipAreas`: [Salah, Quran, Dhikr, Dua, Sadaqah, Zakat, GoodDeeds] (multi)
- `pace`: enum (gentle | balanced | ambitious)
- `trackingFeeling`: enum (motivating | sometimes_heavy | prefer_minimal)
- `lifeContext`: optional enum (busy_parent | student | traveler | none)

### Daily actions (logs)

- `id`, `userId` (or local only), `date` (calendar day)
- `actions`: [{ type: salah | quran | dhikr | dua | sadaqah | zakat | good_deed, subtype?: string, completedAt?: Date }]
- `reflectionNote`: optional string
- `usedGraceDay`: boolean (if that day was a mercy day for streak)

### Intentions

- `id`, `userId`, `setAt`
- `text`: optional user-set intention
- `weeklyFocus`: optional string (e.g. "دعاء بعد الصلاة")

### Progress state

- `currentLevel`: enum (seeds | roots | growth | steadfast | blossom)
- `levelProgress`: 0.0–1.0 within current level
- `streakDays`: Int (consecutive days “on path” after mercy)
- `mercyDaysUsedThisWeek`: Int
- `mercyDaysAllowedPerWeek`: Int (1 or 2 from pace)
- `badges`: [Badge] (ids or types only; no social data)
- `lastPlanAdaptationAt`: optional Date

### Storage

- **Offline-first:** All of the above stored locally (e.g. SwiftUI + UserDefaults, or a single SQLite/Core Data store). Sync is out of scope unless specified later.
- **Privacy:** No user identity required for the Path; "userId" can be a local device identifier or omitted if single-user.

---

### Progress tracking (how it works)

Progress is derived **only from daily action logs** and the user’s **plan (daily essentials)**. No comparison to other users; all logic is local and rule-based.

**1. What counts as “on path” for a given day**

- A day counts as **on path** if the user logged **at least the minimum** for that day:
  - **Minimum:** Either (a) completed at least one “daily essential” from their plan, or (b) used a **mercy day** for that date (user or system marks the day as grace so the streak is preserved).
- Optional bonuses do **not** affect “on path”; they are for encouragement only.
- If the user logs nothing and does not use a mercy day, that day is **not** on path (streak can break or use mercy if available).

**2. Streak (أيام متتالية على المسيرة)**

- **Streak** = number of consecutive **calendar days** that are “on path” (using the rule above).
- **Mercy:** Each week (e.g. Sunday–Saturday or app-defined week), the user has **mercyDaysAllowedPerWeek** (1 for ambitious, 2 for balanced/gentle). If they miss a day:
  - First check: any mercy left this week? If yes, user can mark that day as “يوم راحة” (or the app suggests it once); the day then counts as on path for streak purposes, and `mercyDaysUsedThisWeek` increments.
  - If no mercy left or user doesn’t use it, streak resets to 0 the next day.
- **Reset:** When a day is not on path and no mercy is used, set `streakDays = 0` from the next day. No punishment copy; next open shows “غداً فرصة جديدة” style message.

**3. Level progress (البذور → الجذور → النمو → الثبات)**

- **Level** is a spiritual label only (no “level 3” in UI). Advancement is based on **consistency over time**, not raw counts:
  - **Seeds → Roots:** e.g. 7 days on path (with mercy allowed) in the first 14 days.
  - **Roots → Growth:** e.g. 14 days on path within a 21-day window.
  - **Growth → Steadfast:** e.g. 21 days on path within 28 days.
  - **Steadfast → Blossom (optional):** e.g. 28 days on path within 35 days, or a reflection milestone.
- **levelProgress (0.0–1.0):** Within the current level, progress can be a simple fraction: e.g. `(daysOnPathInCurrentLevelWindow / daysRequiredToAdvance)`. When it reaches 1.0, advance to the next level and reset the window.
- **Window:** Use a rolling or block window (e.g. “last N days” or “since level start”) so that missing a few days doesn’t wipe everything; mercy days count as on path in this window too.

**4. What we store to support this**

- **Per day:** One **Daily actions** record per calendar day (keyed by date). Fields: `date`, `actions[]`, `reflectionNote`, `usedGraceDay`.
- **Derived each time (or cached and invalidated):**
  - “Was this day on path?” = (at least one essential logged) OR `usedGraceDay`.
  - **Streak:** Walk backwards from today, count consecutive on-path days, stop at first miss (or use mercy).
  - **Level + levelProgress:** From history of on-path days in the current level window; update when user opens the Path or logs an action.

**5. Badges (reflection-based, not performance)**

- Stored in **Progress state.badges**. Awarded for events such as:
  - Completed first week with at least one reflection note.
  - Re-answered intention/pace in “refresh intention” flow.
  - Used a mercy day and (optionally) added a short reflection.
- **Not** awarded for: “Perfect week,” “Never missed,” or any count-based achievement that could induce guilt.

**6. User control**

- If **tracking feeling** is “تثقل” or “لا أحب التتبع”: show minimal numbers (e.g. only “مسيرتك: الثبات” and optional “أيام على المسيرة” without a big streak number), and emphasize reflection over stats.
- Settings in the flow can hide streak, hide level progress bar, or show only the current level name.

---

## 8. Accessibility & Trust

### Accessibility

- **VoiceOver:** All headings, buttons, and progress labels have clear labels (e.g. "مسيرتك في العبادة، زر بداية"). Journey/level described in one sentence.
- **Dynamic Type:** Support iOS Dynamic Type for all copy; layout scales (stack/scroll, no fixed small text).
- **Reduce Motion:** Avoid auto-playing animations; if path/tree animates, respect "Reduce Motion" and show final state or a short fade.
- **RTL:** Full RTL layout and leading/trailing semantics; same as existing Hedaya Home.
- **Contrast:** Use existing app palette (e.g. 1B7A4A on F0F7F4) and ensure text meets WCAG AA where possible.

### Privacy

- **Clarity:** On first entry or in a "About مسيرتي" screen: "بياناتك تبقى على جهازك. لا نشارك مسيرتك مع أحد."
- **No social:** No accounts required for the Path; no leaderboards, no friend lists.
- **Control:** User can "مسح بيانات المسيرة" (clear Path data) from within the flow; resets plan and progress, keeps the rest of the app (Azkar, etc.) unchanged.

### User control over tracking intensity

- In onboarding: "tracking feeling" already reduces visible stats.
- In the Path: optional "إعدادات المسيرة" (within the flow) with:
  - "كم عدد الأيام المتتالية التي نعرضها؟" — show streak yes/no or hide number.
  - "إظهار الأرقام والإحصائيات" — toggle to minimal (only journey level and optional reflection).
  - "أيام الراحة" — show/hide or adjust how mercy days are presented.

---

## Summary: Entry Point Only (Implementation Reminder)

- **One entry point:** e.g. one new card on the Home grid: "مسيرتي في العبادة" / "My Worship Path" that presents the intro screen.
- **Rest of the app unchanged:** All of the above lives inside a new navigation flow (new views/view models); existing Azkar, Sebha, ContentView structure stay as they are.
- **iOS 14+, SwiftUI, offline-first, no social features.**

---

*End of design document. No code changes to existing Hedaya files; this spec is for a new, self-contained module.*
