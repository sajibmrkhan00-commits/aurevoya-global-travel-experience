-- ====================================================================
-- AUREVOYA GLOBAL TRAVEL & EXPERIENCE
-- Complete Production Database Architecture (PostgreSQL / Supabase DDL)
-- Project Architect: Sajib Khan (Daffodil University - CSE Final Year)
-- Supervisor: Nusrat Jahan
-- ====================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. USERS & PROFILES
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50) NOT NULL,
    role VARCHAR(50) DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'staff', 'visa_officer')),
    avatar_url TEXT,
    nationality VARCHAR(100) DEFAULT 'Bangladeshi',
    passport_number VARCHAR(100),
    passport_expiry DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. DESTINATIONS
CREATE TABLE IF NOT EXISTS destinations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    region VARCHAR(100) NOT NULL CHECK (region IN ('Bangladesh', 'Asia', 'Middle East', 'Europe', 'Africa', 'Americas', 'Oceania')),
    slug VARCHAR(255) UNIQUE NOT NULL,
    hero_image TEXT NOT NULL,
    gallery_images TEXT[] DEFAULT '{}',
    description TEXT NOT NULL,
    short_description TEXT NOT NULL,
    attractions TEXT[] DEFAULT '{}',
    activities TEXT[] DEFAULT '{}',
    best_time_to_visit TEXT NOT NULL,
    travel_tips TEXT[] DEFAULT '{}',
    average_cost_per_day NUMERIC(10, 2) NOT NULL,
    rating NUMERIC(3, 2) DEFAULT 4.80,
    reviews_count INT DEFAULT 0,
    featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TOUR PACKAGES
CREATE TABLE IF NOT EXISTS packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    destination_id UUID REFERENCES destinations(id) ON DELETE SET NULL,
    category VARCHAR(100) NOT NULL CHECK (category IN ('International', 'Bangladesh', 'Luxury', 'Family', 'Honeymoon', 'Adventure', 'Cultural', 'Budget', 'Wellness')),
    duration_days INT NOT NULL,
    duration_nights INT NOT NULL,
    price_usd NUMERIC(10, 2) NOT NULL,
    discount_percentage INT DEFAULT 0,
    featured_image TEXT NOT NULL,
    gallery_images TEXT[] DEFAULT '{}',
    overview TEXT NOT NULL,
    highlights TEXT[] DEFAULT '{}',
    itinerary JSONB NOT NULL DEFAULT '[]',
    included TEXT[] DEFAULT '{}',
    excluded TEXT[] DEFAULT '{}',
    accommodation TEXT NOT NULL,
    transportation TEXT NOT NULL,
    next_departure_dates DATE[] DEFAULT '{}',
    max_group_size INT DEFAULT 12,
    rating NUMERIC(3, 2) DEFAULT 4.90,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. HAJJ PACKAGES
CREATE TABLE IF NOT EXISTS hajj_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    season_year INT NOT NULL,
    tier VARCHAR(50) NOT NULL CHECK (tier IN ('VIP', 'Premium', 'Standard', 'Economy')),
    package_type VARCHAR(100) NOT NULL,
    duration_days INT NOT NULL,
    departure_dates DATE[] DEFAULT '{}',
    price_usd NUMERIC(10, 2) NOT NULL,
    makkah_hotel VARCHAR(255) NOT NULL,
    makkah_hotel_distance_meters INT NOT NULL,
    madinah_hotel VARCHAR(255) NOT NULL,
    madinah_hotel_distance_meters INT NOT NULL,
    mashair_arrangement TEXT NOT NULL,
    ritual_guidance TEXT[] DEFAULT '{"Tamattu", "Qiran", "Ifrad"}',
    included TEXT[] DEFAULT '{}',
    optional TEXT[] DEFAULT '{}',
    excluded TEXT[] DEFAULT '{}',
    image TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'Open for Registration',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. UMRAH PACKAGES
CREATE TABLE IF NOT EXISTS umrah_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    tier VARCHAR(50) NOT NULL CHECK (tier IN ('VIP', 'Premium', 'Standard', 'Economy')),
    duration_days INT NOT NULL CHECK (duration_days IN (10, 12, 14, 21)),
    category VARCHAR(100) NOT NULL,
    price_usd NUMERIC(10, 2) NOT NULL,
    makkah_hotel VARCHAR(255) NOT NULL,
    makkah_hotel_distance_meters INT NOT NULL,
    madinah_hotel VARCHAR(255) NOT NULL,
    madinah_hotel_distance_meters INT NOT NULL,
    transport_type TEXT NOT NULL,
    ziyarat_included BOOLEAN DEFAULT TRUE,
    included TEXT[] DEFAULT '{}',
    excluded TEXT[] DEFAULT '{}',
    departure_dates DATE[] DEFAULT '{}',
    image TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. VISA REQUIREMENTS
CREATE TABLE IF NOT EXISTS visa_requirements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    destination_country VARCHAR(100) NOT NULL,
    visa_category VARCHAR(100) NOT NULL,
    processing_time_days VARCHAR(100) NOT NULL,
    govt_fee_usd NUMERIC(10, 2) NOT NULL,
    service_fee_usd NUMERIC(10, 2) NOT NULL,
    required_documents TEXT[] DEFAULT '{}',
    official_source TEXT NOT NULL,
    last_verified_date DATE NOT NULL,
    important_notes TEXT[] DEFAULT '{}',
    eligibility_summary TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. VISA APPLICATIONS
CREATE TABLE IF NOT EXISTS visa_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_number VARCHAR(100) UNIQUE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    applicant_name VARCHAR(255) NOT NULL,
    applicant_email VARCHAR(255) NOT NULL,
    applicant_phone VARCHAR(50) NOT NULL,
    nationality VARCHAR(100) NOT NULL,
    passport_number VARCHAR(100) NOT NULL,
    passport_expiry DATE NOT NULL,
    destination_country VARCHAR(100) NOT NULL,
    visa_category VARCHAR(100) NOT NULL,
    intended_travel_date DATE NOT NULL,
    travel_purpose TEXT NOT NULL,
    additional_notes TEXT,
    current_status VARCHAR(100) NOT NULL DEFAULT 'Submitted',
    status_history JSONB NOT NULL DEFAULT '[]',
    verified_decision_document_url TEXT,
    verified_decision_date TIMESTAMP WITH TIME ZONE,
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. VISA DOCUMENTS
CREATE TABLE IF NOT EXISTS visa_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID REFERENCES visa_applications(id) ON DELETE CASCADE,
    document_name VARCHAR(255) NOT NULL,
    document_type VARCHAR(100) NOT NULL,
    file_url TEXT NOT NULL,
    uploaded_by UUID REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending_review',
    rejection_reason TEXT,
    file_size_kb INT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. BOOKINGS
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_reference VARCHAR(100) UNIQUE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(50) NOT NULL,
    booking_type VARCHAR(50) NOT NULL,
    item_id VARCHAR(100) NOT NULL,
    item_title VARCHAR(255) NOT NULL,
    travel_date DATE NOT NULL,
    return_date DATE,
    travelers_count INT NOT NULL DEFAULT 1,
    travelers_details JSONB NOT NULL DEFAULT '[]',
    total_price_usd NUMERIC(10, 2) NOT NULL,
    currency_paid VARCHAR(10) NOT NULL DEFAULT 'USD',
    payment_status VARCHAR(50) DEFAULT 'Pending',
    booking_status VARCHAR(50) DEFAULT 'Pending Payment',
    special_requests TEXT,
    voucher_number VARCHAR(100),
    is_demo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. PAYMENT TRANSACTIONS
CREATE TABLE IF NOT EXISTS payment_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    booking_reference VARCHAR(100) NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    customer_name VARCHAR(255) NOT NULL,
    amount_usd NUMERIC(10, 2) NOT NULL,
    amount_local NUMERIC(12, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Demo Only',
    gateway_response_ref TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    is_demo BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. NOTIFICATION DISPATCH LOGS
CREATE TABLE IF NOT EXISTS notification_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_email VARCHAR(255),
    recipient_phone VARCHAR(50),
    channel VARCHAR(50) NOT NULL CHECK (channel IN ('email', 'sms', 'whatsapp', 'in_app')),
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    related_entity VARCHAR(50) NOT NULL,
    entity_reference VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'delivered',
    provider_response TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. AUDIT LOGS
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    action VARCHAR(255) NOT NULL,
    admin_user VARCHAR(255) NOT NULL,
    target_entity VARCHAR(100) NOT NULL,
    target_id VARCHAR(100) NOT NULL,
    details TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_destinations_region ON destinations(region);
CREATE INDEX IF NOT EXISTS idx_packages_category ON packages(category);
CREATE INDEX IF NOT EXISTS idx_visa_applications_ref ON visa_applications(reference_number);
CREATE INDEX IF NOT EXISTS idx_visa_applications_user ON visa_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_ref ON bookings(booking_reference);
