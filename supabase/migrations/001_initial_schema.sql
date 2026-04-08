-- CourtPlus: W.E.R. Joell Tennis Stadium
-- Initial Schema Migration

-- ============================================================
-- ADMIN ROLES
-- ============================================================
CREATE TABLE IF NOT EXISTS admin_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'admin',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE admin_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can read roles" ON admin_roles FOR SELECT TO authenticated USING (true);

-- ============================================================
-- COURTS
-- ============================================================
CREATE TABLE IF NOT EXISTS courts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sport_type TEXT NOT NULL CHECK (sport_type IN ('tennis', 'pickleball')),
  surface TEXT,
  has_floodlights BOOLEAN DEFAULT false,
  capacity INT DEFAULT 4,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'closed')),
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE courts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can read active courts" ON courts FOR SELECT USING (status = 'active');
CREATE POLICY "Admins full access courts select" ON courts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins full access courts insert" ON courts FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Admins full access courts update" ON courts FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Admins full access courts delete" ON courts FOR DELETE TO authenticated USING (true);

-- ============================================================
-- USERS (public profiles)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone TEXT,
  membership_type TEXT DEFAULT 'recreational' CHECK (membership_type IN ('junior', 'adult', 'senior', 'recreational', 'competitive')),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'pending')),
  court_reserve_id TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins full access users select" ON user_profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins full access users insert" ON user_profiles FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Admins full access users update" ON user_profiles FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Admins full access users delete" ON user_profiles FOR DELETE TO authenticated USING (true);
-- Allow public self-registration
CREATE POLICY "Public can insert own profile" ON user_profiles FOR INSERT WITH CHECK (true);

-- ============================================================
-- BOOKINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_profile_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
  court_id UUID REFERENCES courts(id) ON DELETE SET NULL,
  sport_type TEXT NOT NULL CHECK (sport_type IN ('tennis', 'pickleball')),
  booking_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  duration_hours NUMERIC(4,2),
  player_count INT DEFAULT 2,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed', 'no_show')),
  payment_status TEXT DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'paid', 'refunded', 'partial')),
  amount_due NUMERIC(10,2) DEFAULT 0,
  amount_paid NUMERIC(10,2) DEFAULT 0,
  court_reserve_booking_id TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins full access bookings select" ON bookings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins full access bookings insert" ON bookings FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Admins full access bookings update" ON bookings FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Admins full access bookings delete" ON bookings FOR DELETE TO authenticated USING (true);
-- Allow public to create bookings
CREATE POLICY "Public can create bookings" ON bookings FOR INSERT WITH CHECK (true);

-- ============================================================
-- PRICING
-- ============================================================
CREATE TABLE IF NOT EXISTS pricing (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category TEXT NOT NULL,
  label TEXT NOT NULL,
  sport_type TEXT CHECK (sport_type IN ('tennis', 'pickleball', 'both')),
  price_per_hour NUMERIC(10,2),
  price_flat NUMERIC(10,2),
  period TEXT CHECK (period IN ('peak', 'off_peak', 'any')),
  membership_tier TEXT,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE pricing ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can read active pricing" ON pricing FOR SELECT USING (is_active = true);
CREATE POLICY "Admins full access pricing select" ON pricing FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins full access pricing insert" ON pricing FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Admins full access pricing update" ON pricing FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Admins full access pricing delete" ON pricing FOR DELETE TO authenticated USING (true);

-- ============================================================
-- OPENING HOURS
-- ============================================================
CREATE TABLE IF NOT EXISTS opening_hours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  day_of_week INT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Sunday
  open_time TIME,
  close_time TIME,
  is_closed BOOLEAN DEFAULT false,
  notes TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE opening_hours ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can read hours" ON opening_hours FOR SELECT USING (true);
CREATE POLICY "Admins full access hours" ON opening_hours FOR ALL TO authenticated USING (true);

-- ============================================================
-- SERVICE UPDATES / NOTICES
-- ============================================================
CREATE TABLE IF NOT EXISTS service_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  update_type TEXT DEFAULT 'info' CHECK (update_type IN ('info', 'warning', 'closure', 'maintenance')),
  is_published BOOLEAN DEFAULT false,
  start_date DATE,
  end_date DATE,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE service_updates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can read published updates" ON service_updates FOR SELECT USING (is_published = true);
CREATE POLICY "Admins full access updates select" ON service_updates FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins full access updates insert" ON service_updates FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Admins full access updates update" ON service_updates FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Admins full access updates delete" ON service_updates FOR DELETE TO authenticated USING (true);

-- ============================================================
-- FAQs
-- ============================================================
CREATE TABLE IF NOT EXISTS faqs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category TEXT NOT NULL CHECK (category IN ('booking', 'payment', 'membership', 'facilities', 'programs', 'general')),
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  is_published BOOLEAN DEFAULT true,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE faqs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can read published faqs" ON faqs FOR SELECT USING (is_published = true);
CREATE POLICY "Admins full access faqs select" ON faqs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins full access faqs insert" ON faqs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Admins full access faqs update" ON faqs FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Admins full access faqs delete" ON faqs FOR DELETE TO authenticated USING (true);

-- ============================================================
-- SEED DATA
-- ============================================================

-- Courts
INSERT INTO courts (name, sport_type, surface, has_floodlights, capacity, description) VALUES
  ('Hard Court 1', 'tennis', 'Hard', true, 4, 'Full-size hard court with floodlighting for evening play.'),
  ('Hard Court 2', 'tennis', 'Hard', true, 4, 'Full-size hard court with floodlighting for evening play.'),
  ('Hard Court 3', 'tennis', 'Hard', false, 4, 'Full-size hard court, daytime use only.'),
  ('Clay Court 1', 'tennis', 'Clay', true, 4, 'Professional clay court surface, ideal for competitive play.'),
  ('Clay Court 2', 'tennis', 'Clay', false, 4, 'Professional clay court surface.'),
  ('Pickleball Court 1', 'pickleball', 'Hard', true, 4, 'Dedicated pickleball court with floodlighting.'),
  ('Pickleball Court 2', 'pickleball', 'Hard', true, 4, 'Dedicated pickleball court with floodlighting.'),
  ('Practice Wall', 'tennis', 'Hard', false, 1, 'Solo practice wall for warm-up and skill development.');

-- Opening Hours (0=Sun, 1=Mon, ..., 6=Sat)
INSERT INTO opening_hours (day_of_week, open_time, close_time, is_closed, notes) VALUES
  (0, '08:00', '18:00', false, 'Sunday hours'),
  (1, '07:00', '21:00', false, 'Monday hours'),
  (2, '07:00', '21:00', false, 'Tuesday hours'),
  (3, '07:00', '21:00', false, 'Wednesday hours'),
  (4, '07:00', '21:00', false, 'Thursday hours'),
  (5, '07:00', '21:00', false, 'Friday hours'),
  (6, '08:00', '20:00', false, 'Saturday hours');

-- Pricing
INSERT INTO pricing (category, label, sport_type, price_per_hour, period, membership_tier, description, sort_order) VALUES
  ('membership', 'Junior Membership (Under 18)', 'both', NULL, 'any', 'junior', 'Annual membership for players under 18', 1),
  ('membership', 'Adult Membership', 'both', NULL, 'any', 'adult', 'Annual membership for adult players', 2),
  ('membership', 'Senior Membership (65+)', 'both', NULL, 'any', 'senior', 'Annual membership for senior players', 3),
  ('court_hire', 'Tennis Court — Peak Hours', 'tennis', 20.00, 'peak', NULL, 'Mon–Fri 17:00–21:00, Weekends all day', 4),
  ('court_hire', 'Tennis Court — Off-Peak', 'tennis', 12.00, 'off_peak', NULL, 'Mon–Fri 07:00–17:00', 5),
  ('court_hire', 'Pickleball Court — Peak Hours', 'pickleball', 15.00, 'peak', NULL, 'Mon–Fri 17:00–21:00, Weekends all day', 6),
  ('court_hire', 'Pickleball Court — Off-Peak', 'pickleball', 10.00, 'off_peak', NULL, 'Mon–Fri 07:00–17:00', 7),
  ('equipment_hire', 'Tennis Racquet Hire', 'tennis', NULL, 'any', NULL, 'Per session racquet hire', 8),
  ('equipment_hire', 'Pickleball Paddle Hire', 'pickleball', NULL, 'any', NULL, 'Per session paddle hire', 9),
  ('equipment_hire', 'Ball Hire (Tennis)', 'tennis', NULL, 'any', NULL, 'Per session ball hire', 10);

-- FAQs
INSERT INTO faqs (category, question, answer, sort_order) VALUES
  ('booking', 'How do I create an account?', 'Visit the CourtReserve registration portal at the link provided on this page, or download the CourtReserve mobile app and search for "WER Joell Tennis Stadium". Follow the prompts to create your free account and request access.', 1),
  ('booking', 'How do I book a court?', 'Once registered, log in to the CourtReserve portal or app, browse available courts and time slots, and confirm your booking. You will receive a confirmation email with payment instructions.', 2),
  ('booking', 'Can I book for someone else?', 'Bookings must be made by registered account holders. You may add guests to your booking, subject to the guest policy. Please contact the facility for group or institutional bookings.', 3),
  ('booking', 'How far in advance can I book?', 'Courts can be booked up to 7 days in advance for standard members. Please check the CourtReserve portal for current availability windows.', 4),
  ('booking', 'How do I cancel or amend a booking?', 'Cancellations must be made at least 24 hours before your session via the CourtReserve portal or app. Late cancellations may forfeit the session fee. See our Cancellation Policy for full details.', 5),
  ('payment', 'How do I pay for my booking?', 'After securing your booking on CourtReserve, you must complete payment separately via the WER Joell payment portal. The payment link is included in your booking confirmation email.', 6),
  ('payment', 'Why is payment on a different website?', 'The booking system (CourtReserve) and the payment system (WER Joell portal) are currently separate platforms operated by the Department of Sports and Recreation. We are working to streamline this process.', 7),
  ('payment', 'What payment methods are accepted?', 'The WER Joell payment portal accepts major credit and debit cards. Please visit the payment portal for the full list of accepted payment methods.', 8),
  ('payment', 'Is my payment secure?', 'Yes. All payments are processed through the secure WER Joell government payment portal, which uses industry-standard encryption and security protocols.', 9),
  ('payment', 'Will I receive a receipt?', 'Yes. A payment confirmation and receipt will be sent to your registered email address upon successful payment.', 10),
  ('membership', 'What memberships are available?', 'We offer Junior (under 18), Adult, and Senior (65+) membership tiers. Each tier provides access to court booking, discounted rates, and facility amenities. Contact us for current pricing.', 11),
  ('membership', 'How do I sign up for a membership?', 'Register via the CourtReserve portal and select your membership tier. Membership fees are payable via the WER Joell payment portal.', 12),
  ('facilities', 'Are the courts covered or outdoor?', 'All courts at W.E.R. Joell Tennis Stadium are outdoor. Several courts have floodlighting for evening play.', 13),
  ('facilities', 'Is parking available?', 'Yes, parking is available at the facility. Please contact us for specific parking arrangements.', 14),
  ('facilities', 'Are there changing facilities?', 'Changing room availability is subject to confirmation. Please contact the facility directly for the latest information.', 15),
  ('facilities', 'Can I hire a racquet?', 'Yes, tennis racquets and pickleball paddles are available for hire. See our Prices section for hire rates.', 16),
  ('programs', 'What programs are available for children?', 'We offer junior tennis and pickleball programs. Please contact the facility or check the CourtReserve portal for current program schedules.', 17),
  ('programs', 'Do you offer coaching for beginners?', 'Yes, beginner coaching sessions are available for both tennis and pickleball. Contact us for coach availability and booking.', 18),
  ('general', 'What are the opening hours?', 'The stadium is open Monday to Friday 07:00–21:00, Saturday 08:00–20:00, and Sunday 08:00–18:00. Hours may vary on public holidays.', 19),
  ('general', 'Who do I contact for more information?', 'Please use the Contact Us section on this page to reach the facility by phone or email. You can also visit us in person during opening hours.', 20);
