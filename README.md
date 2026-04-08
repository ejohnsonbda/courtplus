# CourtPlus — W.E.R. Joell Tennis Stadium

**CourtPlus** is the official web presence and management platform for the **W.E.R. Joell Tennis Stadium**, operated by the Department of Sports and Recreation, Bermuda.

---

## Live Site

Hosted on GitHub Pages: `https://ejohnsonbda.github.io/courtplus/`

---

## Features

### Public Landing Page
- **Hero section** with Register / Book / Pay CTAs (colour-coded by platform)
- **Sticky tab navigation**: Overview, Facilities, Opening Hours, Book a Court, Prices, Contact Us, FAQ
- **Sport selector**: Tennis or Pickleball booking flow
- **3-step booking guide**: Register → Book (CourtReserve) → Pay (WER Joell Portal)
- **Facilities showcase**: Tennis hard courts, clay courts, pickleball courts, practice wall
- **Opening hours table** with today highlighted
- **Pricing grid** with category filter tabs
- **FAQ accordion** with category filter and search
- **App download section** (CourtReserve iOS & Android)
- **Service update banner** (admin-controlled)
- **Google Maps embed** in Contact section
- **Mobile-responsive** design

### Admin Backend (`/#/admin`)
- **Secure login** via Supabase Auth (admin role required)
- **Dashboard**: live stats (users, bookings, revenue, courts) + charts
- **User Management**: view, add, edit, delete user profiles
- **Court Management**: manage tennis & pickleball courts, status, surface type
- **Booking Management**: filter by sport/status/date, update booking & payment status
- **Revenue Dashboard**: total revenue, breakdown by sport (Tennis vs Pickleball), outstanding payments
- **Service Updates**: publish/unpublish notices, closures, maintenance alerts
- **FAQ Management**: add/edit/delete/publish FAQs
- **Pricing Management**: manage court hire rates, membership fees, equipment hire
- **Opening Hours**: update weekly schedule

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Pure HTML5 / CSS3 / Vanilla JS (zero dependencies) |
| Backend / Database | [Supabase](https://supabase.com) (PostgreSQL + Auth + RLS) |
| Hosting | GitHub Pages |
| Booking | [CourtReserve](https://app.courtreserve.com/Online/Account/LogIn/8636) (external) |
| Payment | WER Joell Payment Portal (external) |

---

## Setup Instructions

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project.
2. In the **SQL Editor**, run the migration file: `supabase/migrations/001_initial_schema.sql`
3. Copy your **Project URL** and **anon public key** from Settings → API.

### 2. Configure the App

Open `index.html` and replace the placeholder values near the top of the `<script>` section:

```js
const SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_ANON_KEY = 'eyJ...your-anon-key...';
```

### 3. Create an Admin User

```bash
export SUPABASE_URL='https://YOUR_PROJECT.supabase.co'
export SUPABASE_SERVICE_KEY='your-service-role-key'
python3 scripts/create_admin_user.py admin@example.com YourSecurePassword123
```

### 4. Deploy to GitHub Pages

```bash
git init && git add . && git commit -m "Initial CourtPlus deployment"
git branch -m main
gh repo create ejohnsonbda/courtplus --public --source=. --push
```

Then in the GitHub repository: **Settings → Pages → Source: main branch, root folder → Save**

The site will be live at: `https://ejohnsonbda.github.io/courtplus/`

---

## Booking Flow

The site guides users through a 3-step process that bridges two separate platforms:

```
Step 1: REGISTER  →  CourtReserve Portal (free account creation)
Step 2: BOOK      →  CourtReserve Portal (select Tennis or Pickleball court)
Step 3: PAY       →  WER Joell Payment Portal (separate payment system)
```

CTA buttons are colour-coded to signal the platform switch:
- **Navy** = Register (CourtReserve)
- **Light Blue** = Book (CourtReserve)
- **Green** = Pay (WER Joell Portal)

---

## Admin Access

Navigate to `/#/admin` on the live site. Sign in with your admin credentials created via the setup script above.

---

## Project Reference

- **Ref**: DSR-WEB-TENNIS-001
- **Client**: Department of Sports and Recreation, Bermuda
- **Prepared for**: W.E.R. Joell Tennis Stadium
- **Version**: 1.0

---

## Policies & Content

The following content items are to be provided by the Department of Sports and Recreation (DSR):

- Facility contact details (phone, email, address)
- WER Joell payment portal URL
- Hero photography / video
- Final pricing figures
- Activity Terms & Conditions
- Booking Policy
- Cancellation Policy
- Privacy Policy
- CourtReserve App Store URLs (Apple & Android)

These can be updated directly in the admin backend once the site is live.
